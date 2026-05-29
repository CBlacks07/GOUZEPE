<template>
  <div class="public-root">

    <header class="pub-header">
      <div class="pub-header-inner">
        <RouterLink to="/" class="pub-logo">
          <img src="/assets/icons/apple-touch-icon.png" alt="GOUZEPE" class="pub-logo-img" />
          <div class="pub-logo-text-wrap">
            <span class="pub-logo-title">GOUZEPE</span>
            <span class="pub-logo-sub">eFOOTBALL CLUB</span>
          </div>
        </RouterLink>
        <div class="pub-header-actions">
          <RouterLink to="/login" class="btn text-sm">Se connecter</RouterLink>
        </div>
      </div>
    </header>

    <main class="pub-main">
      <div class="form-wrap">
        <div class="form-card">

          <template v-if="!submitted">
            <div class="form-head">
              <img src="/assets/icons/apple-touch-icon.png" alt="" class="form-logo" />
              <div>
                <h1 class="form-title">Demande de membre</h1>
                <p class="form-sub">Rejoins le GOUZEPE Gaming Club — compétition eFootball interne.</p>
              </div>
            </div>

            <form @submit.prevent="submit" class="form-fields">

              <!-- Infos personnelles -->
              <fieldset class="form-group">
                <legend class="form-legend">Informations personnelles</legend>
                <div class="form-row-2">
                  <div>
                    <label class="label">Pseudo / Nom en jeu *</label>
                    <input v-model="form.name" class="input" placeholder="Ton pseudo eFootball" required maxlength="60" />
                  </div>
                  <div>
                    <label class="label">Âge *</label>
                    <input v-model.number="form.age" type="number" class="input" placeholder="Ex: 22" min="13" max="99" required />
                  </div>
                </div>
                <div>
                  <label class="label">Email *</label>
                  <input v-model="form.email" type="email" class="input" placeholder="ton@email.com" required />
                </div>
              </fieldset>

              <!-- Infos jeu -->
              <fieldset class="form-group">
                <legend class="form-legend">Profil de joueur</legend>
                <div class="form-row-2">
                  <div>
                    <label class="label">Plateforme *</label>
                    <select v-model="form.platform" class="input" required>
                      <option value="">— Choisir —</option>
                      <option value="PS5">PlayStation 5</option>
                      <option value="PS4">PlayStation 4</option>
                      <option value="Xbox">Xbox</option>
                      <option value="PC">PC / Steam</option>
                      <option value="Mobile">Mobile</option>
                    </select>
                  </div>
                  <div>
                    <label class="label">Fréquence de jeu *</label>
                    <select v-model="form.frequency" class="input" required>
                      <option value="">— Choisir —</option>
                      <option value="daily">Tous les jours</option>
                      <option value="several_week">Plusieurs fois/semaine</option>
                      <option value="weekly">Une fois/semaine</option>
                      <option value="occasional">Occasionnellement</option>
                    </select>
                  </div>
                </div>
                <div>
                  <label class="label">Message / Présentation (optionnel)</label>
                  <textarea v-model="form.message" class="input" rows="3"
                            placeholder="Comment as-tu connu le club ? Ton niveau estimé…"
                            maxlength="400" style="resize:vertical" />
                  <p class="char-count">{{ form.message.length }}/400</p>
                </div>
              </fieldset>

              <!-- Règlement -->
              <fieldset class="form-group">
                <legend class="form-legend">Règlement du club</legend>
                <div class="rules-box">
                  <p><strong>1. Respect</strong> — Tout membre s'engage à respecter les autres joueurs et les décisions des administrateurs.</p>
                  <p><strong>2. Disponibilité</strong> — Participer aux journées officielles est obligatoire sauf absence justifiée.</p>
                  <p><strong>3. Fair-play</strong> — Les scores doivent être reportés honnêtement. Toute tentative de triche entraîne une exclusion immédiate.</p>
                  <p><strong>4. Ponctualité</strong> — Les matchs doivent être joués dans les délais fixés par les administrateurs.</p>
                  <p><strong>5. Admissibilité</strong> — La demande est soumise à validation par un administrateur. Le club se réserve le droit de refuser sans justification.</p>
                </div>
                <label class="terms-check">
                  <input type="checkbox" v-model="form.accepted" required />
                  <span>J'ai lu et j'accepte le règlement du GOUZEPE Gaming Club *</span>
                </label>
              </fieldset>

              <p v-if="error" class="form-error">{{ error }}</p>

              <button type="submit" :disabled="loading || !form.accepted" class="btn-primary w-full justify-center py-3 text-base">
                <Loader2Icon v-if="loading" class="w-4 h-4 animate-spin" />
                {{ loading ? 'Envoi en cours…' : 'Envoyer ma demande' }}
              </button>

              <p class="text-xs text-center" style="color:var(--muted)">
                Déjà membre ?
                <RouterLink to="/login" class="underline" style="color:var(--blue)">Se connecter</RouterLink>
              </p>
            </form>
          </template>

          <!-- Succès -->
          <template v-else>
            <div class="success-block">
              <div class="success-icon-wrap">
                <img src="/assets/icons/apple-touch-icon.png" alt="" class="success-logo" />
              </div>
              <h2 class="form-title">Demande envoyée !</h2>
              <p class="form-sub">Ta demande a bien été reçue. Un administrateur l'examinera et te contactera à l'adresse <strong>{{ form.email }}</strong>.</p>
              <RouterLink to="/" class="btn mt-2">Retour à l'accueil</RouterLink>
            </div>
          </template>

        </div>
      </div>
    </main>

    <footer class="pub-footer">
      Copyright © GOUZEPE GAMING CLUB 2026
    </footer>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { RouterLink } from 'vue-router'
