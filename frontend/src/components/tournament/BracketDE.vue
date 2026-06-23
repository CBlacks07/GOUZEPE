<template>
  <div ref="deRootEl" class="space-y-4 bracket-lanes de-layout">
    <section class="de-block">
      <h3 class="lane-heading">Winner Bracket</h3>
      <div ref="wbLaneEl" class="lane-scroll">
          <svg
            class="bracket-svg"
            :width="wbSvgWidth"
            :height="wbSvgHeight"
            :viewBox="`0 0 ${wbSvgWidth} ${wbSvgHeight}`"
            preserveAspectRatio="none"
            aria-hidden="true"
          >
            <path
              v-for="(pathD, idx) in wbPaths"
              :key="`wb-branch-${idx}`"
              :d="pathD"
              class="branch-path"
            />
          </svg>

          <div
            v-for="round in wbDisplayRounds"
            :key="`${round.side}-${round.no}`"
            :class="['round-col', round.isSpacer && 'round-col--spacer']"
          >
            <div v-if="round.label" class="round-title">{{ round.label }}</div>
            <div
              v-for="m in round.matches"
              :key="m.id"
              class="match-slot"
              :data-slot-id="round.side === 'GF' ? `gf-${m.id}` : `wb-${m.id}`"
              :ref="(el) => setWbSlotRef(el, m.id)"
              :style="{ marginTop: `${m.offset || 0}px` }"
            >
              <MatchCard
                :match="m"
                :admin-mode="adminMode"
                :is-final="round.side === 'GF'"
                density="bracket"
                @score-saved="$emit('score-saved', $event)"
              />
            </div>
          </div>
        <p v-if="!wbDisplayRounds.length" class="text-gz-muted text-sm py-4">Aucun match winner bracket.</p>
      </div>
    </section>

    <section v-if="lbRounds.length" class="de-block">
      <h3 class="lane-heading">Loser Bracket</h3>
      <div ref="lbLaneEl" class="lane-scroll">
        <svg
          class="bracket-svg"
          :width="lbSvgWidth"
          :height="lbSvgHeight"
          :viewBox="`0 0 ${lbSvgWidth} ${lbSvgHeight}`"
          preserveAspectRatio="none"
          aria-hidden="true"
        >
          <path
            v-for="(pathD, idx) in lbPaths"
            :key="`lb-branch-${idx}`"
            :d="pathD"
            class="branch-path"
          />
        </svg>

        <div
          v-for="round in lbRounds"
          :key="round.no"
          class="round-col"
        >
          <div class="round-title">{{ round.label }}</div>
          <div
            v-for="m in round.matches"
            :key="m.id"
            class="match-slot"
            :data-slot-id="`lb-${m.id}`"
            :ref="(el) => setLbSlotRef(el, m.id)"
            :style="{ marginTop: `${m.offset || 0}px` }"
          >
            <MatchCard
              :match="m"
              :admin-mode="adminMode"
              density="bracket"
              @score-saved="$emit('score-saved', $event)"
            />
          </div>
        </div>
      </div>
    </section>

    <svg
      class="de-bridge-svg"
      :width="bridgeSvgWidth"
      :height="bridgeSvgHeight"
      :viewBox="`0 0 ${bridgeSvgWidth} ${bridgeSvgHeight}`"
      preserveAspectRatio="none"
      aria-hidden="true"
    >
      <path
        v-for="(pathD, idx) in bridgePaths"
        :key="`de-bridge-${idx}`"
        :d="pathD"
        class="branch-path branch-path--bridge"
      />
    </svg>
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

// Construit les tours bruts (triés, sans offset) à partir d'une liste de matchs.
function buildRawRounds(list, labelFn) {
  const byRound = {}
  for (const m of list) {
    if (!isDisplayableMatch(m)) continue
    if (!byRound[m.round_no]) byRound[m.round_no] = []
    byRound[m.round_no].push(m)
  }
  return Object.keys(byRound)
    .map(Number)
    .sort((a, b) => a - b)
    .map((no, idx, arr) => ({
      no,
      label: labelFn(idx, arr, no),
      matches: byRound[no].slice().sort((a, b) => (a.slot_no || 0) - (b.slot_no || 0)),
    }))
    .filter((round) => round.matches.length > 0)
}

