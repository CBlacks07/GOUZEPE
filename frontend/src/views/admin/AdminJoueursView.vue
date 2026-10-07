<template>
  <AppLayout season-label="Joueurs">
    <div class="page-wrap admin-joueurs-wrap">

      <!-- En-tête -->
      <header class="al-head reveal">
        <div>
          <h1 class="al-title">Joueurs</h1>
          <p class="al-sub">Les membres et invités du club, leur pôle et leur compte de connexion.</p>
          <div class="al-stats">
            <span class="al-stat"><strong>{{ members.length }}</strong> membres</span>
            <span class="al-stat"><strong>{{ guests.length }}</strong> invités</span>
            <span class="al-stat"><strong>{{ players.filter(p => p.user_email).length }}</strong> avec compte</span>
          </div>
        </div>
        <button class="btn-primary flex items-center gap-1.5" :aria-expanded="String(showCreate)" @click="showCreate = !showCreate">
          <XIcon v-if="showCreate" class="w-4 h-4" />
          <UserPlusIcon v-else class="w-4 h-4" />
          {{ showCreate ? 'Fermer' : 'Nouveau joueur' }}
        </button>
      </header>

      <!-- Création -->
      <section v-if="showCreate" class="al-panel reveal">
        <h2 class="al-panel-title"><UserPlusIcon class="w-4 h-4" /> Ajouter un joueur</h2>
        <div class="al-form">
          <div>
            <label class="label">ID (ex: CBlacks_GZ)</label>
            <input v-model="newP.player_id" type="text" class="input" placeholder="ID joueur" autocomplete="off" />
          </div>
          <div>
            <label class="label">Nom complet</label>
            <input v-model="newP.name" type="text" class="input" placeholder="Nom complet" autocomplete="off" />
          </div>
          <div>
            <label class="label">Statut</label>
            <select v-model="newP.role" class="input">
              <option value="MEMBRE">Membre</option>
              <option value="INVITE">Invité</option>
            </select>
          </div>
          <div>
            <label class="label">Pôle</label>
            <select v-model="newP.main_game" class="input">
              <option value="efoot">eFootball</option>
              <option value="tekken">Tekken</option>
              <option value="both">Les deux</option>
            </select>
          </div>
          <button @click="addPlayer" :disabled="adding" class="btn-primary flex items-center justify-center gap-1.5">
            <Loader2Icon v-if="adding" class="w-3.5 h-3.5 animate-spin" />
            <PlusIcon v-else class="w-3.5 h-3.5" />
            Ajouter
          </button>
        </div>
        <p v-if="createMsg" :class="['text-sm mt-2', createOk ? 'text-gz-green' : 'text-gz-red']">{{ createMsg }}</p>
      </section>

      <!-- Barre d'outils -->
      <div class="al-toolbar reveal delay-1">
        <div class="al-seg" role="tablist" aria-label="Statut">
          <button role="tab" :aria-selected="String(tab === 'members')" :class="{ on: tab === 'members' }" @click="tab = 'members'">Membres<span class="n">{{ filteredMembers.length }}</span></button>
          <button role="tab" :aria-selected="String(tab === 'guests')" :class="{ on: tab === 'guests' }" @click="tab = 'guests'">Invités<span class="n">{{ filteredGuests.length }}</span></button>
        </div>
        <div class="al-seg" role="group" aria-label="Pôle">
          <button v-for="o in poleOptions" :key="o.v" :class="{ on: poleFilter === o.v }" :aria-pressed="String(poleFilter === o.v)" @click="poleFilter = o.v">{{ o.l }}</button>
        </div>
        <div class="al-search">
          <SearchIcon class="w-4 h-4" />
          <input v-model="search" type="search" class="input" placeholder="Rechercher un joueur…" aria-label="Rechercher un joueur" />
        </div>
        <span class="al-spacer"></span>
        <button @click="loadPlayers" class="al-icon" title="Rafraîchir la liste" aria-label="Rafraîchir la liste">
          <RefreshCwIcon class="w-4 h-4" :class="{ 'animate-spin': loading }" />
        </button>
      </div>

      <!-- Liste -->
      <section class="al-card reveal delay-2">
        <SkeletonBlock v-if="loading && !players.length" :count="6" class="p-3" />
        <div v-else-if="!shownRows.length" class="al-empty">
          <strong>{{ search || poleFilter !== 'all' ? 'Aucun résultat' : tab === 'guests' ? 'Aucun invité' : 'Aucun membre' }}</strong>
          <span v-if="search || poleFilter !== 'all'">Essaie un autre nom ou retire le filtre de pôle.</span>
          <span v-else>Utilise « Nouveau joueur » pour en ajouter un.</span>
        </div>
        <div v-else class="overflow-x-auto">
          <table class="al-table">
            <thead>
              <tr>
                <th>Joueur</th>
                <th>Pôle</th>
                <th class="hidden sm:table-cell">Admission</th>
                <th class="hidden md:table-cell">Compte</th>
                <th style="text-align:right">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="p in shownRows" :key="p.player_id">
                <td>
                  <div class="al-who">
                    <span class="al-av" aria-hidden="true">{{ initials(p.name || p.player_id) }}</span>
                    <span class="min-w-0">
                      <span class="al-name">{{ p.name || '—' }}</span>
                      <span class="al-id">{{ p.player_id }}</span>
                    </span>
                  </div>
                </td>
                <td><span :class="['al-pill', p.main_game || 'efoot']">{{ poleLabel(p.main_game) }}</span></td>
                <td class="al-muted hidden sm:table-cell">{{ p.admission_year || '—' }}</td>
                <td class="hidden md:table-cell">
                  <span v-if="p.user_email" class="al-pill ok" :title="p.user_email">Compte lié</span>
                  <span v-else class="al-pill none">Aucun compte</span>
                </td>
                <td>
                  <div class="al-actions">
                    <button @click="openEdit(p)" class="al-icon" :title="'Modifier ' + (p.name || p.player_id)" :aria-label="'Modifier ' + (p.name || p.player_id)"><PencilIcon class="w-4 h-4" /></button>
                    <button @click="deletePlayer(p.player_id)" class="al-icon danger" :title="'Supprimer ' + (p.name || p.player_id)" :aria-label="'Supprimer ' + (p.name || p.player_id)"><Trash2Icon class="w-4 h-4" /></button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
    </div>

    <!-- Modal édition joueur -->
    <BaseModal :open="modal" title="Modifier le joueur" @close="modal = false">
      <div class="space-y-4">
        <div>
          <label class="label">ID (clé) — attention : modifier l'ID affecte toutes les références</label>
          <input v-model="form.player_id" type="text" class="input" />
        </div>
        <div>
          <label class="label">Nom</label>
          <input v-model="form.name" type="text" class="input" placeholder="Nom complet" />
        </div>
        <div>
          <label class="label">Statut</label>
          <select v-model="form.role" class="input">
            <option value="MEMBRE">MEMBRE</option>
            <option value="INVITE">INVITE</option>
          </select>
        </div>
        <div>
          <label class="label">Pole principal</label>
          <select v-model="form.main_game" class="input">
            <option value="efoot">eFootball</option>
            <option value="tekken">Tekken</option>
            <option value="both">Les deux</option>
          </select>
        </div>
        <div>
          <label class="label">Annee d'admission</label>
          <input v-model.number="form.admission_year" type="number" class="input" min="2000" :max="new Date().getFullYear()" placeholder="2025" />
        </div>
        <div>
          <label class="label">Photo de profil</label>
          <div class="flex items-center gap-3">
            <div v-if="form.profile_pic_url" class="w-12 h-12 rounded-full overflow-hidden bg-gz-panel flex-none">
              <img :src="photoPreview || resolvePhotoUrl(form.profile_pic_url)" class="w-full h-full object-cover" />
            </div>
            <div v-else class="w-12 h-12 rounded-full bg-gz-panel flex-none grid place-items-center text-gz-muted font-bold">
              {{ initials(form.name) }}
            </div>
            <label class="btn py-1.5 px-3 text-xs cursor-pointer flex items-center gap-1">
              <CameraIcon class="w-3.5 h-3.5" />
              Changer la photo
              <input type="file" accept="image/*" class="hidden" @change="uploadPlayerPhoto" />
            </label>
            <span v-if="photoMsg" :class="['text-xs', photoOk ? 'text-gz-green' : 'text-gz-red']">{{ photoMsg }}</span>
          </div>
        </div>

        <hr class="border-gz-border" />
        <p class="text-gz-muted text-xs font-semibold">Compte membre associé (connexion nom@gz)</p>
        <div>
          <label class="label">Email (défaut : nom@gz.local)</label>
          <input v-model="form.email" type="text" class="input" placeholder="ex: zidane@gz.local" />
        </div>
        <div>
          <label class="label">Nouveau mot de passe (optionnel)</label>
          <input v-model="form.password" type="password" class="input" placeholder="••••••" />
        </div>

        <p v-if="editMsg" :class="['text-sm', editOk ? 'text-gz-green' : 'text-gz-red']">{{ editMsg }}</p>
      </div>
      <template #footer>
        <button v-if="form.has_user" @click="detachUser"
                class="btn-danger mr-auto text-xs py-1.5 px-3 flex items-center gap-1">
          <UnlinkIcon class="w-3 h-3" /> Détacher
        </button>
        <button @click="modal = false" class="btn">Annuler</button>
        <button @click="attachUser" class="btn flex items-center gap-1.5">Lier/MAJ compte</button>
        <button @click="saveEdit" :disabled="saving" class="btn-primary flex items-center gap-1.5">
          <Loader2Icon v-if="saving" class="w-3.5 h-3.5 animate-spin" />
          Enregistrer
        </button>
      </template>
    </BaseModal>
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import AppLayout from '@/components/layout/AppLayout.vue'
import BaseModal from '@/components/ui/BaseModal.vue'
import { useAPI } from '@/composables/useAPI'
import { useSessionState } from '@/composables/useSessionState'
import { PlusIcon, PencilIcon, Trash2Icon, RefreshCwIcon, Loader2Icon, UnlinkIcon, CameraIcon, ArrowLeftIcon, SearchIcon, UserPlusIcon, XIcon } from 'lucide-vue-next'
import SkeletonBlock from '@/components/ui/SkeletonBlock.vue'
import { resolveBaseURL } from '@/composables/useAPI'

