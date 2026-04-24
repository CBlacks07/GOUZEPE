<template>
  <AppLayout season-label="Duels">
    <div class="page-wrap duel-wrap">
      <div class="grid grid-cols-1 xl:grid-cols-2 gap-4 md:gap-6">

        <!-- ── Nouveau duel ── -->
        <section class="card reveal">
          <h2 class="font-semibold text-gz-text flex items-center gap-2 mb-4">
            <SwordsIcon class="w-4 h-4 text-gz-muted" /> Nouveau duel (exhibition)
          </h2>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-4">
            <div>
              <label class="label">Joueur A</label>
              <select v-model="form.p1" class="input">
                <option value="">Choisir…</option>
                <option v-for="p in players" :key="p.player_id" :value="p.player_id">
                  {{ p.name || p.player_id }}
                </option>
              </select>
            </div>
            <div>
              <label class="label">Joueur B</label>
              <select v-model="form.p2" class="input">
                <option value="">Choisir…</option>
                <option v-for="p in players" :key="p.player_id" :value="p.player_id">
                  {{ p.name || p.player_id }}
                </option>
              </select>
            </div>
          </div>

          <!-- Résultat pills -->
          <div class="mb-4">
            <label class="label mb-2">Résultat</label>
            <div class="flex gap-2 flex-wrap">
              <button v-for="opt in resultOptions" :key="opt.v"
                @click="form.result = opt.v"
                :class="['px-4 py-2 rounded-full border text-sm font-bold transition-all',
                         form.result === opt.v ? opt.activeClass : 'border-gz-border bg-gz-card text-gz-text hover:border-gz-border/80']"
                :aria-pressed="form.result === opt.v">
                {{ opt.label }}
              </button>
            </div>
            <p class="text-xs text-gz-muted mt-2">L'historique retient uniquement V/N/D (pas de score).</p>
          </div>

          <div class="flex gap-3 flex-col sm:flex-row sm:items-end mb-3">
            <div class="flex-1 min-w-[180px]">
              <label class="label">Date &amp; heure (facultatif)</label>
              <input v-model="form.date" type="datetime-local" class="input" />
            </div>
            <button @click="saveDuel" :disabled="saving" class="btn-primary w-full sm:w-auto justify-center">
              <Loader2Icon v-if="saving" class="w-3.5 h-3.5 animate-spin" />
              Enregistrer le duel
            </button>
          </div>

          <p v-if="saveMsg" :class="['text-sm', saveMsgOk ? 'text-gz-green' : 'text-gz-red']">
            {{ saveMsg }}
          </p>
        </section>

        <!-- ── Face-à-face ── -->
        <section class="card reveal delay-1">
          <h2 class="font-semibold text-gz-text flex items-center gap-2 mb-4">
            <UsersIcon class="w-4 h-4 text-gz-muted" /> Face-à-face
          </h2>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-3">
            <div>
              <label class="label">Joueur A</label>
              <select v-model="cmp.a" class="input">
                <option value="">Choisir…</option>
                <option v-for="p in players" :key="p.player_id" :value="p.player_id">{{ p.name || p.player_id }}</option>
              </select>
            </div>
            <div>
              <label class="label">Joueur B</label>
              <select v-model="cmp.b" class="input">
                <option value="">Choisir…</option>
                <option v-for="p in players" :key="p.player_id" :value="p.player_id">{{ p.name || p.player_id }}</option>
              </select>
            </div>
          </div>
          <div class="cmp-filters mb-4">
            <div class="flex-1 min-w-[110px]">
              <label class="label">Depuis</label>
              <input v-model="cmp.from" type="date" class="input" />
            </div>
            <div class="flex-1 min-w-[110px]">
              <label class="label">Jusqu'au</label>
              <input v-model="cmp.to" type="date" class="input" />
            </div>
            <button @click="compare" class="btn w-full sm:w-auto justify-center">Comparer</button>
          </div>

          <div v-if="cmpResult" class="flex items-center justify-between gap-3 flex-wrap
                                        px-4 py-3 bg-gz-panel border border-gz-border rounded-xl">
            <div class="text-sm">
              <strong>{{ cmpResult.nameA }}</strong>
              <span class="text-gz-muted mx-2 text-xs">vs</span>
              <strong>{{ cmpResult.nameB }}</strong>
              <span class="text-gz-muted text-xs ml-2">{{ cmpResult.legs }} match(s)</span>
            </div>
            <span :class="['badge text-sm font-bold', leaderClass(cmpResult)]">
              {{ leaderLabel(cmpResult) }} &bull; {{ cmpResult.wins }}V-{{ cmpResult.draws }}N-{{ cmpResult.losses }}D
            </span>
          </div>
          <p v-else-if="cmpResult === null" class="text-gz-muted text-sm">Choisis deux joueurs.</p>
        </section>

        <!-- ── Historique ── -->
        <section class="card xl:col-span-2 reveal delay-2">
          <div class="flex flex-wrap items-start justify-between gap-3 mb-4">
            <h2 class="font-semibold text-gz-text flex items-center gap-2">
              <ClockIcon class="w-4 h-4 text-gz-muted" /> Historique des duels
            </h2>
            <div class="duel-filters text-sm">
              <select v-model="hist.period" @change="onPeriodChange" class="input duel-filter-control py-1.5 text-xs">
                <option value="all">Toujours</option>
                <option value="today">Aujourd'hui</option>
                <option value="week">7 jours</option>
                <option value="month">30 jours</option>
              </select>
              <input v-model="hist.from" type="date" class="input duel-filter-control py-1.5 text-xs" />
              <input v-model="hist.to" type="date" class="input duel-filter-control py-1.5 text-xs" />
              <select v-model="hist.player" class="input duel-filter-control py-1.5 text-xs">
                <option value="">Tous les joueurs</option>
                <option v-for="p in players" :key="p.player_id" :value="p.player_id">{{ p.name || p.player_id }}</option>
              </select>
              <select v-model="hist.limit" class="input duel-limit-control py-1.5 text-xs">
                <option value="5">5</option>
                <option value="10">10</option>
                <option value="20">20</option>
                <option value="50">50</option>
              </select>
              <button @click="loadHistory" class="btn duel-filter-action py-1.5 text-xs justify-center">
                <RefreshCwIcon class="w-3 h-3" /> Rafraîchir
              </button>
              <a :href="csvUrl" class="btn duel-filter-action py-1.5 text-xs justify-center">CSV</a>
              <a :href="pdfUrl" target="_blank" rel="noopener" class="btn duel-filter-action py-1.5 text-xs justify-center">PDF</a>
            </div>
          </div>

          <div class="overflow-x-auto table-shell">
            <table class="data-table">
              <thead>
                <tr>
                  <th>Date</th>
                  <th>Joueur A</th>
                  <th>Résultat</th>
                  <th>Joueur B</th>
                  <th>Leader</th>
                  <th v-if="auth.isAdmin">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="loadingHist">
                  <td :colspan="historyColspan" class="text-center text-gz-muted py-6">Chargement…</td>
                </tr>
                <tr v-else-if="!duels.length">
                  <td :colspan="historyColspan" class="text-center text-gz-muted py-6">Aucun duel.</td>
                </tr>
                <tr v-for="d in duels" :key="d.id" v-else>
                  <td class="text-gz-muted text-xs whitespace-nowrap">
                    {{ fmtDate(d.played_at) }}
                  </td>
                  <td class="font-medium">{{ d.p1_name || d.p1_id }}</td>
                  <td>
                    <span :class="['badge', resultClass(d)]">{{ resultLabel(d) }}</span>
                  </td>
                  <td class="font-medium">{{ d.p2_name || d.p2_id }}</td>
                  <td class="font-semibold">{{ leaderName(d) }}</td>
                  <td v-if="auth.isAdmin">
                    <button @click="deleteDuel(d.id)"
                            class="text-xs text-gz-red hover:text-gz-red/70 transition-colors">
                      Supprimer
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>

      </div>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import AppLayout from '@/components/layout/AppLayout.vue'