// Aligne chaque match à la hauteur moyenne (centroïde) de ses matchs sources
// réels (suivi de next_match_id). Évite le zig-zag dans les brackets irréguliers.
function assignCentroidOffsets(rounds, allMatches, cardH = 52) {
  const G = 8
  const unit = cardH + G
  const allById = new Map((allMatches || []).map((m) => [Number(m.id), m]))
  const topById = new Map()

  function resolveTargetId(sourceMatch, targetIds) {
    let tId = Number(sourceMatch?.next_match_id || 0)
    const seen = new Set()
    while (tId && !seen.has(tId)) {
      seen.add(tId)
      if (targetIds.has(tId)) return tId
      const t = allById.get(tId)
      if (!t) break
      tId = Number(t.next_match_id || 0)
    }
    return 0
  }

  rounds.forEach((round, r) => {
    if (r === 0) {
      round.matches.forEach((m, i) => topById.set(Number(m.id), i * unit))
      return
    }
    const prev = rounds[r - 1].matches
    const curIds = new Set(round.matches.map((m) => Number(m.id)))
    const sources = new Map()
    for (const sm of prev) {
      const tId = resolveTargetId(sm, curIds)
      if (!tId) continue
      const st = topById.get(Number(sm.id))
      if (st == null) continue
      if (!sources.has(tId)) sources.set(tId, [])
      sources.get(tId).push(st)
    }
    let prevTop = -Infinity
    round.matches.forEach((m, i) => {
      const id = Number(m.id)
      const src = sources.get(id)
      let top
      if (src && src.length) {
        top = src.reduce((a, b) => a + b, 0) / src.length
      } else {
        const prevSibling = i > 0 ? topById.get(Number(round.matches[i - 1].id)) : null
        top = prevSibling != null ? prevSibling + unit : i * unit
      }
      if (top < prevTop + unit) top = prevTop + unit
      topById.set(id, top)
      prevTop = top
    })
  })

  // Convertit les hauteurs absolues en marges (marginTop) cumulables.
  return rounds.map((round) => {
    let cursor = 0
    return {
      ...round,
      matches: round.matches.map((m, i) => {
        const top = topById.get(Number(m.id)) ?? 0
        const offset = i === 0 ? top : top - cursor
        cursor = top + unit
        return { ...m, offset: Math.max(0, Math.round(offset)) }
      }),
    }
  })
}

function groupRounds(list, cardH = 52) {
  const raw = buildRawRounds(list, (idx, arr, no) => (idx === arr.length - 1 ? 'Finale LB' : `LB Round ${no}`))
  return assignCentroidOffsets(raw, list, cardH)
}

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

const wbCardH = ref(52)
const lbCardH = ref(52)

const wbRounds = computed(() => {
  const wb = props.matches.filter((m) => m.bracket_side === 'W')
  const raw = buildRawRounds(wb, (idx, arr, no) =>
    idx === arr.length - 1 ? 'Finale WB' : idx === arr.length - 2 ? 'Demies WB' : `WB Round ${no}`)
  return assignCentroidOffsets(raw, wb, wbCardH.value)
})

const lbRounds = computed(() => groupRounds(props.matches.filter((m) => m.bracket_side === 'L'), lbCardH.value))
const gfMatches = computed(() => props.matches.filter((m) => m.bracket_side === 'GF' && isDisplayableMatch(m)))
const wbDisplayRounds = computed(() => {
  const rounds = wbRounds.value.map((r) => ({ ...r, side: 'W' }))
  if (gfMatches.value.length) {
    const targetColumnsBeforeGf = Math.max(wbRounds.value.length, lbRounds.value.length)
    while (rounds.length < targetColumnsBeforeGf) {
      rounds.push({
        no: (rounds.at(-1)?.no || 0) + 1,
        label: '',
        side: 'SP',
        isSpacer: true,
        matches: [],
      })
    }
    rounds.push({
      no: (rounds.at(-1)?.no || 0) + 1,
      label: 'Grande Finale',
      side: 'GF',
      matches: gfMatches.value.slice().sort((a, b) => (a.slot_no || 0) - (b.slot_no || 0)),
    })
  }
  return rounds
})

