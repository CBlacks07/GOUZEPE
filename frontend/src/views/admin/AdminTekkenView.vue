<template>
  <AppLayout season-label="Admin Tekken">
    <div class="page-wrap tk-admin">
      <div class="mb-6">
        <RouterLink to="/admin" class="back">&larr; Console</RouterLink>
        <h1 class="title">Tekken -- Ladder &amp; Duels</h1>
      </div>

      <!-- Onglets -->
      <div class="tabs">
        <button :class="['tab', { on: tab === 'ladder' }]" @click="tab='ladder'">
          <ListOrderedIcon class="w-4 h-4" /> Ladder
        </button>
        <button :class="['tab', { on: tab === 'duels' }]" @click="tab='duels'">
          <SwordsIcon class="w-4 h-4" /> Duels
        </button>
        <button :class="['tab', { on: tab === 'new' }]" @click="tab='new'">
          <PlusIcon class="w-4 h-4" /> Enregistrer un duel
        </button>
      </div>

      <!-- TAB: Ladder -->
      <section v-if="tab === 'ladder'" class="card">
        <div class="flex flex-wrap items-center justify-between gap-3 mb-4">
          <div>
            <h2 class="font-semibold">Classement ELO</h2>
            <p class="text-xs text-gz-muted mt-0.5">
              Un joueur rejoint le ladder automatiquement des son premier duel ou match de tournoi
              compte pour le ladder -- aucun ajout ni ELO de depart manuel.
            </p>
          </div>
          <button @click="loadLadder" class="btn text-xs flex items-center gap-1">
            <RefreshCwIcon class="w-3.5 h-3.5" /> Rafraichir
          </button>
        </div>

        <div class="overflow-x-auto table-shell">
          <table class="data-table">
            <thead>
              <tr>
                <th class="w-10">#</th>
                <th>Joueur</th>
                <th class="text-center">ELO</th>
                <th class="text-center">V</th>
                <th class="text-center">D</th>
                <th class="text-center">Serie</th>
                <th class="text-center">Peak</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="ladderLoading">
                <td colspan="8" class="text-center text-gz-muted py-8">Chargement...</td>
              </tr>
              <tr v-else-if="!ladder.length">
                <td colspan="8" class="text-center text-gz-muted py-8">
                  Aucun joueur dans le ladder -- il se peuple des le premier duel ou match de tournoi joue.
                </td>
              </tr>
              <tr v-for="(p, i) in ladder" :key="p.player_id">
                <td class="text-gz-muted font-bold">{{ i + 1 }}</td>
                <td class="font-medium">{{ p.name }} <span class="text-gz-muted text-xs">({{ p.player_id }})</span></td>
                <td class="text-center font-bold text-lg">{{ p.elo }}</td>
                <td class="text-center text-gz-green font-semibold">{{ p.wins }}</td>
                <td class="text-center text-gz-red font-semibold">{{ p.losses }}</td>
                <td class="text-center">
                  <span :class="p.streak > 0 ? 'text-gz-green' : p.streak < 0 ? 'text-gz-red' : 'text-gz-muted'">
                    {{ p.streak > 0 ? '+' + p.streak : p.streak }}
                  </span>
                </td>
                <td class="text-center text-gz-muted">{{ p.peak_elo }}</td>
                <td>
                  <div class="flex gap-1">
                    <button @click="openCorrect(p)" class="btn py-1 px-2 text-xs flex items-center gap-1" title="Corriger l'ELO (erreur de saisie, litige...)">
                      <WrenchIcon class="w-3 h-3" /> Corriger
                    </button>
                    <button @click="removeLadder(p.player_id)" class="btn-danger py-1 px-2 text-xs flex items-center gap-1">
                      <Trash2Icon class="w-3 h-3" /> Retirer
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <!-- TAB: Historique duels -->
      <section v-if="tab === 'duels'" class="card">
        <div class="flex flex-wrap items-center justify-between gap-3 mb-4">
          <h2 class="font-semibold">Historique des duels</h2>
          <button @click="loadDuels" class="btn text-xs flex items-center gap-1">
            <RefreshCwIcon class="w-3.5 h-3.5" /> Rafraichir
          </button>
        </div>

        <div class="overflow-x-auto table-shell">
          <table class="data-table">
            <thead>
              <tr>
                <th>Date</th>
                <th>Origine</th>
                <th>Joueur 1</th>
                <th class="text-center">Score</th>
                <th>Joueur 2</th>
                <th class="text-center">ELO +/-</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="duelsLoading">
                <td colspan="7" class="text-center text-gz-muted py-8">Chargement...</td>
              </tr>
              <tr v-else-if="!duels.length">
                <td colspan="7" class="text-center text-gz-muted py-8">Aucun duel enregistre.</td>
              </tr>
              <tr v-for="d in duels" :key="d.id">
                <td class="text-gz-muted text-xs whitespace-nowrap">{{ fmtDate(d.played_at) }}</td>
                <td class="text-xs">
                  <span v-if="d.source === 'tournament'" class="origin-badge origin-tournament" :title="d.tournament_name || ''">
                    Tournoi<span v-if="d.tournament_name"> -- {{ d.tournament_name }}</span>
                  </span>
                  <span v-else class="origin-badge origin-duel">Duel libre</span>
                </td>
                <td :class="{ 'font-bold': d.winner_id === d.p1_id }">{{ d.p1_name }}</td>
                <td class="text-center font-mono font-bold">{{ d.score_p1 }} - {{ d.score_p2 }}</td>
                <td :class="{ 'font-bold': d.winner_id === d.p2_id }">{{ d.p2_name }}</td>
                <td class="text-center text-xs">
                  <span :class="eloDelta(d, d.p1_id) >= 0 ? 'text-gz-green' : 'text-gz-red'">{{ eloDelta(d, d.p1_id) > 0 ? '+' : '' }}{{ eloDelta(d, d.p1_id) }}</span>
                  /
                  <span :class="eloDelta(d, d.p2_id) >= 0 ? 'text-gz-green' : 'text-gz-red'">{{ eloDelta(d, d.p2_id) > 0 ? '+' : '' }}{{ eloDelta(d, d.p2_id) }}</span>
                </td>
                <td>
                  <button v-if="d.source !== 'tournament'" @click="deleteDuel(d.id)" class="btn-danger py-1 px-2 text-xs flex items-center gap-1">
                    <Trash2Icon class="w-3 h-3" />
                  </button>
                  <span v-else class="text-gz-muted text-xs" title="Corrige via le bouton Corriger du ladder si besoin">--</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <!-- TAB: Nouveau duel -->
      <section v-if="tab === 'new'" class="card">
        <h2 class="font-semibold mb-4">Enregistrer un duel</h2>

        <div class="duel-form">
          <div class="duel-players">
            <div class="duel-side">
              <label class="label">Joueur 1</label>
              <select v-model="dForm.p1_id" class="input">
                <option value="">-- Choisir --</option>
                <option v-for="p in tekkenPlayers" :key="p.player_id" :value="p.player_id">
                  {{ p.name }} ({{ eloOf(p.player_id) }})
                </option>
              </select>
            </div>
            <div class="duel-vs">VS</div>
            <div class="duel-side">
              <label class="label">Joueur 2</label>
              <select v-model="dForm.p2_id" class="input">
                <option value="">-- Choisir --</option>
                <option v-for="p in tekkenPlayers.filter(x => x.player_id !== dForm.p1_id)" :key="p.player_id" :value="p.player_id">
                  {{ p.name }} ({{ eloOf(p.player_id) }})
                </option>
              </select>
            </div>
          </div>

          <div class="duel-scores">
            <div>
              <label class="label">Manches J1</label>
              <input v-model.number="dForm.score_p1" type="number" min="0" class="input text-center text-lg font-bold" />
            </div>
            <div>
              <label class="label">Format</label>
              <select v-model.number="dForm.best_of" class="input text-center">
                <option :value="3">BO3</option>
                <option :value="5">BO5</option>
                <option :value="7">BO7</option>
              </select>
            </div>
            <div>
              <label class="label">Manches J2</label>
              <input v-model.number="dForm.score_p2" type="number" min="0" class="input text-center text-lg font-bold" />
            </div>
          </div>

          <div class="mt-4 flex items-center gap-3">
            <button @click="submitDuel" :disabled="!canSubmitDuel || submittingDuel"
                    class="btn-primary flex items-center gap-1.5">
              <Loader2Icon v-if="submittingDuel" class="w-4 h-4 animate-spin" />
              Valider le duel
            </button>
            <span v-if="duelMsg" :class="['text-sm', duelOk ? 'text-gz-green' : 'text-gz-red']">{{ duelMsg }}</span>
          </div>

          <!-- Resultat apres soumission -->
          <div v-if="lastResult" class="mt-4 p-3 border border-gz-border rounded-lg bg-gz-panel/30">
            <p class="text-sm font-semibold mb-1">Resultat enregistre</p>
            <p class="text-sm text-gz-muted">
              Vainqueur : <strong>{{ lastResult.winner_name }}</strong>
            </p>
            <p class="text-sm text-gz-muted">
              ELO : {{ lastResult.p1_name }} {{ lastResult.elo.p1.before }} &rarr; {{ lastResult.elo.p1.after }}
              ({{ lastResult.elo.p1.after - lastResult.elo.p1.before > 0 ? '+' : '' }}{{ lastResult.elo.p1.after - lastResult.elo.p1.before }})
              | {{ lastResult.p2_name }} {{ lastResult.elo.p2.before }} &rarr; {{ lastResult.elo.p2.after }}
              ({{ lastResult.elo.p2.after - lastResult.elo.p2.before > 0 ? '+' : '' }}{{ lastResult.elo.p2.after - lastResult.elo.p2.before }})
            </p>
          </div>
        </div>
      </section>
    </div>

    <!-- Modal correction ELO -->
    <BaseModal :open="correctModal" title="Corriger l'ELO" @close="correctModal = false">
      <div v-if="correctTarget" class="space-y-4">
        <p class="text-xs text-gz-muted">
          {{ correctTarget.name }} ({{ correctTarget.player_id }}) -- ELO actuel : <strong>{{ correctTarget.elo }}</strong>.
          Reserve aux erreurs de saisie ou litiges : l'attribution normale passe par les duels et les
          matchs de tournoi. Cette action est tracee.
        </p>
        <div>
          <label class="label">Nouvel ELO</label>
          <input v-model.number="correctForm.elo" type="number" class="input" />
        </div>
        <div>
          <label class="label">Motif (obligatoire)</label>
          <textarea v-model="correctForm.reason" class="input min-h-[90px]"
                    placeholder="ex : score de duel mal saisi le 12/08, corrige suite a verification..." />
        </div>
        <p v-if="correctErr" class="text-gz-red text-sm">{{ correctErr }}</p>
      </div>
      <template #footer>
        <button @click="correctModal = false" class="btn">Annuler</button>
        <button @click="confirmCorrect" :disabled="correcting || !correctForm.reason.trim()" class="btn-primary flex items-center gap-1.5">
          <Loader2Icon v-if="correcting" class="w-3.5 h-3.5 animate-spin" />
          Appliquer le correctif
        </button>
      </template>
    </BaseModal>
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import AppLayout from '@/components/layout/AppLayout.vue'
import BaseModal from '@/components/ui/BaseModal.vue'
import { useAPI } from '@/composables/useAPI'
import { useToast } from '@/composables/useToast'
import { ListOrderedIcon, SwordsIcon, PlusIcon, RefreshCwIcon, Trash2Icon, Loader2Icon, WrenchIcon } from 'lucide-vue-next'

