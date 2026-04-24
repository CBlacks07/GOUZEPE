<template>
  <AppLayout season-label="Tournois">
    <div class="page-wrap tournois-wrap">
      <div class="grid grid-cols-1 2xl:grid-cols-[280px_minmax(0,1fr)] gap-6 items-start">
        <aside class="reveal space-y-4">
          <section class="card sidebar-card">
            <h2 class="text-xs font-semibold text-gz-muted uppercase tracking-wide mb-3">Tournois</h2>
            <div v-if="loadingList" class="text-gz-muted text-sm py-4 text-center">Chargement...</div>
            <div v-else-if="!tournaments.length" class="empty-sidebar">
              <TrophyIcon class="w-8 h-8 text-gz-muted/40 mx-auto mb-2" />
              <p class="text-gz-muted text-xs text-center">Aucun tournoi actif pour le moment.</p>
            </div>
            <div v-else class="space-y-1 sidebar-scroll pr-1">
              <button
                v-for="t in tournaments"
                :key="t.id"
                @click="selectTournament(t)"
                :class="[
                  'w-full text-left px-3 py-2.5 rounded-lg border transition-all text-sm',
                  selected?.id === t.id
                    ? 'border-gz-green/50 bg-gz-green/8 text-gz-text shadow-sm'
                    : 'border-transparent hover:border-gz-border hover:bg-gz-card text-gz-muted hover:text-gz-text'
                ]"
                :title="`Ouvrir ${t.name}`"
              >
                <div class="font-medium truncate">{{ t.name }}</div>
                <div class="flex items-center gap-2 mt-0.5">
                  <BaseBadge :variant="statusVariant(t.status)" class="text-[10px]">
                    {{ statusLabel(t.status) }}
                  </BaseBadge>
                  <span class="text-xs text-gz-muted">{{ formatLabel(t.format) }}</span>
                </div>
              </button>
            </div>
          </section>

          <section
            v-if="showFinalStandings"
            class="card final-standing-shell"
          >
            <h3 class="text-xs font-semibold text-gz-muted uppercase tracking-wide mb-3">
              Classement final
            </h3>
            <div class="rounded-xl border border-gz-border/55 overflow-hidden bg-gz-panel/55">
              <div
                v-for="(row, i) in finalStandings"
                :key="`side-final-${row.name}-${i}`"
                class="flex items-center gap-2.5 px-3 py-2.5 border-b border-gz-border/25 last:border-0"
                :class="i === 0 ? 'bg-gz-amber/6' : ''"
              >
                <span
                  class="rank-badge text-[10px] flex-shrink-0"
                  :class="{ 'rank-gold': i === 0, 'rank-silver': i === 1, 'rank-bronze': i === 2 }"
                >{{ i + 1 }}</span>
                <div class="flex-1 min-w-0">
                  <div class="font-medium text-sm truncate" :class="i === 0 ? 'text-gz-amber' : 'text-gz-text'">
                    {{ row.name }}
                  </div>
                  <div class="text-[11px] text-gz-muted">{{ bracketPositionLabel(i) }}</div>
                </div>
                <div class="text-right flex-shrink-0">
                  <span class="text-xs text-gz-green font-medium">{{ row.wins }}V</span>
                  <span class="text-xs text-gz-muted mx-0.5">·</span>
                  <span class="text-xs text-gz-red">{{ row.losses }}D</span>
                </div>
              </div>
            </div>
          </section>
        </aside>

        <main class="min-w-0 space-y-4">
          <section v-if="!selected" class="card reveal delay-1 empty-main">
            <div class="empty-main-inner">
              <div class="empty-trophy-wrap">
                <TrophyIcon class="w-14 h-14 text-gz-muted/20" />
                <div class="empty-trophy-glow" />
              </div>
              <h2 class="text-lg font-bold text-gz-text mt-4 mb-1">Tournois GOUZEPE</h2>
              <p class="text-sm text-gz-muted max-w-xs text-center">
                Sélectionne un tournoi dans la liste pour voir le bracket, les scores et le classement final.
              </p>
              <div v-if="!tournaments.length" class="mt-6 flex flex-wrap gap-2 justify-center">
                <span class="format-chip">Élimination simple</span>
                <span class="format-chip">Double élimination</span>
                <span class="format-chip">Round Robin</span>
                <span class="format-chip">Groupes + Finales</span>
              </div>
              <div v-else class="mt-4 flex flex-wrap gap-2 justify-center">
                <button
                  v-for="t in tournaments.slice(0, 4)"
                  :key="t.id"
                  @click="selectTournament(t)"
                  class="format-chip format-chip-btn"
                >
                  {{ t.name }}
                </button>
              </div>
            </div>
          </section>

          <template v-else>
            <section class="card reveal delay-1">
              <div class="flex items-start justify-between flex-wrap gap-3">
                <div>
                  <h1 class="text-xl font-bold text-gz-text">{{ selected.name }}</h1>
                  <div class="flex items-center gap-2 mt-1 flex-wrap">
                    <BaseBadge :variant="statusVariant(selected.status)">
                      {{ statusLabel(selected.status) }}
                    </BaseBadge>
                    <span class="text-sm text-gz-muted">{{ formatLabel(selected.format) }}</span>
                    <span v-if="selected.format === 'round_robin'" class="text-sm text-gz-muted">
                      • {{ rrMatchModeLabel(selected.rr_match_mode) }} • {{ rrStandingsModeLabel(selected.rr_standings_mode) }}
                    </span>
                    <span v-if="selected.participants?.length" class="text-sm text-gz-muted">
                      • {{ selected.participants.length }} participants
                    </span>
                  </div>
                </div>
              </div>
            </section>

            <div class="tournois-main-split">
              <section class="card bracket-shell flex-1 min-w-0 reveal delay-2">
                <div v-if="loadingBracket" class="text-gz-muted text-sm py-8 text-center">
                  Chargement du bracket...
                </div>
                <template v-else>
                  <BracketSE
                    v-if="selected.format === 'single_elimination'"
                    :matches="matches"
                    :admin-mode="false"
                    :persist-key="`tournois-public-${selected?.id || 'none'}-se`"
                  />
                  <BracketDE
                    v-else-if="selected.format === 'double_elimination'"
                    :matches="matches"
                    :admin-mode="false"
                    :persist-key="`tournois-public-${selected?.id || 'none'}-de`"
                  />
                  <BracketRR
                    v-else-if="selected.format === 'round_robin'"
                    :matches="matches"
                    :standings="rrStandings"
                    :standings-mode="selected.rr_standings_mode || 'goals'"
                    :admin-mode="false"
                  />
                  <div
                    v-else-if="selected.format === 'groups_knockout'"
                    class="space-y-4"
                  >
                    <section class="rounded-xl border border-gz-border/45 p-3 bg-gz-panel/40">
                      <div class="flex items-center justify-between mb-3 gap-2 flex-wrap">
                        <h3 class="text-xs font-semibold uppercase tracking-wide text-gz-muted">Phase de groupes</h3>
                        <span class="text-xs text-gz-muted">{{ groupMatches.length }} match(s)</span>
                      </div>
                      <div class="grid grid-cols-1 xl:grid-cols-2 gap-3">
                        <div
                          v-for="grp in groupMatchBuckets"
                          :key="`gm-${grp.group_no}`"
                          class="rounded-lg border border-gz-border/40 p-2 bg-gz-panel/30"
                        >
                          <div class="px-1 pb-2 text-xs font-semibold uppercase tracking-wide text-gz-muted">
                            Groupe {{ groupLabel(grp.group_no) }}
                          </div>
                          <BracketRR :matches="grp.matches" :standings="[]" :admin-mode="false" />
                        </div>
                      </div>
                    </section>

                    <section v-if="groupStandings.length" class="rounded-xl border border-gz-border/45 p-3 bg-gz-panel/40">
                      <h3 class="text-xs font-semibold uppercase tracking-wide text-gz-muted mb-3">
                        Classements des groupes
                      </h3>
                      <div class="grid grid-cols-1 xl:grid-cols-2 gap-3">
                        <div
                          v-for="grp in groupStandings"
                          :key="`grp-${grp.group_no}`"
                          class="rounded-lg border border-gz-border/40 overflow-hidden"
                        >
                          <div class="px-3 py-2 text-xs font-semibold uppercase tracking-wide text-gz-muted border-b border-gz-border/35">
                            Groupe {{ groupLabel(grp.group_no) }}
                          </div>
                          <div class="group-table-scroll">
                            <table class="data-table text-xs">
                              <thead>
                                <tr>
                                  <th class="w-8">#</th>
                                  <th>Joueur</th>
                                  <th class="text-center">J</th>
                                  <th class="text-center">V</th>
                                  <th class="text-center">N</th>
                                  <th class="text-center">D</th>
                                  <th class="text-center">BM</th>
                                  <th class="text-center">BC</th>
                                  <th class="text-center">Diff</th>
                                  <th class="text-center">Pts</th>
                                </tr>
                              </thead>
                              <tbody>
                                <tr v-for="(s, idx) in grp.standings || []" :key="s.participant_id || `${grp.group_no}-${idx}`">
                                  <td class="text-center text-gz-muted">{{ idx + 1 }}</td>
                                  <td class="font-medium truncate">{{ s.name }}</td>
                                  <td class="text-center text-gz-muted">{{ playedOf(s) }}</td>
                                  <td class="text-center text-gz-green">{{ winOf(s) }}</td>
                                  <td class="text-center text-gz-muted">{{ drawOf(s) }}</td>
                                  <td class="text-center text-gz-red">{{ lossOf(s) }}</td>
                                  <td class="text-center">{{ bfOf(s) }}</td>
                                  <td class="text-center">{{ bcOf(s) }}</td>
                                  <td class="text-center" :class="diffOf(s) > 0 ? 'text-gz-green' : diffOf(s) < 0 ? 'text-gz-red' : 'text-gz-muted'">
                                    {{ diffOf(s) > 0 ? '+' : '' }}{{ diffOf(s) }}
                                  </td>
                                  <td class="text-center font-semibold">{{ ptsOf(s) }}</td>
                                </tr>
                              </tbody>
                            </table>
                          </div>
                        </div>
                      </div>
                    </section>

                    <section class="rounded-xl border border-gz-border/45 p-3 bg-gz-panel/40">
                      <div class="flex items-center justify-between mb-3 gap-2 flex-wrap">
                        <h3 class="text-xs font-semibold uppercase tracking-wide text-gz-muted">Tableau final</h3>
                        <span class="text-xs text-gz-muted">{{ knockoutMatches.length }} match(s)</span>
                      </div>
                      <div v-if="knockoutMatches.length" class="knockout-grid">
                        <div class="min-w-0">
                          <BracketSE :matches="knockoutMatches" :admin-mode="false" :persist-key="`tournois-public-${selected?.id || 'none'}-gk-ko`" />
                        </div>
                      </div>
                      <div v-else class="text-sm text-gz-muted py-4">Tableau final non genere pour ce tournoi.</div>
                    </section>
                  </div>
                  <div v-else class="text-gz-muted text-sm">Format non supporte.</div>
                </template>
              </section>
            </div>
          </template>
        </main>
      </div>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import AppLayout from '@/components/layout/AppLayout.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'
