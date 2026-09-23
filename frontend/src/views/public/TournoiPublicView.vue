<template>
  <AdaptiveLayout season-label="Tournoi">
    <div class="page-wrap tp">
      <RouterLink :to="backLink" class="tp-back"><ArrowLeftIcon class="w-4 h-4" /> {{ isTekken ? 'Tekken' : 'eFootball' }}</RouterLink>

      <div v-if="loading && !data" class="tp-empty"><Loader2Icon class="w-5 h-5 animate-spin inline" /> Chargement…</div>
      <div v-else-if="error" class="tp-empty">{{ error }}</div>

      <template v-else-if="data">
        <header class="tp-head">
          <div class="min-w-0">
            <div class="tp-kicker">
              <span :class="['tp-status', t.status]">
                <span v-if="t.status === 'live'" class="tp-dot" aria-hidden="true" />
                {{ t.status === 'live' ? 'En direct' : 'Terminé' }}
              </span>
              <span>{{ isTekken ? 'Tekken' : 'eFootball' }} · {{ formatLabel(t.format) }}</span>
              <span v-if="t.starts_at">· {{ fmtDate(t.starts_at) }}</span>
              <span>· {{ data.participants.length }} joueurs</span>
            </div>
            <h1 class="tp-title">{{ t.name }}</h1>
          </div>
          <div v-if="t.winner_name" class="tp-champ">
            <TrophyIcon class="w-5 h-5" aria-hidden="true" />
            <div><span>Vainqueur</span><strong>{{ t.winner_name }}</strong></div>
          </div>
        </header>

        <section v-if="data.ranking?.length" class="tp-card">
          <h2 class="tp-h2">Classement</h2>
          <ol class="tp-rank">
            <li v-for="r in data.ranking" :key="r.rank + r.name" :class="{ podium: r.rank <= 3 }">
              <span :class="['tp-pos', `p${r.rank}`]">{{ r.rank }}</span>
              <RouterLink v-if="r.player_id" :to="`/joueur/${encodeURIComponent(r.player_id)}`" class="tp-name">{{ r.name }}</RouterLink>
              <span v-else class="tp-name">{{ r.name }}</span>
            </li>
          </ol>
        </section>

        <section class="tp-card">
          <h2 v-if="t.format !== 'round_robin'" class="tp-h2">Tableau</h2>
          <BracketView :matches="data.matches" :format="t.format"
                       :standings-mode="isTekken ? 'wins' : (t.rr_standings_mode || 'goals')"
                       :persist-key="`pub-t-${t.id}`" />
        </section>
      </template>
    </div>
  </AdaptiveLayout>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import AdaptiveLayout from '@/components/layout/AdaptiveLayout.vue'
import BracketView from '@/components/tournament/BracketView.vue'
import { useAPI } from '@/composables/useAPI'
import { useGameStore } from '@/stores/game'
import { onRealtimeEvent } from '@/composables/useRealtimeSocket'
import { FORMAT_LABELS } from '@/utils/bracketMatches'
import { TrophyIcon, Loader2Icon, ArrowLeftIcon } from 'lucide-vue-next'

const api = useAPI()
const route = useRoute()
const game = useGameStore()

const data = ref(null)
const loading = ref(false)
const error = ref('')
const t = computed(() => data.value?.tournament || {})
const isTekken = computed(() => t.value.game_type === 'tekken')
const backLink = computed(() => (isTekken.value ? '/tekken' : '/efootball'))

async function load() {
  const id = Number(route.params.id)
  if (!Number.isInteger(id) || id <= 0) { error.value = 'Tournoi introuvable.'; return }
  loading.value = true
  error.value = ''
  try {
    const { data: d } = await api.get(`/public/tournaments/${id}`)
    data.value = d
    game.set(d.tournament.game_type === 'tekken' ? 'tekken' : 'efoot')
  } catch (e) {
    error.value = e.response?.status === 404 ? 'Tournoi introuvable ou pas encore lancé.' : 'Impossible de charger le tournoi.'
  } finally {
    loading.value = false
  }
}

