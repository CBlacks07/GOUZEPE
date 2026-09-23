<template>
  <AdaptiveLayout season-label="Tekken · Journées">
    <div class="page-wrap tkj">
      <div class="tkj-top">
        <div>
          <h1 class="tkj-h1">Journées Tekken</h1>
          <p class="tkj-lead">Le championnat du club : chaque victoire rapporte des points, chaque match compte pour l'ELO.</p>
        </div>
        <div class="flex items-end gap-2">
          <div>
            <label class="label" for="tkj-season">Saison</label>
            <select id="tkj-season" v-model="seasonId" class="input w-52" @change="loadJournees">
              <option v-for="s in seasons" :key="s.id" :value="s.id">{{ s.name }}{{ s.is_closed ? ' (clôturée)' : '' }}</option>
            </select>
          </div>
          <RouterLink to="/tekken/classement" class="btn text-sm">
            <BarChart2Icon class="w-4 h-4" /> Classement
          </RouterLink>
        </div>
      </div>

      <div v-if="loadingList" class="tkj-empty"><Loader2Icon class="w-5 h-5 animate-spin inline" /> Chargement…</div>
      <div v-else-if="!journees.length" class="tkj-empty">Aucune journée Tekken pour cette saison.</div>

      <template v-else>
        <nav class="tkj-list" aria-label="Journées de la saison">
          <button v-for="j in journees" :key="j.id" type="button"
                  :class="['tkj-chip', { on: j.id === selectedId, live: j.status === 'live' }]"
                  :aria-current="j.id === selectedId ? 'true' : null"
                  @click="select(j.id)">
            <span v-if="j.status === 'live'" class="tkj-live">En direct</span>
            <strong>{{ j.name }}</strong>
            <span class="tkj-meta">
              {{ j.starts_at ? shortDate(j.starts_at) : statusLabel(j.status) }}
              <template v-if="j.winner_name"> · <TrophyIcon class="w-3 h-3 inline" style="color:#eab308" /> {{ j.winner_name }}</template>
            </span>
          </button>
        </nav>

        <TekkenJourneeDetail v-if="selectedId" :journee-id="selectedId" />
      </template>
    </div>
  </AdaptiveLayout>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import AdaptiveLayout from '@/components/layout/AdaptiveLayout.vue'
import TekkenJourneeDetail from '@/components/tekken/TekkenJourneeDetail.vue'
import { useAPI } from '@/composables/useAPI'
import { useGameStore } from '@/stores/game'
import { onRealtimeEvent } from '@/composables/useRealtimeSocket'
import { TrophyIcon, Loader2Icon, BarChart2Icon } from 'lucide-vue-next'

const api = useAPI()
const route = useRoute()
const router = useRouter()
useGameStore().set('tekken') // accent Tekken, y compris pour un visiteur

const seasons = ref([])
const seasonId = ref(null)
const journees = ref([])
const selectedId = ref(null)
const loadingList = ref(false)

async function loadSeasons() {
  try {
    const { data } = await api.get('/public/seasons')
    seasons.value = data.seasons || []
    const current = seasons.value.find((s) => !s.is_closed) || seasons.value[0]
    seasonId.value = current ? current.id : null
  } catch (_) {}
}

async function loadJournees() {
  loadingList.value = true
  try {
    const { data } = await api.get('/tekken/journees', { params: seasonId.value ? { season_id: seasonId.value } : {} })
    journees.value = data.journees || []
    if (!seasonId.value) seasonId.value = data.season_id
    // Priorité : lien direct (?j=), sinon la journée en direct, sinon la plus récente.
    const wanted = Number(route.query.j)
    const pick = journees.value.find((j) => j.id === wanted)
      || journees.value.find((j) => j.status === 'live')
      || journees.value[0]
    selectedId.value = pick ? pick.id : null
  } catch (_) {
    journees.value = []
  } finally {
    loadingList.value = false
  }
}

function select(id) {
  selectedId.value = id
  router.replace({ query: { ...route.query, j: id } })
}

// Une journée créée, supprimée ou qui change de statut se met à jour sans recharger la page.
let offChanged = null
let listTimer = null
onMounted(async () => {
  await loadSeasons()
  await loadJournees()
  offChanged = onRealtimeEvent('tournament:changed', () => {
    clearTimeout(listTimer)
    listTimer = setTimeout(refreshListQuietly, 400)
  })
})
onUnmounted(() => {
  if (offChanged) offChanged()
  clearTimeout(listTimer)
})

async function refreshListQuietly() {
  try {
    const { data } = await api.get('/tekken/journees', { params: { season_id: seasonId.value } })
    journees.value = data.journees || []
  } catch (_) {}
}

const STATUS = { draft: 'À venir', live: 'En direct', completed: 'Terminée', archived: 'Archivée', cancelled: 'Annulée' }
function statusLabel(s) { return STATUS[s] || s }
function shortDate(v) {
  const d = new Date(v)
  return isNaN(d) ? '' : d.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' })
}
</script>

<style scoped>
.tkj-top { display: flex; flex-wrap: wrap; align-items: flex-end; justify-content: space-between; gap: 1rem; margin-bottom: 1.25rem; }
.tkj-h1 { font-family: var(--font-title); font-weight: 700; font-size: clamp(1.7rem, 4vw, 2.4rem); text-transform: uppercase; letter-spacing: .03em; line-height: 1.05; }
.tkj-lead { color: var(--muted); margin-top: .35rem; max-width: 42rem; }
.tkj-empty { color: var(--muted); padding: 2.5rem 0; text-align: center; }

.tkj-list { display: flex; gap: .6rem; overflow-x: auto; padding-bottom: .4rem; margin-bottom: 1.25rem; scrollbar-width: thin; }
.tkj-chip {
  flex: none; display: flex; flex-direction: column; gap: .15rem; text-align: left;
  min-width: 11rem; max-width: 16rem; padding: .65rem .85rem; border-radius: .8rem;
  border: 1px solid var(--border); background: var(--card); color: var(--text); cursor: pointer;
  transition: border-color .15s, background-color .15s;
}
.tkj-chip:hover { border-color: color-mix(in srgb, var(--accent) 35%, var(--border)); }
.tkj-chip.on { border-color: color-mix(in srgb, var(--accent) 65%, var(--border)); background: color-mix(in srgb, var(--accent) 12%, var(--card)); }
.tkj-chip strong { font-size: .9rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.tkj-meta { font-size: .74rem; color: var(--muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.tkj-live { align-self: flex-start; font-size: .6rem; font-weight: 800; text-transform: uppercase; letter-spacing: .08em; padding: .05rem .45rem; border-radius: 999px; background: rgba(239, 68, 68, .16); color: #f87171; }
</style>