import axios from 'axios'
import { Loader2Icon } from 'lucide-vue-next'
import { resolveBaseURL } from '@/composables/useAPI'

const base = resolveBaseURL()
const loading = ref(false)
const submitted = ref(false)
const error = ref('')
const form = reactive({
  name: '', email: '', age: '', platform: '', frequency: '', message: '', accepted: false
})

async function submit() {
  error.value = ''
  if (!form.accepted) { error.value = 'Veuillez accepter le règlement.'; return }
  loading.value = true
  try {
    await axios.post(`${base}/public/inscription`, {
      name: form.name, email: form.email,
      age: form.age || null, platform: form.platform,
      frequency: form.frequency, message: form.message,
    })
    submitted.value = true
  } catch (e) {
    error.value = e.response?.data?.error || 'Erreur lors de l\'envoi. Réessaie plus tard.'
  }
  loading.value = false
}
</script>

<style scoped>
.public-root { min-height: 100dvh; display: flex; flex-direction: column; background: var(--bg); color: var(--text); }

.pub-header { border-bottom: 1px solid rgba(148,163,184,.18); background: var(--panel); position: sticky; top: 0; z-index: 10; }
.pub-header-inner { max-width: 1100px; margin: 0 auto; padding: 0 1.5rem; height: 60px; display: flex; align-items: center; justify-content: space-between; }
.pub-logo { display: flex; align-items: center; gap: 0.6rem; text-decoration: none; color: inherit; }
.pub-logo-img { width: 36px; height: 36px; border-radius: 8px; object-fit: cover; }
.pub-logo-text-wrap { display: flex; flex-direction: column; line-height: 1.1; }
.pub-logo-title { font-weight: 800; font-size: 1rem; letter-spacing: 0.06em; }
.pub-logo-sub { font-size: 0.62rem; font-weight: 600; color: var(--muted); letter-spacing: 0.1em; text-transform: uppercase; }
.pub-header-actions { display: flex; gap: 0.5rem; }

.pub-main { flex: 1; display: flex; align-items: flex-start; justify-content: center; padding: 2rem 1.25rem; }
.form-wrap { width: 100%; max-width: 560px; }
.form-card { background: var(--card); border: 1px solid rgba(148,163,184,.2); border-radius: 16px; padding: 2rem; }

.form-head { display: flex; align-items: center; gap: 1rem; margin-bottom: 1.5rem; }
.form-logo { width: 52px; height: 52px; border-radius: 12px; object-fit: cover; flex-shrink: 0; }
.form-title { font-size: 1.25rem; font-weight: 800; margin-bottom: 0.2rem; }
.form-sub { font-size: 0.85rem; color: var(--muted); line-height: 1.5; }

.form-fields { display: flex; flex-direction: column; gap: 1.25rem; }

.form-group { border: 1px solid rgba(148,163,184,.15); border-radius: 10px; padding: 1rem; display: flex; flex-direction: column; gap: 0.75rem; }
.form-legend { font-size: 0.7rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.07em; color: var(--muted); padding: 0 0.25rem; }
.form-row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem; }
.char-count { font-size: 0.72rem; color: var(--muted); text-align: right; margin-top: 2px; }

.rules-box {
  background: rgba(148,163,184,.06);
  border: 1px solid rgba(148,163,184,.15);
  border-radius: 8px;
  padding: 0.85rem 1rem;
  font-size: 0.82rem;
  color: var(--muted);
  line-height: 1.6;
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}
.rules-box strong { color: var(--text); }

.terms-check {
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
  font-size: 0.85rem;
  cursor: pointer;
}
.terms-check input { margin-top: 3px; flex-shrink: 0; width: 16px; height: 16px; accent-color: var(--green); }

.form-error { font-size: 0.85rem; color: #ef4444; background: rgba(239,68,68,.1); border-radius: 8px; padding: 0.5rem 0.75rem; }

.success-block { text-align: center; display: flex; flex-direction: column; align-items: center; gap: 0.75rem; padding: 1rem 0; }
.success-icon-wrap { }
.success-logo { width: 72px; height: 72px; border-radius: 16px; object-fit: cover; box-shadow: 0 8px 24px rgba(0,0,0,.25); }

.pub-footer { text-align: center; font-size: 0.75rem; color: var(--muted); padding: 1.25rem; border-top: 1px solid rgba(148,163,184,.12); }

@media (max-width: 480px) { .form-row-2 { grid-template-columns: 1fr; } }
</style>
