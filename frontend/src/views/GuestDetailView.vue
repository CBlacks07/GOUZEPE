<template>
  <AppLayout season-label="Invité">
    <div class="page-wrap guest-detail">
      <RouterLink to="/accueil" class="back-link"><ArrowLeftIcon class="w-4 h-4" /> Retour à l'accueil</RouterLink>

      <div v-if="loading" class="text-gz-muted text-sm py-10 text-center">Chargement…</div>
      <div v-else-if="error" class="text-gz-red text-sm py-10 text-center">{{ error }}</div>

      <template v-else>
        <!-- En-tête -->
        <section class="card gd-head reveal">
          <div class="gd-id">
            <span class="gd-avatar">{{ initials }}</span>
            <div class="min-w-0">
              <h1 class="gd-name">{{ data.player_id }}</h1>
              <p class="gd-sub">
                <span v-if="data.is_invite" class="gd-tag">Invité</span>
                {{ data.name }} · {{ summary.sorties }} sortie(s)
              </p>
            </div>
          </div>
          <div class="gd-stats">
            <div class="gds"><span class="gds-v">{{ summary.moy.toFixed(2) }}</span><span class="gds-l">moy/sortie</span></div>
            <div class="gds"><span class="gds-v gds-win">{{ summary.v }}</span><span class="gds-l">V</span></div>
            <div class="gds"><span class="gds-v">{{ summary.n }}</span><span class="gds-l">N</span></div>
            <div class="gds"><span class="gds-v gds-loss">{{ summary.d }}</span><span class="gds-l">D</span></div>
            <div class="gds"><span class="gds-v" :class="summary.diff >= 0 ? 'gds-win' : 'gds-loss'">{{ summary.diff > 0 ? '+' : '' }}{{ summary.diff }}</span><span class="gds-l">Diff</span></div>
          </div>
        </section>

        <!-- Courbe de forme -->
        <section v-if="sorties.length > 1" class="card reveal delay-1">
          <h2 class="gd-h2">Courbe de forme</h2>
          <p class="gd-h2-sub">Points par sortie (chronologique)</p>
          <svg class="gd-spark" :viewBox="`0 0 ${sparkW} ${sparkH}`" preserveAspectRatio="none" role="img" aria-label="Courbe des points par sortie">
            <polyline :points="sparkArea" class="gd-spark-area" />
            <polyline :points="sparkLine" class="gd-spark-line" />
            <circle v-for="(p, i) in sparkPoints" :key="i" :cx="p.x" :cy="p.y" r="2.5" class="gd-spark-dot" />
          </svg>
          <div class="gd-spark-meta">
            <span>Min {{ minPts }}</span>
            <span>Moy {{ summary.moy.toFixed(1) }}</span>
            <span>Max {{ maxPts }}</span>
          </div>
        </section>

        <!-- Timeline -->
        <section class="card reveal delay-2">
          <h2 class="gd-h2">Historique des sorties</h2>
          <div v-if="!sorties.length" class="text-gz-muted text-sm py-4">Aucune sortie enregistrée.</div>
          <div v-else class="gd-timeline">
            <div v-for="(s, i) in sortiesDesc" :key="i" class="gd-row">
              <div class="gd-row-left">
                <span class="gd-type" :class="s.type === 'tournoi' ? 't-tournoi' : 't-journee'">
                  {{ s.type === 'tournoi' ? 'Tournoi' : (s.div || 'Journée') }}
                </span>
                <div class="min-w-0">
                  <div class="gd-label">{{ s.label }}</div>
                  <div class="gd-date">{{ fmtDate(s.date) }}</div>
                </div>
              </div>
              <div class="gd-row-right">
                <span class="gd-vnd">
                  <span class="gds-win">{{ s.v }}V</span>·{{ s.n }}N·<span class="gds-loss">{{ s.d }}D</span>
                </span>
                <span class="gd-diff" :class="(s.bp - s.bc) >= 0 ? 'gds-win' : 'gds-loss'">
                  {{ (s.bp - s.bc) > 0 ? '+' : '' }}{{ s.bp - s.bc }}
                </span>
                <span class="gd-pts">{{ s.pts }}<small> pts</small></span>
              </div>
            </div>
          </div>
        </section>
      </template>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, RouterLink } from 'vue-router'
