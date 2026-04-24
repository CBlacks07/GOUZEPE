<template>
  <div class="rr-layout bracket-lanes">

    <!-- MATCHS — tableau résultats -->
    <section class="rr-section">
      <div class="rr-head">
        <h3 class="rr-heading">Matchs</h3>
        <span class="text-xs text-gz-muted">{{ matches.length }} confrontation(s)</span>
      </div>

      <div v-if="pairRows.length" class="rr-results-shell">
        <table class="rr-results-table">
          <thead>
            <tr>
              <th class="col-vs">Confrontation</th>
              <th class="col-score text-center">Aller</th>
              <th v-if="hasRetour" class="col-score text-center">Retour</th>
              <th v-if="adminMode" class="col-act"></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(p, i) in pairRows" :key="i" :class="editingIdx === i && 'row-editing'">
              <!-- Confrontation -->
              <td class="cell-vs">
                <span class="vs-name">{{ p.nameA }}</span>
                <span class="vs-sep">vs</span>
                <span class="vs-name">{{ p.nameB }}</span>
              </td>

              <!-- Aller -->
              <td class="cell-score text-center">
                <template v-if="editingIdx === i">
                  <div class="score-edit">
                    <input v-model.number="editA.s1" type="number" min="0" class="score-inp"
                           @keydown.enter="saveEditingPair(p)" />
                    <span class="score-dash">–</span>
                    <input v-model.number="editA.s2" type="number" min="0" class="score-inp"
                           @keydown.enter="saveEditingPair(p)" />
                  </div>
                </template>
                <template v-else>
                  <span v-if="isDone(p.aller)" class="score-pill" :class="pillClass(p.aller)">
                    {{ p.aller.score1 }} – {{ p.aller.score2 }}
                  </span>
                  <span v-else class="score-pending">—</span>
                </template>
              </td>

              <!-- Retour -->
              <td v-if="hasRetour" class="cell-score text-center">
                <template v-if="editingIdx === i && p.retour">
                  <div class="score-edit">
                    <input v-model.number="editR.s1" type="number" min="0" class="score-inp"
                           @keydown.enter="saveEditingPair(p)" />
                    <span class="score-dash">–</span>
                    <input v-model.number="editR.s2" type="number" min="0" class="score-inp"
                           @keydown.enter="saveEditingPair(p)" />
                  </div>
                </template>
                <template v-else-if="p.retour">
                  <span v-if="isDone(p.retour)" class="score-pill" :class="pillClass(p.retour)">
                    {{ p.retour.score1 }} – {{ p.retour.score2 }}
                  </span>
                  <span v-else class="score-pending">—</span>
                </template>
                <span v-else class="score-pending">—</span>
              </td>

              <!-- Actions admin -->
              <td v-if="adminMode" class="cell-act text-center">
                <template v-if="editingIdx === i">
                  <button @click="saveEditingPair(p)" :disabled="saving"
                          class="btn-primary act-btn" title="Valider">
                    {{ saving ? '…' : '✓' }}
                  </button>
                  <button @click="editingIdx = -1" class="btn act-btn ml-1" title="Annuler">✕</button>
                </template>
                <button v-else-if="p.aller?.p1_id && p.aller?.p2_id"
                        @click="startEditPair(i, p)"
                        class="btn act-btn" title="Saisir les scores">
                  <PencilIcon class="w-3 h-3" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <p v-else-if="!matches.length" class="text-gz-muted text-sm py-4 text-center">Aucun match.</p>
    </section>

    <!-- TABLEAU DES CONFRONTATIONS -->
    <section v-if="crossPlayers.length >= 2" class="rr-section">
      <div class="rr-head">
        <h3 class="rr-heading">Confrontations</h3>
        <span class="text-xs text-gz-muted">ligne → colonne</span>
      </div>
      <div class="cross-shell">
        <table class="cross-table">
          <thead>
            <tr>
              <th class="cross-corner"></th>
              <th v-for="p in crossPlayers" :key="p.id" class="cross-col-head">
                {{ abbrev(p.name) }}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in crossPlayers" :key="row.id">
              <th class="cross-row-head">{{ abbrev(row.name) }}</th>
              <td
                v-for="col in crossPlayers"
                :key="col.id"
                class="cross-cell"
              >
                <span v-if="row.id === col.id" class="cross-self">—</span>
                <template v-else>
                  <div v-if="getResults(row.id, col.id).length" class="cross-results">
                    <template v-for="(r, ri) in getResults(row.id, col.id)" :key="ri">
                      <span class="cross-sep" v-if="ri > 0">·</span>
                      <span
                        class="cross-score"
                        :class="r.own > r.opp ? 'score-win' : r.own < r.opp ? 'score-loss' : 'score-draw'"
                      >{{ r.own }}–{{ r.opp }}</span>
                    </template>
                  </div>
                  <span v-else class="cross-pending">·</span>
                </template>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- CLASSEMENT -->
    <section class="rr-section" v-if="standings.length">
      <div class="rr-head">
        <h3 class="rr-heading">Classement</h3>
        <span class="text-xs text-gz-muted">Vue complète</span>
      </div>

      <div class="rr-standings-shell">
        <table class="data-table text-sm">
          <thead>
            <tr>
              <th class="w-8 text-center">#</th>
              <th>Joueur</th>
              <th class="text-center">J</th>
              <th class="text-center">V</th>
              <th v-if="showGoalColumns" class="text-center">N</th>
              <th v-if="showGoalColumns" class="text-center">D</th>
              <th v-if="showGoalColumns" class="text-center">BM</th>
              <th v-if="showGoalColumns" class="text-center">BC</th>
              <th v-if="showGoalColumns" class="text-center">Diff</th>
              <th class="text-center">{{ showGoalColumns ? 'Pts' : 'Score' }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(s, i) in standings" :key="s.participant_id || s.player_id || i">
              <td class="text-center text-gz-muted">{{ i + 1 }}</td>
              <td class="font-semibold">{{ s.name || s.player_id }}</td>
              <td class="text-center">{{ playedOf(s) }}</td>
              <td class="text-center text-gz-green">{{ winOf(s) }}</td>
              <td v-if="showGoalColumns" class="text-center text-gz-muted">{{ drawOf(s) }}</td>
              <td v-if="showGoalColumns" class="text-center text-gz-red">{{ lossOf(s) }}</td>
              <td v-if="showGoalColumns" class="text-center">{{ bfOf(s) }}</td>
              <td v-if="showGoalColumns" class="text-center">{{ bcOf(s) }}</td>
              <td v-if="showGoalColumns" class="text-center" :class="diffOf(s) > 0 ? 'text-gz-green' : diffOf(s) < 0 ? 'text-gz-red' : 'text-gz-muted'">
                {{ diffOf(s) > 0 ? '+' : '' }}{{ diffOf(s) }}
              </td>
              <td class="text-center font-bold">{{ ptsOf(s) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { PencilIcon } from 'lucide-vue-next'

const props = defineProps({
  matches: { type: Array, default: () => [] },
  standings: { type: Array, default: () => [] },
  standingsMode: { type: String, default: 'goals' },
  adminMode: { type: Boolean, default: false },
})

const emit = defineEmits(['score-saved'])

const showGoalColumns = computed(() => String(props.standingsMode || 'goals') !== 'wins')

/* ---- Editing state ---- */
const editingIdx = ref(-1)
const editA = ref({ s1: 0, s2: 0 })
const editR = ref({ s1: 0, s2: 0 })
const saving = ref(false)

/* ---- Pair grouping ---- */
const matchPairs = computed(() => {
  const pairs = new Map()
  for (const m of props.matches) {
    const p1 = String(m.p1_id ?? m.p1_participant_id ?? '')
    const p2 = String(m.p2_id ?? m.p2_participant_id ?? '')
    const key = p1 && p2 ? [p1, p2].sort().join('||') : `solo-${m.id}`
    if (!pairs.has(key)) pairs.set(key, [])
    pairs.get(key).push(m)
  }
  return [...pairs.values()]
    .map((pair) => pair.slice().sort((a, b) => (a.round_no ?? 0) - (b.round_no ?? 0)))
    .sort((a, b) => (a[0]?.id ?? 0) - (b[0]?.id ?? 0))
})

const pairRows = computed(() =>
  matchPairs.value.map((pair) => {
    const aller = pair[0] || null
    const retour = pair[1] || null
    return {
      nameA: aller?.p1_name || aller?.p1_id || 'TBD',
      nameB: aller?.p2_name || aller?.p2_id || 'TBD',
      aller,
      retour,
    }
  })
)

const hasRetour = computed(() => pairRows.value.some((p) => p.retour !== null))

/* ---- Score helpers ---- */
function isDone(m) {
  return m && (m.status === 'done' || m.status === 'completed')
}

function pillClass(m) {
  if (!m) return ''
  const s1 = +(m.score1 ?? 0)
  const s2 = +(m.score2 ?? 0)
  if (s1 > s2) return 'pill-win'
  if (s1 < s2) return 'pill-loss'
  return 'pill-draw'
}

/* ---- Edit / Save ---- */
function startEditPair(idx, pair) {
  editingIdx.value = idx
  editA.value = { s1: pair.aller?.score1 ?? 0, s2: pair.aller?.score2 ?? 0 }
  editR.value = { s1: pair.retour?.score1 ?? 0, s2: pair.retour?.score2 ?? 0 }
}

function saveMatch(matchId, s1, s2) {
  return new Promise((resolve, reject) => {
    emit('score-saved', {
      matchId,
      score1: s1,
      score2: s2,
      done: resolve,
      fail: () => reject(new Error('save failed')),
    })
  })
}

async function saveEditingPair(pair) {
  saving.value = true
  try {
    if (pair.aller?.id) await saveMatch(pair.aller.id, editA.value.s1, editA.value.s2)
    if (pair.retour?.id) await saveMatch(pair.retour.id, editR.value.s1, editR.value.s2)
    editingIdx.value = -1
  } catch (_) { /* toast is handled by parent */ }
  saving.value = false
}

/* ---- Cross-table ---- */
const crossPlayers = computed(() => {
  if (props.standings.length) {
    return props.standings.map((s) => ({
      id: String(s.participant_id ?? s.player_id ?? ''),
      name: s.name ?? String(s.player_id ?? ''),
    }))
  }
  const seen = new Map()
  for (const m of props.matches) {
    const id1 = m.p1_id ?? m.p1_participant_id
    const id2 = m.p2_id ?? m.p2_participant_id
    if (id1 && !seen.has(String(id1))) seen.set(String(id1), m.p1_name ?? String(id1))
    if (id2 && !seen.has(String(id2))) seen.set(String(id2), m.p2_name ?? String(id2))
  }
  return [...seen.entries()].map(([id, name]) => ({ id, name }))
})

const resultMatrix = computed(() => {
  const matrix = {}
  for (const m of props.matches) {
    const p1 = m.p1_id ?? m.p1_participant_id
    const p2 = m.p2_id ?? m.p2_participant_id
    const s1 = m.score1 ?? m.score_p1
    const s2 = m.score2 ?? m.score_p2
    if (!p1 || !p2 || s1 === null || s1 === undefined || s1 === '' || s2 === null || s2 === undefined || s2 === '') continue
    const n1 = Number(s1)
    const n2 = Number(s2)
    if (!Number.isFinite(n1) || !Number.isFinite(n2)) continue
    const id1 = String(p1)
    const id2 = String(p2)
    if (!matrix[id1]) matrix[id1] = {}
    if (!matrix[id2]) matrix[id2] = {}
    if (!matrix[id1][id2]) matrix[id1][id2] = []
    if (!matrix[id2][id1]) matrix[id2][id1] = []
    matrix[id1][id2].push({ own: n1, opp: n2 })
    matrix[id2][id1].push({ own: n2, opp: n1 })
  }
  return matrix
})

function getResults(rowId, colId) {
  return resultMatrix.value[String(rowId)]?.[String(colId)] ?? []
}

function abbrev(name) {
  if (!name) return '?'
  const s = String(name)
  return s.length > 7 ? s.slice(0, 6) + '…' : s
}

/* ---- Standings helpers ---- */
function toInt(v) {
  const n = Number(v)
  return Number.isFinite(n) ? n : 0
}
function winOf(s)  { return toInt(s.w ?? s.wins) }
function drawOf(s) { return toInt(s.d ?? s.draws) }
function lossOf(s) { return toInt(s.l ?? s.losses) }
function bfOf(s)   { return toInt(s.bf ?? s.goals_for) }
function bcOf(s)   { return toInt(s.bc ?? s.goals_against) }

function diffOf(s) {
  const explicit = s.diff
  if (explicit !== undefined && explicit !== null && explicit !== '') return toInt(explicit)
  return bfOf(s) - bcOf(s)
}
function ptsOf(s) { return toInt(s.pts ?? s.points) }
function playedOf(s) {
  const explicit = s.played
  if (explicit !== undefined && explicit !== null && explicit !== '') return toInt(explicit)
  return winOf(s) + drawOf(s) + lossOf(s)
}
</script>

<style scoped>
.rr-layout {
  display: grid;
  gap: 1rem;
}

/* ---- Section wrapper commun ---- */
.rr-section {
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 12px;
  background: color-mix(in srgb, var(--panel) 86%, transparent);
  padding: 0.75rem;
}

.rr-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.5rem;
  margin-bottom: 0.65rem;
}

.rr-heading {
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--muted);
}

/* ======== Tableau résultats RR ======== */
.rr-results-shell {
  border: 1px solid rgba(148, 163, 184, 0.18);
  border-radius: 10px;
  overflow-x: auto;
  overflow-y: auto;
  max-height: 420px;
  background: color-mix(in srgb, var(--card) 90%, transparent);
}

.rr-results-table {
  border-collapse: collapse;
  font-size: 0.82rem;
}

.rr-results-table thead th {
  padding: 0.4rem 0.5rem;
  font-size: 0.68rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--muted);
  border-bottom: 1px solid rgba(148, 163, 184, 0.18);
  white-space: nowrap;
  position: sticky;
  top: 0;
  background: color-mix(in srgb, var(--card) 98%, transparent);
  z-index: 1;
}

