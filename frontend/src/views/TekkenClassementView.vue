<template>
  <AdaptiveLayout season-label="Tekken · Classement">
    <div class="page-wrap tkc">
      <div class="tkc-top">
        <div>
          <h1 class="tkc-h1">Classement Tekken</h1>
          <p class="tkc-lead">
            Championnat de la saison : somme des points gagnés sur les journées terminées.
            <span v-if="!loading">{{ journeesCount }} journée(s) disputée(s).</span>
          </p>
        </div>
        <div class="flex items-end gap-2 flex-wrap">
          <div>
            <label class="label" for="tkc-season">Saison</label>
            <select id="tkc-season" v-model="seasonId" class="input w-52" @change="load">
              <option v-for="s in seasons" :key="s.id" :value="s.id">{{ s.name }}{{ s.is_closed ? ' (clôturée)' : '' }}</option>
            </select>
          </div>
          <RouterLink to="/tekken/journees" class="btn text-sm"><CalendarDaysIcon class="w-4 h-4" /> Journées</RouterLink>
          <RouterLink :to="ladderLink" class="btn text-sm"><ListOrderedIcon class="w-4 h-4" /> Ladder ELO</RouterLink>
        </div>
      </div>

      <div v-if="loading" class="tkc-empty"><Loader2Icon class="w-5 h-5 animate-spin inline" /> Chargement…</div>
      <div v-else-if="!rows.length" class="tkc-empty">
        Aucune journée terminée pour cette saison : le classement apparaîtra après la première journée.
      </div>

      <template v-else>
        <!-- Podium -->
        <div class="tkc-podium">
          <div v-for="r in rows.slice(0, 3)" :key="r.rank" :class="['tkc-pod', `p${r.rank}`]">
            <span class="tkc-rank">{{ r.rank }}</span>
            <strong>{{ r.name }}</strong>
            <span class="tkc-pts">{{ r.points }} pts</span>
            <span class="tkc-sub">{{ r.titles }} titre(s) · {{ r.wins }} V</span>
          </div>
        </div>

        <div class="tkc-card overflow-x-auto">
          <table class="data-table text-sm w-full">
            <thead>
              <tr>
                <th class="text-center w-10">#</th>
                <th>Joueur</th>
                <th class="text-center w-20">Journées</th>
                <th class="text-center w-16">Titres</th>
                <th class="text-center w-14">V</th>
                <th class="text-center w-14">D</th>
                <th class="text-center w-16">Diff.</th>
                <th class="text-center w-20">Points</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="r in rows" :key="r.player_id || r.name">
                <td class="text-center" style="color:var(--muted)">{{ r.rank }}</td>
                <td class="font-semibold">
                  <RouterLink v-if="r.player_id" :to="`/joueur/${encodeURIComponent(r.player_id)}`" class="tkc-player">{{ r.name }}</RouterLink>
                  <span v-else>{{ r.name }}</span>
                </td>
                <td class="text-center">{{ r.journees }}</td>
                <td class="text-center">
                  <span v-if="r.titles" class="inline-flex items-center gap-1"><TrophyIcon class="w-3.5 h-3.5" style="color:#eab308" />{{ r.titles }}</span>
                  <span v-else style="color:var(--muted)">0</span>
                </td>
                <td class="text-center">{{ r.wins }}</td>
                <td class="text-center">{{ r.losses }}</td>
                <td class="text-center" style="color:var(--muted)">{{ r.rounds_diff > 0 ? '+' : '' }}{{ r.rounds_diff }}</td>
                <td class="text-center font-bold">{{ r.points }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>
    </div>
  </AdaptiveLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import AdaptiveLayout from '@/components/layout/AdaptiveLayout.vue'
import { useAPI } from '@/composables/useAPI'
import { useAuthStore } from '@/stores/auth'
import { useGameStore } from '@/stores/game'
import { TrophyIcon, Loader2Icon, CalendarDaysIcon, ListOrderedIcon } from 'lucide-vue-next'

const api = useAPI()
const auth = useAuthStore()
useGameStore().set('tekken')

const seasons = ref([])
const seasonId = ref(null)
const rows = ref([])
const journeesCount = ref(0)
const loading = ref(false)

// Le ladder détaillé est réservé aux membres ; les visiteurs le voient dans les classements publics.
const ladderLink = computed(() => (auth.isValid ? '/tekken-ladder' : '/classements'))

async function load() {
  loading.value = true
  try {
    const { data } = await api.get('/tekken/season-standings', { params: seasonId.value ? { season_id: seasonId.value } : {} })
    rows.value = data.standings || []
    journeesCount.value = data.journees_count || 0
    if (!seasonId.value) seasonId.value = data.season_id
  } catch (_) {
    rows.value = []
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  try {
    const { data } = await api.get('/public/seasons')
    seasons.value = data.seasons || []
    const current = seasons.value.find((s) => !s.is_closed) || seasons.value[0]
    seasonId.value = current ? current.id : null
  } catch (_) {}
  await load()
})
</script>

<style scoped>
.tkc-top { display: flex; flex-wrap: wrap; align-items: flex-end; justify-content: space-between; gap: 1rem; margin-bottom: 1.5rem; }
.tkc-h1 { font-family: var(--font-title); font-weight: 700; font-size: clamp(1.7rem, 4vw, 2.4rem); text-transform: uppercase; letter-spacing: .03em; line-height: 1.05; }
.tkc-lead { color: var(--muted); margin-top: .35rem; max-width: 44rem; }
.tkc-empty { color: var(--muted); padding: 2.5rem 0; text-align: center; }

.tkc-podium { display: grid; gap: .8rem; grid-template-columns: 1fr; margin-bottom: 1.25rem; }
@media (min-width: 720px) { .tkc-podium { grid-template-columns: repeat(3, 1fr); } }
.tkc-pod { display: grid; grid-template-columns: auto 1fr; column-gap: .8rem; align-items: center;
  padding: .9rem 1rem; border-radius: 14px; border: 1px solid var(--border); background: var(--card); }
.tkc-pod strong { font-family: var(--font-title); font-size: 1.15rem; letter-spacing: .02em; }
.tkc-rank { grid-row: span 3; display: grid; place-items: center; width: 2.4rem; height: 2.4rem; border-radius: 50%;
  font-family: var(--font-title); font-weight: 800; font-size: 1.1rem; background: color-mix(in srgb, var(--border) 45%, transparent); }
.tkc-pod.p1 { border-color: rgba(234, 179, 8, .45); background: linear-gradient(135deg, rgba(234, 179, 8, .12), var(--card)); }
.tkc-pod.p1 .tkc-rank { background: #eab308; color: #1a1300; }
.tkc-pod.p2 .tkc-rank { background: #cbd5e1; color: #111827; }
.tkc-pod.p3 .tkc-rank { background: #d97706; color: #1a0f00; }
.tkc-pts { font-weight: 700; color: var(--accent-l); }
.tkc-sub { font-size: .75rem; color: var(--muted); }

.tkc-card { border: 1px solid var(--border); border-radius: 14px; background: var(--card); }
.tkc-player { color: inherit; text-decoration: none; }
.tkc-player:hover { color: var(--accent-l); }
</style>
