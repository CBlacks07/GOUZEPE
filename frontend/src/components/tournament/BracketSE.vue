<template>
  <div class="bracket-lanes se-lanes">
    <div v-if="!rounds.length" class="text-gz-muted text-sm py-8 text-center">Aucun match.</div>

    <div v-else ref="laneEl" class="lane-scroll">
      <svg
        class="bracket-svg"
        :width="svgWidth"
        :height="svgHeight"
        :viewBox="`0 0 ${svgWidth} ${svgHeight}`"
        preserveAspectRatio="none"
        aria-hidden="true"
      >
        <path
          v-for="(pathD, idx) in bracketPaths"
          :key="`se-branch-${idx}`"
          :d="pathD"
          class="branch-path"
        />
      </svg>

      <div
        v-for="(round, roundIndex) in rounds"
        :key="round.no"
        :class="['round-col', round.isFinalRound && 'round-col--final']"
      >
        <div class="round-title">
          <span class="round-title-label">{{ round.label }}</span>
          <span class="round-title-count">{{ round.matches.length }}</span>
        </div>
        <div
          v-for="(match, matchIndex) in round.matches"
          :key="match.id"
          class="match-slot"
          :ref="(el) => setSlotRef(el, match.id)"
          :style="{ marginTop: `${match.offset || 0}px` }"
        >
          <MatchCard
            :match="match"
            :admin-mode="adminMode"
            :is-final="!!match._isFinal"
            density="bracket"
            @score-saved="$emit('score-saved', $event)"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import MatchCard from './MatchCard.vue'

const props = defineProps({
  matches: { type: Array, default: () => [] },
  adminMode: { type: Boolean, default: false },
  persistKey: { type: String, default: '' },
})

defineEmits(['score-saved'])

function hasScoreValue(v) {
  return v !== null && v !== undefined && v !== ''
}

function isDisplayableMatch(m) {
  const p1 = m?.p1_id ?? m?.p1_participant_id ?? null
  const p2 = m?.p2_id ?? m?.p2_participant_id ?? null
  const winner = m?.winner_id ?? m?.winner_participant_id ?? null
  const status = String(m?.status || '').toLowerCase()
  const score1 = m?.score1 ?? m?.score_p1
  const score2 = m?.score2 ?? m?.score_p2
  return !!(p1 || p2 || winner || status === 'completed' || hasScoreValue(score1) || hasScoreValue(score2))
}

const rounds = computed(() => {
  const byRound = {}
  for (const m of props.matches) {
    if (!isDisplayableMatch(m)) continue
    if (!byRound[m.round_no]) byRound[m.round_no] = []
    byRound[m.round_no].push(m)
  }

  const roundNos = Object.keys(byRound)
    .map(Number)
    .sort((a, b) => a - b)
  const totalRounds = roundNos.length

  // Gap CSS entre les cartes dans une colonne (0.48rem ≈ 8px)
  const CARD_G = 8
  const unit = measuredCardH.value + CARD_G

  return roundNos.map((no, idx) => {
    const label =
      idx === totalRounds - 1
        ? 'Finale'
        : idx === totalRounds - 2
          ? 'Demi-finales'
          : idx === totalRounds - 3
            ? 'Quarts'
            : `Tour ${no}`

    const multiplier = Math.pow(2, idx) // 1, 2, 4, 8…
    const sortedMatches = byRound[no].sort((a, b) => (a.slot_no || 0) - (b.slot_no || 0))
    const isFinalRound = idx === totalRounds - 1 && sortedMatches.length === 1

    return {
      no,
      label,
      isFinalRound,
      matches: sortedMatches.map((m, matchIdx) => ({
        ...m,
        _isFinal: isFinalRound,
        // 1er match : centré entre ses 2 sources du tour précédent
        // Matchs suivants : espacement doublé entre eux (mais CSS gap déjà inclus)
        offset: matchIdx === 0
          ? Math.max(0, Math.round(unit * (multiplier - 1) / 2))
          : Math.max(0, Math.round(unit * (multiplier - 1))),
      })),
    }
  }).filter((round) => round.matches.length > 0)
})

const laneEl = ref(null)
const svgWidth = ref(1)
const svgHeight = ref(1)
const bracketPaths = ref([])
const slotRefs = new Map()
const measuredCardH = ref(52) // sera mis à jour depuis le DOM
let resizeObserver = null
let rafId = 0
let persistRafId = 0

const laneStorageKey = computed(() => {
  const base = String(props.persistKey || '').trim()
  if (!base) return ''
  return `efoot.bracket.scroll.${base}.se`
})