const api = useAPI()
const { success, error: toastError } = useToast()
const tab = ref('ladder')

const ladder = ref([])
const ladderLoading = ref(false)
const duels = ref([])
const duelsLoading = ref(false)
const allPlayers = ref([])

const dForm = ref({ p1_id: '', p2_id: '', score_p1: 0, score_p2: 0, best_of: 3 })
const submittingDuel = ref(false)
const duelMsg = ref('')
const duelOk = ref(true)
const lastResult = ref(null)

const correctModal  = ref(false)
const correctTarget = ref(null)
const correctForm   = ref({ elo: 1200, reason: '' })
const correctErr    = ref('')
const correcting    = ref(false)

const tekkenPlayers = computed(() => {
  return allPlayers.value.filter(p => p.main_game === 'tekken' || p.main_game === 'both')
})

// ELO d'un joueur : celui du ladder s'il y est deja, sinon 1200 par defaut (pas encore joue).
function eloOf(pid) {
  return ladder.value.find(p => p.player_id === pid)?.elo ?? 1200
}

function playerName(pid) {
  return ladder.value.find(p => p.player_id === pid)?.name
    || allPlayers.value.find(p => p.player_id === pid)?.name
    || pid
}

const canSubmitDuel = computed(() => {
  const f = dForm.value
  return f.p1_id && f.p2_id && f.p1_id !== f.p2_id && (f.score_p1 > 0 || f.score_p2 > 0)
})

