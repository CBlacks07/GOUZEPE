<template>
  <AdaptiveLayout season-label="eFootball · Journées">
    <div class="page-wrap ej">
      <div class="ej-top">
        <div>
          <h1 class="ej-h1">Journées eFootball</h1>
          <p class="ej-lead">Chaque journée confirmée du championnat : champions, classements D1 / D2 et résultats.</p>
        </div>
        <div>
          <label class="label" for="ej-season">Saison</label>
          <select id="ej-season" v-model="seasonId" class="input w-52" @change="loadDays">
            <option v-for="s in seasons" :key="s.id" :value="s.id">{{ s.name }}{{ s.is_closed ? ' (clôturée)' : '' }}</option>
          </select>
        </div>
      </div>

      <div v-if="loadingDays" class="ej-empty"><Loader2Icon class="w-5 h-5 animate-spin inline" /> Chargement…</div>
      <div v-else-if="!days.length" class="ej-empty">Aucune journée confirmée pour cette saison.</div>

      <template v-else>
        <nav class="ej-list" aria-label="Journées de la saison">
          <button v-for="d in days" :key="d.day" type="button" :class="['ej-chip', { on: d.day === selected }]"
                  :aria-current="d.day === selected ? 'true' : null" @click="select(d.day)">
            <strong>{{ shortDate(d.day) }}</strong>
            <span v-if="d.champion_d1" class="ej-meta"><TrophyIcon class="w-3 h-3 inline" style="color:#eab308" /> {{ d.champion_d1 }}</span>
          </button>
        </nav>

        <div v-if="loadingDay && !day" class="ej-empty"><Loader2Icon class="w-5 h-5 animate-spin inline" /></div>
        <template v-else-if="day">
          <h2 class="ej-h2">Journée du {{ longDate(day.day) }}</h2>

          <div class="ej-champs">
            <div v-for="dv in ['d1', 'd2']" :key="dv" v-show="day.champions?.[dv]?.id" class="ej-champ">
              <TrophyIcon class="w-5 h-5" aria-hidden="true" />
              <div>
                <span>Champion {{ dv.toUpperCase() }}</span>
                <strong>{{ day.champions?.[dv]?.id }}</strong>
                <em v-if="day.champions?.[dv]?.team">{{ String(day.champions[dv].team).trim() }}</em>
              </div>
            </div>
          </div>

          <div class="ej-grid">
            <section v-for="dv in ['d1', 'd2']" :key="dv" class="ej-card">
              <h3 class="ej-h3">Division {{ dv === 'd1' ? 1 : 2 }}</h3>
              <div class="overflow-x-auto">
                <table class="data-table text-sm w-full">
                  <thead>
                    <tr>
                      <th class="text-center w-8">#</th><th>Joueur</th>
                      <th class="text-center">J</th><th class="text-center">V</th><th class="text-center">N</th><th class="text-center">D</th>
                      <th class="text-center">Diff</th><th class="text-center">Pts</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-if="!day[dv]?.members?.length"><td colspan="8" class="text-center py-3" style="color:var(--muted)">Aucun match.</td></tr>
                    <tr v-for="r in day[dv]?.members || []" :key="r.id">
                      <td class="text-center" style="color:var(--muted)">{{ r.rank }}</td>
                      <td class="font-semibold">
                        <RouterLink :to="`/joueur/${encodeURIComponent(r.id)}`" class="ej-player">{{ r.id }}</RouterLink>
                      </td>
                      <td class="text-center">{{ r.J }}</td><td class="text-center">{{ r.V }}</td><td class="text-center">{{ r.N }}</td><td class="text-center">{{ r.D }}</td>
                      <td class="text-center" style="color:var(--muted)">{{ r.DIFF > 0 ? '+' : '' }}{{ r.DIFF }}</td>
                      <td class="text-center font-bold">{{ r.PTS }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <p v-if="day[dv]?.guests?.length" class="ej-guests">
                Invités (non classés) : {{ day[dv].guests.map((g) => g.id).join(', ') }}
              </p>

              <details v-if="day[`results_${dv}`]?.length" class="ej-results">
                <summary>Résultats des matchs ({{ day[`results_${dv}`].length }})</summary>
                <ul>
                  <li v-for="(m, i) in day[`results_${dv}`]" :key="i">
                    <span class="ej-p">{{ m.p1 }}</span>
                    <span class="ej-score">{{ legs(m) }}</span>
                    <span class="ej-p ej-p2">{{ m.p2 }}</span>
                  </li>
                </ul>
              </details>
            </section>
          </div>
        </template>
      </template>
    </div>
  </AdaptiveLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import AdaptiveLayout from '@/components/layout/AdaptiveLayout.vue'
import { useAPI } from '@/composables/useAPI'
import { useGameStore } from '@/stores/game'
import { TrophyIcon, Loader2Icon } from 'lucide-vue-next'

const api = useAPI()
const route = useRoute()
const router = useRouter()
useGameStore().set('efoot')

const seasons = ref([])
const seasonId = ref(null)
const days = ref([])
const selected = ref('')
const day = ref(null)
const loadingDays = ref(false)
const loadingDay = ref(false)

async function loadDays() {
  loadingDays.value = true
  try {
    const { data } = await api.get('/public/matchdays', { params: seasonId.value ? { season_id: seasonId.value } : {} })
    days.value = data.days || []
    const wanted = String(route.query.d || '')
    const pick = days.value.find((d) => d.day === wanted) || days.value[0]
    if (pick) await select(pick.day, false)
    else { selected.value = ''; day.value = null }
  } catch (_) {
    days.value = []
  } finally {
    loadingDays.value = false
  }
}

async function select(d, updateUrl = true) {
  selected.value = d
  if (updateUrl) router.replace({ query: { ...route.query, d } })
  loadingDay.value = true
  try {
    const { data } = await api.get(`/public/matchday/${d}`)
    if (selected.value === d) day.value = data
  } catch (_) {
    day.value = null
  } finally {
    loadingDay.value = false
  }
}

onMounted(async () => {
  try {
    const { data } = await api.get('/public/seasons')
    seasons.value = data.seasons || []
    // Par défaut : la saison en cours si elle a des journées, sinon la plus récente qui en a.
    const current = seasons.value.find((s) => !s.is_closed) || seasons.value[0]
    seasonId.value = current ? current.id : null
  } catch (_) {}
  await loadDays()
  if (!days.value.length && seasons.value.length > 1) {
    const prev = seasons.value.find((s) => s.id !== seasonId.value)
    if (prev) { seasonId.value = prev.id; await loadDays() }
  }
})

// Aller / retour sur une même ligne : « 2-1 / 0-0 ».
function legs(m) {
  const out = []
  if (m.a1 != null && m.a2 != null) out.push(`${m.a1}-${m.a2}`)
  if (m.r1 != null && m.r2 != null) out.push(`${m.r1}-${m.r2}`)
  return out.join(' / ') || '—'
}
function shortDate(d) { return new Date(`${d}T12:00:00`).toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' }) }
function longDate(d) { return new Date(`${d}T12:00:00`).toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' }) }
</script>

<style scoped>
.ej-top { display: flex; flex-wrap: wrap; align-items: flex-end; justify-content: space-between; gap: 1rem; margin-bottom: 1.25rem; }
.ej-h1 { font-family: var(--font-title); font-weight: 700; font-size: clamp(1.7rem, 4vw, 2.4rem); text-transform: uppercase; letter-spacing: .03em; line-height: 1.05; }
.ej-lead { color: var(--muted); margin-top: .35rem; max-width: 42rem; }
.ej-empty { color: var(--muted); padding: 2.5rem 0; text-align: center; }
.ej-h2 { font-family: var(--font-title); font-weight: 700; font-size: 1.35rem; text-transform: uppercase; letter-spacing: .03em; margin-bottom: .9rem; }
.ej-h2::first-letter { text-transform: uppercase; }
.ej-h3 { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .05em; font-size: .95rem; margin-bottom: .6rem; }

.ej-list { display: flex; gap: .5rem; overflow-x: auto; padding-bottom: .4rem; margin-bottom: 1.25rem; scrollbar-width: thin; }
.ej-chip { flex: none; display: flex; flex-direction: column; gap: .1rem; text-align: left; min-width: 7.5rem; padding: .55rem .75rem; border-radius: .7rem;
  border: 1px solid var(--border); background: var(--card); color: var(--text); cursor: pointer; }
.ej-chip:hover { border-color: color-mix(in srgb, var(--accent) 35%, var(--border)); }
.ej-chip.on { border-color: color-mix(in srgb, var(--accent) 65%, var(--border)); background: color-mix(in srgb, var(--accent) 12%, var(--card)); }
.ej-meta { font-size: .72rem; color: var(--muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 9rem; }

.ej-champs { display: flex; flex-wrap: wrap; gap: .75rem; margin-bottom: 1rem; }
.ej-champ { display: flex; align-items: center; gap: .65rem; padding: .6rem .9rem; border-radius: .8rem; border: 1px solid rgba(234, 179, 8, .4); background: rgba(234, 179, 8, .08); color: #eab308; }
.ej-champ span { display: block; font-size: .65rem; font-weight: 800; text-transform: uppercase; letter-spacing: .1em; }
.ej-champ strong { display: block; color: var(--text); }
.ej-champ em { display: block; font-style: normal; font-size: .75rem; color: var(--muted); }

.ej-grid { display: grid; gap: 1rem; grid-template-columns: 1fr; }
@media (min-width: 1100px) { .ej-grid { grid-template-columns: 1fr 1fr; } }
.ej-card { border: 1px solid var(--border); border-radius: 14px; background: var(--card); padding: 1rem; min-width: 0; }
.ej-card .data-table { min-width: 0; }
.ej-player { color: inherit; text-decoration: none; }
.ej-player:hover { color: var(--accent-l); }
.ej-guests { font-size: .75rem; color: var(--muted); margin-top: .5rem; }

.ej-results { margin-top: .75rem; }
.ej-results summary { cursor: pointer; font-size: .85rem; font-weight: 600; color: var(--muted); }
.ej-results summary:hover { color: var(--text); }
.ej-results ul { list-style: none; padding: 0; margin: .5rem 0 0; display: flex; flex-direction: column; gap: .25rem; }
.ej-results li { display: grid; grid-template-columns: 1fr auto 1fr; align-items: center; gap: .6rem; font-size: .82rem; padding: .3rem .4rem; border-radius: .4rem; }
.ej-results li:nth-child(odd) { background: color-mix(in srgb, var(--border) 18%, transparent); }
.ej-p { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.ej-p2 { text-align: right; }
.ej-score { font-family: var(--font-title); font-weight: 700; white-space: nowrap; }
</style>