.rr-results-table tbody tr {
  transition: background 0.12s;
}

.rr-results-table tbody tr:not(:last-child) {
  border-bottom: 1px solid rgba(148, 163, 184, 0.08);
}

.rr-results-table tbody tr:hover {
  background: rgba(148, 163, 184, 0.05);
}

.row-editing {
  background: rgba(34, 197, 94, 0.06) !important;
}

.col-vs { width: auto; white-space: nowrap; }
.col-score { width: 80px; }
.col-act { width: 50px; }

.cell-vs {
  padding: 0.35rem 0.5rem;
  white-space: nowrap;
}

.vs-name {
  font-weight: 600;
  font-size: 0.82rem;
  color: var(--text);
}

.vs-sep {
  font-size: 0.68rem;
  color: var(--muted);
  margin: 0 0.35rem;
}

.cell-score {
  padding: 0.3rem 0.25rem;
  white-space: nowrap;
}

.cell-act {
  padding: 0.3rem 0.2rem;
}

/* Score pill (read-only) */
.score-pill {
  display: inline-block;
  font-weight: 700;
  font-size: 0.8rem;
  padding: 0.15rem 0.55rem;
  border-radius: 6px;
  letter-spacing: 0.02em;
  font-variant-numeric: tabular-nums;
}

.pill-win {
  background: color-mix(in srgb, #16a34a 18%, transparent);
  color: #4ade80;
}

.pill-loss {
  background: color-mix(in srgb, #ef4444 14%, transparent);
  color: #f87171;
}

.pill-draw {
  background: color-mix(in srgb, var(--muted) 12%, transparent);
  color: var(--muted);
}

.score-pending {
  color: var(--muted);
  opacity: 0.4;
  font-size: 0.8rem;
}

/* Score edit (inline inputs) */
.score-edit {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
}

.score-inp {
  width: 2.2rem;
  padding: 0.15rem 0.2rem;
  text-align: center;
  font-size: 0.8rem;
  font-weight: 700;
  border: 1px solid rgba(34, 197, 94, 0.4);
  border-radius: 6px;
  background: rgba(34, 197, 94, 0.08);
  color: var(--text);
  appearance: textfield;
  -moz-appearance: textfield;
}

.score-inp::-webkit-outer-spin-button,
.score-inp::-webkit-inner-spin-button {
  -webkit-appearance: none;
  margin: 0;
}

.score-dash {
  font-size: 0.75rem;
  color: var(--muted);
}

.act-btn {
  padding: 0.2rem 0.5rem !important;
  font-size: 0.7rem !important;
  line-height: 1.2;
}

/* ---- Cross-table ---- */
.cross-shell {
  overflow-x: auto;
  border: 1px solid rgba(148, 163, 184, 0.18);
  border-radius: 10px;
  background: color-mix(in srgb, var(--card) 88%, transparent);
}

.cross-table {
  border-collapse: collapse;
  font-size: 0.7rem;
  width: 100%;
}

.cross-corner {
  min-width: 84px;
  background: transparent;
}

.cross-col-head {
  padding: 0.28rem 0.5rem;
  text-align: center;
  font-weight: 600;
  font-size: 0.64rem;
  color: var(--muted);
  min-width: 68px;
  white-space: nowrap;
  border-bottom: 1px solid rgba(148, 163, 184, 0.14);
  background: color-mix(in srgb, var(--panel) 50%, transparent);
}

.cross-row-head {
  padding: 0.28rem 0.55rem;
  text-align: left;
  font-weight: 600;
  font-size: 0.68rem;
  color: var(--text);
  white-space: nowrap;
  border-right: 1px solid rgba(148, 163, 184, 0.14);
  background: color-mix(in srgb, var(--panel) 50%, transparent);
}

.cross-cell {
  padding: 0.22rem 0.3rem;
  text-align: center;
  vertical-align: middle;
  border: 1px solid rgba(148, 163, 184, 0.07);
}

.cross-self {
  color: var(--muted);
  opacity: 0.3;
  font-size: 0.75rem;
}

.cross-pending {
  color: var(--muted);
  opacity: 0.3;
  font-size: 0.9rem;
}

.cross-results {
  display: inline-flex;
  align-items: center;
  gap: 0.18rem;
  border: 1px solid rgba(148, 163, 184, 0.16);
  border-radius: 6px;
  padding: 0.1rem 0.28rem;
  background: color-mix(in srgb, var(--card) 70%, transparent);
}

.cross-sep {
  color: var(--muted);
  opacity: 0.4;
  font-size: 0.6rem;
  line-height: 1;
}

.cross-score {
  font-size: 0.65rem;
  font-weight: 700;
  white-space: nowrap;
  letter-spacing: 0.01em;
}

.score-win {
  background: color-mix(in srgb, #16a34a 20%, transparent);
  color: #4ade80;
}

.score-loss {
  background: color-mix(in srgb, #ef4444 16%, transparent);
  color: #f87171;
}

.score-draw {
  background: color-mix(in srgb, var(--muted) 14%, transparent);
  color: var(--muted);
}

/* ---- Classement ---- */
.rr-standings-shell {
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 10px;
  overflow: auto;
  background: color-mix(in srgb, var(--card) 88%, transparent);
}

.rr-standings-shell :deep(.data-table thead th) { white-space: nowrap; }
.rr-standings-shell :deep(.data-table tbody td) { white-space: nowrap; }

.rr-standings-shell :deep(.data-table) {
  table-layout: fixed;
  min-width: 640px;
}

.rr-standings-shell :deep(.data-table th:first-child),
.rr-standings-shell :deep(.data-table td:first-child) {
  width: 44px;
  text-align: center;
}

.rr-standings-shell :deep(.data-table th:nth-child(2)),
.rr-standings-shell :deep(.data-table td:nth-child(2)) {
  width: 200px;
}

.rr-standings-shell :deep(.data-table th:nth-child(n + 3)),
.rr-standings-shell :deep(.data-table td:nth-child(n + 3)) {
  width: 72px;
  text-align: center;
}

/* ---- Responsive ---- */
@media (max-width: 600px) {
  .col-vs { min-width: 140px; }
  .vs-name { font-size: 0.76rem; }
  .score-pill { font-size: 0.74rem; padding: 0.12rem 0.4rem; }
}
</style>
