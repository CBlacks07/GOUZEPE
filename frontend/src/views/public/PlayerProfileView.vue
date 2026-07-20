<template>
  <div class="pp">
    <PublicNav />

    <section class="section">
      <RouterLink to="/membres" class="back"><ArrowLeftIcon class="w-4 h-4" /> Membres</RouterLink>

      <div v-if="loading" class="empty">Chargement…</div>
      <div v-else-if="error" class="empty">{{ error }}</div>

      <template v-else>
        <!-- En-tête -->
        <header class="pp-head">
          <span class="pp-avatar">{{ initials }}</span>
          <div class="min-w-0">
            <h1 class="pp-name">{{ data.player.id }}</h1>
            <p class="pp-sub">
              {{ data.player.name }}
              <span v-if="data.stats" class="pp-rank">· {{ data.stats.rank }}<sup>{{ data.stats.rank === 1 ? 'er' : 'e' }}</sup> / {{ data.stats.classed }} — {{ data.season?.name }}</span>
            </p>
          </div>
        </header>

        <!-- Stats saison -->
        <div class="cards">
          <div class="stat"><span class="stat-v">{{ data.stats ? Number(data.stats.moyenne).toFixed(2) : '—' }}</span><span class="stat-l">Moyenne</span></div>
          <div class="stat"><span class="stat-v">{{ data.agg.J }}</span><span class="stat-l">Manches</span></div>
          <div class="stat"><span class="stat-v win">{{ data.agg.V }}</span><span class="stat-l">V</span></div>
          <div class="stat"><span class="stat-v">{{ data.agg.N }}</span><span class="stat-l">N</span></div>
          <div class="stat"><span class="stat-v loss">{{ data.agg.D }}</span><span class="stat-l">D</span></div>
          <div class="stat"><span class="stat-v" :class="(data.agg.BP - data.agg.BC) >= 0 ? 'win' : 'loss'">{{ (data.agg.BP - data.agg.BC) > 0 ? '+' : '' }}{{ data.agg.BP - data.agg.BC }}</span><span class="stat-l">Diff</span></div>
        </div>

        <div class="grid2">
          <!-- Forme + titres -->
          <section class="panel">
            <h2 class="panel-h">Forme récente</h2>
            <div v-if="data.form.length" class="form-dots">
              <span v-for="(f, i) in data.form" :key="i" class="fd" :class="{ v: f === 'V', n: f === 'N', d: f === 'D' }">{{ f }}</span>
            </div>
            <p v-else class="muted">Pas de résultat récent.</p>

            <h2 class="panel-h mt">Titres de journée</h2>
            <div class="titles-row">
              <span class="title-pill gold"><TrophyIcon class="w-3.5 h-3.5" /> {{ data.titles.d1 }} D1</span>
              <span class="title-pill"><TrophyIcon class="w-3.5 h-3.5" /> {{ data.titles.d2 }} D2</span>
            </div>
            <div v-if="data.titles.list.length" class="titles-list">
              <span v-for="(t, i) in data.titles.list" :key="i" class="title-chip" :class="{ d1: t.div === 'D1' }">{{ t.div }} · {{ fmtShort(t.date) }}</span>
            </div>
          </section>

          <!-- Face à face -->
          <section class="panel">
            <h2 class="panel-h">Face à face</h2>
            <select v-model="oppId" class="input" @change="loadFaceoff">
              <option value="">— Choisir un adversaire —</option>
              <option v-for="o in opponents" :key="o.id" :value="o.id">{{ o.id }}</option>
            </select>

            <div v-if="foLoading" class="muted mt">Calcul…</div>
            <div v-else-if="fo" class="fo">
              <div class="fo-head">
                <span class="fo-name">{{ fo.a_name }}</span>
                <span class="fo-legs">{{ fo.legs }} manche(s)</span>
                <span class="fo-name right">{{ fo.b_name }}</span>
              </div>
              <div class="fo-bar">
                <div class="fo-a" :style="{ width: pct(fo.aWins) + '%' }" />
                <div class="fo-n" :style="{ width: pct(fo.draws) + '%' }" />
                <div class="fo-b" :style="{ width: pct(fo.bWins) + '%' }" />
              </div>
              <div class="fo-foot">
                <span class="win">{{ fo.aWins }}V</span>
                <span class="muted">{{ fo.draws }}N</span>
                <span class="loss">{{ fo.bWins }}V</span>
              </div>
              <div class="fo-goals">Buts : <strong>{{ fo.aGoals }}</strong> — <strong>{{ fo.bGoals }}</strong></div>
            </div>
            <p v-else class="muted mt">Choisis un adversaire pour voir l'historique.</p>
          </section>
        </div>
      </template>
    </section>

    <PublicFooter />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, RouterLink } from 'vue-router'