const api = useAPI()

const players   = ref([])
const search    = ref('')
const poleFilter = ref('all')
const showCreate = ref(false)
const tab = ref('members')
const poleOptions = [{ v: 'all', l: 'Tous' }, { v: 'efoot', l: 'eFootball' }, { v: 'tekken', l: 'Tekken' }, { v: 'both', l: 'Les deux' }]
const loading   = ref(false)
const modal     = ref(false)
const saving    = ref(false)
const adding    = ref(false)
const createMsg = ref('')
const createOk  = ref(true)
const editMsg   = ref('')
const editOk    = ref(true)
const editingId = ref('')   // old player_id
const photoMsg  = ref('')
const photoOk   = ref(true)
const photoPreview = ref('')

const newP = ref({ player_id: '', name: '', role: 'MEMBRE', main_game: 'efoot' })
const form = ref({ player_id: '', name: '', role: 'MEMBRE', main_game: 'efoot', admission_year: new Date().getFullYear(), email: '', password: '', has_user: false })

const POLE_LABELS = { efoot: 'eFootball', tekken: 'Tekken', both: 'Les deux' }
function poleLabel(g) { return POLE_LABELS[g] || g || 'eFootball' }
function poleColor(g) {
  if (g === 'tekken') return 'color: #ff5a2c'
  if (g === 'both') return 'color: #a78bfa'
  return 'color: #3b82f6'
}