import BracketSE from '@/components/tournament/BracketSE.vue'
import BracketDE from '@/components/tournament/BracketDE.vue'
import BracketRR from '@/components/tournament/BracketRR.vue'
import { useAPI } from '@/composables/useAPI'
import { useSessionState } from '@/composables/useSessionState'
import { onRealtimeEvent, joinRealtimeRoom, leaveRealtimeRoom } from '@/composables/useRealtimeSocket'
import { TrophyIcon } from 'lucide-vue-next'

const api = useAPI()

const tournaments = ref([])
const selected = ref(null)
const matches = ref([])
const rrStandings = ref([])
const groupStandings = ref([])
const loadingList = ref(false)
const loadingBracket = ref(false)
const selectedTournamentId = ref(null)
let realtimeOffTournamentChanged = null
let joinedTournamentRoom = ''

useSessionState('efoot.ui.tournois.view.v1', {
  selectedTournamentId,
})

const groupMatches = computed(() =>
  matches.value.filter((m) => m.bracket_side === 'G' || (m.group_no !== null && m.group_no !== undefined))
)

const knockoutMatches = computed(() =>
  matches.value.filter((m) => !(m.bracket_side === 'G' || (m.group_no !== null && m.group_no !== undefined)))
)

const groupMatchBuckets = computed(() => {
  const map = new Map()
  for (const m of groupMatches.value) {
    const key = Number.isFinite(Number(m.group_no)) ? Number(m.group_no) : 0
    if (!map.has(key)) map.set(key, [])
    map.get(key).push(m)
  }
  return [...map.entries()]
    .sort((a, b) => a[0] - b[0])
    .map(([group_no, list]) => ({ group_no, matches: list }))
})

