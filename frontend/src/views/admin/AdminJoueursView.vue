<template>
  <AppLayout season-label="Joueurs">
    <div class="page-wrap admin-joueurs-wrap">

      <!-- Créer un joueur -->
      <section class="card mb-4 reveal">
        <h2 class="font-semibold text-gz-text mb-4">Créer / modifier un joueur</h2>
        <div class="flex flex-wrap gap-2 items-end">
          <div class="min-w-[150px]">
            <label class="label">ID (ex: CBlacks_GZ)</label>
            <input v-model="newP.player_id" type="text" class="input" placeholder="ID joueur" />
          </div>
          <div class="flex-1 min-w-[200px]">
            <label class="label">Nom complet</label>
            <input v-model="newP.name" type="text" class="input" placeholder="Nom complet" />
          </div>
          <div>
            <label class="label">Statut</label>
            <select v-model="newP.role" class="input">
              <option value="MEMBRE">MEMBRE</option>
              <option value="INVITE">INVITE</option>
            </select>
          </div>
          <button @click="addPlayer" :disabled="adding" class="btn-primary flex items-center gap-1.5">
            <Loader2Icon v-if="adding" class="w-3.5 h-3.5 animate-spin" />
            <PlusIcon v-else class="w-3.5 h-3.5" />
            Ajouter
          </button>
        </div>
        <p v-if="createMsg" :class="['text-sm mt-2', createOk ? 'text-gz-green' : 'text-gz-red']">
          {{ createMsg }}
        </p>
      </section>

      <!-- Liste joueurs -->
      <section class="card reveal delay-1">
        <div class="flex flex-wrap items-center justify-between gap-3 mb-4">
          <h2 class="font-semibold text-gz-text">Joueurs enregistrés</h2>
          <div class="flex gap-2">
            <input v-model="search" type="text" class="input w-56" placeholder="Rechercher (ID/nom)…" />
            <button @click="loadPlayers" class="btn flex items-center gap-1">
              <RefreshCwIcon class="w-3.5 h-3.5" /> Rafraîchir
            </button>
          </div>
        </div>

        <div class="overflow-x-auto table-shell">
          <table class="data-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Nom</th>
                <th>Statut</th>
                <th>Compte</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="loading">
                <td colspan="5" class="text-center text-gz-muted py-8">Chargement…</td>
              </tr>
              <tr v-else-if="!filtered.length">
                <td colspan="5" class="text-center text-gz-muted py-8">Aucun joueur.</td>
              </tr>
              <tr v-for="p in filtered" :key="p.player_id">
                <td class="font-mono text-gz-muted text-xs">{{ p.player_id }}</td>
                <td class="font-medium">{{ p.name || '—' }}</td>
                <td>
                  <span :class="['badge text-xs font-bold px-2 py-0.5 rounded-full border',
                    p.role === 'INVITE'
                      ? 'bg-gz-amber/15 text-gz-amber border-gz-amber/30'
                      : 'bg-gz-blue/15 text-gz-blue border-gz-blue/30']">
                    {{ p.role || 'MEMBRE' }}
                  </span>
                </td>
                <td class="text-gz-muted text-sm">{{ p.user_email || '—' }}</td>
                <td>
                  <div class="flex gap-1">
                    <button @click="openEdit(p)" class="btn py-1 px-2 text-xs flex items-center gap-1">
                      <PencilIcon class="w-3 h-3" /> Modifier
                    </button>
                    <button @click="deletePlayer(p.player_id)" class="btn-danger py-1 px-2 text-xs flex items-center gap-1">
                      <Trash2Icon class="w-3 h-3" /> Supprimer
                    </button>
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
import { PlusIcon, PencilIcon, Trash2Icon, RefreshCwIcon, Loader2Icon, UnlinkIcon } from 'lucide-vue-next'

const api = useAPI()

const players   = ref([])
const search    = ref('')
const loading   = ref(false)
const modal     = ref(false)
const saving    = ref(false)
const adding    = ref(false)
const createMsg = ref('')
const createOk  = ref(true)
const editMsg   = ref('')
const editOk    = ref(true)
const editingId = ref('')   // old player_id

const newP = ref({ player_id: '', name: '', role: 'MEMBRE' })
const form = ref({ player_id: '', name: '', role: 'MEMBRE', email: '', password: '', has_user: false })

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
    !q || (p.player_id || '').toLowerCase().includes(q) || (p.name || '').toLowerCase().includes(q)
  )
})

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
  const { player_id, name, role } = newP.value
  if (!player_id || !name) { createMsg.value = 'ID et Nom requis'; createOk.value = false; return }
  adding.value = true
  createMsg.value = 'Enregistrement…'
  try {
    await api.post('/admin/players', { player_id, name, role })
    createMsg.value = 'Joueur créé ✓'; createOk.value = true
    newP.value = { player_id: '', name: '', role: 'MEMBRE' }
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

function openEdit(p) {
  editingId.value = p.player_id
  form.value = {
    player_id: p.player_id,
    name:      p.name || '',
    role:      (p.role || 'MEMBRE').toUpperCase(),
    email:     p.user_email || slugifyToEmail(p.name || p.player_id),
    password:  '',
    has_user:  !!p.user_email,
  }
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

    const body = { name: form.value.name.trim(), role: form.value.role }
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

.reveal {
  animation: rise-in 420ms ease both;
}

.delay-1 {
  animation-delay: 80ms;
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