import { useAuthStore } from '@/stores/auth'
import { useAPI } from '@/composables/useAPI'
import { useToast } from '@/composables/useToast'
import { SwordsIcon, UsersIcon, ClockIcon, RefreshCwIcon, Loader2Icon } from 'lucide-vue-next'

const auth = useAuthStore()
const api  = useAPI()
const { success, error: toastError } = useToast()

// ── State ──────────────────────────────────────────────────────
const players = ref([])
const myPid   = ref(null)
const myRole  = ref('member')

const form  = ref({ p1: '', p2: '', result: null, date: nowLocal() })
const saving   = ref(false)
const saveMsg  = ref('')
const saveMsgOk = ref(true)

const cmp       = ref({ a: '', b: '', from: '', to: '' })
const cmpResult = ref(undefined)

const hist = ref({ period: 'all', from: '', to: '', player: '', limit: '10' })
const duels       = ref([])
const loadingHist = ref(false)
const historyColspan = computed(() => (auth.isAdmin ? 6 : 5))

const resultOptions = [
  { v: 'A', label: 'A gagne', activeClass: 'border-gz-green/60 bg-gz-green/15 text-[var(--green-l)]' },
  { v: 'D', label: 'Nul',     activeClass: 'border-gz-border bg-gz-border/30 text-gz-text' },
  { v: 'B', label: 'B gagne', activeClass: 'border-gz-blue/60 bg-gz-blue/15 text-[var(--blue-l)]' },
]