const showFinalStandings = computed(() => {
  if (!finalStandings.value.length) return false
  if (!selected.value) return false
  if (selected.value.format === 'round_robin') return false
  return true
})

const finalStandings = computed(() => {
  if (!selected.value || !matches.value.length) return []

  const stats = new Map()
  const ensure = (name) => {
    if (!name) return null
    if (!stats.has(name)) {
      stats.set(name, {
        name,
        points: 0,
        wins: 0,
        draws: 0,
        losses: 0,
        gf: 0,
        ga: 0,
        played: 0,
      })
    }
    return stats.get(name)
  }

  for (const p of selected.value.participants || []) {
    ensure(normalizePersonName(p))
  }

  const completed = []
  for (const m of matches.value) {
    const p1 = normalizePersonName(m.p1_name || m.p1_id)
    const p2 = normalizePersonName(m.p2_name || m.p2_id)
    const a = ensure(p1)
    const b = ensure(p2)
    if (!a || !b) continue

    const isDone = m.status === 'done' || m.status === 'completed'
    if (!isDone) continue

    const s1 = Number(m.score1)
    const s2 = Number(m.score2)
    if (!Number.isFinite(s1) || !Number.isFinite(s2)) continue

    a.played += 1
    b.played += 1
    a.gf += s1
    a.ga += s2
    b.gf += s2
    b.ga += s1

    if (s1 > s2) {
      a.points += 3
      a.wins += 1
      b.losses += 1
    } else if (s2 > s1) {
      b.points += 3
      b.wins += 1
      a.losses += 1
    } else {
      a.points += 1
      b.points += 1
      a.draws += 1
      b.draws += 1
    }
    completed.push(m)
  }

  // Keep champion then runner-up first when a final match exists.
  let championName = ''
  let runnerName = ''
  const finals = completed
    .filter((m) => {
      const side = normalizeBracketSide(m.bracket_side, selected.value?.format, m.round_no)
      return side !== 'G' && !m.next_match_id
    })
    .sort((a, b) => {
      const sidePriority = (mm) => {
        const side = normalizeBracketSide(mm.bracket_side, selected.value?.format, mm.round_no)
        if (side === 'GF') return 3
        if (side === 'W') return 2
        if (side === 'L') return 1
        return 0
      }
      return sidePriority(b) - sidePriority(a)
        || Number(b.round_no || 0) - Number(a.round_no || 0)
        || Number(b.id || 0) - Number(a.id || 0)
    })

  if (finals.length) {
    const f = finals[0]
    const p1 = normalizePersonName(f.p1_name || f.p1_id)
    const p2 = normalizePersonName(f.p2_name || f.p2_id)
    const s1 = Number(f.score1)
    const s2 = Number(f.score2)
    if (Number.isFinite(s1) && Number.isFinite(s2) && s1 !== s2) {
      championName = s1 > s2 ? p1 : p2
      runnerName = championName === p1 ? p2 : p1
    }
  }

  const rows = [...stats.values()]
  rows.sort((a, b) => {
    const tier = (row) => {
      if (championName && row.name === championName) return 0
      if (runnerName && row.name === runnerName) return 1
      return 2
    }
    const t = tier(a) - tier(b)
    if (t !== 0) return t
    const diffA = a.gf - a.ga
    const diffB = b.gf - b.ga
    return b.points - a.points
      || b.wins - a.wins
      || diffB - diffA
      || b.gf - a.gf
      || b.played - a.played
      || a.name.localeCompare(b.name, 'fr')
  })

  return rows
})