function setSlotRef(el, matchId) {
  const key = String(matchId || '')
  if (!key) return
  if (el) slotRefs.set(key, el)
  else slotRefs.delete(key)
  queueRebuild()
}

function queueRebuild() {
  if (rafId) cancelAnimationFrame(rafId)
  rafId = requestAnimationFrame(() => {
    rafId = 0
    rebuildPaths()
  })
}

function restoreLaneScroll() {
  const lane = laneEl.value
  const key = laneStorageKey.value
  if (!lane || !key || typeof sessionStorage === 'undefined') return
  try {
    const parsed = JSON.parse(sessionStorage.getItem(key) || '{}')
    lane.scrollLeft = Math.max(0, Number(parsed.left) || 0)
    lane.scrollTop = Math.max(0, Number(parsed.top) || 0)
  } catch (_) {}
}

function persistLaneScroll() {
  const lane = laneEl.value
  const key = laneStorageKey.value
  if (!lane || !key || typeof sessionStorage === 'undefined') return
  try {
    sessionStorage.setItem(key, JSON.stringify({
      left: lane.scrollLeft || 0,
      top: lane.scrollTop || 0,
    }))
  } catch (_) {}
}

function onLaneScroll() {
  if (persistRafId) cancelAnimationFrame(persistRafId)
  persistRafId = requestAnimationFrame(() => {
    persistRafId = 0
    persistLaneScroll()
    queueRebuild()
  })
}

function getSlotPoint(matchId, laneRect, sx, sy) {
  const node = slotRefs.get(String(matchId || ''))
  if (!node) return null
  const rect = node.getBoundingClientRect()
  return {
    left: rect.left - laneRect.left + sx,
    right: rect.right - laneRect.left + sx,
    cy: rect.top - laneRect.top + sy + rect.height / 2,
  }
}

function resolveVisibleTargetId(sourceMatch, visibleById, allById) {
  let targetId = Number(sourceMatch?.next_match_id || 0)
  const seen = new Set()
  while (targetId && !seen.has(targetId)) {
    seen.add(targetId)
    if (visibleById.has(targetId)) return targetId
    const target = allById.get(targetId)
    if (!target) break
    targetId = Number(target.next_match_id || 0)
  }
  return 0
}

function rebuildPaths() {
  const lane = laneEl.value
  if (!lane) return

  // Mesure la hauteur réelle d'une carte depuis le premier slot DOM connu
  for (const el of slotRefs.values()) {
    const h = el?.getBoundingClientRect?.()?.height
    if (h && h > 10 && Math.abs(h - measuredCardH.value) > 1) {
      measuredCardH.value = h // rounds se recalcule → nouveau rebuild via watch
      return
    }
    break
  }

  svgWidth.value = Math.max(lane.scrollWidth, lane.clientWidth, 1)
  svgHeight.value = Math.max(lane.scrollHeight, lane.clientHeight, 1)

  const laneRect = lane.getBoundingClientRect()
  const sx = lane.scrollLeft
  const sy = lane.scrollTop
  const paths = []

  const flatMatches = rounds.value.flatMap((r) => r?.matches || [])
  const visibleById = new Map(flatMatches.map((m) => [Number(m.id), m]))
  const allById = new Map((props.matches || []).map((m) => [Number(m.id), m]))
  for (const match of flatMatches) {
    const targetId = resolveVisibleTargetId(match, visibleById, allById)
    if (!targetId) continue
    const source = getSlotPoint(match.id, laneRect, sx, sy)
    const target = getSlotPoint(targetId, laneRect, sx, sy)
    if (!source || !target) continue

    const fromX = source.right
    const gap = target.left - fromX
    const midX = fromX + Math.max(10, Math.min(gap * 0.5, 24))
    paths.push(roundedConnector(source.right, source.cy, target.left, target.cy, midX))
  }

  bracketPaths.value = paths
}

// Connecteur orthogonal à coudes arrondis (style esports pro)
function roundedConnector(x1, y1, x2, y2, midX) {
  const safeMid = Math.max(x1 + 4, Math.min(midX, x2 - 4))
  const dy = y2 - y1
  if (Math.abs(dy) < 1.5) {
    return `M ${x1} ${y1} L ${x2} ${y2}`
  }
  const r = Math.min(9, Math.abs(dy) / 2, safeMid - x1, x2 - safeMid)
  if (r < 2) {
    return `M ${x1} ${y1} H ${safeMid} V ${y2} H ${x2}`
  }
  const dir = dy > 0 ? 1 : -1
  return [
    `M ${x1} ${y1}`,
    `H ${safeMid - r}`,
    `Q ${safeMid} ${y1} ${safeMid} ${y1 + dir * r}`,
    `V ${y2 - dir * r}`,
    `Q ${safeMid} ${y2} ${safeMid + r} ${y2}`,
    `H ${x2}`,
  ].join(' ')
}

