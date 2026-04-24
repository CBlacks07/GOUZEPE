<template>
  <div class="login-wrap">
    <div class="login-card">
      <div class="login-head">
        <img src="/assets/icons/apple-touch-icon.png" alt="GOUZEPE" class="logo" />
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

      <form class="login-body" @submit.prevent="submit">
        <h2>Connexion</h2>

        <label class="label" for="email">Email</label>
        <input
          id="email"
          v-model="form.email"
          class="input"
          type="email"
          placeholder="admin@gz.local"
          autocomplete="email"
        />

        <label class="label" for="password">Mot de passe</label>
        <div class="field">
          <input
            id="password"
            v-model="form.password"
            class="input"
            :type="showPwd ? 'text' : 'password'"
            placeholder="********"
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
        <p class="msg muted">{{ bootMessage }}</p>

        <div class="login-footer">
          <span class="muted">Session : 24h</span>
          <button type="submit" class="btn-primary" :disabled="loading">
            <Loader2Icon v-if="loading" class="w-4 h-4 animate-spin" />
            <span>{{ loading ? 'Connexion...' : 'Se connecter' }}</span>
          </button>
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
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { EyeIcon, EyeOffIcon, Loader2Icon, MoonIcon, SunIcon } from 'lucide-vue-next'
import { useAPI } from '@/composables/useAPI'
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

const currentApiUrl = computed(() =>
  (localStorage.getItem('efoot.api') || `http://${location.hostname || 'localhost'}:3005`).replace(/\/+$/, '')
)

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

  await router.replace(auth.isAdmin ? '/' : '/profil')
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
    await router.replace(auth.isAdmin ? '/' : '/profil')
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
.login-wrap {
  min-height: 100dvh;
  display: grid;
  place-items: center;
  padding: 16px;
  background:
    radial-gradient(900px 600px at 20% 0%, rgba(96, 165, 250, 0.12), transparent 40%),
    radial-gradient(900px 600px at 80% 100%, rgba(34, 197, 94, 0.1), transparent 40%),
    var(--bg);
}

.login-card {
  width: min(560px, 94vw);
  border: 1px solid var(--border);
  border-radius: 18px;
  background: var(--panel);
  box-shadow: var(--shadow);
  overflow: hidden;
}

.login-head {
  position: relative;
  display: grid;
  place-items: center;
  padding: 20px 18px;
  border-bottom: 1px solid var(--border);
}

.logo {
  width: 68px;
  height: 68px;
  border-radius: 14px;
  object-fit: cover;
}

.icon-btn {
  position: absolute;
  top: 10px;
  right: 10px;
  border: 1px solid var(--border);
  background: transparent;
  color: var(--text);
  border-radius: 10px;
  padding: 8px;
  cursor: pointer;
}

.login-body {
  padding: 18px;
}

.login-body h2 {
  margin: 0 0 12px;
  font-size: 18px;
  text-align: center;
}

.field {
  position: relative;
}

.field .input {
  padding-right: 44px;
}

.field-btn {
  position: absolute;
  right: 8px;
  top: 50%;
  transform: translateY(-50%);
  border: 1px solid var(--border);
  background: transparent;
  color: var(--text);
  border-radius: 10px;
  padding: 6px 8px;
  cursor: pointer;
}

.msg {
  min-height: 20px;
  margin-top: 8px;
  font-size: 14px;
}

.error {
  color: #ef4444;
}

.muted {
  color: var(--muted);
}

.login-footer {
  margin-top: 14px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.api-toggle {
  padding: 0 18px 10px;
  text-align: center;
}

.api-box {
  padding: 0 18px 16px;
  border-top: 1px solid var(--border);
}

.api-row {
  display: flex;
  gap: 8px;
  margin-bottom: 8px;
}

@media (max-width: 520px) {
  .login-footer {
    flex-direction: column;
    align-items: stretch;
  }

  .login-footer .btn-primary {
    width: 100%;
    justify-content: center;
  }

  .api-row {
    flex-direction: column;
  }
}
</style>
