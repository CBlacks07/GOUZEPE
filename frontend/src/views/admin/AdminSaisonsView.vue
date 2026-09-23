<template>
  <AppLayout season-label="Administration">
    <div class="page-wrap adm-saisons">
      <div class="head">
        <div>
          <h1 class="title">Saisons</h1>
          <p class="sub">Saisons eFootball et journées confirmées. La saisie se fait dans <RouterLink to="/admin/journees">Journées</RouterLink>.</p>
        </div>
        <div class="flex flex-wrap gap-2">
          <RouterLink to="/admin/journees" class="btn text-sm">
            <CalendarPlusIcon class="w-4 h-4" /> Nouvelle journée
          </RouterLink>
          <button @click="createOpen = true" class="btn-primary text-sm">
            <PlusIcon class="w-4 h-4" /> Créer une saison
          </button>
        </div>
      </div>

      <div v-if="loadingSeasons" class="empty"><Loader2Icon class="w-5 h-5 animate-spin inline" /> Chargement…</div>
      <div v-else-if="!seasons.length" class="empty">Aucune saison. Crée la première pour commencer.</div>

      <div v-else class="grid-layout">
        <!-- Liste des saisons -->
        <div class="season-list" role="listbox" aria-label="Saisons">
          <button v-for="s in seasons" :key="s.id" type="button" role="option"
                  :aria-selected="String(s.id === selectedId)"
                  :class="['season-item', { on: s.id === selectedId }]" @click="selectSeason(s.id)">
            <div class="flex items-center justify-between gap-2">
              <strong>{{ s.name }}</strong>
              <span :class="['pill', s.is_closed ? 'pill-closed' : 'pill-open']">{{ s.is_closed ? 'Clôturée' : 'En cours' }}</span>
            </div>
            <span class="dates">
              {{ fmtDate(s.started_at) }}<template v-if="s.ended_at"> → {{ fmtDate(s.ended_at) }}</template>
            </span>
          </button>
        </div>

        <!-- Journées de la saison sélectionnée -->
        <section class="card">
          <div class="card-head">
            <h2>Journées confirmées <span v-if="!loadingDays" class="count">{{ days.length }}</span></h2>
            <RouterLink v-if="selected" :to="{ path: '/classement' }" class="text-xs link-muted">Voir le classement →</RouterLink>
          </div>

          <div v-if="loadingDays" class="empty"><Loader2Icon class="w-5 h-5 animate-spin inline" /></div>
          <div v-else-if="!days.length" class="empty">Aucune journée confirmée dans cette saison.</div>
          <table v-else class="data-table text-sm w-full">
            <thead>
              <tr>
                <th>Date</th>
                <th class="text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="d in days" :key="d">
                <td class="font-semibold capitalize">{{ fmtDay(d) }}</td>
                <td class="text-right whitespace-nowrap">
                  <RouterLink :to="{ path: '/admin/journees', query: { day: d } }" class="btn text-xs">
                    <PencilIcon class="w-3.5 h-3.5" /> Modifier
                  </RouterLink>
                  <button @click="deleteDay(d)" class="btn text-xs btn-danger ml-1" :disabled="deleting === d"
                          :aria-label="`Supprimer la journée du ${fmtDay(d)}`">
                    <Loader2Icon v-if="deleting === d" class="w-3.5 h-3.5 animate-spin" />
                    <Trash2Icon v-else class="w-3.5 h-3.5" />
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </section>
      </div>
    </div>

    <BaseModal :open="createOpen" title="Créer une saison" @close="createOpen = false" size="sm">
      <div>
        <label class="label" for="new-season-name">Nom de la saison</label>
        <input id="new-season-name" v-model="newName" type="text" class="input" placeholder="ex: Saison 2026-2027"
               @keydown.enter="createSeason" />
        <p class="text-xs mt-2" style="color:var(--amber,#f59e0b)">
          Créer une saison <strong>clôture la saison en cours</strong>. Elle reste consultable, mais les nouvelles journées iront dans la nouvelle saison.
        </p>
      </div>
      <template #footer>
        <button @click="createOpen = false" class="btn">Annuler</button>
        <button @click="createSeason" class="btn-primary" :disabled="!newName.trim() || creating">
          <Loader2Icon v-if="creating" class="w-3.5 h-3.5 animate-spin" /> Créer
        </button>
      </template>
    </BaseModal>
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import AppLayout from '@/components/layout/AppLayout.vue'
import BaseModal from '@/components/ui/BaseModal.vue'
import { useAPI } from '@/composables/useAPI'
import { useToast } from '@/composables/useToast'
import { PlusIcon, CalendarPlusIcon, PencilIcon, Trash2Icon, Loader2Icon } from 'lucide-vue-next'

const api = useAPI()
const { success, error: toastError } = useToast()

const seasons = ref([])
const selectedId = ref(null)
const days = ref([])
const loadingSeasons = ref(false)
const loadingDays = ref(false)
const deleting = ref(null)