useSessionState('efoot.ui.admin.joueurs.v1', {
  search,
  modal,
  editingId,
  newP,
  form,
})

const filtered = computed(() => {
  const q = search.value.toLowerCase()
  return players.value.filter(p =>
    (poleFilter.value === 'all' || (p.main_game || 'efoot') === poleFilter.value) &&
    (!q || (p.player_id || '').toLowerCase().includes(q) || (p.name || '').toLowerCase().includes(q))
  )
})
const filteredMembers = computed(() => filtered.value.filter(p => (p.role || 'MEMBRE').toUpperCase() !== 'INVITE'))
const filteredGuests  = computed(() => filtered.value.filter(p => (p.role || 'MEMBRE').toUpperCase() === 'INVITE'))
const members = computed(() => players.value.filter(p => (p.role || 'MEMBRE').toUpperCase() !== 'INVITE'))
const guests  = computed(() => players.value.filter(p => (p.role || 'MEMBRE').toUpperCase() === 'INVITE'))
const shownRows = computed(() => (tab.value === 'guests' ? filteredGuests.value : filteredMembers.value))

onMounted(() => loadPlayers())

async function loadPlayers() {
  loading.value = true
  try {
    const { data } = await api.get('/players')
    players.value = (data.players || []).sort((a, b) =>
      (a.name || a.player_id).localeCompare(b.name || b.player_id, 'fr'))
  } catch (_) {}
  loading.value = false
}

