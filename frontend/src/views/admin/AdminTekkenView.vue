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
          <h2 class="font-semibold">Classement ELO</h2>
          <div class="flex gap-2">
            <button @click="loadLadder" class="btn text-xs flex items-center gap-1">
              <RefreshCwIcon class="w-3.5 h-3.5" /> Rafraichir
            </button>
          </div>
        </div>

        <!-- Ajouter un joueur -->
        <div class="flex flex-wrap gap-2 items-end mb-4 p-3 border border-gz-border rounded-lg bg-gz-panel/30">
          <div class="flex-1 min-w-[200px]">
            <label class="label">Joueur</label>
            <select v-model="addPid" class="input">
              <option value="">-- Choisir --</option>
              <option v-for="p in availablePlayers" :key="p.player_id" :value="p.player_id">
                {{ p.player_id }} ({{ p.name }})
              </option>
            </select>
          </div>
          <div class="w-24">
            <label class="label">ELO</label>
            <input v-model.number="addElo" type="number" class="input" />
          </div>
          <button @click="addToLadder" :disabled="!addPid || addingLadder" class="btn-primary text-xs py-2 px-3 flex items-center gap-1">
            <Loader2Icon v-if="addingLadder" class="w-3.5 h-3.5 animate-spin" />
            <PlusIcon v-else class="w-3.5 h-3.5" /> Ajouter
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
                <td colspan="8" class="text-center text-gz-muted py-8">Aucun joueur dans le ladder.</td>
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
                <th>Joueur 1</th>
                <th class="text-center">Score</th>
                <th>Joueur 2</th>
                <th class="text-center">ELO +/-</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="duelsLoading">
                <td colspan="6" class="text-center text-gz-muted py-8">Chargement...</td>
              </tr>
              <tr v-else-if="!duels.length">
                <td colspan="6" class="text-center text-gz-muted py-8">Aucun duel enregistre.</td>
              </tr>
              <tr v-for="d in duels" :key="d.id">
                <td class="text-gz-muted text-xs whitespace-nowrap">{{ fmtDate(d.played_at) }}</td>
                <td :class="{ 'font-bold': d.winner_id === d.p1_id }">{{ d.p1_name }}</td>
                <td class="text-center font-mono font-bold">{{ d.score_p1 }} - {{ d.score_p2 }}</td>
                <td :class="{ 'font-bold': d.winner_id === d.p2_id }">{{ d.p2_name }}</td>
                <td class="text-center text-xs">
                  <span :class="eloDelta(d, d.p1_id) >= 0 ? 'text-gz-green' : 'text-gz-red'">{{ eloDelta(d, d.p1_id) > 0 ? '+' : '' }}{{ eloDelta(d, d.p1_id) }}</span>
                  /
                  <span :class="eloDelta(d, d.p2_id) >= 0 ? 'text-gz-green' : 'text-gz-red'">{{ eloDelta(d, d.p2_id) > 0 ? '+' : '' }}{{ eloDelta(d, d.p2_id) }}</span>
                </td>
                <td>
                  <button @click="deleteDuel(d.id)" class="btn-danger py-1 px-2 text-xs flex items-center gap-1">
                    <Trash2Icon class="w-3 h-3" />
                  </button>
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
                <option v-for="p in ladder" :key="p.player_id" :value="p.player_id">
                  {{ p.name }} ({{ p.elo }})
                </option>
              </select>
            </div>
            <div class="duel-vs">VS</div>
            <div class="duel-side">
              <label class="label">Joueur 2</label>
              <select v-model="dForm.p2_id" class="input">
                <option value="">-- Choisir --</option>
                <option v-for="p in ladder.filter(x => x.player_id !== dForm.p1_id)" :key="p.player_id" :value="p.player_id">
                  {{ p.name }} ({{ p.elo }})
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
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import AppLayout from '@/components/layout/AppLayout.vue'
import { useAPI } from '@/composables/useAPI'
import { ListOrderedIcon, SwordsIcon, PlusIcon, RefreshCwIcon, Trash2Icon, Loader2Icon } from 'lucide-vue-next'

const api = useAPI()
const tab = ref('ladder')

const ladder = ref([])
const ladderLoading = ref(false)
const duels = ref([])
const duelsLoading = ref(false)
const allPlayers = ref([])

const addPid = ref('')
const addElo = ref(1200)
const addingLadder = ref(false)

const dForm = ref({ p1_id: '', p2_id: '', score_p1: 0, score_p2: 0, best_of: 3 })
const submittingDuel = ref(false)
const duelMsg = ref('')
const duelOk = ref(true)
const lastResult = ref(null)

const tekkenPlayers = computed(() => {
  return allPlayers.value.filter(p => p.main_game === 'tekken' || p.main_game === 'both')
})

const availablePlayers = computed(() => {
  const inLadder = new Set(ladder.value.map(p => p.player_id))
  return tekkenPlayers.value.filter(p => !inLadder.has(p.player_id))
})

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

async function addToLadder() {
  if (!addPid.value) return
  addingLadder.value = true
  try {
    await api.post('/admin/tekken/ladder', { player_id: addPid.value, elo: addElo.value })
    addPid.value = ''
    addElo.value = 1200
    await loadLadder()
  } catch (e) { alert(e.response?.data?.error || 'Erreur') }
  addingLadder.value = false
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
    const p1 = ladder.value.find(p => p.player_id === dForm.value.p1_id)
    const p2 = ladder.value.find(p => p.player_id === dForm.value.p2_id)
    const winner = ladder.value.find(p => p.player_id === data.winner_id)
    lastResult.value = {
      winner_name: winner?.name || data.winner_id || 'Egalite',
      p1_name: p1?.name || dForm.value.p1_id,
      p2_name: p2?.name || dForm.value.p2_id,
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
</style>