import PublicNav from '@/components/public/PublicNav.vue'
import PublicFooter from '@/components/public/PublicFooter.vue'
import { resolveBaseURL } from '@/composables/useAPI'
import { ArrowLeftIcon, TrophyIcon } from 'lucide-vue-next'

const route = useRoute()
const loading = ref(true)
const error = ref('')
const data = ref({ player: {}, agg: {}, form: [], titles: { list: [] }, stats: null, season: null })
const opponents = ref([])
const oppId = ref('')
const fo = ref(null)
const foLoading = ref(false)

const initials = computed(() => String(data.value.player?.id || '').replace(/[^A-Za-z0-9]/g, '').slice(0, 2).toUpperCase() || '?')

function fmtShort(d) { try { return new Date(d + 'T12:00:00').toLocaleDateString('fr-FR', { day: '2-digit', month: 'short' }) } catch (_) { return d } }
function pct(v) { const tot = (fo.value?.legs) || 1; return Math.round((v / tot) * 100) }
async function getJSON(p) { const r = await fetch(resolveBaseURL() + p, { headers: { Accept: 'application/json' } }); if (!r.ok) throw new Error(String(r.status)); return r.json() }

async function loadFaceoff() {
  fo.value = null
  if (!oppId.value) return
  foLoading.value = true
  try { fo.value = await getJSON(`/public/faceoff/${encodeURIComponent(route.params.id)}/${encodeURIComponent(oppId.value)}`) } catch (_) {}
  foLoading.value = false
}

async function load() {
  loading.value = true; error.value = ''; fo.value = null; oppId.value = ''
  try {
    data.value = await getJSON(`/public/player/${encodeURIComponent(route.params.id)}`)
  } catch (e) { error.value = 'Profil introuvable.' }
  try {
    const m = await getJSON('/public/members')
    opponents.value = (m.members || []).filter(p => p.player_id !== route.params.id).map(p => ({ id: p.player_id }))
  } catch (_) {}
  loading.value = false
}

onMounted(load)
watch(() => route.params.id, load)
</script>

<style scoped>
.pp { position: relative; z-index: 1; color: var(--text); min-height: 100dvh; }
.section { padding: 2rem clamp(1.25rem, 4vw, 4rem) 3rem; max-width: 62rem; }
.back { display: inline-flex; align-items: center; gap: .35rem; color: var(--muted); text-decoration: none; font-size: .85rem; font-weight: 600; margin-bottom: 1.2rem; }
.back:hover { color: var(--accent-l); }
.empty { color: var(--muted); padding: 2rem 0; }
.muted { color: var(--muted); font-size: .85rem; }
.mt { margin-top: .8rem; }