async function addPlayer() {
  const { player_id, name, role, main_game } = newP.value
  if (!player_id || !name) { createMsg.value = 'ID et Nom requis'; createOk.value = false; return }
  adding.value = true
  createMsg.value = 'Enregistrement...'
  try {
    await api.post('/admin/players', { player_id, name, role, main_game })
    createMsg.value = 'Joueur cree'; createOk.value = true
    newP.value = { player_id: '', name: '', role: 'MEMBRE', main_game: 'efoot' }
    await loadPlayers()
  } catch (e) {
    createMsg.value = e.response?.data?.error || 'Erreur'; createOk.value = false
  } finally {
    adding.value = false
  }
}

function slugifyToEmail(name) {
  const domain = localStorage.getItem('efoot.emailDomain') || 'gz.local'
  const loc = (name || '')
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .toLowerCase().replace(/[^a-z0-9]+/g, '.').replace(/\.+/g, '.').replace(/^\.|\.$/g, '')
  return (loc || 'membre') + '@' + domain
}

function resolvePhotoUrl(u) {
  if (!u) return ''
  if (/^https?:\/\//.test(u)) return u
  return resolveBaseURL() + (u.startsWith('/') ? u : '/' + u)
}
function initials(name) {
  return String(name || '?').trim().split(/\s+/).slice(0, 2).map(w => w[0]).join('').toUpperCase()
}

async function uploadPlayerPhoto(e) {
  const file = e.target.files?.[0]
  if (!file) return
  photoMsg.value = 'Upload...'
  photoOk.value = true
  photoPreview.value = URL.createObjectURL(file)
  try {
    const fd = new FormData()
    fd.append('photo', file)
    const { data } = await api.post('/admin/players/' + encodeURIComponent(editingId.value) + '/photo', fd)
    form.value.profile_pic_url = data.profile_pic_url
    photoMsg.value = 'Photo enregistree'
    photoOk.value = true
    await loadPlayers()
  } catch (err) {
    photoMsg.value = err.response?.data?.error || 'Erreur upload'
    photoOk.value = false
  }
}

function openEdit(p) {
  editingId.value = p.player_id
  form.value = {
    player_id: p.player_id,
    name:      p.name || '',
    role:      (p.role || 'MEMBRE').toUpperCase(),
    main_game: p.main_game || 'efoot',
    admission_year: p.admission_year || new Date().getFullYear(),
    profile_pic_url: p.profile_pic_url || '',
    email:     p.user_email || slugifyToEmail(p.name || p.player_id),
    password:  '',
    has_user:  !!p.user_email,
  }
  photoMsg.value = ''
  photoPreview.value = ''
  editMsg.value = '—'
  modal.value = true
}

async function saveEdit() {
  saving.value = true
  editMsg.value = 'Mise à jour…'
  try {
    const oldId  = editingId.value
    const newId  = form.value.player_id.trim()
    if (!newId) { editMsg.value = 'ID requis'; editOk.value = false; saving.value = false; return }

    const body = { name: form.value.name.trim(), role: form.value.role, admission_year: form.value.admission_year, main_game: form.value.main_game }
    if (newId !== oldId) {
      if (!confirm(`⚠ Modifier l'ID "${oldId}" → "${newId}" ? Cela affectera toutes les références.`)) {
        saving.value = false; return
      }
      body.player_id = newId
    }
    await api.put('/admin/players/' + encodeURIComponent(oldId), body)
    editMsg.value = 'Enregistré ✓'; editOk.value = true
    modal.value = false
    await loadPlayers()
  } catch (e) {
    editMsg.value = e.response?.data?.error || 'Erreur'; editOk.value = false
  } finally {
    saving.value = false
  }
}

async function attachUser() {
  editMsg.value = 'Liaison du compte…'
  try {
    const payload = { email: form.value.email.trim() }
    if (form.value.password) payload.password = form.value.password
    const { data } = await api.post('/admin/players/' + encodeURIComponent(editingId.value) + '/attach_user', payload)
    editMsg.value = 'Compte lié : ' + (data.user?.email || form.value.email); editOk.value = true
    form.value.has_user = true
    await loadPlayers()
  } catch (e) {
    editMsg.value = e.response?.data?.error || 'Erreur'; editOk.value = false
  }
}

async function detachUser() {
  if (!confirm('Voulez-vous vraiment dissocier le compte utilisateur de ce joueur ?')) return
  editMsg.value = 'Dissociation…'
  try {
    await api.post('/admin/players/' + encodeURIComponent(editingId.value) + '/detach_user')
    editMsg.value = 'Compte dissocié'; editOk.value = true
    form.value.has_user = false
    modal.value = false
    await loadPlayers()
  } catch (e) {
    editMsg.value = e.response?.data?.error || 'Erreur'; editOk.value = false
  }
}

async function deletePlayer(pid) {
  if (!confirm(`Supprimer le joueur "${pid}" ?`)) return
  try {
    await api.delete('/admin/players/' + encodeURIComponent(pid))
    players.value = players.value.filter(p => p.player_id !== pid)
  } catch (e) {
    alert(e.response?.data?.error || 'Erreur')
  }
}
</script>

<style scoped>
.admin-joueurs-wrap {
  width: 100%;
}

.admin-joueurs-wrap :deep(.card) {
  transition: transform 180ms ease, box-shadow 180ms ease, border-color 180ms ease;
}

.admin-joueurs-wrap :deep(.card:hover) {
  transform: translateY(-1px);
  box-shadow: 0 12px 26px rgba(2, 6, 23, 0.2);
  border-color: color-mix(in srgb, var(--border) 68%, var(--blue) 32%);
}

.players-group + .players-group {
  margin-top: 1.5rem;
}

.players-group-h {
  display: flex;
  align-items: center;
  gap: .5rem;
  font-size: .85rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: .04em;
  color: var(--text);
  margin-bottom: .6rem;
}

.dot {
  width: .55rem;
  height: .55rem;
  border-radius: 50%;
  flex: none;
}
.dot-member { background: var(--blue); }
.dot-guest  { background: var(--amber); }

.players-count {
  font-family: var(--font-title);
  font-weight: 800;
  font-size: .72rem;
  color: var(--muted);
  background: color-mix(in srgb, var(--border) 45%, transparent);
  border-radius: 999px;
  padding: .1rem .5rem;
}

.table-shell {
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 12px;
  background: color-mix(in srgb, var(--card) 92%, transparent);
}

.table-shell :deep(.data-table thead th) {
  border-bottom: 1px solid rgba(148, 163, 184, 0.24);
}

.table-shell :deep(.data-table tbody td) {
  border-bottom: 1px solid rgba(148, 163, 184, 0.12);
}

.table-shell :deep(.data-table tbody tr:last-child td) {
  border-bottom: none;
}


@media (min-width: 1024px) {
  .admin-joueurs-wrap {
    max-width: none;
    padding: clamp(14px, 2.1vw, 30px);
  }
}

@media (prefers-reduced-motion: reduce) {
  .reveal {
    animation: none !important;
  }

  .admin-joueurs-wrap :deep(.card) {
    transition: none !important;
  }
}
</style>
