<template>
  <div class="reg">

    <!-- ── Panneau marque (gauche) ── -->
    <aside class="reg-brand">
      <div class="reg-brand-bg" aria-hidden="true"></div>
      <div class="reg-brand-content">
        <RouterLink to="/" class="brand">
          <img class="brand-logo" src="/assets/icons/apple-touch-icon.png" alt="GOUZEPE" />
          <span class="brand-text">GOUZEPE<span class="brand-sub">GAMING CLUB</span></span>
        </RouterLink>

        <h1 class="brand-title">Rejoins<br/>la communauté.</h1>
        <p class="brand-lead">
          Deviens membre du club et entre dans la compétition <strong>eFootball</strong> &amp; <strong>Tekken</strong>.
        </p>

        <ol class="reg-steps">
          <li><span class="step-n">1</span><div><strong>Remplis le formulaire</strong><span>Quelques infos sur toi et ton jeu.</span></div></li>
          <li><span class="step-n">2</span><div><strong>Validation admin</strong><span>Un administrateur examine ta demande.</span></div></li>
          <li><span class="step-n">3</span><div><strong>En piste !</strong><span>Tu accèdes à ton espace et aux compétitions.</span></div></li>
        </ol>
      </div>
    </aside>

    <!-- ── Formulaire (droite) ── -->
    <main class="reg-main">
      <div class="reg-card">

        <div class="reg-top">
          <RouterLink to="/" class="reg-back"><ArrowLeftIcon class="w-4 h-4" /> Accueil</RouterLink>
          <RouterLink to="/login" class="reg-link">Déjà membre ?</RouterLink>
        </div>

        <!-- Marque compacte (mobile uniquement) -->
        <div class="reg-mobi-brand">
          <img src="/assets/icons/apple-touch-icon.png" alt="GOUZEPE" />
          <div><strong>GOUZEPE</strong><span>GAMING CLUB</span></div>
        </div>

        <template v-if="!submitted">
          <div class="reg-head">
            <h2 class="reg-h2">Demande de membre</h2>
            <p class="reg-hint">Tous les champs marqués * sont obligatoires.</p>
          </div>

          <form @submit.prevent="submit" class="reg-form">

            <!-- Jeux pratiqués -->
            <fieldset class="fg">
              <legend>Tu joues à *</legend>
              <div class="game-pick">
                <button type="button" v-for="g in gameOptions" :key="g.v"
                        :class="['gp', { on: form.games.includes(g.v) }, g.v]"
                        @click="toggleGame(g.v)">
                  <CheckIcon v-if="form.games.includes(g.v)" class="w-4 h-4" />
                  {{ g.label }}
                </button>
              </div>
            </fieldset>

            <!-- Identité -->
            <fieldset class="fg">
              <legend>Informations personnelles</legend>
              <div class="row-2">
                <div>
                  <label class="label">Pseudo / Nom en jeu *</label>
                  <input v-model="form.name" class="input" placeholder="Ton pseudo" required maxlength="60" />
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

            <!-- Profil joueur -->
            <fieldset class="fg">
              <legend>Profil de joueur</legend>
              <div class="row-2">
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
            <fieldset class="fg">
              <legend>Règlement du club</legend>
              <div class="rules-box">
                <p><strong>1. Respect</strong> — Respecter les autres joueurs et les décisions des administrateurs.</p>
                <p><strong>2. Disponibilité</strong> — Participer aux journées/compétitions sauf absence justifiée.</p>
                <p><strong>3. Fair-play</strong> — Reporter les scores honnêtement ; toute triche entraîne une exclusion.</p>
                <p><strong>4. Ponctualité</strong> — Jouer les matchs dans les délais fixés.</p>
                <p><strong>5. Admissibilité</strong> — Demande soumise à validation. Le club peut refuser sans justification.</p>
              </div>
              <label class="terms-check">
                <input type="checkbox" v-model="form.accepted" required />
                <span>J'ai lu et j'accepte le règlement du GOUZEPE Gaming Club *</span>
              </label>
            </fieldset>

            <p v-if="error" class="form-error">{{ error }}</p>

            <button type="submit" :disabled="loading || !form.accepted" class="btn-primary reg-submit">
              <Loader2Icon v-if="loading" class="w-4 h-4 animate-spin" />
              {{ loading ? 'Envoi en cours…' : 'Envoyer ma demande' }}
            </button>
          </form>
        </template>

        <!-- Succès -->
        <template v-else>
          <div class="success-block">
            <div class="success-ring"><CheckIcon class="w-9 h-9" /></div>
            <h2 class="reg-h2">Demande envoyée !</h2>
            <p class="reg-hint">Ta demande a bien été reçue. Un administrateur l'examinera et te contactera à <strong>{{ form.email }}</strong>.</p>
            <RouterLink to="/" class="btn-primary mt">Retour à l'accueil</RouterLink>
          </div>
        </template>

      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { RouterLink } from 'vue-router'
