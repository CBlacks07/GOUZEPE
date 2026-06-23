<template>
  <div class="auth">

    <!-- ── Panneau marque (gauche) ── -->
    <aside class="auth-brand">
      <div class="auth-brand-bg" aria-hidden="true"></div>
      <div class="auth-brand-content">
        <RouterLink to="/" class="brand">
          <img class="brand-logo" src="/assets/icons/apple-touch-icon.png" alt="GOUZEPE" />
          <span class="brand-text">GOUZEPE<span class="brand-sub">GAMING CLUB</span></span>
        </RouterLink>

        <h1 class="brand-title">Entre dans<br/>l'arène.</h1>
        <p class="brand-lead">
          La communauté compétitive <strong>eFootball</strong> &amp; <strong>Tekken</strong>.
          Connecte-toi pour accéder à ton espace.
        </p>

        <ul class="brand-feats">
          <li><CheckIcon class="w-4 h-4" /> Journées, saisons &amp; classements</li>
          <li><CheckIcon class="w-4 h-4" /> Tournois &amp; duels classés</li>
          <li><CheckIcon class="w-4 h-4" /> Ton profil &amp; ton palmarès</li>
        </ul>
      </div>
    </aside>

    <!-- ── Formulaire (droite) ── -->
    <main class="auth-main">
      <div class="auth-card">
        <div class="auth-top">
          <RouterLink to="/" class="auth-back"><ArrowLeftIcon class="w-4 h-4" /> Accueil</RouterLink>
          <button
            type="button"
            class="icon-btn"
            :title="theme.mode === 'dark' ? 'Mode clair' : 'Mode sombre'"
            @click="theme.toggle()"
          >
            <SunIcon v-if="theme.mode === 'dark'" class="w-4 h-4" />
            <MoonIcon v-else class="w-4 h-4" />
          </button>
        </div>

        <form class="auth-form" @submit.prevent="submit">
          <h2 class="auth-h2">Connexion</h2>
          <p class="auth-hint">Ravi de te revoir. Entre tes identifiants.</p>

          <label class="label" for="email">Email</label>
          <input
            id="email"
            v-model="form.email"
            class="input"
            type="email"
            placeholder="admin@gz.local"
            autocomplete="email"
          />

          <label class="label mt" for="password">Mot de passe</label>
          <div class="field">
            <input
              id="password"
              v-model="form.password"
              class="input"
              :type="showPwd ? 'text' : 'password'"
              placeholder="••••••••"
              autocomplete="current-password"
            />
            <button
              type="button"
              class="field-btn"
              :title="showPwd ? 'Masquer' : 'Afficher'"
              @click="showPwd = !showPwd"
            >
              <EyeOffIcon v-if="showPwd" class="w-4 h-4" />
              <EyeIcon v-else class="w-4 h-4" />
            </button>
          </div>

          <p v-if="error" class="msg error">{{ error }}</p>
          <p v-else-if="bootMessage" class="msg muted">{{ bootMessage }}</p>

          <button type="submit" class="btn-primary auth-submit" :disabled="loading">
            <Loader2Icon v-if="loading" class="w-4 h-4 animate-spin" />
            <span>{{ loading ? 'Connexion...' : 'Se connecter' }}</span>
          </button>

          <div class="auth-meta">
            <span class="muted">Session : 24h</span>
            <RouterLink to="/inscription" class="auth-link">Pas encore membre ?</RouterLink>
          </div>
        </form>

        <div class="api-toggle">
          <button type="button" class="btn-ghost" @click="showApiConfig = !showApiConfig">
            Configuration API
          </button>
        </div>

        <div v-if="showApiConfig" class="api-box">
          <label class="label" for="apiUrl">Adresse API</label>
          <div class="api-row">
            <input
              id="apiUrl"
              v-model="apiUrl"
              class="input"
              type="text"
              placeholder="http://192.168.1.122:3005"
            />
            <button type="button" class="btn" @click="saveApiUrl">Enregistrer</button>
          </div>
          <p class="muted text-xs">Actuel : <span class="font-mono">{{ currentApiUrl }}</span></p>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ArrowLeftIcon, CheckIcon, EyeIcon, EyeOffIcon, Loader2Icon, MoonIcon, SunIcon } from 'lucide-vue-next'
import { useAPI, resolveBaseURL } from '@/composables/useAPI'
import { useAuthStore } from '@/stores/auth'
import { useThemeStore } from '@/stores/theme'

const auth = useAuthStore()
const theme = useThemeStore()
const router = useRouter()
const api = useAPI()

const form = ref({ email: '', password: '' })
const showPwd = ref(false)
const showApiConfig = ref(false)
const apiUrl = ref('')
const loading = ref(false)
const error = ref('')
const bootMessage = ref('')

const currentApiUrl = computed(() => resolveBaseURL())

function normalizeEmail(raw) {
  const email = String(raw || '').trim().toLowerCase()
  if (!email) return ''
  if (email.includes('@')) return email
  return `${email}@gz.local`
}

async function validateExistingSession() {
  const token = localStorage.getItem('efoot.token') || ''
  const expAt = Number(localStorage.getItem('efoot.expAt') || 0)
  if (!token || !expAt || Date.now() >= expAt) return false

  bootMessage.value = 'Verification de session...'
  const ok = await auth.hydrateFromServer()
  if (!ok) {
    bootMessage.value = ''
    return false
  }

  await router.replace('/profil')
  return true
}

async function submit() {
  error.value = ''
  bootMessage.value = ''

  const email = normalizeEmail(form.value.email)
  const password = String(form.value.password || '')
  if (!email || !password) {
    error.value = 'Remplis tous les champs.'
    return
  }

  loading.value = true
  try {
    const { data } = await api.post('/auth/login', { email, password })
    auth.login(data)
    await auth.hydrateFromServer(true)
    bootMessage.value = 'Connexion reussie...'
    await router.replace('/profil')
  } catch (e) {
    error.value = e.response?.data?.error || e.response?.data?.message || 'Identifiants invalides.'
  } finally {
    loading.value = false
  }
}