function useLaneConnectors(roundsRef, sideKey, allMatchesRef, cardHRef) {
  const laneEl = ref(null)
  const svgWidth = ref(1)
  const svgHeight = ref(1)
  const bracketPaths = ref([])
  const slotRefs = new Map()
  let resizeObserver = null
  let rafId = 0
  let persistRafId = 0

  const laneStorageKey = computed(() => {
    const base = String(props.persistKey || '').trim()
    if (!base) return ''
    return `efoot.bracket.scroll.${base}.${sideKey}`
  })

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

    if (cardHRef) {
      for (const el of slotRefs.values()) {
        const h = el?.getBoundingClientRect?.()?.height
        if (h && h > 10 && Math.abs(h - cardHRef.value) > 1) {
          cardHRef.value = h
          return
        }
        break
      }
    }

    svgWidth.value = Math.max(lane.scrollWidth, lane.clientWidth, 1)
    svgHeight.value = Math.max(lane.scrollHeight, lane.clientHeight, 1)

    const laneRect = lane.getBoundingClientRect()
    const sx = lane.scrollLeft
    const sy = lane.scrollTop
    const paths = []
    const rounds = roundsRef.value || []
    const visible = rounds.flatMap((round) => round?.matches || [])
    const visibleById = new Map(visible.map((m) => [Number(m.id), m]))
    const allById = new Map((allMatchesRef.value || []).map((m) => [Number(m.id), m]))
    const roundIndexById = new Map()
    const matchIndexById = new Map()
    rounds.forEach((round, rIdx) => {
      ;(round?.matches || []).forEach((m, mIdx) => {
        const id = Number(m?.id || 0)
        if (!id) return
        roundIndexById.set(id, rIdx)
        matchIndexById.set(id, mIdx)
      })
    })

    // Draw only between adjacent rounds to guarantee local and readable links.
    for (let r = 0; r < rounds.length - 1; r += 1) {
      const currentRound = rounds[r]?.matches || []
      const nextRound = rounds[r + 1]?.matches || []
      if (!currentRound.length || !nextRound.length) continue

      for (let sIdx = 0; sIdx < currentRound.length; sIdx += 1) {
        const sourceMatch = currentRound[sIdx]
        const sourceId = Number(sourceMatch?.id || 0)
        if (!sourceId) continue

        // Prefer explicit route only if it targets the immediate next visible round.
        let explicitTargetId = resolveVisibleTargetId(sourceMatch, visibleById, allById)
        if (explicitTargetId) {
          const targetRoundIdx = roundIndexById.get(Number(explicitTargetId))
          if (targetRoundIdx !== r + 1) explicitTargetId = 0
        }

        let targetId = explicitTargetId
        if (!targetId) {
          // Proportional fallback: stable for WB and LB even with irregular round sizes.
          const nLen = nextRound.length
          const cLen = currentRound.length
          const proportionalIndex = Math.floor(((sIdx + 0.5) * nLen) / Math.max(1, cLen))
          const targetIndex = Math.max(0, Math.min(nLen - 1, proportionalIndex))
          targetId = Number(nextRound[targetIndex]?.id || 0)
        }
        if (!targetId) continue

        const source = getSlotPoint(sourceId, laneRect, sx, sy)
        const target = getSlotPoint(targetId, laneRect, sx, sy)
        if (!source || !target) continue

        const fromX = source.right
        const gap = target.left - fromX
        if (gap <= 0) continue
        const midX = fromX + Math.max(10, Math.min(26, gap * 0.52))
        paths.push(roundedConnector(source.right, source.cy, target.left, target.cy, midX))
      }
    }

    bracketPaths.value = paths
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

  watch(roundsRef, () => {
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

  return { laneEl, svgWidth, svgHeight, bracketPaths, setSlotRef }
}

const wbMatches = computed(() => props.matches.filter((m) => m.bracket_side === 'W' || m.bracket_side === 'GF'))
const lbMatches = computed(() => props.matches.filter((m) => m.bracket_side === 'L'))

const {
  laneEl: wbLaneEl,
  svgWidth: wbSvgWidth,
  svgHeight: wbSvgHeight,
  bracketPaths: wbPaths,
  setSlotRef: setWbSlotRef,
} = useLaneConnectors(wbDisplayRounds, 'wb', wbMatches, wbCardH)

const {
  laneEl: lbLaneEl,
  svgWidth: lbSvgWidth,
  svgHeight: lbSvgHeight,
  bracketPaths: lbPaths,
  setSlotRef: setLbSlotRef,
} = useLaneConnectors(lbRounds, 'lb', lbMatches, lbCardH)

const deRootEl = ref(null)
const bridgePaths = ref([])
const bridgeSvgWidth = ref(1)
const bridgeSvgHeight = ref(1)
let bridgeRafId = 0
let bridgeResizeObserver = null
let laneSyncLock = false
let detachLaneSync = null

function queueBridgeRebuild() {
  if (bridgeRafId) cancelAnimationFrame(bridgeRafId)
  bridgeRafId = requestAnimationFrame(() => {
    bridgeRafId = 0
    rebuildBridgePaths()
  })
}

function getGlobalSlotPoint(slotId) {
  const root = deRootEl.value
  if (!root || !slotId) return null
  const node = root.querySelector(`[data-slot-id="${slotId}"]`)
  if (!node) return null
  const rootRect = root.getBoundingClientRect()
  const rect = node.getBoundingClientRect()
  return {
    left: rect.left - rootRect.left,
    right: rect.right - rootRect.left,
    cy: rect.top - rootRect.top + rect.height / 2,
  }
}

function rebuildBridgePaths() {
  const root = deRootEl.value
  if (!root) return
  bridgeSvgWidth.value = Math.max(root.clientWidth || 0, 1)
  bridgeSvgHeight.value = Math.max(root.clientHeight || 0, 1)

  const paths = []
  const wbFinal = wbRounds.value.at(-1)?.matches?.[0] || null
  const lbFinal = lbRounds.value.at(-1)?.matches?.[0] || null
  if (!wbFinal || !lbFinal) {
    bridgePaths.value = paths
    return
  }

  const wbPoint = getGlobalSlotPoint(`wb-${wbFinal.id}`)
  const lbPoint = getGlobalSlotPoint(`lb-${lbFinal.id}`)
  if (!wbPoint || !lbPoint) {
    bridgePaths.value = paths
    return
  }

  const gf = gfMatches.value[0]
  if (gf) {
    const gfPoint = getGlobalSlotPoint(`gf-${gf.id}`)
    if (gfPoint) {
      // WB -> GF is already drawn in WB lane.
      // Only draw LB -> GF bridge here to avoid oversized trunk rectangles.
      if (gfPoint.left > lbPoint.right + 8) {
        const midX = Math.min(lbPoint.right + 22, gfPoint.left - 10)
        paths.push(roundedConnector(lbPoint.right, lbPoint.cy, gfPoint.left, gfPoint.cy, midX))
      }
      bridgePaths.value = paths
      return
    }
  }

  // Fallback when GF is missing: keep a compact WB/LB bridge.
  const trunkX = Math.max(wbPoint.right, lbPoint.right) + 18
  const topY = Math.min(wbPoint.cy, lbPoint.cy)
  const bottomY = Math.max(wbPoint.cy, lbPoint.cy)
  paths.push(`M ${wbPoint.right} ${wbPoint.cy} H ${trunkX}`)
  paths.push(`M ${lbPoint.right} ${lbPoint.cy} H ${trunkX}`)
  paths.push(`M ${trunkX} ${topY} V ${bottomY}`)

  bridgePaths.value = paths
}

function bindLaneSync() {
  if (detachLaneSync) {
    detachLaneSync()
    detachLaneSync = null
  }

  const wb = wbLaneEl.value
  const lb = lbLaneEl.value
  if (!wb || !lb) {
    queueBridgeRebuild()
    return
  }

  const onWbScroll = () => {
    if (!laneSyncLock) {
      laneSyncLock = true
      lb.scrollLeft = wb.scrollLeft
      laneSyncLock = false
    }
    queueBridgeRebuild()
  }
  const onLbScroll = () => {
    if (!laneSyncLock) {
      laneSyncLock = true
      wb.scrollLeft = lb.scrollLeft
      laneSyncLock = false
    }
    queueBridgeRebuild()
  }

  wb.addEventListener('scroll', onWbScroll, { passive: true })
  lb.addEventListener('scroll', onLbScroll, { passive: true })

  laneSyncLock = true
  lb.scrollLeft = wb.scrollLeft
  laneSyncLock = false
  queueBridgeRebuild()

  detachLaneSync = () => {
    wb.removeEventListener('scroll', onWbScroll)
    lb.removeEventListener('scroll', onLbScroll)
  }
}

onMounted(() => {
  nextTick(() => {
    bindLaneSync()
    queueBridgeRebuild()
  })
  if (typeof ResizeObserver !== 'undefined') {
    bridgeResizeObserver = new ResizeObserver(() => queueBridgeRebuild())
    if (deRootEl.value) bridgeResizeObserver.observe(deRootEl.value)
  }
  window.addEventListener('resize', queueBridgeRebuild, { passive: true })
})

onBeforeUnmount(() => {
  if (bridgeRafId) cancelAnimationFrame(bridgeRafId)
  if (bridgeResizeObserver) bridgeResizeObserver.disconnect()
  if (detachLaneSync) detachLaneSync()
  detachLaneSync = null
  window.removeEventListener('resize', queueBridgeRebuild)
})

watch([wbLaneEl, lbLaneEl], () => {
  nextTick(() => bindLaneSync())
})

watch([wbRounds, lbRounds, gfMatches], () => {
  nextTick(() => queueBridgeRebuild())
}, { deep: true })

watch(() => props.matches, () => {
  nextTick(() => queueBridgeRebuild())
}, { deep: true })
</script>

<style scoped>
.bracket-lanes {
  width: 100%;
}

.de-layout {
  width: 100%;
  position: relative;
}

.de-bridge-svg {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 4;
}

.de-block {
  border: 1px solid rgba(148, 163, 184, 0.14);
  border-radius: 12px;
  background: color-mix(in srgb, var(--panel) 82%, transparent);
  padding: 0.42rem;
  position: relative;
}

@media (max-width: 768px) {
  .de-block::after {
    content: '';
    position: absolute;
    right: 0;
    top: 0;
    bottom: 0;
    width: 32px;
    background: linear-gradient(to right, transparent, var(--bg) 90%);
    pointer-events: none;
    z-index: 10;
    border-radius: 0 12px 12px 0;
  }
}

.lane-heading {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.66rem;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.07em;
  color: var(--text);
  margin-bottom: 0.5rem;
  padding: 0.24rem 0.6rem 0.24rem 0.5rem;
  border-radius: 7px;
  background: color-mix(in srgb, var(--panel) 70%, transparent);
  border-left: 2px solid color-mix(in srgb, var(--accent) 60%, var(--border));
}
.lane-heading::before {
  content: '';
  width: 0.45rem;
  height: 0.45rem;
  border-radius: 50%;
  background: var(--accent);
}

.lane-scroll {
  display: flex;
  gap: 0.72rem;
  overflow-x: auto;
  padding: 0.16rem 0.2rem;
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

.branch-path--bridge {
  stroke: #f59e0b;
  stroke-width: 2;
  opacity: 0.95;
  stroke-dasharray: 5 3;
}

.round-col {
  min-width: 206px;
  display: flex;
  flex-direction: column;
  gap: 0.55rem;
  padding: 0;
  scroll-snap-align: start;
  position: relative;
  z-index: 2;
}

.round-col--spacer {
  min-width: 122px;
  gap: 0;
}

.match-slot {
  position: relative;
  display: flex;
  width: max-content;
}

.round-title {
  font-size: 0.62rem;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.07em;
  color: var(--muted);
  text-align: left;
  padding: 0.26rem 0.55rem;
  margin-bottom: 0.15rem;
  border-radius: 7px;
  background: color-mix(in srgb, var(--panel) 65%, transparent);
  border: 1px solid color-mix(in srgb, var(--border) 50%, transparent);
  border-left: 2px solid color-mix(in srgb, var(--accent) 55%, var(--border));
}

@media (max-width: 768px) {
  .lane-scroll {
    gap: 0.56rem;
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
