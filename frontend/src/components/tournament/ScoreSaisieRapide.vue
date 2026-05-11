<template>
  <Teleport to="body">
    <!-- Overlay sans fermeture au clic extérieur -->
    <div class="saisie-overlay">
      <div class="saisie-panel">

        <!-- Header -->
        <div class="saisie-header">
          <div>
            <h2 class="saisie-title">Saisie des scores</h2>
            <p class="saisie-sub">{{ pendingCount }} score(s) modifié(s) — {{ doneCount }}/{{ totalCount }} terminé(s)</p>
          </div>
          <div class="saisie-header-actions">
            <button @click="clearAll" class="btn text-xs gap-1" title="Remettre à zéro">
              <Trash2Icon class="w-3 h-3" /> Effacer
            </button>
            <button @click="saveAll" :disabled="saving || pendingCount === 0" class="btn-primary text-sm gap-1">
              <Loader2Icon v-if="saving" class="w-4 h-4 animate-spin" />
              <SaveIcon v-else class="w-4 h-4" />
              {{ saving ? 'Enregistrement…' : `Enregistrer (${pendingCount})` }}
            </button>
            <button @click="$emit('close')" class="btn-ghost p-2" title="Fermer">
              <XIcon class="w-5 h-5" />
            </button>
          </div>
        </div>

        <!-- Filtres -->
        <div class="saisie-filters">
          <div class="flex items-center gap-2">
            <SearchIcon class="w-4 h-4 text-gz-muted shrink-0" />
            <input v-model="search" class="input text-sm" placeholder="Filtrer par joueur…" style="max-width:200px" />
          </div>
          <label class="flex items-center gap-2 text-sm text-gz-muted cursor-pointer select-none">
            <input type="checkbox" v-model="onlyPending" class="w-4 h-4" />
            Non saisis seulement
          </label>
          <span class="text-xs text-gz-muted ml-auto hidden sm:inline">Tab pour naviguer</span>
        </div>

        <!-- Table -->
        <div class="saisie-scroll">
          <table class="saisie-table">
            <thead>
              <tr>
                <th class="col-joueur">Joueur A</th>
                <th class="col-score text-center" colspan="3">Aller</th>
                <th v-if="hasRetour" class="col-score text-center" colspan="3">Retour</th>
                <th class="col-joueur text-right">Joueur B</th>
                <th class="col-st text-center">
                  <CheckCircleIcon class="w-4 h-4 inline" />
                </th>
              </tr>
            </thead>
            <tbody>
              <template v-for="(row, i) in filteredRows" :key="row.aller?.id ?? i">
                <tr :class="rowClass(row)">
                  <!-- Joueur A -->
                  <td class="cell-name">
                    <span class="player-name">{{ row.nameA }}</span>
                  </td>

                  <!-- Aller -->
                  <td class="cell-inp">
                    <input
                      :value="getVal(row, row.aller, 's1')"
                      @input="e => setVal(row, row.aller, 's1', e.target.value)"
                      @focus="e => e.target.select()"
                      type="number" min="0" class="score-inp"
                      :placeholder="getPlaceholder(row, row.aller, 's1')"
                    />
                  </td>
                  <td class="cell-sep">–</td>
                  <td class="cell-inp">
                    <input
                      :value="getVal(row, row.aller, 's2')"
                      @input="e => setVal(row, row.aller, 's2', e.target.value)"
                      @focus="e => e.target.select()"
                      type="number" min="0" class="score-inp"
                      :placeholder="getPlaceholder(row, row.aller, 's2')"
                    />
                  </td>

                  <!-- Retour -->
                  <template v-if="hasRetour">
                    <td class="cell-inp">
                      <input
                        v-if="row.retour"
                        :value="getVal(row, row.retour, 's1')"
                        @input="e => setVal(row, row.retour, 's1', e.target.value)"
                        @focus="e => e.target.select()"
                        type="number" min="0" class="score-inp"
                        :placeholder="getPlaceholder(row, row.retour, 's1')"
                      />
                      <span v-else class="text-gz-muted text-xs">—</span>
                    </td>
                    <td class="cell-sep">–</td>
                    <td class="cell-inp">
                      <input
                        v-if="row.retour"
                        :value="getVal(row, row.retour, 's2')"
                        @input="e => setVal(row, row.retour, 's2', e.target.value)"
                        @focus="e => e.target.select()"
                        type="number" min="0" class="score-inp"
                        :placeholder="getPlaceholder(row, row.retour, 's2')"
                      />
                      <span v-else class="text-gz-muted text-xs">—</span>
                    </td>
                  </template>

                  <!-- Joueur B -->
                  <td class="cell-name text-right">
                    <span class="player-name">{{ row.nameB }}</span>
                  </td>

                  <!-- État -->
                  <td class="cell-st text-center">
                    <CheckCircleIcon v-if="isFullyDone(row)" class="w-4 h-4 inline text-gz-green" />
                    <MinusCircleIcon v-else-if="isPartiallyDone(row)" class="w-4 h-4 inline text-amber-400" />
                    <CircleIcon v-else class="w-4 h-4 inline text-gz-muted opacity-30" />
                  </td>
                </tr>
              </template>
            </tbody>
          </table>
        </div>

        <!-- Footer -->
        <div class="saisie-footer">
          <span class="text-xs text-gz-muted">{{ filteredRows.length }} confrontation(s) affichée(s)</span>
          <button @click="saveAll" :disabled="saving || pendingCount === 0" class="btn-primary text-sm gap-1">
            <SaveIcon class="w-4 h-4" />
            {{ saving ? 'Enregistrement…' : `Enregistrer ${pendingCount} score(s)` }}
          </button>
        </div>

      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { ref, computed, reactive, watch, onMounted } from 'vue'