import axios from 'axios'
import { ArrowLeftIcon, CheckIcon, Loader2Icon } from 'lucide-vue-next'
import { resolveBaseURL } from '@/composables/useAPI'

const base = resolveBaseURL()
const loading = ref(false)
const submitted = ref(false)
const error = ref('')
const form = reactive({
  name: '', email: '', age: '', platform: '', frequency: '', message: '', accepted: false, games: [],
})

const gameOptions = [
  { v: 'efoot', label: 'eFootball' },
  { v: 'tekken', label: 'Tekken' },
]

function toggleGame(v) {
  const i = form.games.indexOf(v)
  if (i >= 0) form.games.splice(i, 1)
  else form.games.push(v)
}

async function submit() {
  error.value = ''
  if (!form.games.length) { error.value = 'Choisis au moins un jeu.'; return }
  if (!form.accepted) { error.value = 'Veuillez accepter le règlement.'; return }
  loading.value = true
  try {
    await axios.post(`${base}/public/inscription`, {
      name: form.name, email: form.email,
      age: form.age || null, platform: form.platform,
      frequency: form.frequency, message: form.message,
      games: form.games,
    })
    submitted.value = true
  } catch (e) {
    error.value = e.response?.data?.error || 'Erreur lors de l\'envoi. Réessaie plus tard.'
  }
  loading.value = false
}
</script>

<style scoped>
.reg { min-height: 100dvh; display: grid; grid-template-columns: 1fr; }

/* ── Panneau marque ── */
.reg-brand { position: relative; display: none; overflow: hidden; color: var(--text); }
.reg-brand-bg {
  position: absolute; inset: 0;
  background:
    radial-gradient(60vw 60vh at 25% 15%, rgba(var(--accent-rgb), .35), transparent 60%),
    linear-gradient(160deg, var(--panel), var(--bg));
}
.reg-brand-bg::after {
  content: ''; position: absolute; inset: 0;
  background-image:
    linear-gradient(rgba(var(--accent-rgb), .08) 1px, transparent 1px),
    linear-gradient(90deg, rgba(var(--accent-rgb), .08) 1px, transparent 1px);
  background-size: 44px 44px;
  mask-image: radial-gradient(70% 70% at 30% 30%, #000, transparent 75%);
}
.reg-brand-content { position: relative; z-index: 1; display: flex; flex-direction: column; min-height: 100%; padding: 3rem 3.5rem; }
.brand { display: inline-flex; align-items: center; gap: .6rem; text-decoration: none; color: var(--text); }
.brand-logo { width: 40px; height: 40px; border-radius: 9px; object-fit: cover; flex: none; }
.brand-text { display: flex; flex-direction: column; line-height: 1; font-family: var(--font-title); font-weight: 700; letter-spacing: .06em; }
.brand-sub { font-size: .58rem; color: var(--muted); letter-spacing: .24em; margin-top: 3px; }
.brand-title { margin: auto 0 1rem; font-family: var(--font-title); font-weight: 700; font-size: clamp(2.2rem, 3.4vw, 3.4rem); line-height: .98; text-transform: uppercase; letter-spacing: .02em; }
.brand-lead { max-width: 26rem; color: var(--muted); line-height: 1.6; margin: 0 0 2rem; }
.brand-lead strong { color: var(--text); }

.reg-steps { list-style: none; padding: 0; margin: 0; display: grid; gap: 1.1rem; }
.reg-steps li { display: flex; gap: .9rem; align-items: flex-start; }
.step-n { flex: none; width: 1.9rem; height: 1.9rem; display: grid; place-items: center; border-radius: 50%; background: var(--accent); color: #fff; font-family: var(--font-title); font-weight: 700; }
.reg-steps strong { display: block; font-weight: 600; }
.reg-steps span { color: var(--muted); font-size: .85rem; }

/* ── Colonne formulaire ── */
.reg-main {
  display: grid; place-items: start center; padding: 1.5rem;
  background: radial-gradient(900px 600px at 80% 0%, rgba(var(--accent-rgb), .1), transparent 45%), var(--bg);
}
.reg-card { position: relative; width: min(560px, 96vw); border: 1px solid var(--border); border-radius: 18px; background: var(--panel); box-shadow: var(--shadow); padding: 1.25rem 1.5rem 1.75rem; overflow: hidden; }
.reg-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px; background: linear-gradient(90deg, var(--accent), var(--accent-l, var(--accent))); }

/* Marque compacte (mobile) */
.reg-mobi-brand { display: flex; align-items: center; gap: .6rem; margin-bottom: 1.25rem; }
.reg-mobi-brand img { width: 38px; height: 38px; border-radius: 9px; object-fit: cover; flex: none; }
.reg-mobi-brand strong { display: block; font-family: var(--font-title); font-weight: 700; letter-spacing: .06em; line-height: 1; }
.reg-mobi-brand span { font-size: .56rem; color: var(--muted); letter-spacing: .22em; }

.reg-top { display: flex; align-items: center; justify-content: space-between; padding-bottom: 1rem; border-bottom: 1px solid var(--border); margin-bottom: 1.25rem; }
.reg-back { display: inline-flex; align-items: center; gap: .35rem; color: var(--muted); text-decoration: none; font-size: .85rem; font-weight: 600; }
.reg-back:hover { color: var(--accent-l); }
.reg-link { color: var(--accent-l); text-decoration: none; font-size: .85rem; font-weight: 600; }
.reg-link:hover { text-decoration: underline; }

.reg-head { margin-bottom: 1.25rem; }
.reg-h2 { margin: 0; font-family: var(--font-title); font-weight: 700; font-size: 1.6rem; text-transform: uppercase; letter-spacing: .04em; }
.reg-hint { margin: .25rem 0 0; color: var(--muted); font-size: .9rem; }

.reg-form { display: flex; flex-direction: column; gap: 1.25rem; }
.fg { border: 1px solid var(--border); border-radius: 12px; padding: 1rem; display: flex; flex-direction: column; gap: .75rem; }
.fg legend { font-family: var(--font-title); font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: .08em; color: var(--muted); padding: 0 .35rem; }
.row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: .75rem; }
.char-count { font-size: .72rem; color: var(--muted); text-align: right; margin-top: 2px; }