// ── Computed ───────────────────────────────────────────────────
const apiBase = computed(() => {
  const stored = localStorage.getItem('efoot.api')
  return stored || ('http://' + location.hostname + ':3005')
})

const csvUrl = computed(() => {
  const qs = histParams()
  return apiBase.value + '/duels/export.csv?' + qs.toString()
})
const pdfUrl = computed(() => {
  const qs = histParams()
  return apiBase.value + '/duels/export.html?' + qs.toString()
})

// ── Lifecycle ──────────────────────────────────────────────────
onMounted(async () => {
  await Promise.all([loadPlayers(), loadMe(), loadHistory()])
})

async function loadMe() {
  try {
    const { data } = await api.get('/auth/me')
    myRole.value = (data.user?.role || 'member').toLowerCase()
    myPid.value  = data.user?.player_id || null
  } catch (_) {}
}

async function loadPlayers() {
  try {
    const { data } = await api.get('/players')
    players.value = (data.players || []).sort((a, b) =>
      (a.name || a.player_id).localeCompare(b.name || b.player_id, 'fr'))
  } catch (_) {}
}

// ── Duel save ──────────────────────────────────────────────────
async function saveDuel() {
  saveMsg.value = ''
  const { p1, p2, result, date } = form.value
  if (!p1 || !p2) { saveMsg.value = 'Sélectionne les deux joueurs.'; saveMsgOk.value = false; return }
  if (p1 === p2)  { saveMsg.value = 'Choisis deux joueurs différents.'; saveMsgOk.value = false; return }
  if (!result)    { saveMsg.value = 'Choisis le résultat.'; saveMsgOk.value = false; return }
  if (myRole.value !== 'admin') {
    if (!myPid.value) { saveMsg.value = "Compte non lié à un player_id."; saveMsgOk.value = false; return }
    if (p1 !== myPid.value && p2 !== myPid.value) {
      saveMsg.value = "Vous ne pouvez enregistrer qu'un duel auquel vous participez."
      saveMsgOk.value = false; return
    }
  }
  saving.value = true
  try {
    const body = {
      p1, p2,
      score_a: result === 'A' ? 1 : 0,
      score_b: result === 'B' ? 1 : 0,
    }
    if (date) body.played_at = new Date(date).toISOString()
    await api.post('/duels', body)
    saveMsg.value = 'Duel enregistré ✓'; saveMsgOk.value = true
    form.value.result = null; form.value.date = nowLocal()
    await loadHistory()
  } catch (e) {
    saveMsg.value = e.response?.data?.error || 'Erreur'
    saveMsgOk.value = false
  } finally {
    saving.value = false
  }
}

// ── Compare ────────────────────────────────────────────────────
async function compare() {
  const { a, b, from, to } = cmp.value
  if (!a || !b) { cmpResult.value = null; return }
  const qs = new URLSearchParams({ p1: a, p2: b })
  if (from) qs.set('from', from)
  if (to)   qs.set('to', to)
  try {
    const { data } = await api.get('/duels/compare?' + qs.toString())
    const t = data.totals || {}
    const nameMap = Object.fromEntries(players.value.map(p => [p.player_id, p.name || p.player_id]))
    cmpResult.value = {
      nameA: data.p1?.name || nameMap[a] || a,
      nameB: data.p2?.name || nameMap[b] || b,
      wins: t.wins || 0, draws: t.draws || 0, losses: t.losses || 0, legs: t.legs || 0
    }
  } catch (_) { cmpResult.value = null }
}

// ── History ────────────────────────────────────────────────────
function histParams() {
  const qs = new URLSearchParams({ limit: hist.value.limit })
  if (hist.value.player) qs.set('player', hist.value.player)
  const { from, to } = periodRange()
  if (from) qs.set('from', from)
  if (to)   qs.set('to', to)
  return qs
}

async function loadHistory() {
  loadingHist.value = true
  try {
    const { data } = await api.get('/duels/recent?' + histParams().toString())
    duels.value = data.duels || []
  } catch (_) { duels.value = [] }
  finally { loadingHist.value = false }
}