let off = null
let timer = null
onMounted(() => {
  load()
  off = onRealtimeEvent('tournament:changed', (ev = {}) => {
    if (Number(ev.tournamentId) !== Number(route.params.id)) return
    clearTimeout(timer)
    timer = setTimeout(load, 250)
  })
})
onUnmounted(() => { if (off) off(); clearTimeout(timer) })
watch(() => route.params.id, (v) => { if (v && route.name === 'TournoiPublic') { data.value = null; load() } })

function formatLabel(f) { return FORMAT_LABELS[f] || f }
function fmtDate(v) {
  const d = new Date(v)
  return isNaN(d) ? '' : d.toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' })
}
</script>

<style scoped>
.tp { display: flex; flex-direction: column; gap: 1rem; }
.tp-back { display: inline-flex; align-items: center; gap: .35rem; color: var(--muted); text-decoration: none; font-size: .85rem; font-weight: 600; align-self: flex-start; }
.tp-back:hover { color: var(--accent-l); }
.tp-empty { color: var(--muted); padding: 2.5rem 0; text-align: center; }

.tp-head { display: flex; flex-wrap: wrap; align-items: flex-start; justify-content: space-between; gap: 1rem; }
.tp-kicker { display: flex; flex-wrap: wrap; align-items: center; gap: .45rem; font-size: .8rem; color: var(--muted); }
.tp-title { font-family: var(--font-title); font-weight: 700; font-size: clamp(1.7rem, 4vw, 2.4rem); text-transform: uppercase; letter-spacing: .03em; margin: .3rem 0 0; line-height: 1.05; }
.tp-status { display: inline-flex; align-items: center; gap: .35rem; font-size: .68rem; font-weight: 800; text-transform: uppercase; letter-spacing: .08em; padding: .15rem .55rem; border-radius: 999px; background: rgba(34, 197, 94, .14); color: #4ade80; }
.tp-status.live { background: rgba(239, 68, 68, .16); color: #f87171; }
.tp-dot { width: .45rem; height: .45rem; border-radius: 50%; background: #ef4444; animation: tp-pulse 1.4s ease-in-out infinite; }
@keyframes tp-pulse { 0%, 100% { opacity: 1; } 50% { opacity: .25; } }
@media (prefers-reduced-motion: reduce) { .tp-dot { animation: none; } }
.tp-champ { display: flex; align-items: center; gap: .65rem; padding: .6rem .9rem; border-radius: .8rem; border: 1px solid rgba(234, 179, 8, .4); background: rgba(234, 179, 8, .08); color: #eab308; }
.tp-champ span { display: block; font-size: .65rem; font-weight: 800; text-transform: uppercase; letter-spacing: .1em; }
.tp-champ strong { display: block; color: var(--text); font-size: 1rem; }

.tp-card { border: 1px solid var(--border); border-radius: 14px; background: var(--card); padding: 1rem; min-width: 0; }
.tp-h2 { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .05em; font-size: .95rem; margin-bottom: .75rem; }
.tp-rank { display: grid; gap: .4rem; grid-template-columns: repeat(auto-fill, minmax(12rem, 1fr)); list-style: none; padding: 0; margin: 0; }
.tp-rank li { display: flex; align-items: center; gap: .6rem; padding: .45rem .6rem; border-radius: .6rem; border: 1px solid var(--border); }
.tp-rank li.podium { border-color: color-mix(in srgb, var(--accent) 35%, var(--border)); }
.tp-pos { display: grid; place-items: center; width: 1.7rem; height: 1.7rem; border-radius: 50%; flex: none; font-weight: 800; font-size: .8rem; background: color-mix(in srgb, var(--border) 45%, transparent); }
.tp-pos.p1 { background: #eab308; color: #1a1300; }
.tp-pos.p2 { background: #cbd5e1; color: #111827; }
.tp-pos.p3 { background: #d97706; color: #1a0f00; }
.tp-name { color: var(--text); text-decoration: none; font-weight: 600; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
a.tp-name:hover { color: var(--accent-l); }
</style>