onMounted(() => {
  nextTick(() => {
    restoreLaneScroll()
    queueRebuild()
  })
  if (typeof ResizeObserver !== 'undefined') {
    resizeObserver = new ResizeObserver(() => queueRebuild())
    if (laneEl.value) resizeObserver.observe(laneEl.value)
  }
  if (laneEl.value) {
    laneEl.value.addEventListener('scroll', onLaneScroll, { passive: true })
  }
  window.addEventListener('resize', queueRebuild, { passive: true })
})

onBeforeUnmount(() => {
  if (rafId) cancelAnimationFrame(rafId)
  if (persistRafId) cancelAnimationFrame(persistRafId)
  if (laneEl.value) {
    laneEl.value.removeEventListener('scroll', onLaneScroll)
  }
  if (resizeObserver) resizeObserver.disconnect()
  window.removeEventListener('resize', queueRebuild)
  persistLaneScroll()
})

watch(rounds, () => {
  nextTick(() => queueRebuild())
}, { deep: true })

watch(() => props.matches, () => {
  const lane = laneEl.value
  const prevLeft = lane ? lane.scrollLeft : 0
  const prevTop = lane ? lane.scrollTop : 0
  nextTick(() => {
    if (laneEl.value) {
      laneEl.value.scrollLeft = prevLeft
      laneEl.value.scrollTop = prevTop
    }
    queueRebuild()
    persistLaneScroll()
  })
}, { deep: true })

watch(laneStorageKey, () => {
  nextTick(() => restoreLaneScroll())
})
</script>

<style scoped>
.bracket-lanes {
  width: 100%;
  position: relative;
}

@media (max-width: 768px) {
  .bracket-lanes::after {
    content: '';
    position: absolute;
    right: 0;
    top: 0;
    bottom: 0;
    width: 32px;
    background: linear-gradient(to right, transparent, var(--bg) 90%);
    pointer-events: none;
    z-index: 10;
  }
}

.lane-scroll {
  display: flex;
  gap: 1.05rem;
  overflow-x: auto;
  padding: 0.15rem 0.2rem;
  scrollbar-gutter: stable both-edges;
  scroll-snap-type: x proximity;
  position: relative;
  align-items: flex-start;
}

.bracket-svg {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  overflow: visible;
  pointer-events: none;
  z-index: 1;
}

.branch-path {
  fill: none;
  stroke: color-mix(in srgb, var(--accent) 72%, transparent);
  stroke-width: 1.8;
  stroke-linecap: round;
  stroke-linejoin: round;
  opacity: 1;
}

.round-col {
  min-width: 206px;
  display: flex;
  flex-direction: column;
  gap: 0.55rem;
  padding: 0;
  position: relative;
  scroll-snap-align: start;
  z-index: 2;
}

.round-title {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.4rem;
  font-size: 0.64rem;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.07em;
  color: var(--muted);
  padding: 0.28rem 0.55rem;
  margin-bottom: 0.15rem;
  border-radius: 7px;
  background: color-mix(in srgb, var(--panel) 65%, transparent);
  border: 1px solid color-mix(in srgb, var(--border) 50%, transparent);
  border-left: 2px solid color-mix(in srgb, var(--accent) 60%, var(--border));
}

.round-title-count {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 1.05rem;
  height: 1.05rem;
  padding: 0 0.25rem;
  font-size: 0.58rem;
  font-weight: 800;
  border-radius: 999px;
  color: var(--muted);
  background: color-mix(in srgb, var(--card) 85%, transparent);
  border: 1px solid color-mix(in srgb, var(--border) 60%, transparent);
}

.round-col--final .round-title {
  color: #b8860b;
  border-left-color: #f59e0b;
  background: color-mix(in srgb, #fbbf24 12%, transparent);
  border-color: color-mix(in srgb, #fbbf24 35%, transparent);
}
.round-col--final .round-title-count {
  color: #b8860b;
  background: color-mix(in srgb, #fbbf24 16%, transparent);
  border-color: color-mix(in srgb, #fbbf24 40%, transparent);
}

.match-slot {
  display: flex;
  position: relative;
  width: max-content;
}

@media (max-width: 768px) {
  .lane-scroll {
    gap: 0.7rem;
    padding: 0.08rem;
  }

  .round-col {
    min-width: 188px;
    gap: 0.45rem;
  }

  .bracket-svg {
    display: none;
  }
}
</style>