const createOpen = ref(false)
const newName = ref('')
const creating = ref(false)

const selected = computed(() => seasons.value.find((s) => s.id === selectedId.value) || null)

function fmtDate(v) {
  if (!v) return '—'
  const d = new Date(v)
  return isNaN(d) ? '—' : d.toLocaleDateString('fr-FR', { day: '2-digit', month: 'short', year: 'numeric' })
}
function fmtDay(day) {
  const d = new Date(`${day}T12:00:00`)
  return isNaN(d) ? day : d.toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })
}

async function loadSeasons() {
  loadingSeasons.value = true
  try {
    const { data } = await api.get('/seasons')
    seasons.value = data.seasons || []
    if (!seasons.value.some((s) => s.id === selectedId.value)) {
      const current = seasons.value.find((s) => !s.is_closed) || seasons.value[0]
      selectedId.value = current ? current.id : null
    }
    await loadDays()
  } catch (_) {
    toastError('Impossible de charger les saisons')
  } finally {
    loadingSeasons.value = false
  }
}

async function loadDays() {
  if (!selectedId.value) { days.value = []; return }
  loadingDays.value = true
  try {
    const { data } = await api.get(`/seasons/${selectedId.value}/matchdays`)
    days.value = [...(data.days || [])].reverse()
  } catch (_) {
    days.value = []
    toastError('Impossible de charger les journées')
  } finally {
    loadingDays.value = false
  }
}

function selectSeason(id) {
  if (id === selectedId.value) return
  selectedId.value = id
  loadDays()
}

async function deleteDay(day) {
  if (!confirm(`Supprimer définitivement la journée du ${fmtDay(day)} ?\nSes résultats seront retirés du classement.`)) return
  deleting.value = day
  try {
    await api.delete(`/matchdays/${day}`)
    days.value = days.value.filter((d) => d !== day)
    success('Journée supprimée')
  } catch (_) {
    toastError('Suppression impossible')
  } finally {
    deleting.value = null
  }
}

async function createSeason() {
  const name = newName.value.trim()
  if (!name || creating.value) return
  creating.value = true
  try {
    const { data } = await api.post('/seasons', { name })
    success('Saison créée')
    newName.value = ''
    createOpen.value = false
    selectedId.value = data?.season?.id ?? null
    await loadSeasons()
  } catch (_) {
    toastError('Création impossible')
  } finally {
    creating.value = false
  }
}

onMounted(loadSeasons)
</script>

<style scoped>
.adm-saisons { max-width: 64rem; }
.head { display: flex; flex-wrap: wrap; align-items: flex-end; justify-content: space-between; gap: 1rem; margin-bottom: 1.5rem; }
.title { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .04em; font-size: 1.5rem; }
.sub { color: var(--muted); margin-top: .25rem; font-size: .9rem; }
.sub a { color: var(--accent-l); }

.grid-layout { display: grid; gap: 1rem; grid-template-columns: 1fr; }
@media (min-width: 900px) { .grid-layout { grid-template-columns: 17rem 1fr; align-items: start; } }

.season-list { display: flex; flex-direction: column; gap: .5rem; }
.season-item {
  text-align: left; padding: .8rem .9rem; border-radius: .75rem;
  background: var(--card); border: 1px solid var(--border); color: var(--text); cursor: pointer;
  transition: border-color .15s;
}
.season-item:hover { border-color: color-mix(in srgb, var(--accent) 35%, var(--border)); }
.season-item.on { border-color: color-mix(in srgb, var(--accent) 60%, var(--border)); background: color-mix(in srgb, var(--accent) 10%, var(--card)); }
.dates { display: block; font-size: .75rem; color: var(--muted); margin-top: .25rem; }

.pill { font-size: .62rem; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; padding: .1rem .45rem; border-radius: 999px; white-space: nowrap; }
.pill-open { color: #4ade80; background: rgba(34, 197, 94, .14); }
.pill-closed { color: var(--muted); background: color-mix(in srgb, var(--border) 40%, transparent); }

.card { background: var(--card); border: 1px solid var(--border); border-radius: .9rem; overflow: hidden; }
.card-head { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: .75rem; padding: .8rem 1rem; border-bottom: 1px solid var(--border); }
.card-head h2 { white-space: nowrap; font-weight: 600; display: flex; align-items: center; gap: .5rem; }
.count { font-size: .72rem; font-weight: 700; color: var(--muted); background: color-mix(in srgb, var(--border) 40%, transparent); padding: .05rem .45rem; border-radius: 999px; }
.link-muted { color: var(--muted); text-decoration: none; }
.link-muted:hover { color: var(--accent-l); }
.card .data-table { min-width: 0; }

.btn-danger { color: #fca5a5; }
.btn-danger:hover { border-color: #7f1d1d; background: rgba(127, 29, 29, .25); }
.empty { padding: 1.5rem 1rem; text-align: center; color: var(--muted); font-size: .9rem; }
</style>