import AppLayout from '@/components/layout/AppLayout.vue'
import { useAPI } from '@/composables/useAPI'
import { ArrowLeftIcon } from 'lucide-vue-next'

const api = useAPI()
const route = useRoute()

const loading = ref(true)
const error = ref('')
const data = ref({ player_id: '', name: '', is_invite: false, summary: {}, sorties: [] })

const summary = computed(() => ({
  sorties: 0, pts: 0, v: 0, n: 0, d: 0, bp: 0, bc: 0, diff: 0, moy: 0,
  ...(data.value.summary || {}),
}))
const sorties = computed(() => data.value.sorties || [])
const sortiesDesc = computed(() => [...sorties.value].reverse())

const initials = computed(() => {
  const s = String(data.value.player_id || '').replace(/[^A-Za-z0-9]/g, '')
  return (s.slice(0, 2) || '?').toUpperCase()
})

const ptsArr = computed(() => sorties.value.map((s) => Number(s.pts) || 0))
const minPts = computed(() => (ptsArr.value.length ? Math.min(...ptsArr.value) : 0))
const maxPts = computed(() => (ptsArr.value.length ? Math.max(...ptsArr.value) : 0))

const sparkW = 300
const sparkH = 70
const sparkPoints = computed(() => {
  const arr = ptsArr.value
  if (arr.length < 2) return []
  const mn = minPts.value
  const span = Math.max(1, maxPts.value - mn)
  const stepX = sparkW / (arr.length - 1)
  const pad = 8
  return arr.map((v, i) => ({
    x: +(i * stepX).toFixed(1),
    y: +(sparkH - pad - ((v - mn) / span) * (sparkH - pad * 2)).toFixed(1),
  }))
})
const sparkLine = computed(() => sparkPoints.value.map((p) => `${p.x},${p.y}`).join(' '))
const sparkArea = computed(() => {
  const pts = sparkPoints.value
  if (!pts.length) return ''
  return `${pts[0].x},${sparkH} ${pts.map((p) => `${p.x},${p.y}`).join(' ')} ${pts[pts.length - 1].x},${sparkH}`
})

function fmtDate(d) {
  if (!d) return ''
  try {
    return new Date(d + 'T12:00:00').toLocaleDateString('fr-FR', { day: '2-digit', month: 'short', year: 'numeric' })
  } catch (_) { return d }
}

async function load() {
  loading.value = true
  error.value = ''
  try {
    const { data: d } = await api.get(`/season/guest/${encodeURIComponent(route.params.id)}`)
    data.value = d
  } catch (e) {
    error.value = e.response?.data?.error || 'Impossible de charger ce profil.'
  } finally {
    loading.value = false
  }
}

onMounted(load)
watch(() => route.params.id, load)
</script>

<style scoped>
.guest-detail { max-width: 56rem; }
.back-link { display: inline-flex; align-items: center; gap: .35rem; color: var(--muted); text-decoration: none; font-size: .85rem; font-weight: 600; margin-bottom: 1rem; }
.back-link:hover { color: var(--accent-l); }

