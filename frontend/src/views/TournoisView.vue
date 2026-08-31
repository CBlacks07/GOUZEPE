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
            <div v-else class="space-y-1.5 sidebar-scroll pr-1">
              <button
                v-for="t in tournaments"
                :key="t.id"
                @click="selectTournament(t)"
                :class="[
                  'w-full text-left px-3 py-2.5 rounded-xl border transition-all duration-200 relative overflow-hidden',
                  selected?.id === t.id
                    ? 'border-gz-green/40 bg-gz-green/8 text-gz-text shadow-sm'
                    : 'border-gz-border/30 hover:border-gz-green/25 hover:bg-gz-card text-gz-muted hover:text-gz-text'
                ]"
              >
                <!-- Indicateur live -->
                <span v-if="t.status === 'live'"
                  class="absolute top-2 right-2 w-1.5 h-1.5 rounded-full bg-gz-green animate-pulse" />
                <div class="font-semibold truncate text-sm pr-4">{{ t.name }}</div>
                <div class="flex items-center gap-1.5 mt-1 flex-wrap">
                  <span :class="[
                    'text-[10px] font-bold px-1.5 py-0.5 rounded-full',
                    t.status === 'live' ? 'bg-gz-green/15 text-gz-green' :
                    t.status === 'completed' ? 'bg-gz-muted/10 text-gz-muted' :
                    'bg-gz-blue/15 text-gz-blue'
                  ]">{{ statusLabel(t.status) }}</span>
                  <span class="text-[10px] text-gz-muted">{{ formatLabel(t.format) }}</span>
                  <span v-if="t.winner_name && t.status === 'completed'" class="text-[10px] text-gz-amber font-semibold ml-auto">
                    <TrophyIcon class="w-3 h-3 inline" /> {{ t.member_tournament !== false ? (t.winner_player_id || t.winner_name) : t.winner_name }}
                  </span>
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
                :key="`side-final-${row.participant_id}-${i}`"
                class="flex items-center gap-2.5 px-3 py-2.5 border-b border-gz-border/25 last:border-0"
                :class="i === 0 ? 'bg-gz-amber/6' : ''"
              >
                <span
                  class="rank-badge text-[10px] flex-shrink-0"
                  :class="{ 'rank-gold': i === 0, 'rank-silver': i === 1, 'rank-bronze': i === 2 }"
                >{{ row.rank }}</span>
                <div class="flex-1 min-w-0">
                  <div class="font-semibold text-sm truncate" :class="i === 0 ? 'text-gz-amber' : 'text-gz-text'">
                    {{ row.player_id || row.name }}
                  </div>
                  <div v-if="row.name && row.name !== (row.player_id || row.name)" class="text-[11px] text-gz-muted truncate">
                    {{ row.name }}
                  </div>
                </div>
                <div class="text-right flex-shrink-0">
                  <div v-if="row.stage" class="text-[10px] font-semibold mb-0.5"
                    :class="row.rank === 1 ? 'text-gz-amber' : 'text-gz-muted'">{{ row.stage }}</div>
                  <div>
                    <span class="text-xs text-gz-green font-medium">{{ row.wins }}V</span>
                    <span class="text-xs text-gz-muted mx-0.5">·</span>
                    <span class="text-xs text-gz-red">{{ row.losses }}D</span>
                  </div>
                </div>
              </div>
            </div>
          </section>
        </aside>

        <main class="min-w-0 space-y-4">
          <section v-if="!selected" class="empty-main reveal delay-1">
            <div class="empty-main-inner">
              <div class="empty-trophy-wrap">
                <TrophyIcon class="w-16 h-16" style="color:rgba(34,197,94,.25)" />
                <div class="empty-trophy-glow" />
              </div>
              <h2 class="text-xl font-bold mt-5 mb-2">Tournois GOUZEPE</h2>
              <p class="text-sm text-gz-muted max-w-sm text-center leading-relaxed">
                Sélectionne un tournoi dans la liste pour afficher le bracket, les scores et le classement final.
              </p>
              <!-- Chips de tournois récents -->
              <div v-if="tournaments.length" class="mt-6 flex flex-wrap gap-2 justify-center">
                <button
                  v-for="t in tournaments.slice(0, 5)"
                  :key="t.id"
                  @click="selectTournament(t)"
                  class="quick-pick-btn"
                >
                  <span v-if="t.status === 'live'" class="w-1.5 h-1.5 rounded-full bg-gz-green animate-pulse inline-block mr-1" />
                  {{ t.name }}
                </button>
              </div>
              <div v-else class="mt-6 flex flex-wrap gap-2 justify-center">
                <span class="format-chip">Élimination simple</span>
                <span class="format-chip">Double élimination</span>
                <span class="format-chip">Round Robin</span>
                <span class="format-chip">Groupes + Finales</span>
              </div>
            </div>
          </section>

          <template v-else>
            <section class="tournament-header-card reveal delay-1">
              <div class="th-top">
                <!-- Statut badge -->
                <span :class="[
                  'th-status-badge',
                  selected.status === 'live' ? 'th-live' :
                  selected.status === 'completed' ? 'th-done' : 'th-draft'
                ]">
                  <span v-if="selected.status === 'live'" class="th-live-dot" />
                  {{ statusLabel(selected.status) }}
                </span>
                <span class="th-format">{{ formatLabel(selected.format) }}
                  <template v-if="selected.format === 'round_robin'">
                    &nbsp;·&nbsp;{{ rrMatchModeLabel(selected.rr_match_mode) }}
                  </template>
                </span>
                <span v-if="selected.participants?.length" class="th-participants">
                  {{ selected.participants.length }} participants
                </span>
                <button @click="printTournamentResults" :disabled="printing" class="th-download-btn" title="Télécharger les résultats en PDF">
                  <Loader2Icon v-if="printing" class="w-3.5 h-3.5 animate-spin" />
                  <DownloadIcon v-else class="w-3.5 h-3.5" />
                  Télécharger les résultats
                </button>
              </div>
              <h1 class="th-title">{{ selected.name }}</h1>
              <!-- Vainqueur si terminé -->
              <div v-if="selected.winner_name && selected.status === 'completed'" class="th-winner">
                <TrophyIcon class="th-winner-crown-icon" />
                <span class="th-winner-label">Vainqueur</span>
                <span class="th-winner-name">{{ selected.winner_name }}</span>
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
import { useAPI, mediaUrl } from '@/composables/useAPI'
import { useSessionState } from '@/composables/useSessionState'
import { useSiteSettings } from '@/stores/siteSettings'
import { useToast } from '@/composables/useToast'
import { onRealtimeEvent, joinRealtimeRoom, leaveRealtimeRoom } from '@/composables/useRealtimeSocket'
import { applyIdLabels, applyIdStandings, buildIdIndex, participantIdLabel } from '@/utils/tournamentLabels'
import { computeFinalStandings } from '@/utils/tournamentStandings'
import { TrophyIcon, DownloadIcon, Loader2Icon } from 'lucide-vue-next'