function normalizePersonName(value) {
  if (!value) return ''
  if (typeof value === 'string') {
    const s = value.trim()
    return s === '[object Object]' ? '' : s
  }
  if (typeof value === 'object') {
    const s = String(value.display_name || value.name || value.player_id || value.id || '').trim()
    return s === '[object Object]' ? '' : s
  }
  const s = String(value).trim()
  return s === '[object Object]' ? '' : s
}

onMounted(async () => {
  bindRealtimeListeners()
  loadingList.value = true
  try {
    const { data } = await api.get('/tournaments')
    tournaments.value = (data.tournaments || []).filter((t) => t.status !== 'draft')
    const wantedId = Number(selectedTournamentId.value || 0)
    if (wantedId > 0) {
      const found = tournaments.value.find((t) => Number(t.id) === wantedId)
      if (found) {
        await selectTournament(found)
      }
    }
  } catch (_) {}
  loadingList.value = false
})

onUnmounted(() => {
  if (joinedTournamentRoom) void leaveRealtimeRoom(joinedTournamentRoom).catch(() => {})
  joinedTournamentRoom = ''
  unbindRealtimeListeners()
})

async function syncTournamentRoom(tournamentId) {
  const room = Number.isInteger(Number(tournamentId)) && Number(tournamentId) > 0
    ? `tournament:${Number(tournamentId)}`
    : ''
  if (joinedTournamentRoom && joinedTournamentRoom !== room) {
    await leaveRealtimeRoom(joinedTournamentRoom)
    joinedTournamentRoom = ''
  }
  if (room && joinedTournamentRoom !== room) {
    await joinRealtimeRoom(room)
    joinedTournamentRoom = room
  }
}