function saveApiUrl() {
  const next = String(apiUrl.value || '').trim().replace(/\/+$/, '')
  if (!next) return
  localStorage.setItem('efoot.api', next)
  location.reload()
}

onMounted(async () => {
  theme.apply()
  apiUrl.value = currentApiUrl.value
  await validateExistingSession()
})
</script>

<style scoped>
.auth {
  min-height: 100dvh;
  display: grid;
  grid-template-columns: 1fr;
}

/* ── Panneau marque ── */
.auth-brand {
  position: relative;
  display: none;
  overflow: hidden;
  color: var(--text);
}
.auth-brand-bg {
  position: absolute; inset: 0;
  background:
    radial-gradient(60vw 60vh at 25% 15%, rgba(var(--accent-rgb), .35), transparent 60%),
    linear-gradient(160deg, var(--panel), var(--bg));
}
.auth-brand-bg::after {
  content: ''; position: absolute; inset: 0;
  background-image:
    linear-gradient(rgba(var(--accent-rgb), .08) 1px, transparent 1px),
    linear-gradient(90deg, rgba(var(--accent-rgb), .08) 1px, transparent 1px);
  background-size: 44px 44px;
  mask-image: radial-gradient(70% 70% at 30% 30%, #000, transparent 75%);
}
.auth-brand-content {
  position: relative; z-index: 1;
  display: flex; flex-direction: column;
  height: 100%; padding: 3rem 3.5rem;
}
.brand { display: inline-flex; align-items: center; gap: .6rem; text-decoration: none; color: var(--text); }
.brand-mark { color: var(--accent); font-size: 1.5rem; line-height: 1; }
.brand-logo { width: 40px; height: 40px; border-radius: 9px; object-fit: cover; flex: none; }
.brand-text { display: flex; flex-direction: column; line-height: 1; font-family: var(--font-title); font-weight: 700; letter-spacing: .06em; }
.brand-sub { font-size: .58rem; color: var(--muted); letter-spacing: .24em; margin-top: 3px; }

.brand-title {
  margin: auto 0 1rem;
  font-family: var(--font-title); font-weight: 700;
  font-size: clamp(2.5rem, 4vw, 4rem); line-height: .98;
  text-transform: uppercase; letter-spacing: .02em;
}
.brand-lead { max-width: 26rem; color: var(--muted); line-height: 1.6; margin: 0 0 1.75rem; }
.brand-lead strong { color: var(--text); }

.brand-feats { list-style: none; padding: 0; margin: 0; display: grid; gap: .7rem; }
.brand-feats li { display: flex; align-items: center; gap: .6rem; color: var(--muted); font-weight: 500; }
.brand-feats svg { color: var(--accent); flex: none; }

/* ── Colonne formulaire ── */
.auth-main {
  display: grid; place-items: center;
  padding: 1.5rem;
  background:
    radial-gradient(900px 600px at 80% 0%, rgba(var(--accent-rgb), .1), transparent 45%),
    var(--bg);
}
.auth-card {
  width: min(440px, 96vw);
  border: 1px solid var(--border);
  border-radius: 18px;
  background: var(--panel);
  box-shadow: var(--shadow);
  overflow: hidden;
}
.auth-top {
  display: flex; align-items: center; justify-content: space-between;
  padding: 1rem 1.25rem; border-bottom: 1px solid var(--border);
}
.auth-back { display: inline-flex; align-items: center; gap: .35rem; color: var(--muted); text-decoration: none; font-size: .85rem; font-weight: 600; transition: color .15s; }
.auth-back:hover { color: var(--accent-l); }
.icon-btn { border: 1px solid var(--border); background: transparent; color: var(--text); border-radius: 10px; padding: 8px; cursor: pointer; transition: border-color .15s; }
.icon-btn:hover { border-color: color-mix(in srgb, var(--accent) 50%, var(--border)); }

.auth-form { padding: 1.5rem 1.25rem 1rem; }
.auth-h2 { margin: 0; font-family: var(--font-title); font-weight: 700; font-size: 1.6rem; text-transform: uppercase; letter-spacing: .04em; }
.auth-hint { margin: .25rem 0 1.25rem; color: var(--muted); font-size: .9rem; }
.label.mt { margin-top: .9rem; }

.field { position: relative; }
.field .input { padding-right: 44px; }
.field-btn {
  position: absolute; right: 8px; top: 50%; transform: translateY(-50%);
  border: 1px solid var(--border); background: transparent; color: var(--text);
  border-radius: 10px; padding: 6px 8px; cursor: pointer;
}

.msg { min-height: 20px; margin-top: 10px; font-size: .875rem; }
.error { color: var(--red); }
.muted { color: var(--muted); }

.auth-submit { width: 100%; justify-content: center; margin-top: 1.1rem; padding: .7rem; font-size: 1rem; }

.auth-meta { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-top: 1rem; font-size: .85rem; }
.auth-link { color: var(--accent-l); text-decoration: none; font-weight: 600; }
.auth-link:hover { text-decoration: underline; }

.api-toggle { padding: 0 1.25rem .75rem; text-align: center; }
.api-box { padding: 0 1.25rem 1.25rem; border-top: 1px solid var(--border); }
.api-row { display: flex; gap: 8px; margin: .5rem 0; }

@media (min-width: 880px) {
  .auth { grid-template-columns: 1.05fr .95fr; }
  .auth-brand { display: block; }
}
@media (max-width: 520px) {
  .api-row { flex-direction: column; }
}
</style>