async function deleteDuel(id) {
  if (!confirm('Supprimer ce duel ?')) return
  try {
    await api.delete('/duels/' + id)
    success('Duel supprimé')
    await loadHistory()
  } catch (e) { toastError(e.response?.data?.error || 'Erreur') }
}

function onPeriodChange() {
  const r = periodRange()
  hist.value.from = r.from; hist.value.to = r.to
  loadHistory()
}

function periodRange() {
  const v = hist.value.period
  const d = new Date()
  const iso = x => x.toISOString().slice(0, 10)
  if (v === 'today') return { from: iso(d), to: iso(d) }
  if (v === 'week')  { const a = new Date(); a.setDate(d.getDate() - 6); return { from: iso(a), to: iso(d) } }
  if (v === 'month') { const a = new Date(); a.setDate(d.getDate() - 29); return { from: iso(a), to: iso(d) } }
  return { from: hist.value.from, to: hist.value.to }
}

// ── Helpers display ────────────────────────────────────────────
function nowLocal() {
  const d = new Date(); d.setSeconds(0, 0)
  const p = n => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${p(d.getMonth()+1)}-${p(d.getDate())}T${p(d.getHours())}:${p(d.getMinutes())}`
}
function fmtDate(s) {
  return new Date(s).toLocaleString('fr-FR', { dateStyle: 'short', timeStyle: 'short' })
}
function resultLabel(d) {
  const a = +d.score_a, b = +d.score_b
  return a > b ? 'A gagne' : a < b ? 'B gagne' : 'Nul'
}
function resultClass(d) {
  const a = +d.score_a, b = +d.score_b
  return a > b ? 'badge-green' : a < b ? 'badge-blue' : 'badge-muted'
}
function leaderName(d) {
  const a = +d.score_a, b = +d.score_b
  return a > b ? (d.p1_name || d.p1_id) : a < b ? (d.p2_name || d.p2_id) : 'Égalité'
}
function leaderClass(r) {
  return r.wins > r.losses ? 'badge-green' : r.losses > r.wins ? 'badge-blue' : 'badge-muted'
}
function leaderLabel(r) {
  return r.wins > r.losses ? 'Leader A' : r.losses > r.wins ? 'Leader B' : 'Égalité'
}
</script>

<style scoped>
.duel-wrap {
  width: 100%;
}

.duel-wrap :deep(.card) {
  transition: transform 180ms ease, box-shadow 180ms ease, border-color 180ms ease;
}

.duel-wrap :deep(.card:hover) {
  transform: translateY(-1px);
  box-shadow: 0 12px 26px rgba(2, 6, 23, 0.2);
  border-color: color-mix(in srgb, var(--border) 68%, var(--blue) 32%);
}

.table-shell {
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 12px;
  background: color-mix(in srgb, var(--card) 92%, transparent);
}

.table-shell :deep(.data-table thead th) {
  border-bottom: 1px solid rgba(148, 163, 184, 0.24);
}

.table-shell :deep(.data-table tbody td) {
  border-bottom: 1px solid rgba(148, 163, 184, 0.12);
}

.table-shell :deep(.data-table tbody tr:last-child td) {
  border-bottom: none;
}

.cmp-filters {
  display: grid;
  gap: 0.75rem;
  grid-template-columns: 1fr;
  align-items: end;
}

.duel-filters {
  width: 100%;
  display: grid;
  gap: 0.5rem;
  grid-template-columns: 1fr;
}

.duel-filter-control,
.duel-filter-action {
  width: 100%;
}

.duel-limit-control {
  width: 100%;
}

.reveal {
  animation: rise-in 420ms ease both;
}

.delay-1 {
  animation-delay: 80ms;
}

.delay-2 {
  animation-delay: 150ms;
}

@keyframes rise-in {
  from {
    opacity: 0;
    transform: translateY(8px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@media (min-width: 1024px) {
  .duel-wrap {
    max-width: none;
    padding: clamp(14px, 2.1vw, 30px);
  }
}

@media (min-width: 640px) {
  .cmp-filters {
    grid-template-columns: 1fr 1fr auto;
  }

  .duel-filters {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .duel-limit-control {
    width: 5.25rem;
  }
}

@media (min-width: 1280px) {
  .duel-filters {
    width: auto;
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    justify-content: flex-end;
    gap: 0.5rem;
  }

  .duel-filter-control {
    width: 9rem;
  }

  .duel-filter-action {
    width: auto;
  }
}

@media (prefers-reduced-motion: reduce) {
  .reveal {
    animation: none !important;
  }

  .duel-wrap :deep(.card) {
    transition: none !important;
  }
}
</style>