function bindRealtimeListeners() {
  if (realtimeOffTournamentChanged) return
  realtimeOffTournamentChanged = onRealtimeEvent('tournament:changed', async (event = {}) => {
    const tournamentId = Number(event.tournamentId || 0)
    if (!Number.isInteger(tournamentId) || tournamentId <= 0) return
    try {
      const { data } = await api.get('/tournaments')
      tournaments.value = (data.tournaments || []).filter((t) => t.status !== 'draft')
      if (selected.value?.id === tournamentId) {
        const fresh = tournaments.value.find((t) => Number(t.id) === tournamentId)
        if (fresh) {
          await selectTournament(fresh)
        } else {
          await syncTournamentRoom(null)
          selectedTournamentId.value = null
          selected.value = null
          matches.value = []
          rrStandings.value = []
          groupStandings.value = []
        }
      }
    } catch (_) {}
  })
}

function unbindRealtimeListeners() {
  if (realtimeOffTournamentChanged) realtimeOffTournamentChanged()
  realtimeOffTournamentChanged = null
}

async function selectTournament(t) {
  selectedTournamentId.value = Number(t?.id || 0) || null
  matches.value = []
  rrStandings.value = []
  groupStandings.value = []
  loadingBracket.value = true
  try {
    const { data } = await api.get(`/tournaments/${t.id}`)
    const tournament = data.tournament || t
    const participants = (Array.isArray(data.participants) ? data.participants : [])
      .map((p) => normalizePersonName(p))
      .filter(Boolean)

    selected.value = {
      ...tournament,
      participants,
      participants_count: tournament.participants_count ?? participants.length,
    }
    await syncTournamentRoom(selected.value.id)
    matches.value = normalizeMatches(data.matches || [], tournament.format)

    if (tournament.format === 'round_robin' || tournament.format === 'groups_knockout') {
      try {
        const { data: s } = await api.get(`/tournaments/${t.id}/standings`)
        if (tournament.format === 'round_robin') {
          rrStandings.value = s.standings || []
          groupStandings.value = []
        } else {
          rrStandings.value = []
          groupStandings.value = s.groups || []
        }
      } catch (_) {}
    }
  } catch (_) {}
  loadingBracket.value = false
}