/* Choix des jeux */
.game-pick { display: grid; grid-template-columns: 1fr 1fr; gap: .6rem; }
.gp {
  display: inline-flex; align-items: center; justify-content: center; gap: .4rem;
  padding: .7rem; border-radius: 10px; cursor: pointer;
  border: 1px solid var(--border); background: var(--card); color: var(--text);
  font-family: var(--font-title); font-weight: 700; letter-spacing: .03em; text-transform: uppercase; font-size: .9rem;
  transition: all .15s;
}
.gp:hover { border-color: color-mix(in srgb, var(--accent) 50%, var(--border)); }
.gp.on { background: var(--accent); border-color: var(--accent); color: #fff; box-shadow: 0 5px 16px rgba(var(--accent-rgb), .3); }
.gp.tekken.on { background: #ff5a2c; border-color: #ff5a2c; box-shadow: 0 5px 16px rgba(255,90,44,.32); }

.rules-box { background: rgba(148,163,184,.06); border: 1px solid var(--border); border-radius: 8px; padding: .85rem 1rem; font-size: .82rem; color: var(--muted); line-height: 1.6; display: flex; flex-direction: column; gap: .35rem; }
.rules-box strong { color: var(--text); }

.terms-check { display: flex; align-items: flex-start; gap: .5rem; font-size: .85rem; cursor: pointer; }
.terms-check input { margin-top: 3px; flex-shrink: 0; width: 16px; height: 16px; accent-color: var(--accent); }

.form-error { font-size: .85rem; color: var(--red); background: rgba(239,68,68,.1); border-radius: 8px; padding: .5rem .75rem; }
.reg-submit { width: 100%; justify-content: center; padding: .8rem; font-size: 1rem; }

.success-block { text-align: center; display: flex; flex-direction: column; align-items: center; gap: .85rem; padding: 2rem 0; }
.success-ring { width: 76px; height: 76px; border-radius: 50%; display: grid; place-items: center; color: #fff; background: var(--accent); box-shadow: 0 10px 28px rgba(var(--accent-rgb), .35); }
.mt { margin-top: .5rem; }

@media (min-width: 880px) {
  .reg { grid-template-columns: 1fr 1fr; }
  .reg-brand { display: block; }
  .reg-main { align-items: center; }
  .reg-mobi-brand { display: none; }
}
@media (max-width: 480px) {
  .row-2, .game-pick { grid-template-columns: 1fr; }
  .reg-main { padding: 1rem .85rem; }
  .reg-card { padding: 1.1rem 1rem 1.5rem; }
  .fg { padding: .85rem; }
}
</style>