.gd-head { display: flex; align-items: center; justify-content: space-between; gap: 1rem; flex-wrap: wrap; }
.gd-id { display: flex; align-items: center; gap: .9rem; min-width: 0; }
.gd-avatar {
  flex: none; width: 3rem; height: 3rem; border-radius: 50%;
  display: inline-flex; align-items: center; justify-content: center;
  font-family: var(--font-title); font-weight: 800; color: #fff;
  background: linear-gradient(135deg, var(--accent), var(--accent-l, var(--accent)));
}
.gd-name { font-family: var(--font-title); font-weight: 800; font-size: 1.4rem; margin: 0; line-height: 1.1; }
.gd-sub { font-size: .82rem; color: var(--muted); margin: .15rem 0 0; }
.gd-tag { font-size: .58rem; font-weight: 800; text-transform: uppercase; letter-spacing: .05em; color: var(--accent-l, var(--accent)); background: color-mix(in srgb, var(--accent) 14%, transparent); border-radius: 999px; padding: .08rem .4rem; margin-right: .3rem; }

.gd-stats { display: flex; gap: 1.1rem; flex-wrap: wrap; }
.gds { display: flex; flex-direction: column; align-items: center; }
.gds-v { font-family: var(--font-title); font-weight: 900; font-size: 1.2rem; line-height: 1; font-variant-numeric: tabular-nums; }
.gds-l { font-size: .58rem; font-weight: 700; text-transform: uppercase; letter-spacing: .05em; color: var(--muted); margin-top: .2rem; }
.gds-win { color: #22c55e; }
.gds-loss { color: var(--red, #ef4444); }

.gd-h2 { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .04em; font-size: 1rem; margin: 0; }
.gd-h2-sub { font-size: .78rem; color: var(--muted); margin: .15rem 0 .8rem; }

.gd-spark { width: 100%; height: 90px; display: block; }
.gd-spark-line { fill: none; stroke: var(--accent); stroke-width: 2; stroke-linejoin: round; stroke-linecap: round; }
.gd-spark-area { fill: color-mix(in srgb, var(--accent) 12%, transparent); stroke: none; }
.gd-spark-dot { fill: var(--accent-l, var(--accent)); }
.gd-spark-meta { display: flex; justify-content: space-between; font-size: .7rem; color: var(--muted); margin-top: .4rem; }

.gd-timeline { display: flex; flex-direction: column; gap: .4rem; }
.gd-row {
  display: flex; align-items: center; justify-content: space-between; gap: .75rem;
  padding: .55rem .65rem; border-radius: 10px;
  border: 1px solid color-mix(in srgb, var(--border) 55%, transparent);
  background: color-mix(in srgb, var(--panel) 50%, transparent);
}
.gd-row-left { display: flex; align-items: center; gap: .7rem; min-width: 0; }
.gd-type { flex: none; font-size: .58rem; font-weight: 800; text-transform: uppercase; letter-spacing: .05em; padding: .14rem .45rem; border-radius: 6px; min-width: 3.6rem; text-align: center; }
.t-journee { color: var(--accent-l, var(--accent)); background: color-mix(in srgb, var(--accent) 13%, transparent); }
.t-tournoi { color: #f59e0b; background: color-mix(in srgb, #f59e0b 14%, transparent); }
.gd-label { font-weight: 600; font-size: .88rem; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.gd-date { font-size: .72rem; color: var(--muted); }
.gd-row-right { display: flex; align-items: center; gap: .8rem; flex: none; }
.gd-vnd { font-size: .76rem; color: var(--muted); font-variant-numeric: tabular-nums; }
.gd-diff { font-size: .78rem; font-weight: 700; font-variant-numeric: tabular-nums; min-width: 2.2rem; text-align: right; }
.gd-pts { font-family: var(--font-title); font-weight: 800; font-size: .95rem; font-variant-numeric: tabular-nums; }
.gd-pts small { font-size: .58rem; font-weight: 600; color: var(--muted); }

.reveal { animation: rise-in .4s ease both; }
.delay-1 { animation-delay: 80ms; }
.delay-2 { animation-delay: 160ms; }
@keyframes rise-in { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }

@media (max-width: 560px) {
  .gd-stats { width: 100%; justify-content: space-between; gap: .5rem; }
  .gd-row-right { gap: .55rem; }
  .gd-vnd { display: none; }
}
</style>
