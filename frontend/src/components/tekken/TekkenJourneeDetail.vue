<template>
  <div class="tj">
    <div v-if="loading && !data" class="tj-empty"><Loader2Icon class="w-5 h-5 animate-spin inline" /> Chargement…</div>
    <div v-else-if="error" class="tj-empty">{{ error }}</div>

    <template v-else-if="data">
      <!-- En-tête -->
      <header class="tj-head">
        <div class="min-w-0">
          <div class="tj-kicker">
            <span :class="['tj-status', t.status]">
              <span v-if="t.status === 'live'" class="tj-dot" aria-hidden="true" />
              {{ statusLabel(t.status) }}
            </span>
            <span>{{ formatLabel(t.format) }}</span>
            <span v-if="t.starts_at">· {{ fmtDate(t.starts_at) }}</span>
            <span>· {{ participantsCount }} joueurs</span>
          </div>
          <h2 class="tj-title">{{ t.name }}</h2>
          <p v-if="t.day_comment" class="tj-comment">{{ t.day_comment }}</p>
        </div>
        <div v-if="champion" class="tj-champ">
          <TrophyIcon class="w-5 h-5" aria-hidden="true" />
          <div><span>Champion</span><strong>{{ champion.name }}</strong></div>
        </div>
      </header>

      <!-- Points de la journée -->
      <section class="tj-card">
        <div class="tj-card-head">
          <h3>Points de la journée</h3>
          <span class="tj-hint">{{ scoringHint }}</span>
        </div>
        <div class="overflow-x-auto">
          <table class="data-table text-sm w-full">
            <thead>
              <tr>
                <th class="text-center w-10">#</th>
                <th>Joueur</th>
                <th class="text-center w-14">V</th>
                <th class="text-center w-14">D</th>
                <th class="text-center w-16">Diff.</th>
                <th class="text-center w-16">Pts</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="!standings.length">
                <td colspan="6" class="text-center py-4" style="color:var(--muted)">Les participants ne sont pas encore connus.</td>
              </tr>
              <tr v-for="r in standings" :key="r.participant_id">
                <td class="text-center" style="color:var(--muted)">{{ r.rank }}</td>
                <td class="font-semibold">
                  <RouterLink v-if="r.player_id" :to="`/joueur/${encodeURIComponent(r.player_id)}`" class="tj-player">{{ r.name }}</RouterLink>
                  <span v-else>{{ r.name }}</span>
                  <TrophyIcon v-if="r.champion" class="w-3.5 h-3.5 inline ml-1" style="color:#eab308" aria-label="Champion de la journée" />
                </td>
                <td class="text-center">{{ r.wins }}</td>
                <td class="text-center">{{ r.losses }}</td>
                <td class="text-center" style="color:var(--muted)">{{ r.rounds_diff > 0 ? '+' : '' }}{{ r.rounds_diff }}</td>
                <td class="text-center font-bold">{{ r.points }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <!-- Matchs / bracket -->
      <section class="tj-card">
        <!-- Le tableau toutes rondes porte déjà son titre « Confrontations ». -->
        <div v-if="t.format !== 'round_robin' || !matches.length" class="tj-card-head"><h3>Tableau</h3></div>
        <div v-if="!matches.length" class="tj-empty">Le tableau n'est pas encore généré.</div>
        <template v-else>
          <BracketSE v-if="t.format === 'single_elimination'" :matches="matches" :admin-mode="false" :persist-key="`tk-j-${t.id}-se`" />
          <BracketDE v-else-if="t.format === 'double_elimination'" :matches="matches" :admin-mode="false" :persist-key="`tk-j-${t.id}-de`" />
          <BracketRR v-else-if="t.format === 'round_robin'" :matches="matches" :standings="[]" standings-mode="wins" :admin-mode="false" />
          <div v-else-if="t.format === 'groups_knockout'" class="space-y-4">
            <div v-for="g in groups" :key="g.group_no">
              <h4 class="tj-sub">Groupe {{ String.fromCharCode(65 + g.group_no) }}</h4>
              <BracketRR :matches="g.matches" :standings="[]" standings-mode="wins" :admin-mode="false" />
            </div>
            <div>
              <h4 class="tj-sub">Phase finale</h4>
              <BracketSE v-if="knockout.length" :matches="knockout" :admin-mode="false" :persist-key="`tk-j-${t.id}-ko`" />
              <p v-else class="tj-empty">La phase finale commencera à la fin des groupes.</p>
            </div>
          </div>
        </template>
      </section>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { RouterLink } from 'vue-router'
import BracketSE from '@/components/tournament/BracketSE.vue'
import BracketDE from '@/components/tournament/BracketDE.vue'
import BracketRR from '@/components/tournament/BracketRR.vue'
import { useAPI } from '@/composables/useAPI'
import { onRealtimeEvent } from '@/composables/useRealtimeSocket'
import { TrophyIcon, Loader2Icon } from 'lucide-vue-next'

const props = defineProps({ journeeId: { type: Number, required: true } })
const emit = defineEmits(['loaded'])

const api = useAPI()
const data = ref(null)
const loading = ref(false)
const error = ref('')

const t = computed(() => data.value?.tournament || {})
const standings = computed(() => data.value?.day_standings || [])
const champion = computed(() => standings.value.find((r) => r.champion) || null)
const participantsCount = computed(() => data.value?.participants?.length || 0)

const scoringHint = computed(() => {
  const s = data.value?.day_scoring
  if (!s) return ''
  const parts = []
  if (t.value.format === 'round_robin' || t.value.format === 'groups_knockout') parts.push(`victoire en poule ${s.groupWin}`)
  if (t.value.format !== 'round_robin') parts.push(`victoire en phase finale ${s.bracketWin}`)
  if (t.value.format === 'double_elimination') parts.push(`victoire en repêchage ${s.losersWin}`)
  parts.push(`champion +${s.championBonus}`)
  return 'Barème : ' + parts.join(' · ')
})

// Même normalisation que les écrans de tournoi : les brackets attendent ces champs.
function normalizeSide(raw, format, roundNo) {
  const side = String(raw || '').trim().toUpperCase()
  if (['W', 'L', 'GF', 'G'].includes(side)) return side
  if (format === 'double_elimination') return roundNo >= 20 ? 'GF' : roundNo >= 10 ? 'L' : 'W'
  return 'W'
}
const matches = computed(() => (data.value?.matches || []).map((m) => {
  const roundNo = Number(m.round_no || 0)
  return {
    ...m,
    round_no: roundNo,
    slot_no: Number(m.slot_no || 0),
    p1_id: m.p1_participant_id ?? null,
    p2_id: m.p2_participant_id ?? null,
    score1: m.score_p1 ?? null,
    score2: m.score_p2 ?? null,
    bracket_side: normalizeSide(m.bracket_side, t.value.format, roundNo),
  }
}))
const isGroup = (m) => m.bracket_side === 'G' || (m.group_no !== null && m.group_no !== undefined)
const groups = computed(() => {
  const map = new Map()
  for (const m of matches.value.filter(isGroup)) {
    const k = Number(m.group_no) || 0
    if (!map.has(k)) map.set(k, [])
    map.get(k).push(m)
  }
  return [...map.entries()].sort((a, b) => a[0] - b[0]).map(([group_no, list]) => ({ group_no, matches: list }))
})
const knockout = computed(() => matches.value.filter((m) => !isGroup(m)))

async function load() {
  const id = props.journeeId
  loading.value = true
  error.value = ''
  try {
    const { data: d } = await api.get(`/tekken/journees/${id}`)
    if (id !== props.journeeId) return
    data.value = d
    emit('loaded', d)
  } catch (e) {
    error.value = e.response?.status === 404 ? 'Journée introuvable.' : 'Impossible de charger la journée.'
  } finally {
    loading.value = false
  }
}

// Temps réel : un score saisi par l'admin met la page à jour chez tout le monde.
let offChanged = null
let reloadTimer = null
onMounted(() => {
  load()
  offChanged = onRealtimeEvent('tournament:changed', (ev = {}) => {
    if (Number(ev.tournamentId) !== props.journeeId) return
    clearTimeout(reloadTimer)
    reloadTimer = setTimeout(load, 250) // regroupe les rafales (saisie rapide)
  })
})
onUnmounted(() => {
  if (offChanged) offChanged()
  clearTimeout(reloadTimer)
})
watch(() => props.journeeId, () => { data.value = null; load() })

const STATUS = { draft: 'À venir', live: 'En direct', completed: 'Terminée', archived: 'Archivée', cancelled: 'Annulée' }
const FORMATS = {
  single_elimination: 'Élimination simple',
  double_elimination: 'Double élimination',
  round_robin: 'Toutes rondes',
  groups_knockout: 'Poules + phase finale',
}
function statusLabel(s) { return STATUS[s] || s }
function formatLabel(f) { return FORMATS[f] || f }
function fmtDate(v) {
  const d = new Date(v)
  return isNaN(d) ? '' : d.toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' })
}
</script>

<style scoped>
.tj { display: flex; flex-direction: column; gap: 1rem; }
.tj-empty { color: var(--muted); padding: 1.5rem 0; text-align: center; font-size: .9rem; }

.tj-head { display: flex; flex-wrap: wrap; align-items: flex-start; justify-content: space-between; gap: 1rem; }
.tj-kicker { display: flex; flex-wrap: wrap; align-items: center; gap: .45rem; font-size: .8rem; color: var(--muted); }
.tj-title { font-family: var(--font-title); font-weight: 700; font-size: clamp(1.4rem, 3vw, 1.9rem); text-transform: uppercase; letter-spacing: .03em; margin: .3rem 0 0; line-height: 1.1; }
.tj-comment { color: var(--muted); margin-top: .4rem; font-size: .9rem; white-space: pre-line; }

.tj-status { display: inline-flex; align-items: center; gap: .35rem; font-size: .68rem; font-weight: 800; text-transform: uppercase; letter-spacing: .08em; padding: .15rem .55rem; border-radius: 999px; background: color-mix(in srgb, var(--border) 45%, transparent); color: var(--muted); }
.tj-status.live { background: rgba(239, 68, 68, .16); color: #f87171; }
.tj-status.completed { background: rgba(34, 197, 94, .14); color: #4ade80; }
.tj-dot { width: .45rem; height: .45rem; border-radius: 50%; background: #ef4444; animation: tj-pulse 1.4s ease-in-out infinite; }
@keyframes tj-pulse { 0%, 100% { opacity: 1; } 50% { opacity: .25; } }
@media (prefers-reduced-motion: reduce) { .tj-dot { animation: none; } }

.tj-champ { display: flex; align-items: center; gap: .65rem; padding: .6rem .9rem; border-radius: .8rem; border: 1px solid rgba(234, 179, 8, .4); background: rgba(234, 179, 8, .08); color: #eab308; }
.tj-champ span { display: block; font-size: .65rem; font-weight: 800; text-transform: uppercase; letter-spacing: .1em; }
.tj-champ strong { display: block; color: var(--text); font-size: 1rem; }

.tj-card { border: 1px solid var(--border); border-radius: 14px; background: var(--card); padding: 1rem; min-width: 0; }
.tj-card-head { display: flex; flex-wrap: wrap; align-items: baseline; justify-content: space-between; gap: .5rem; margin-bottom: .75rem; }
.tj-card-head h3 { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .05em; font-size: .95rem; }
.tj-hint { font-size: .75rem; color: var(--muted); }
.tj-sub { font-size: .72rem; font-weight: 800; text-transform: uppercase; letter-spacing: .08em; color: var(--muted); margin-bottom: .5rem; }
.tj-player { color: inherit; text-decoration: none; }
.tj-player:hover { color: var(--accent-l); }
.tj-card .data-table { min-width: 0; }
</style>