import {
  XIcon, Trash2Icon, SaveIcon, Loader2Icon,
  SearchIcon, CheckCircleIcon, MinusCircleIcon, CircleIcon
} from 'lucide-vue-next'

const props = defineProps({
  pairRows:  { type: Array, default: () => [] },
  hasRetour: { type: Boolean, default: false },
  cacheKey:  { type: String, default: 'saisie-rapide-cache' },
})

const emit = defineEmits(['close', 'batch-save'])

const saving    = ref(false)
const search    = ref('')
const onlyPending = ref(false)

// scores[matchId] = { s1, s2 }
const scores = reactive(new Map())

function buildCacheKey() {
  return `gz.saisie.${props.cacheKey}`
}

function saveToCache() {
  try {
    const obj = {}
    for (const [id, s] of scores.entries()) obj[id] = s
    localStorage.setItem(buildCacheKey(), JSON.stringify(obj))
  } catch (_) {}
}

function loadFromCache() {
  try {
    const raw = localStorage.getItem(buildCacheKey())
    if (!raw) return null
    return JSON.parse(raw)
  } catch (_) { return null }
}

function clearCache() {
  try { localStorage.removeItem(buildCacheKey()) } catch (_) {}
}

onMounted(() => {
  // Pré-remplir depuis les scores existants
  props.pairRows.forEach(p => {
    if (p.aller?.id != null) {
      scores.set(p.aller.id, {
        s1: p.aller.score1 ?? '',
        s2: p.aller.score2 ?? '',
      })
    }
    if (p.retour?.id != null) {
      scores.set(p.retour.id, {
        s1: p.retour.score1 ?? '',
        s2: p.retour.score2 ?? '',
      })
    }
  })

  // Restaurer le cache localStorage par-dessus (priorité cache)
  const cached = loadFromCache()
  if (cached) {
    for (const [id, s] of Object.entries(cached)) {
      scores.set(Number(id), s)
    }
  }
})

// Sauvegarder en cache à chaque modification
watch(scores, saveToCache, { deep: true })

function isSwapped(row, match) {
  if (!match || !row.idA) return false
  return String(match.p1_id) !== String(row.idA)
}

function getVal(row, match, type) {
  if (!match) return ''
  const s = scores.get(match.id)
  if (!s) return ''
  const swapped = isSwapped(row, match)
  if (type === 's1') return swapped ? s.s2 : s.s1
  if (type === 's2') return swapped ? s.s1 : s.s2
  return ''
}

function setVal(row, match, type, raw) {
  if (!match) return
  const matchId = match.id
  const swapped = isSwapped(row, match)
  const cur = scores.get(matchId) || { s1: '', s2: '' }
  
  const val = raw === '' ? '' : Number(raw)
  if (type === 's1') {
    if (swapped) cur.s2 = val
    else cur.s1 = val
  } else {
    if (swapped) cur.s1 = val
    else cur.s2 = val
  }
  scores.set(matchId, { ...cur })
}

function getPlaceholder(row, match, type) {
  if (!match) return '—'
  const swapped = isSwapped(row, match)
  if (type === 's1') {
    const v = swapped ? match.score2 : match.score1
    return v ?? '—'
  } else {
    const v = swapped ? match.score1 : match.score2
    return v ?? '—'
  }
}

function clearAll() {
  props.pairRows.forEach(p => {
    if (p.aller?.id != null)  scores.set(p.aller.id,  { s1: '', s2: '' })
    if (p.retour?.id != null) scores.set(p.retour.id, { s1: '', s2: '' })
  })
  clearCache()
}

function isMatchComplete(matchId) {
  if (matchId == null) return false
  const s = scores.get(matchId)
  return s && s.s1 !== '' && s.s2 !== ''
}

function isFullyDone(row) {
  return isMatchComplete(row.aller?.id) && (!row.retour || isMatchComplete(row.retour?.id))
}