function fmtDate(d) {
  if (!d) return ''
  const dt = new Date(d)
  return dt.toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit', year: 'numeric' })
}

function eloDelta(d, pid) {
  if (pid === d.p1_id) return (d.elo_p1_after || 0) - (d.elo_p1_before || 0)
  return (d.elo_p2_after || 0) - (d.elo_p2_before || 0)
}

async function loadLadder() {
  ladderLoading.value = true
  try {
    const { data } = await api.get('/tekken/ladder')
    ladder.value = data.ladder || []
  } catch (_) {}
  ladderLoading.value = false
}

async function loadDuels() {
  duelsLoading.value = true
  try {
    const { data } = await api.get('/tekken/duels')
    duels.value = data.duels || []
  } catch (_) {}
  duelsLoading.value = false
}

async function loadPlayers() {
  try {
    const { data } = await api.get('/players')
    allPlayers.value = (data.players || []).sort((a, b) => (a.name || '').localeCompare(b.name || '', 'fr'))
  } catch (_) {}
}

function openCorrect(p) {
  correctTarget.value = p
  correctErr.value = ''
  correctForm.value = { elo: p.elo, reason: '' }
  correctModal.value = true
}

async function confirmCorrect() {
  if (!correctTarget.value) return
  correctErr.value = ''
  correcting.value = true
  try {
    await api.post(`/admin/tekken/ladder/${encodeURIComponent(correctTarget.value.player_id)}/correct`, correctForm.value)
    correctModal.value = false
    success('ELO corrige')
    await loadLadder()
  } catch (e) {
    correctErr.value = e.response?.data?.error || 'Erreur lors du correctif'
  } finally {
    correcting.value = false
  }
}

