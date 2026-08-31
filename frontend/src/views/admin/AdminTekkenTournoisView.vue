<template>
  <AppLayout season-label="Admin Tournois Tekken">
    <div class="page-wrap admin-tournois-wrap">
      <div class="mb-4">
        <RouterLink to="/admin/tekken" class="text-sm text-gz-muted hover:text-gz-text transition-colors">&larr; Admin Tekken</RouterLink>
      </div>
      <div class="grid grid-cols-1 xl:grid-cols-[320px_minmax(0,1fr)] gap-4 md:gap-6 items-start">
        <aside class="space-y-4 reveal admin-sidebar">
          <section class="card">
            <h2 class="font-semibold text-gz-text mb-4">Nouveau tournoi</h2>
            <div class="space-y-3">
              <div>
                <label class="label">Nom</label>
                <input v-model="newT.name" type="text" class="input" placeholder="Cup #1" />
              </div>
              <div>
                <label class="label">Format</label>
                <select v-model="newT.format" class="input">
                  <option value="single_elimination">Elimination simple</option>
                  <option value="double_elimination">Double elimination</option>
                  <option value="round_robin">Round Robin</option>
                  <option value="groups_knockout">Groupes + Finales</option>
                </select>
              </div>
              <template v-if="newT.format === 'round_robin'">
                <div>
                  <label class="label">Mode matchs (Round Robin)</label>
                  <select v-model="newT.rrMatchMode" class="input">
                    <option value="single">Match simple</option>
                    <option value="home_away">Aller / Retour</option>
                  </select>
                </div>
              </template>
              <div>
                <label class="label">Date & heure</label>
                <input v-model="newT.startsAtInput" type="datetime-local" class="input" />
              </div>
              <div class="space-y-2">
                <div class="pl-5 space-y-1.5 border-l-2 border-gz-green/30">
                  <p class="text-xs text-gz-muted font-medium">Comptant pour le ladder ELO ?</p>
                  <div class="flex gap-4">
                    <label class="inline-flex items-center gap-1.5 text-sm cursor-pointer">
                      <input v-model="newT.countsForTitle" type="radio" :value="true" class="accent-[var(--green)]" />
                      <span class="text-gz-text">Oui</span>
                    </label>
                    <label class="inline-flex items-center gap-1.5 text-sm cursor-pointer">
                      <input v-model="newT.countsForTitle" type="radio" :value="false" class="accent-[var(--green)]" />
                      <span class="text-gz-text">Non</span>
                    </label>
                  </div>
                  <p class="text-[11px] text-gz-muted leading-snug">
                    <span v-if="newT.countsForTitle">Les resultats impacteront le classement ELO.</span>
                    <span v-else>Tournoi amical -- sans impact sur le ladder ELO.</span>
                  </p>
                </div>
              </div>
              <button @click="createTournament" :disabled="creating" class="btn-primary w-full justify-center" title="Creer un tournoi">
                <Loader2Icon v-if="creating" class="w-3.5 h-3.5 animate-spin" />
                <PlusIcon v-else class="w-3.5 h-3.5" />
                Creer
              </button>
            </div>
          </section>

          <section class="card">
            <h2 class="font-semibold text-gz-text mb-3">Tournois</h2>
            <div v-if="loadingList" class="text-gz-muted text-sm text-center py-4">Chargement...</div>
            <div v-else class="space-y-1 sidebar-scroll pr-1">
              <button
                v-for="t in tournaments"
                :key="t.id"
                @click="selectTournament(t)"
                :class="[
                  'w-full text-left px-3 py-2 rounded-lg border text-sm transition-all',
                  selected?.id === t.id
                    ? 'border-gz-green/50 bg-gz-green/8 text-gz-text shadow-sm'
                    : 'border-transparent hover:border-gz-border hover:bg-gz-card text-gz-muted'
                ]"
                :title="`Ouvrir ${t.name}`"
              >
                <div class="font-medium truncate">{{ t.name }}</div>
                <BaseBadge :variant="statusVariant(t.status)" class="text-[10px] mt-0.5">
                  {{ statusLabel(t.status) }}
                </BaseBadge>
              </button>
              <p v-if="!tournaments.length" class="text-gz-muted text-sm text-center py-3">Aucun tournoi.</p>
            </div>
          </section>
        </aside>

        <main class="min-w-0 space-y-4">
          <section v-if="!selected" class="card reveal delay-1 text-gz-muted text-sm py-12 text-center">
            Selectionne ou cree un tournoi Tekken.
          </section>

          <template v-else>
            <section class="card reveal delay-1">
              <div class="flex items-start justify-between flex-wrap gap-3">
                <div>
                  <h1 class="text-xl font-bold text-gz-text">{{ selected.name }}</h1>
                  <div class="flex gap-2 mt-1 flex-wrap">
                    <BaseBadge :variant="statusVariant(selected.status)">{{ statusLabel(selected.status) }}</BaseBadge>
                    <span class="text-sm text-gz-muted">{{ formatLabel(selected.format) }}</span>
                    <span v-if="selected.format === 'round_robin'" class="text-sm text-gz-muted">
                      • {{ rrMatchModeLabel(selected.rr_match_mode) }}
                    </span>
                    <span class="text-sm text-gz-muted">
                      <template v-if="selected.counts_for_title">• Tournoi membre <span class="text-gz-green font-medium">· Compte pour le ladder ELO</span></template>
                      <template v-else>• Tournoi membre <span class="text-gz-muted">· Amical</span></template>
                    </span>
                    <span v-if="selected.participants?.length" class="text-sm text-gz-muted">• {{ selected.participants.length }} participants</span>
                  </div>
                </div>

                <div class="admin-actions">
                  <button
                    v-if="selected.status === 'draft'"
                    @click="generateBracket"
                    :disabled="generating"
                    class="btn-primary w-full sm:w-auto justify-center"
                    title="Generer le bracket"
                  >
                    <Loader2Icon v-if="generating" class="w-3.5 h-3.5 animate-spin" />
                    Generer le bracket
                  </button>

                  <button
                    v-if="selected.status !== 'live' && selected.status !== 'archived'"
                    @click="changeStatus('live')"
                    class="btn w-full sm:w-auto justify-center"
                    title="Passer en direct"
                  >
                    En direct
                  </button>

                  <button
                    v-if="selected.status === 'live'"
                    @click="changeStatus('completed')"
                    class="btn w-full sm:w-auto justify-center"
                    title="Passer en termine"
                  >
                    Terminer
                  </button>

                  <button
                    v-if="selected.status !== 'cancelled' && selected.status !== 'archived' && selected.status !== 'completed'"
                    @click="changeStatus('cancelled')"
                    class="btn btn-ghost w-full sm:w-auto justify-center text-gz-red"
                    title="Annuler ce tournoi"
                  >
                    Annuler
                  </button>

                  <button
                    v-if="selected.status === 'completed' || selected.status === 'cancelled'"
                    @click="changeStatus('archived')"
                    class="btn w-full sm:w-auto justify-center"
                    title="Archiver ce tournoi"
                  >
                    Archiver
                  </button>

                  <button
                    v-if="selected.status === 'completed' || selected.status === 'archived'"
                    @click="printTournamentResults"
                    :disabled="printing"
                    class="btn w-full sm:w-auto justify-center"
                    title="Télécharger les résultats en PDF"
                  >
                    <Loader2Icon v-if="printing" class="w-3.5 h-3.5 animate-spin" />
                    <DownloadIcon v-else class="w-3.5 h-3.5" />
                    Télécharger les résultats
                  </button>

                  <button @click="deleteTournament" class="btn-danger w-full sm:w-auto justify-center" title="Supprimer ce tournoi">
                    <Trash2Icon class="w-3.5 h-3.5" />
                    Supprimer
                  </button>
                </div>
              </div>
              <div class="grid grid-cols-1 lg:grid-cols-[minmax(0,1fr)_auto] gap-3 mt-3">
                <div class="space-y-2">
                  <div>
                    <label class="label">Date & heure du tournoi</label>
                    <input v-model="selectedStartsAtInput" type="datetime-local" class="input" />
                  </div>
                  <div>
                    <label class="label">Commentaire du tournoi (affiche sur l'accueil a cette date)</label>
                    <textarea
                      v-model="selectedDayComment"
                      class="input min-h-[92px]"
                      placeholder="Commentaire de la journee tournoi..."
                    />
                  </div>
                  <template v-if="selected?.format === 'round_robin'">
                    <div>
                      <label class="label">Mode matchs (Round Robin)</label>
                      <select v-model="selectedRrMatchMode" class="input">
                        <option value="single">Match simple</option>
                        <option value="home_away">Aller / Retour</option>
                      </select>
                    </div>
                  </template>
                </div>
                <div class="flex items-end">
                  <button @click="saveTournamentMeta" :disabled="savingMeta" class="btn w-full lg:w-auto justify-center" title="Sauvegarder date, heure et commentaire">
                    <Loader2Icon v-if="savingMeta" class="w-3.5 h-3.5 animate-spin" />
                    Enregistrer meta
                  </button>
                </div>
              </div>
            </section>

            <section v-if="selected.status === 'draft'" class="card reveal delay-2">
              <h3 class="font-semibold text-gz-text mb-3">
                Participants ({{ selected.participants?.length || 0 }})
              </h3>

              <div class="space-y-2 mb-3">
                <!-- Comptant pour le ladder ELO -->
                <div class="pl-5 space-y-1.5 border-l-2 border-gz-green/30">
                  <p class="text-xs text-gz-muted font-medium">Comptant pour le ladder ELO ?</p>
                  <div class="flex gap-4">
                    <label class="inline-flex items-center gap-1.5 text-sm cursor-pointer">
                      <input
                        :checked="selected.counts_for_title === true"
                        @change="setCountsForTitle(true)"
                        type="radio"
                        name="counts_for_title"
                        class="accent-[var(--green)]"
                      />
                      <span class="text-gz-text">Oui</span>
                      <span class="text-[11px] text-gz-muted">(ELO impacte)</span>
                    </label>
                    <label class="inline-flex items-center gap-1.5 text-sm cursor-pointer">
                      <input
                        :checked="selected.counts_for_title !== true"
                        @change="setCountsForTitle(false)"
                        type="radio"
                        name="counts_for_title"
                        class="accent-[var(--green)]"
                      />
                      <span class="text-gz-text">Non</span>
                      <span class="text-[11px] text-gz-muted">(amical)</span>
                    </label>
                  </div>
                </div>
              </div>

              <div class="space-y-2 mb-3">
                <input
                  v-model="memberSelectionSearch"
                  type="text"
                  class="input"
                  placeholder="Rechercher un joueur..."
                />
                <div class="member-picker">
                  <label
                    v-for="p in filteredMemberPlayers"
                    :key="p.player_id"
                    class="member-picker-item"
                  >
                    <input
                      v-model="memberSelection"
                      type="checkbox"
                      :value="p.player_id"
                      class="accent-[var(--green)]"
                    />
                    <span class="truncate">{{ p.name || p.player_id }}</span>
                    <span class="text-gz-muted text-xs">({{ p.player_id }})</span>
                  </label>
                </div>
                <div class="flex gap-2 flex-col sm:flex-row sm:items-center">
                  <button
                    @click="applyMemberSelection"
                    :disabled="memberSelection.length < 2"
                    class="btn w-full sm:w-auto justify-center"
                    title="Valider les joueurs coches"
                  >
                    Valider la selection
                  </button>
                  <button
                    @click="memberSelection = []"
                    class="btn w-full sm:w-auto justify-center"
                    title="Tout decocher"
                  >
                    Tout decocher
                  </button>
                  <span class="text-xs text-gz-muted">{{ memberSelection.length }} selectionne(s)</span>
                </div>
              </div>

              <div class="flex flex-wrap gap-2">
                <div
                  v-for="pid in selected.participants || []"
                  :key="pid"
                  class="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-gz-panel border border-gz-border text-sm"
                >
                  {{ playerName(pid) }}
                  <button @click="removeParticipant(pid)" class="text-gz-muted hover:text-gz-red transition-colors" title="Retirer ce participant">
                    <XIcon class="w-3 h-3" />
                  </button>
                </div>
              </div>
            </section>

            <section v-if="selected.status !== 'draft'" class="card bracket-shell reveal delay-2">
              <div v-if="loadingBracket" class="text-gz-muted text-sm py-8 text-center">Chargement...</div>
              <template v-else>
                <BracketSE
                  v-if="selected.format === 'single_elimination'"
                  :matches="matches"
                  :admin-mode="true"
                  :persist-key="`tk-tournois-admin-${selected?.id || 'none'}-se`"
                  @score-saved="onScoreSaved"
                />
                <BracketDE
                  v-else-if="selected.format === 'double_elimination'"
                  :matches="matches"
                  :admin-mode="true"
                  :persist-key="`tk-tournois-admin-${selected?.id || 'none'}-de`"
                  @score-saved="onScoreSaved"
                />
                <template v-else-if="selected.format === 'round_robin'">
                  <BracketRR
                    :matches="matches"
                    :standings="rrStandings"
                    :standings-mode="selected.rr_standings_mode || 'wins'"
                    :admin-mode="true"
                    @score-saved="onScoreSaved"
                    @show-saisie-rapide="showSaisieRapide = true"
                  />
                  <ScoreSaisieRapide
                    v-if="showSaisieRapide"
                    :pair-rows="rrPairRows"
                    :has-retour="selected.rr_match_mode === 'home_away'"
                    :cache-key="`t-${selected.id}`"
                    @close="showSaisieRapide = false"
                    @batch-save="onBatchScoresSaved"
                  />
                </template>
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
                        <BracketRR
                          :matches="grp.matches"
                          :standings="[]"
                          :admin-mode="true"
                          @score-saved="onScoreSaved"
                        />
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
                    <BracketSE
                      v-if="knockoutMatches.length"
                      :matches="knockoutMatches"
                      :admin-mode="true"
                      :persist-key="`tk-tournois-admin-${selected?.id || 'none'}-gk-ko`"
                      @score-saved="onScoreSaved"
                    />
                    <div v-else class="py-4 space-y-3">
                      <div class="text-sm text-gz-muted">Tableau final non genere pour ce tournoi.</div>
                      <button
                        v-if="shouldShowKnockoutGenerate"
                        @click="generateKnockoutFromGroups()"
                        :disabled="generatingKnockout"
                        class="btn-primary w-full sm:w-auto justify-center"
                        title="Generer le tableau final depuis les groupes"
                      >
                        <Loader2Icon v-if="generatingKnockout" class="w-3.5 h-3.5 animate-spin" />
                        Generer le tableau final
                      </button>
                    </div>
                  </section>
                </div>
              </template>
            </section>
          </template>
        </main>
      </div>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import AppLayout from '@/components/layout/AppLayout.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'
import BracketSE from '@/components/tournament/BracketSE.vue'
import BracketDE from '@/components/tournament/BracketDE.vue'
import BracketRR from '@/components/tournament/BracketRR.vue'
import ScoreSaisieRapide from '@/components/tournament/ScoreSaisieRapide.vue'
import { useAPI, mediaUrl } from '@/composables/useAPI'
import { useToast } from '@/composables/useToast'
import { useSessionState } from '@/composables/useSessionState'
import { useSiteSettings } from '@/stores/siteSettings'
import { onRealtimeEvent, joinRealtimeRoom, leaveRealtimeRoom } from '@/composables/useRealtimeSocket'
import { applyIdStandings } from '@/utils/tournamentLabels'
import { PlusIcon, Trash2Icon, XIcon, Loader2Icon, ZapIcon, DownloadIcon } from 'lucide-vue-next'

const api = useAPI()
const site = useSiteSettings()
const printing = ref(false)
const { success, error: toastError } = useToast()

// Écho temps réel de nos propres sauvegardes (voir AdminTournoisView.vue) : sans ce garde-fou,
// chaque score enregistré redéclenchait un re-fetch complet + saut de scroll en plus de la mise
// à jour déjà faite localement -- rafraîchissement visible "en boucle" en saisie rapide.
let lastLocalSaveAt = 0
const REALTIME_ECHO_GRACE_MS = 4000

const tournaments = ref([])
const selected = ref(null)
const matches = ref([])
const rrStandings = ref([])
const groupStandings = ref([])
const allPlayers = ref([])
const loadingList = ref(false)
const loadingBracket = ref(false)
const creating = ref(false)
const showSaisieRapide = ref(false)
const generating = ref(false)
const generatingKnockout = ref(false)
const savingMeta = ref(false)
const memberSelection = ref([])
const memberSelectionSearch = ref('')
const manualNamesText = ref('')
const selectedStartsAtInput = ref('')
const selectedDayComment = ref('')
const selectedRrMatchMode = ref('single')
const newT = ref({
  name: '',
  format: 'single_elimination',
  startsAtInput: '',
  memberTournament: true,
  countsForTitle: false,
  rrMatchMode: 'single',
})
const selectedTournamentId = ref(null)
let realtimeOffTournamentChanged = null
let joinedTournamentRoom = ''

useSessionState('tekken.ui.admin.tournois.v1', {
  selectedTournamentId,
  selectedStartsAtInput,
  selectedDayComment,
  selectedRrMatchMode,
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

const allGroupMatchesCompleted = computed(() => {
  if (!groupMatches.value.length) return false
  return groupMatches.value.every(isMatchCompleted)
})

const shouldShowKnockoutGenerate = computed(() => (
  selected.value?.format === 'groups_knockout'
  && allGroupMatchesCompleted.value
  && knockoutMatches.value.length === 0
))

const filteredMemberPlayers = computed(() => {
  const q = String(memberSelectionSearch.value || '').trim().toLowerCase()
  return allPlayers.value
    .filter((p) => {
      const game = String(p?.main_game || '').toLowerCase()
      return game === 'tekken' || game === 'both'
    })
    .filter((p) => {
      if (!q) return true
      const name = String(p?.name || '').toLowerCase()
      const pid = String(p?.player_id || '').toLowerCase()
      return name.includes(q) || pid.includes(q)
    })
})
const isMemberTournament = computed(() => selected.value?.member_tournament !== false)

function playerName(pid) {
  return String(pid || '')
}

function playerDisplay(player) {
  return String(player?.name || player?.player_id || '').trim()
}

function mapParticipantsToMemberIds(participants) {
  const tokens = (participants || []).map((x) => String(x || '').trim()).filter(Boolean)
  const byId = new Map(allPlayers.value.map((p) => [String(p.player_id).toLowerCase(), p.player_id]))
  const byName = new Map()
  for (const p of allPlayers.value) {
    const key = String(p?.name || '').trim().toLowerCase()
    if (!key) continue
    if (!byName.has(key)) byName.set(key, [])
    byName.get(key).push(String(p.player_id))
  }

  const out = []
  const seen = new Set()
  for (const token of tokens) {
    const key = token.toLowerCase()
    let pid = byId.get(key) || null
    if (!pid) {
      const candidates = byName.get(key) || []
      if (candidates.length === 1) pid = candidates[0]
    }
    if (pid && !seen.has(pid)) {
      seen.add(pid)
      out.push(pid)
    }
  }
  return out
}

function syncMemberSelectionFromParticipants() {
  memberSelection.value = mapParticipantsToMemberIds(selected.value?.participants || [])
}

function capturePageScroll() {
  const root = document.scrollingElement || document.documentElement
  return {
    x: window.scrollX || window.pageXOffset || root?.scrollLeft || 0,
    y: window.scrollY || window.pageYOffset || root?.scrollTop || 0,
  }
}

function restorePageScroll(pos, frames = 8) {
  if (!pos) return
  const x = Math.max(0, Number(pos.x) || 0)
  const y = Math.max(0, Number(pos.y) || 0)
  const apply = () => window.scrollTo(x, y)
  apply()
  let n = 0
  const tick = () => {
    n += 1
    apply()
    if (n < frames) requestAnimationFrame(tick)
  }
  requestAnimationFrame(tick)
  setTimeout(apply, 30)
  setTimeout(apply, 120)
}

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
    if (Date.now() - lastLocalSaveAt < REALTIME_ECHO_GRACE_MS) return
    try {
      const { data } = await api.get('/tekken/tournaments')
      tournaments.value = data.tournaments || []
      if (selected.value?.id === tournamentId) {
        const scrollPos = capturePageScroll()
        const fresh = tournaments.value.find((t) => Number(t.id) === tournamentId)
        if (fresh) {
          await selectTournament(fresh)
          await nextTick()
          restorePageScroll(scrollPos)
        }
        else {
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

onMounted(async () => {
  bindRealtimeListeners()
  loadingList.value = true
  try {
    const [tRes, pRes] = await Promise.all([api.get('/tekken/tournaments'), api.get('/players')])
    tournaments.value = tRes.data.tournaments || []
    allPlayers.value = (pRes.data.players || []).sort((a, b) =>
      (a.name || a.player_id).localeCompare(b.name || b.player_id, 'fr')
    )
    const wantedId = Number(selectedTournamentId.value || 0)
    if (wantedId > 0) {
      const found = tournaments.value.find((t) => Number(t.id) === wantedId)
      if (found) await selectTournament(found)
    }
  } catch (_) {}
  loadingList.value = false
})

onUnmounted(() => {
  if (joinedTournamentRoom) void leaveRealtimeRoom(joinedTournamentRoom).catch(() => {})
  joinedTournamentRoom = ''
  unbindRealtimeListeners()
})

async function createTournament() {
  if (!newT.value.name.trim()) return
  creating.value = true
  try {
    const startsAt = String(newT.value.startsAtInput || '').trim()
    const { data } = await api.post('/admin/tekken/tournaments', {
      name: newT.value.name,
      format: newT.value.format,
      starts_at: startsAt || null,
      member_tournament: true,
      counts_for_title: !!newT.value.countsForTitle,
      rr_match_mode: newT.value.format === 'round_robin' ? newT.value.rrMatchMode : 'single',
    })
    const t = data.tournament || data
    tournaments.value.unshift(t)
    newT.value = {
      name: '',
      format: 'single_elimination',
      startsAtInput: '',
      memberTournament: true,
      countsForTitle: false,
      rrMatchMode: 'single',
    }
    selectTournament(t)
    success('Tournoi cree')
  } catch (e) {
    toastError(e.response?.data?.error || 'Erreur')
  }
  creating.value = false
}

async function selectTournament(t) {
  selectedTournamentId.value = Number(t?.id || 0) || null
  matches.value = []
  rrStandings.value = []
  groupStandings.value = []
  loadingBracket.value = true
  try {
    const { data } = await api.get(`/tekken/tournaments/${t.id}`)
    const tournament = data.tournament || t
    const participants = Array.isArray(data.participants) ? data.participants : []

    const participantNames = participants
      .map((p) => String(p.player_id || p.display_name || p.name || '').trim())
      .filter(Boolean)

    selected.value = {
      ...tournament,
      member_tournament: tournament.member_tournament !== false,
      participants: participantNames,
      participants_count: tournament.participants_count ?? participantNames.length,
    }
    await syncTournamentRoom(selected.value.id)
    syncMemberSelectionFromParticipants()
    selectedStartsAtInput.value = toDatetimeLocalValue(tournament.starts_at)
    selectedDayComment.value = String(tournament.day_comment || '')
    selectedRrMatchMode.value = String(tournament.rr_match_mode || 'single')
    matches.value = normalizeMatches(data.matches || [], tournament.format)

    if (tournament.format === 'round_robin' || tournament.format === 'groups_knockout') {
      const { data: s } = await api.get(`/tekken/tournaments/${t.id}/standings`)
      if (tournament.format === 'round_robin') {
        rrStandings.value = applyIdStandings(s.standings || [], true)
        groupStandings.value = []
      } else {
        rrStandings.value = []
        groupStandings.value = (s.groups || []).map((g) => ({ ...g, standings: applyIdStandings(g.standings || [], true) }))
      }
    }
  } catch (_) {}
  loadingBracket.value = false
}

async function removeParticipant(pid) {
  const names = (selected.value.participants || []).filter((p) => p !== pid)
  if (names.length < 2) {
    toastError('Il faut au moins 2 participants')
    return
  }
  await updateParticipants(names)
}

async function applyManualParticipants() {
  const names = parseManualNames(manualNamesText.value)
  if (names.length < 2) {
    toastError('Il faut au moins 2 participants')
    return
  }
  await updateParticipants(names)
}

async function applyMemberSelection() {
  if (!selected.value) return
  const ids = [...new Set((memberSelection.value || []).map((x) => String(x || '').trim()).filter(Boolean))]
  if (ids.length < 2) {
    toastError('Il faut au moins 2 participants')
    return
  }
  await updateParticipants(ids)
}

async function setTournamentMemberMode(enabled) {
  if (!selected.value) return
  try {
    const { data } = await api.patch(`/admin/tekken/tournaments/${selected.value.id}`, {
      member_tournament: !!enabled,
      ...(!enabled ? { counts_for_title: false } : {}),
    })
    const tournament = data.tournament || selected.value
    selected.value = {
      ...selected.value,
      ...tournament,
      member_tournament: tournament.member_tournament !== false,
      counts_for_title: enabled ? (tournament.counts_for_title ?? false) : false,
    }
    const idx = tournaments.value.findIndex((t) => t.id === selected.value.id)
    if (idx !== -1) {
      tournaments.value[idx] = {
        ...tournaments.value[idx],
        member_tournament: selected.value.member_tournament,
      }
    }
    if (enabled) {
      manualNamesText.value = ''
      syncMemberSelectionFromParticipants()
    } else {
      memberSelection.value = []
      manualNamesText.value = (selected.value.participants || []).join('\n')
    }
  } catch (e) {
    toastError(e.response?.data?.error || 'Erreur')
  }
}

async function setCountsForTitle(value) {
  if (!selected.value) return
  try {
    const { data } = await api.patch(`/admin/tekken/tournaments/${selected.value.id}`, { counts_for_title: !!value })
    const tournament = data.tournament || selected.value
    selected.value = { ...selected.value, ...tournament, counts_for_title: !!value }
    const idx = tournaments.value.findIndex((t) => t.id === selected.value.id)
    if (idx !== -1) tournaments.value[idx] = { ...tournaments.value[idx], counts_for_title: !!value }
    success(value ? 'Tournoi comptant pour le ladder ELO' : 'Tournoi amical (pas d\'impact ELO)')
  } catch (e) {
    toastError(e.response?.data?.error || 'Erreur')
  }
}

async function updateParticipants(namesRaw) {
  const names = parseManualNames(Array.isArray(namesRaw) ? namesRaw.join('\n') : String(namesRaw || ''))
  try {
    const { data } = await api.put(`/admin/tekken/tournaments/${selected.value.id}/participants`, { names })
    const participantNames = (data.participants || [])
      .map((p) => String(p.player_id || p.display_name || p.name || '').trim())
      .filter(Boolean)
    const tournament = data.tournament || selected.value
    selected.value = {
      ...selected.value,
      ...tournament,
      member_tournament: tournament.member_tournament !== false,
      participants: participantNames,
      participants_count: participantNames.length,
    }
    if (selected.value.member_tournament !== false) {
      syncMemberSelectionFromParticipants()
    }
  } catch (e) {
    toastError(e.response?.data?.error || 'Erreur')
  }
}

function parseManualNames(input) {
  const tokens = String(input || '')
    .split(/[\n,;]+/)
    .map((s) => s.trim())
    .filter(Boolean)
    .slice(0, 256)

  const out = []
  const seen = new Set()
  for (const n of tokens) {
    const key = n.toLowerCase()
    if (!seen.has(key)) {
      seen.add(key)
      out.push(n)
    }
  }
  return out
}

async function generateBracket() {
  generating.value = true
  try {
    await api.post(`/admin/tekken/tournaments/${selected.value.id}/generate`)
    const { data } = await api.get('/tekken/tournaments')
    tournaments.value = data.tournaments || []
    const fresh = tournaments.value.find((t) => t.id === selected.value.id)
    if (fresh) await selectTournament(fresh)
    success('Bracket genere')
  } catch (e) {
    toastError(e.response?.data?.error || 'Erreur')
  }
  generating.value = false
}

async function changeStatus(status) {
  try {
    await api.put(`/admin/tekken/tournaments/${selected.value.id}`, { status })
    selected.value = { ...selected.value, status }
    const idx = tournaments.value.findIndex((t) => t.id === selected.value.id)
    if (idx !== -1) tournaments.value[idx] = { ...tournaments.value[idx], status }
    success('Statut mis a jour')
  } catch (e) {
    toastError(e.response?.data?.error || 'Erreur')
  }
}

async function deleteTournament() {
  if (!selected.value) return
  const isMember = selected.value.member_tournament !== false
  const firstMessage = isMember
    ? `Supprimer le tournoi membre "${selected.value.name}" ?\n\nAttention: cette suppression retirera aussi ses points du classement general.`
    : `Supprimer le tournoi "${selected.value.name}" ?`
  if (!confirm(firstMessage)) return

  let payload = undefined
  if (isMember) {
    const second = confirm('Confirmation finale: supprimer ce tournoi membre et recalculer le classement sans ses points ?')
    if (!second) return
    payload = { confirm_member_delete: true, confirm_points_reset: true }
  }
  try {
    await api.delete(`/admin/tekken/tournaments/${selected.value.id}`, payload ? { data: payload } : undefined)
    tournaments.value = tournaments.value.filter((t) => t.id !== selected.value.id)
    await syncTournamentRoom(null)
    selectedTournamentId.value = null
    selected.value = null
    success('Tournoi supprime')
  } catch (e) {
    toastError(e.response?.data?.error || 'Erreur')
  }
}

async function onScoreSaved({ matchId, score1, score2, done, fail }) {
  const scrollPos = capturePageScroll()
  try {
    lastLocalSaveAt = Date.now()
    await api.post(`/admin/tekken/tournaments/${selected.value.id}/matches/${matchId}/result`, {
      score_p1: score1,
      score_p2: score2,
    })
    lastLocalSaveAt = Date.now()
    const { data } = await api.get(`/tekken/tournaments/${selected.value.id}`)
    matches.value = normalizeMatches(data.matches || [], selected.value.format)
    if (selected.value.format === 'round_robin' || selected.value.format === 'groups_knockout') {
      const { data: s } = await api.get(`/tekken/tournaments/${selected.value.id}/standings`)
      if (selected.value.format === 'round_robin') {
        rrStandings.value = applyIdStandings(s.standings || [], true)
        groupStandings.value = []
      } else {
        rrStandings.value = []
        groupStandings.value = (s.groups || []).map((g) => ({ ...g, standings: applyIdStandings(g.standings || [], true) }))
      }
    }
    const shouldAutoGenerate = shouldShowKnockoutGenerate.value
    done()
    success('Score enregistre')
    if (shouldAutoGenerate) {
      await generateKnockoutFromGroups({ automatic: true })
    }
    await nextTick()
    restorePageScroll(scrollPos, 14)
  } catch (e) {
    toastError(e.response?.data?.error || 'Erreur')
    fail()
  }
}

async function onBatchScoresSaved({ edits, done, fail }) {
  const scrollPos = capturePageScroll()
  try {
    lastLocalSaveAt = Date.now()
    await Promise.all(edits.map((edit) =>
      api.post(`/admin/tekken/tournaments/${selected.value.id}/matches/${edit.matchId}/result`, {
        score_p1: edit.score1,
        score_p2: edit.score2,
      })
    ))
    lastLocalSaveAt = Date.now()

    const { data } = await api.get(`/tekken/tournaments/${selected.value.id}`)
    matches.value = normalizeMatches(data.matches || [], selected.value.format)

    if (selected.value.format === 'round_robin' || selected.value.format === 'groups_knockout') {
      const { data: s } = await api.get(`/tekken/tournaments/${selected.value.id}/standings`)
      if (selected.value.format === 'round_robin') {
        rrStandings.value = applyIdStandings(s.standings || [], true)
        groupStandings.value = []
      } else {
        rrStandings.value = []
        groupStandings.value = (s.groups || []).map((g) => ({ ...g, standings: applyIdStandings(g.standings || [], true) }))
      }
    }

    done()
    showSaisieRapide.value = false
    success(`${edits.length} score(s) enregistres`)
    await nextTick()
    restorePageScroll(scrollPos, 14)
  } catch (e) {
    toastError(e.response?.data?.error || 'Erreur')
    fail()
  }
}

async function generateKnockoutFromGroups({ automatic = false } = {}) {
  if (!selected.value || selected.value.format !== 'groups_knockout') return false
  if (!allGroupMatchesCompleted.value) return false
  if (generatingKnockout.value) return false

  generatingKnockout.value = true
  try {
    const { data } = await api.post(`/admin/tekken/tournaments/${selected.value.id}/generate-knockout`)
    matches.value = normalizeMatches(data.matches || [], selected.value.format)

    const tournament = data.tournament || null
    if (tournament) {
      selected.value = { ...selected.value, ...tournament }
      const idx = tournaments.value.findIndex((t) => t.id === selected.value.id)
      if (idx !== -1) tournaments.value[idx] = { ...tournaments.value[idx], ...tournament }
    }

    const { data: s } = await api.get(`/tekken/tournaments/${selected.value.id}/standings`)
    rrStandings.value = []
    groupStandings.value = (s.groups || []).map((g) => ({ ...g, standings: applyIdStandings(g.standings || [], true) }))
    success(automatic ? 'Tableau final genere automatiquement' : 'Tableau final genere')
    return true
  } catch (e) {
    const message = String(e.response?.data?.error || '')
    const isPendingGroups = Number(e.response?.status || 0) === 400
      && /phase de groupes|pas encore termin/i.test(message)
    if (!(automatic && isPendingGroups)) {
      toastError(message || 'Generation du tableau final impossible')
    }
    return false
  } finally {
    generatingKnockout.value = false
  }
}

function toDatetimeLocalValue(input) {
  if (!input) return ''
  const d = new Date(input)
  if (Number.isNaN(d.getTime())) return ''
  const pad = (v) => String(v).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`
}

function fromDatetimeLocalValue(input) {
  const raw = String(input || '').trim()
  if (!raw) return null
  const d = new Date(raw)
  if (Number.isNaN(d.getTime())) return null
  return d.toISOString()
}

async function saveTournamentMeta() {
  if (!selected.value) return
  savingMeta.value = true
  try {
    const payload = {
      starts_at: fromDatetimeLocalValue(selectedStartsAtInput.value),
      day_comment: String(selectedDayComment.value || '').trim() || null,
      ...(selected.value?.format === 'round_robin'
        ? {
          rr_match_mode: selectedRrMatchMode.value === 'home_away' ? 'home_away' : 'single',
        }
        : {}),
    }
    const { data } = await api.patch(`/admin/tekken/tournaments/${selected.value.id}`, payload)
    const tournament = data.tournament || selected.value
    selected.value = { ...selected.value, ...tournament }
    selectedStartsAtInput.value = toDatetimeLocalValue(tournament.starts_at)
    selectedDayComment.value = String(tournament.day_comment || '')
    selectedRrMatchMode.value = String(tournament.rr_match_mode || 'single')
    const idx = tournaments.value.findIndex((t) => t.id === selected.value.id)
    if (idx !== -1) tournaments.value[idx] = { ...tournaments.value[idx], ...tournament }
    success('Meta tournoi mise a jour')
  } catch (e) {
    toastError(e.response?.data?.error || 'Erreur')
  }
  savingMeta.value = false
}

function statusVariant(s) {
  return { live: 'green', completed: 'blue', archived: 'muted', draft: 'amber', cancelled: 'red' }[s] ?? 'muted'
}

function statusLabel(s) {
  return { live: 'LIVE', completed: 'Termine', archived: 'Archive', draft: 'Brouillon', cancelled: 'Annule' }[s] ?? s
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

const rrPairRows = computed(() => {
  const pairs = new Map()
  for (const m of matches.value) {
    const p1 = String(m.p1_id ?? '')
    const p2 = String(m.p2_id ?? '')
    const key = p1 && p2 ? [p1, p2].sort().join('||') : `solo-${m.id}`
    if (!pairs.has(key)) pairs.set(key, [])
    pairs.get(key).push(m)
  }
  return [...pairs.values()]
    .map(pair => pair.slice().sort((a, b) => (a.round_no ?? 0) - (b.round_no ?? 0)))
    .sort((a, b) => (a[0]?.id ?? 0) - (b[0]?.id ?? 0))
    .map(pair => {
      const aller = pair[0] || null
      const retour = pair[1] || null
      return {
        nameA: aller?.p1_name || aller?.p1_id || 'TBD',
        nameB: aller?.p2_name || aller?.p2_id || 'TBD',
        idA: aller?.p1_id,
        idB: aller?.p2_id,
        aller,
        retour,
      }
    })
})

function normalizeMatches(rawMatches, format) {
  // Tournoi Tekken = toujours membre : on affiche l'identifiant joueur (player_id).
  return (rawMatches || []).map((m) => {
    const roundNo = Number(m.round_no ?? m.roundNo ?? 0)
    return {
      ...m,
      round_no: roundNo,
      slot_no: Number(m.slot_no ?? m.slotNo ?? 0),
      p1_id: m.p1_id ?? m.p1_participant_id ?? null,
      p2_id: m.p2_id ?? m.p2_participant_id ?? null,
      p1_name: m.p1_player_id || m.p1_name,
      p2_name: m.p2_player_id || m.p2_name,
      winner_name: m.winner_player_id || m.winner_name,
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

function groupLabel(groupNo) {
  const n = Number(groupNo)
  if (!Number.isFinite(n) || n < 0) return '?'
  return String.fromCharCode(65 + n)
}

function isMatchCompleted(match) {
  const status = String(match?.status || '').toLowerCase()
  if (status === 'completed') return true
  const hasScore1 = match?.score1 !== null && match?.score1 !== undefined && match?.score1 !== '' && Number.isFinite(Number(match.score1))
  const hasScore2 = match?.score2 !== null && match?.score2 !== undefined && match?.score2 !== '' && Number.isFinite(Number(match.score2))
  return hasScore1 && hasScore2
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

// Fusionne aller/retour sur une ligne (voir TournoisView.vue) plutôt qu'une ligne par tour.
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

// Même mécanisme que la page publique (TekkenTournoisView.vue), accessible ici une fois le
// tournoi termine/archive -- classement sans colonnes de buts (Tekken classe aux victoires).
async function printTournamentResults() {
  if (!selected.value) return
  printing.value = true
  try {
    const t = selected.value
    const format = t.format
    const logo = await logoDataURL()
    const css = '@page{size:A4 landscape;margin:12mm;}body{font:12px/1.4 "Segoe UI",Roboto,Arial,sans-serif;color:#111;}h1{font-size:20px;margin:0 0 4px;display:flex;align-items:center;gap:8px}h1 img{height:30px}h2{font-size:14px;margin:16px 0 6px;font-weight:700}h3{font-size:12px;margin:10px 0 4px;font-weight:700}.meta{color:#555;font-size:11px;margin-bottom:10px}table{width:100%;border-collapse:collapse;border:1px solid #ccc;margin-bottom:10px}th,td{border:1px solid #ccc;padding:4px 8px;text-align:center}thead th{background:#f0f0f0;font-weight:700}td.name{text-align:left}.winner-box{text-align:center;margin:8px 0 14px;padding:10px;border-radius:8px;background:#fffbeb;border:2px solid #ca8a04;font-weight:900;color:#78350f;font-size:16px}'

    let html = `<!doctype html><html lang="fr"><head><meta charset="utf-8"/><title>${escapeHtml(t.name)}</title><style>${css}</style></head><body onload="window.print()">`
    html += `<h1>${logo ? `<img src="${logo}" alt="logo">` : ''}GOUZEPE GAMING CLUB — ${escapeHtml(t.name)} (Tekken)</h1>`
    html += `<div class="meta">${escapeHtml(formatLabel(format))} · ${escapeHtml(statusLabel(t.status))}${t.participants?.length ? ` · ${t.participants.length} participants` : ''}</div>`

    if (t.winner_name && (t.status === 'completed' || t.status === 'archived')) {
      html += `<div class="winner-box">🏆 Vainqueur : ${escapeHtml(t.winner_name)}</div>`
    }

    const standingsTable = (rows) => {
      let h = '<table><thead><tr><th>#</th><th class="name">Joueur</th><th>J</th><th>V</th><th>N</th><th>D</th><th>Pts</th></tr></thead><tbody>'
      rows.forEach((s, idx) => {
        h += `<tr><td>${idx + 1}</td><td class="name">${escapeHtml(s.name)}</td><td>${playedOf(s)}</td><td>${winOf(s)}</td><td>${drawOf(s)}</td><td>${lossOf(s)}</td><td><b>${ptsOf(s)}</b></td></tr>`
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
.admin-tournois-wrap {
  width: 100%;
}

.admin-tournois-wrap :deep(.card) {
  transition: transform 180ms ease, box-shadow 180ms ease, border-color 180ms ease;
}

.admin-tournois-wrap :deep(.card:hover) {
  transform: translateY(-1px);
  box-shadow: 0 12px 26px rgba(2, 6, 23, 0.2);
  border-color: color-mix(in srgb, var(--border) 68%, var(--blue) 32%);
}

.sidebar-scroll {
  max-height: min(70vh, 680px);
  overflow: auto;
}

.admin-actions {
  display: grid;
  grid-template-columns: 1fr;
  gap: 0.5rem;
  width: 100%;
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

.group-table-scroll {
  width: 100%;
  overflow-x: auto;
}

.group-table-scroll :deep(table) {
  min-width: 560px;
}

.member-picker {
  max-height: 260px;
  overflow: auto;
  border: 1px solid rgba(148, 163, 184, 0.24);
  border-radius: 12px;
  background: color-mix(in srgb, var(--panel) 84%, transparent);
  padding: 0.35rem;
}

.member-picker-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.45rem 0.55rem;
  border-radius: 10px;
  font-size: 0.92rem;
  cursor: pointer;
}

.member-picker-item:hover {
  background: color-mix(in srgb, var(--panel) 62%, var(--blue) 38%);
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
  .admin-tournois-wrap {
    max-width: none;
    padding: clamp(14px, 2.1vw, 30px);
  }
}

@media (min-width: 640px) {
  .admin-actions {
    display: flex;
    flex-wrap: wrap;
    justify-content: flex-end;
    width: auto;
  }
}

@media (min-width: 1280px) {
  .admin-sidebar {
    position: sticky;
    top: 88px;
  }
}

@media (max-width: 640px) {
  .admin-tournois-wrap :deep(.card) {
    padding: 0.8rem;
  }
}

@media (prefers-reduced-motion: reduce) {
  .reveal {
    animation: none !important;
  }

  .admin-tournois-wrap :deep(.card) {
    transition: none !important;
  }
}
</style>