const api = useAPI()
const site = useSiteSettings()
const { error: toastError } = useToast()
const printing = ref(false)

const tournaments = ref([])
const selected = ref(null)
const matches = ref([])
const rawMatchesRef = ref([])
const rawParticipants = ref([])
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

// Le classement final n'a de sens qu'une fois le tournoi termine.
const isCompleted = computed(() => selected.value?.status === 'completed')

const showFinalStandings = computed(() => {
  if (!selected.value) return false
  if (!isCompleted.value) return false
  if (selected.value.format === 'round_robin') return false
  return finalStandings.value.length > 0
})

const finalStandings = computed(() => {
  if (!selected.value || !isCompleted.value) return []
  return computeFinalStandings(selected.value.format, rawMatchesRef.value, rawParticipants.value)
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
  rawMatchesRef.value = []
  rawParticipants.value = []
  rrStandings.value = []
  groupStandings.value = []
  loadingBracket.value = true
  try {
    const { data } = await api.get(`/tournaments/${t.id}`)
    const tournament = data.tournament || t
    const useIds = tournament.member_tournament !== false
    const rawParts = Array.isArray(data.participants) ? data.participants : []
    rawParticipants.value = rawParts
    rawMatchesRef.value = Array.isArray(data.matches) ? data.matches : []
    const idIndex = buildIdIndex(rawParts)
    const participants = rawParts
      .map((p) => (useIds ? participantIdLabel(p, true) : normalizePersonName(p)))
      .filter(Boolean)

    selected.value = {
      ...tournament,
      winner_name: useIds && tournament.winner_name
        ? (idIndex.get(String(tournament.winner_name).trim()) || tournament.winner_name)
        : tournament.winner_name,
      participants,
      participants_count: tournament.participants_count ?? participants.length,
    }
    await syncTournamentRoom(selected.value.id)
    matches.value = applyIdLabels(normalizeMatches(data.matches || [], tournament.format), useIds)

    if (tournament.format === 'round_robin' || tournament.format === 'groups_knockout') {
      try {
        const { data: s } = await api.get(`/tournaments/${t.id}/standings`)
        if (tournament.format === 'round_robin') {
          rrStandings.value = applyIdStandings(s.standings || [], useIds)
          groupStandings.value = []
        } else {
          rrStandings.value = []
          groupStandings.value = (s.groups || []).map((g) => ({
            ...g,
            standings: applyIdStandings(g.standings || [], useIds),
          }))
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

function escapeHtml(value) {
  return String(value ?? '').replace(/[&<>"']/g, (m) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
  }[m]))
}

function matchPhaseLabel(m, format) {
  if (format === 'groups_knockout') {
    if (m.group_no !== null && m.group_no !== undefined) return `Groupe ${groupLabel(m.group_no)}`
    return 'Phase finale'
  }
  if (format === 'double_elimination') {
    if (m.bracket_side === 'GF') return 'Grande finale'
    if (m.bracket_side === 'L') return 'Repêchage'
    return 'Tableau principal'
  }
  return ''
}

// Construit les lignes du tableau imprimable "Résultats des matchs" : en round robin aller/retour,
// les deux manches d'une même confrontation sont fusionnées sur une seule ligne ("2-1 / 0-3") au lieu
// d'une ligne par tour -- un score normalisé sur l'ordre du 1er match de la paire (pas celui, potentiellement
// inversé, du match retour) pour ne pas mélanger les perspectives.
function buildResultRows(playedMatches, format, rrMatchMode) {
  if (format === 'round_robin' && rrMatchMode === 'home_away') {
    const pairs = new Map()
    for (const m of playedMatches) {
      const a = m.p1_name || 'TBD'
      const b = m.p2_name || 'TBD'
      const key = [a, b].slice().sort().join('||')
      if (!pairs.has(key)) pairs.set(key, [])
      pairs.get(key).push(m)
    }
    const rows = []
    for (const list of pairs.values()) {
      list.sort((x, y) => x.round_no - y.round_no)
      const p1 = list[0].p1_name || 'TBD'
      const p2 = list[0].p2_name || 'TBD'
      const score = list.map((m) => {
        const sameOrder = (m.p1_name || 'TBD') === p1
        return sameOrder ? `${m.score1}-${m.score2}` : `${m.score2}-${m.score1}`
      }).join(' / ')
      rows.push({ phase: '', p1, p2, score })
    }
    return rows
  }
  return playedMatches.map((m) => ({
    phase: matchPhaseLabel(m, format),
    p1: m.p1_name || 'TBD',
    p2: m.p2_name || 'TBD',
    score: `${m.score1} - ${m.score2}`,
  }))
}

async function logoDataURL() {
  const tryFetch = async (path) => {
    if (!path) return null
    try {
      const r = await fetch(path, { cache: 'no-store' })
      if (!r.ok) return null
      const blob = await r.blob()
      return await new Promise((resolve) => {
        const fr = new FileReader()
        fr.onload = () => resolve(fr.result)
        fr.onerror = () => resolve(null)
        fr.readAsDataURL(blob)
      })
    } catch (_) {
      return null
    }
  }
  const logoPath = mediaUrl(site.settings.brand.logo)
  return (await tryFetch(logoPath))
    || (await tryFetch('/assets/logo.png'))
    || (await tryFetch('/assets/icons/apple-touch-icon.png'))
}

// Génère un document imprimable (PDF via la boîte d'impression du navigateur) reprenant
// le classement final, les classements intermédiaires (round robin / groupes) et la liste
// des résultats de matchs du tournoi sélectionné -- même mécanisme que les exports de
// ClassementView/JourneesView (fenêtre HTML autonome, @page en paysage vu la largeur des tableaux).
async function printTournamentResults() {
  if (!selected.value) return
  printing.value = true
  try {
    const t = selected.value
    const format = t.format
    const logo = await logoDataURL()
    const css = '@page{size:A4 landscape;margin:12mm;}body{font:12px/1.4 "Segoe UI",Roboto,Arial,sans-serif;color:#111;}h1{font-size:20px;margin:0 0 4px;display:flex;align-items:center;gap:8px}h1 img{height:30px}h2{font-size:14px;margin:16px 0 6px;font-weight:700}h3{font-size:12px;margin:10px 0 4px;font-weight:700}.meta{color:#555;font-size:11px;margin-bottom:10px}table{width:100%;border-collapse:collapse;border:1px solid #ccc;margin-bottom:10px}th,td{border:1px solid #ccc;padding:4px 8px;text-align:center}thead th{background:#f0f0f0;font-weight:700}td.name{text-align:left}.winner-box{text-align:center;margin:8px 0 14px;padding:10px;border-radius:8px;background:#fffbeb;border:2px solid #ca8a04;font-weight:900;color:#78350f;font-size:16px}'

    let html = `<!doctype html><html lang="fr"><head><meta charset="utf-8"/><title>${escapeHtml(t.name)}</title><style>${css}</style></head><body onload="window.print()">`
    html += `<h1>${logo ? `<img src="${logo}" alt="logo">` : ''}GOUZEPE GAMING CLUB — ${escapeHtml(t.name)}</h1>`
    html += `<div class="meta">${escapeHtml(formatLabel(format))} · ${escapeHtml(statusLabel(t.status))}${t.participants?.length ? ` · ${t.participants.length} participants` : ''}</div>`

    if (t.winner_name && t.status === 'completed') {
      html += `<div class="winner-box">🏆 Vainqueur : ${escapeHtml(t.winner_name)}</div>`
    }

    if (showFinalStandings.value) {
      html += '<h2>Classement final</h2><table><thead><tr><th>Rang</th><th class="name">Joueur</th><th>V</th><th>D</th><th>Étape</th></tr></thead><tbody>'
      for (const row of finalStandings.value) {
        html += `<tr><td>${row.rank}</td><td class="name">${escapeHtml(row.player_id || row.name)}</td><td>${row.wins}</td><td>${row.losses}</td><td>${escapeHtml(row.stage || '')}</td></tr>`
      }
      html += '</tbody></table>'
    }

    const standingsTable = (rows) => {
      let h = '<table><thead><tr><th>#</th><th class="name">Joueur</th><th>J</th><th>V</th><th>N</th><th>D</th><th>BM</th><th>BC</th><th>Diff</th><th>Pts</th></tr></thead><tbody>'
      rows.forEach((s, idx) => {
        h += `<tr><td>${idx + 1}</td><td class="name">${escapeHtml(s.name)}</td><td>${playedOf(s)}</td><td>${winOf(s)}</td><td>${drawOf(s)}</td><td>${lossOf(s)}</td><td>${bfOf(s)}</td><td>${bcOf(s)}</td><td>${diffOf(s)}</td><td><b>${ptsOf(s)}</b></td></tr>`
      })
      return h + '</tbody></table>'
    }

    if (format === 'round_robin' && rrStandings.value.length) {
      html += '<h2>Classement</h2>' + standingsTable(rrStandings.value)
    }

    if (format === 'groups_knockout' && groupStandings.value.length) {
      html += '<h2>Classements des groupes</h2>'
      for (const grp of groupStandings.value) {
        html += `<h3>Groupe ${groupLabel(grp.group_no)}</h3>` + standingsTable(grp.standings || [])
      }
    }

    const played = matches.value
      .filter((m) => m.score1 != null && m.score2 != null)
      .slice()
      .sort((a, b) => (a.round_no - b.round_no) || (a.slot_no - b.slot_no))
    const resultRows = buildResultRows(played, format, t.rr_match_mode)
    if (resultRows.length) {
      html += '<h2>Résultats des matchs</h2><table><thead><tr><th>Phase</th><th class="name">Joueur 1</th><th>Score</th><th class="name">Joueur 2</th></tr></thead><tbody>'
      for (const r of resultRows) {
        html += `<tr><td>${escapeHtml(r.phase)}</td><td class="name">${escapeHtml(r.p1)}</td><td><b>${escapeHtml(r.score)}</b></td><td class="name">${escapeHtml(r.p2)}</td></tr>`
      }
      html += '</tbody></table>'
    }

    html += '</body></html>'

    const url = URL.createObjectURL(new Blob([html], { type: 'text/html' }))
    const w = window.open(url, '_blank')
    if (!w) { toastError('Popup bloquée. Autorise les popups pour télécharger les résultats.'); return }
    w.addEventListener('unload', () => URL.revokeObjectURL(url), { once: true })
  } catch (_) {
    toastError('Erreur lors de la génération du document')
  } finally {
    printing.value = false
  }
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
  overflow-x: auto;
  overflow-y: visible;
  -webkit-overflow-scrolling: touch;
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

/* ── Quick pick buttons ── */
.quick-pick-btn {
  font-size: 0.78rem; font-weight: 600;
  padding: 0.35rem 0.85rem; border-radius: 99px;
  border: 1px solid rgba(148,163,184,.25);
  background: color-mix(in srgb, var(--panel) 80%, transparent);
  color: var(--muted); cursor: pointer;
  transition: border-color .2s, color .2s, background .2s;
  display: inline-flex; align-items: center; gap: 0.3rem;
}
.quick-pick-btn:hover { border-color: rgba(34,197,94,.4); color: var(--text); background: rgba(34,197,94,.07); }

/* ── Tournament header card ── */
.tournament-header-card {
  background: color-mix(in srgb, var(--panel) 90%, transparent);
  border: 1px solid rgba(148,163,184,.15);
  border-radius: 16px;
  padding: 1.25rem 1.5rem;
}
.th-top { display: flex; align-items: center; gap: 0.6rem; flex-wrap: wrap; margin-bottom: 0.5rem; }
.th-status-badge {
  display: inline-flex; align-items: center; gap: 0.35rem;
  font-size: 0.68rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.07em;
  padding: 3px 10px; border-radius: 99px;
}
.th-live { background: rgba(34,197,94,.12); color: #22c55e; }
.th-done { background: rgba(148,163,184,.1); color: var(--muted); }
.th-draft { background: rgba(95,141,255,.12); color: #5f8dff; }
.th-live-dot { width: 6px; height: 6px; border-radius: 50%; background: #22c55e; animation: pulse 1.5s infinite; }
@keyframes pulse { 0%,100%{opacity:1} 50%{opacity:.4} }
.th-format { font-size: 0.78rem; color: var(--muted); }
.th-participants { font-size: 0.78rem; color: var(--muted); }
.th-download-btn {
  display: inline-flex; align-items: center; gap: 0.4rem; margin-left: auto;
  font-size: 0.75rem; font-weight: 700; color: var(--text);
  background: color-mix(in srgb, var(--panel) 85%, transparent);
  border: 1px solid rgba(148,163,184,.2); border-radius: 10px;
  padding: 0.4rem 0.75rem; cursor: pointer; transition: border-color .15s, background .15s;
}
.th-download-btn:hover:not(:disabled) { border-color: rgba(34,197,94,.4); background: rgba(34,197,94,.08); }
.th-download-btn:disabled { opacity: .6; cursor: not-allowed; }
.th-title { font-size: 1.35rem; font-weight: 800; font-family: var(--font-title); margin-bottom: 0.5rem; }
.th-winner {
  display: inline-flex; align-items: center; gap: 0.5rem;
  background: rgba(251,191,36,.08); border: 1px solid rgba(251,191,36,.2);
  border-radius: 10px; padding: 0.4rem 0.85rem; font-size: 0.85rem;
}
.th-winner-crown { font-size: 1rem; }
.th-winner-crown-icon { width: 1.2rem; height: 1.2rem; color: #eab308; }
.th-winner-label { color: var(--muted); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.06em; font-weight: 700; }
.th-winner-name { font-weight: 800; color: #fbbf24; }

.empty-main {
  min-height: 420px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: color-mix(in srgb, var(--panel) 60%, transparent);
  border: 1px dashed rgba(148,163,184,.15);
  border-radius: 20px;
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