async function removeLadder(pid) {
  if (!confirm(`Retirer ${pid} du ladder Tekken ?`)) return
  try {
    await api.delete('/admin/tekken/ladder/' + encodeURIComponent(pid))
    await loadLadder()
  } catch (e) { alert(e.response?.data?.error || 'Erreur') }
}

async function submitDuel() {
  submittingDuel.value = true
  duelMsg.value = ''
  lastResult.value = null
  try {
    const { data } = await api.post('/admin/tekken/duels', dForm.value)
    lastResult.value = {
      winner_name: data.winner_id ? playerName(data.winner_id) : 'Egalite',
      p1_name: playerName(dForm.value.p1_id),
      p2_name: playerName(dForm.value.p2_id),
      elo: data.elo,
    }
    duelMsg.value = 'Duel enregistre'
    duelOk.value = true
    dForm.value = { p1_id: '', p2_id: '', score_p1: 0, score_p2: 0, best_of: 3 }
    await loadLadder()
    await loadDuels()
  } catch (e) {
    duelMsg.value = e.response?.data?.error || 'Erreur'
    duelOk.value = false
  }
  submittingDuel.value = false
}

async function deleteDuel(id) {
  if (!confirm('Supprimer ce duel ? (les ELO ne seront pas recalcules)')) return
  try {
    await api.delete('/admin/tekken/duels/' + id)
    await loadDuels()
  } catch (e) { alert(e.response?.data?.error || 'Erreur') }
}

onMounted(async () => {
  await Promise.all([loadLadder(), loadDuels(), loadPlayers()])
})
</script>

<style scoped>
.tk-admin { max-width: 64rem; }
.back { color: var(--muted); text-decoration: none; font-size: .85rem; font-weight: 600; }
.back:hover { color: var(--accent-l); }
.title { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .04em; font-size: 1.5rem; margin-top: .4rem; }

.tabs { display: inline-flex; gap: .35rem; padding: 4px; border: 1px solid var(--border); border-radius: 999px; background: var(--card); margin-bottom: 1.2rem; }
.tab { display: flex; align-items: center; gap: .4rem; padding: .45rem 1rem; border: none; background: transparent; color: var(--muted); font-family: var(--font-title); font-weight: 700; letter-spacing: .03em; text-transform: uppercase; font-size: .8rem; border-radius: 999px; cursor: pointer; transition: all .18s; }
.tab.on { background: var(--accent); color: #fff; box-shadow: 0 3px 12px rgba(var(--accent-rgb), .35); }

.table-shell { border: 1px solid rgba(148, 163, 184, 0.2); border-radius: 12px; background: color-mix(in srgb, var(--card) 92%, transparent); }

.duel-form { max-width: 36rem; }
.duel-players { display: flex; align-items: flex-end; gap: 1rem; margin-bottom: 1rem; }
.duel-side { flex: 1; }
.duel-vs { font-family: var(--font-title); font-weight: 700; font-size: 1.2rem; color: var(--accent); padding-bottom: .5rem; }
.duel-scores { display: flex; align-items: flex-end; gap: 1rem; }
.duel-scores > div { flex: 1; }

.origin-badge { display: inline-block; padding: .15rem .5rem; border-radius: 999px; font-weight: 600; white-space: nowrap; }
.origin-duel { background: color-mix(in srgb, var(--muted) 16%, transparent); color: var(--muted); }
.origin-tournament { background: rgba(var(--accent-rgb), .15); color: var(--accent-l, var(--accent)); }
</style>