function isPartiallyDone(row) {
  const a = isMatchComplete(row.aller?.id)
  const r = !row.retour || isMatchComplete(row.retour?.id)
  return a !== r
}

function rowClass(row) {
  if (isFullyDone(row))    return 'row-done'
  if (isPartiallyDone(row)) return 'row-partial'
  return ''
}

const filteredRows = computed(() => {
  let rows = props.pairRows
  if (onlyPending.value) rows = rows.filter(r => !isFullyDone(r))
  if (search.value.trim()) {
    const q = search.value.toLowerCase()
    rows = rows.filter(r =>
      r.nameA.toLowerCase().includes(q) || r.nameB.toLowerCase().includes(q)
    )
  }
  return rows
})

const totalCount   = computed(() => props.pairRows.length)
const doneCount    = computed(() => props.pairRows.filter(r => isFullyDone(r)).length)
const pendingCount = computed(() => {
  let n = 0
  for (const [, s] of scores.entries()) {
    if (s.s1 !== '' && s.s2 !== '') n++
  }
  return n
})

async function saveAll() {
  if (saving.value) return
  const edits = []
  for (const [matchId, s] of scores.entries()) {
    if (s.s1 !== '' && s.s2 !== '') {
      edits.push({ matchId, score1: Number(s.s1), score2: Number(s.s2) })
    }
  }
  if (!edits.length) return
  saving.value = true
  emit('batch-save', {
    edits,
    done: () => { saving.value = false; clearCache() },
    fail: () => { saving.value = false },
  })
}
</script>

<style scoped>
.saisie-overlay {
  position: fixed;
  inset: 0;
  background: rgba(3, 8, 24, 0.82);
  z-index: 9999;
  display: flex;
  align-items: stretch;
  justify-content: center;
  padding: 0;
}

.saisie-panel {
  background: var(--panel);
  width: 100%;
  max-width: 900px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

@media (min-width: 640px) {
  .saisie-overlay { align-items: center; padding: 1rem; }
  .saisie-panel { border-radius: 16px; max-height: 95vh; }
}

.saisie-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding: 1rem 1.25rem;
  border-bottom: 1px solid rgba(148,163,184,.18);
  flex-wrap: wrap;
}

.saisie-header-actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.saisie-title {
  font-size: 1rem;
  font-weight: 700;
  color: var(--text);
  margin: 0;
}

.saisie-sub {
  font-size: 0.75rem;
  color: var(--muted);
  margin: 2px 0 0;
}

.saisie-filters {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.6rem 1.25rem;
  border-bottom: 1px solid rgba(148,163,184,.1);
  background: rgba(148,163,184,.04);
  flex-wrap: wrap;
}

.saisie-scroll {
  flex: 1;
  overflow-y: auto;
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.saisie-table {
  width: 100%;
  min-width: 480px;
  border-collapse: collapse;
  font-size: 0.85rem;
}

.saisie-table thead th {
  position: sticky;
  top: 0;
  background: var(--panel);
  z-index: 1;
  padding: 0.45rem 0.6rem;
  font-size: 0.68rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--muted);
  border-bottom: 1px solid rgba(148,163,184,.2);
  white-space: nowrap;
}

.saisie-table tbody tr {
  border-bottom: 1px solid rgba(148,163,184,.07);
  transition: background 0.1s;
}
.saisie-table tbody tr:hover { background: rgba(148,163,184,.04); }
.row-done    { background: rgba(34,197,94,.05) !important; }
.row-partial { background: rgba(251,191,36,.04) !important; }

.col-joueur { width: 30%; }
.col-score  { width: 10%; }
.col-st     { width: 44px; }

.cell-name {
  padding: 0.35rem 0.6rem;
  white-space: nowrap;
}
.player-name {
  font-weight: 600;
  color: var(--text);
  font-size: 0.83rem;
}
.cell-inp {
  padding: 0.2rem 0.15rem;
  text-align: center;
}
.cell-sep {
  padding: 0 0.1rem;
  color: var(--muted);
  font-size: 0.75rem;
  text-align: center;
  white-space: nowrap;
}
.cell-st { padding: 0.3rem 0.4rem; }

.score-inp {
  width: 52px;
  padding: 0.3rem 0.2rem;
  text-align: center;
  border: 1px solid rgba(148,163,184,.3);
  border-radius: 6px;
  background: var(--input);
  color: var(--text);
  font-size: 0.9rem;
  font-weight: 600;
  outline: none;
  transition: border-color 0.12s;
  -moz-appearance: textfield;
}
.score-inp::-webkit-outer-spin-button,
.score-inp::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }
.score-inp:focus {
  border-color: rgba(34,197,94,.7);
  background: rgba(34,197,94,.06);
}

.saisie-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.75rem 1.25rem;
  border-top: 1px solid rgba(148,163,184,.18);
  flex-wrap: wrap;
  gap: 0.5rem;
}

.animate-spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
</style>