function statusVariant(s) {
  return { live: 'green', completed: 'blue', archived: 'muted', draft: 'amber' }[s] ?? 'muted'
}

function statusLabel(s) {
  return { live: 'LIVE', completed: 'Termine', archived: 'Archive', draft: 'Brouillon' }[s] ?? s
}

function formatLabel(f) {
  return {
    single_elimination: 'Elimination simple',
    double_elimination: 'Double elimination',
    round_robin: 'Round Robin',
    groups_knockout: 'Groupes + Finales',
  }[f] ?? f
}

function rrMatchModeLabel(mode) {
  return mode === 'home_away' ? 'Aller / Retour' : 'Match simple'
}

function rrStandingsModeLabel(mode) {
  return mode === 'wins' ? 'Classement: victoires' : 'Classement: points + buts'
}

function normalizeMatches(rawMatches, format) {
  return (rawMatches || []).map((m) => {
    const roundNo = Number(m.round_no ?? m.roundNo ?? 0)
    return {
      ...m,
      round_no: roundNo,
      slot_no: Number(m.slot_no ?? m.slotNo ?? 0),
      p1_id: m.p1_id ?? m.p1_participant_id ?? null,
      p2_id: m.p2_id ?? m.p2_participant_id ?? null,
      score1: m.score1 ?? m.score_p1 ?? null,
      score2: m.score2 ?? m.score_p2 ?? null,
      bracket_side: normalizeBracketSide(m.bracket_side, format, roundNo),
    }
  })
}

function normalizeBracketSide(raw, format, roundNo) {
  const side = String(raw || '').trim().toUpperCase()
  if (side === 'W' || side === 'WB') return 'W'
  if (side === 'L' || side === 'LB') return 'L'
  if (side === 'GF' || side === 'FINAL' || side === 'GRAND_FINAL') return 'GF'
  if (side === 'G' || side === 'GROUP') return 'G'

  if (!side && format === 'double_elimination') {
    if (roundNo >= 20) return 'GF'
    if (roundNo >= 10) return 'L'
    return 'W'
  }

  if (!side && format === 'groups_knockout') {
    if (roundNo >= 100) return 'W'
  }

  return side || 'W'
}

function bracketPositionLabel(index) {
  const labels = ['Champion', 'Finaliste', '3e place', '4e place', '5e', '6e', '7e', '8e']
  return labels[index] ?? `${index + 1}e`
}

function groupLabel(groupNo) {
  const n = Number(groupNo)
  if (!Number.isFinite(n) || n < 0) return '?'
  return String.fromCharCode(65 + n)
}

function toInt(v) {
  const n = Number(v)
  return Number.isFinite(n) ? n : 0
}

function winOf(s) {
  return toInt(s.w ?? s.wins)
}

function drawOf(s) {
  return toInt(s.d ?? s.draws)
}

function lossOf(s) {
  return toInt(s.l ?? s.losses)
}

function bfOf(s) {
  return toInt(s.bf ?? s.goals_for)
}

function bcOf(s) {
  return toInt(s.bc ?? s.goals_against)
}