.pp-head { display: flex; align-items: center; gap: 1rem; margin-bottom: 1.25rem; }
.pp-avatar { flex: none; width: 3.4rem; height: 3.4rem; border-radius: 50%; display: grid; place-items: center; font-family: var(--font-title); font-weight: 800; font-size: 1.1rem; color: #fff; background: linear-gradient(135deg, var(--accent), var(--accent-l, var(--accent))); }
.pp-name { font-family: var(--font-title); font-weight: 800; font-size: 1.6rem; margin: 0; line-height: 1.1; }
.pp-sub { font-size: .85rem; color: var(--muted); margin: .15rem 0 0; }
.pp-rank { color: var(--accent-l, var(--accent)); font-weight: 600; }

.cards { display: grid; grid-template-columns: repeat(6, 1fr); gap: .5rem; margin-bottom: 1.25rem; }
.stat { border: 1px solid var(--border); border-radius: 12px; background: var(--card); padding: .7rem .4rem; display: flex; flex-direction: column; align-items: center; }
.stat-v { font-family: var(--font-title); font-weight: 900; font-size: 1.15rem; line-height: 1; font-variant-numeric: tabular-nums; }
.stat-l { font-size: .56rem; text-transform: uppercase; letter-spacing: .05em; color: var(--muted); margin-top: .3rem; }
.win { color: #22c55e; } .loss { color: var(--red, #ef4444); }
@media (max-width: 640px) { .cards { grid-template-columns: repeat(3, 1fr); } }

.grid2 { display: grid; gap: 1rem; grid-template-columns: 1fr; }
@media (min-width: 800px) { .grid2 { grid-template-columns: 1fr 1fr; } }
.panel { border: 1px solid var(--border); border-radius: 14px; background: var(--card); padding: 1.1rem 1.2rem; }
.panel-h { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .04em; font-size: .85rem; margin: 0 0 .7rem; }

.form-dots { display: flex; gap: .35rem; flex-wrap: wrap; }
.fd { width: 1.6rem; height: 1.6rem; border-radius: 6px; display: grid; place-items: center; font-weight: 800; font-size: .75rem; background: color-mix(in srgb, var(--muted) 18%, transparent); color: var(--muted); }
.fd.v { background: color-mix(in srgb, #22c55e 20%, transparent); color: #22c55e; }
.fd.d { background: color-mix(in srgb, #ef4444 18%, transparent); color: #ef4444; }

.titles-row { display: flex; gap: .5rem; margin-bottom: .6rem; }
.title-pill { display: inline-flex; align-items: center; gap: .3rem; font-size: .78rem; font-weight: 700; padding: .2rem .6rem; border-radius: 999px; border: 1px solid var(--border); color: var(--muted); }
.title-pill.gold { color: #ca8a04; border-color: color-mix(in srgb, #eab308 40%, transparent); background: color-mix(in srgb, #eab308 10%, transparent); }
.titles-list { display: flex; flex-wrap: wrap; gap: .3rem; }
.title-chip { font-size: .68rem; color: var(--muted); border: 1px solid color-mix(in srgb, var(--border) 60%, transparent); border-radius: 6px; padding: .12rem .4rem; }
.title-chip.d1 { color: #ca8a04; border-color: color-mix(in srgb, #eab308 35%, transparent); }

.fo { margin-top: .8rem; }
.fo-head { display: flex; align-items: center; justify-content: space-between; font-size: .85rem; font-weight: 600; margin-bottom: .4rem; }
.fo-name { min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.fo-name.right { text-align: right; }
.fo-legs { font-size: .68rem; color: var(--muted); flex: none; padding: 0 .5rem; }
.fo-bar { display: flex; height: 10px; border-radius: 999px; overflow: hidden; background: color-mix(in srgb, var(--muted) 15%, transparent); }
.fo-a { background: #22c55e; } .fo-n { background: color-mix(in srgb, var(--muted) 45%, transparent); } .fo-b { background: #ef4444; }
.fo-foot { display: flex; justify-content: space-between; font-size: .78rem; font-weight: 700; margin-top: .3rem; }
.fo-goals { font-size: .82rem; color: var(--muted); margin-top: .5rem; }
</style>