function diffOf(s) {
  const explicit = s.diff
  if (explicit !== undefined && explicit !== null && explicit !== '') return toInt(explicit)
  return bfOf(s) - bcOf(s)
}

function ptsOf(s) {
  return toInt(s.pts ?? s.points)
}

function playedOf(s) {
  const explicit = s.played
  if (explicit !== undefined && explicit !== null && explicit !== '') return toInt(explicit)
  return winOf(s) + drawOf(s) + lossOf(s)
}
</script>

<style scoped>
.tournois-wrap {
  width: 100%;
}

.tournois-wrap :deep(.card) {
  transition: transform 180ms ease, box-shadow 180ms ease, border-color 180ms ease;
}

.tournois-wrap :deep(.card:hover) {
  transform: translateY(-1px);
  box-shadow: 0 12px 26px rgba(2, 6, 23, 0.2);
  border-color: color-mix(in srgb, var(--border) 68%, var(--blue) 32%);
}

.sidebar-card {
  position: sticky;
  top: 88px;
}

.sidebar-scroll {
  max-height: min(72vh, 760px);
  overflow: auto;
}

.tournois-main-split {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: 1rem;
  align-items: start;
}

.bracket-shell {
  overflow: hidden;
}

.bracket-shell :deep(.bracket-lanes) {
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 12px;
  background: color-mix(in srgb, var(--panel) 84%, transparent);
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

.delay-3 {
  animation-delay: 220ms;
}

.knockout-grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: 0.75rem;
  align-items: start;
}

.rank-badge {
  width: 1.35rem;
  height: 1.35rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 999px;
  border: 1px solid rgba(148, 163, 184, 0.42);
  background: color-mix(in srgb, var(--card) 75%, transparent);
  color: var(--muted);
  font-size: 0.72rem;
  font-weight: 700;
  flex: 0 0 auto;
}

.rank-gold {
  border-color: rgba(251, 191, 36, 0.7);
  background: rgba(251, 191, 36, 0.15);
  color: #fbbf24;
}

.rank-silver {
  border-color: rgba(148, 163, 184, 0.7);
  background: rgba(148, 163, 184, 0.15);
  color: #94a3b8;
}

.rank-bronze {
  border-color: rgba(180, 120, 60, 0.7);
  background: rgba(180, 120, 60, 0.12);
  color: #b97c3c;
}

.empty-sidebar {
  padding: 1.5rem 0.5rem;
}

.empty-main {
  min-height: 380px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.empty-main-inner {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 2rem 1rem;
}

.empty-trophy-wrap {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.empty-trophy-glow {
  position: absolute;
  inset: -20px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(22, 163, 74, 0.10) 0%, transparent 70%);
  pointer-events: none;
}

.format-chip {
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.04em;
  padding: 4px 10px;
  border-radius: 999px;
  border: 1px solid rgba(148, 163, 184, 0.2);
  background: color-mix(in srgb, var(--panel) 80%, transparent);
  color: var(--muted);
}

.format-chip-btn {
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s, background 0.2s;
}

.format-chip-btn:hover {
  border-color: rgba(22, 163, 74, 0.4);
  color: var(--text);
  background: rgba(22, 163, 74, 0.08);
}

.group-table-scroll {
  width: 100%;
  overflow-x: auto;
}

.group-table-scroll :deep(table) {
  min-width: 560px;
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
  .tournois-wrap {
    max-width: none;
    padding: clamp(14px, 2.1vw, 30px);
  }
}

@media (max-width: 1535px) {
  .sidebar-card {
    position: static;
  }
}

@media (min-width: 1280px) {
  .final-standing-shell {
    position: sticky;
    top: 88px;
  }
}

@media (max-width: 640px) {
  .tournois-wrap :deep(.card) {
    padding: 0.8rem;
  }
}

@media (prefers-reduced-motion: reduce) {
  .reveal {
    animation: none !important;
  }

  .tournois-wrap :deep(.card) {
    transition: none !important;
  }
}
</style>
