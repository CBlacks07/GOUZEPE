<template>
  <AppLayout season-label="Utilisateurs">
    <div class="page-wrap admin-utilisateurs-wrap">

      <!-- Créer un utilisateur -->
      <section class="card mb-4 reveal">
        <h2 class="font-semibold text-gz-text mb-4">Créer un utilisateur</h2>
        <div class="flex flex-wrap gap-2 items-end">
          <div class="flex-1 min-w-[200px]">
            <label class="label">Email</label>
            <input v-model="newU.email" type="text" class="input" placeholder="ex: admin@gz ou user" />
          </div>
          <div class="flex-1 min-w-[160px]">
            <label class="label">Mot de passe</label>
            <input v-model="newU.password" type="password" class="input" placeholder="mot de passe" />
          </div>
          <div>
            <label class="label">Rôle</label>
            <select v-model="newU.role" class="input">
              <option value="member">member</option>
              <option value="admin">admin</option>
            </select>
          </div>
          <button @click="addUser" :disabled="adding" class="btn-primary flex items-center gap-1.5">
            <Loader2Icon v-if="adding" class="w-3.5 h-3.5 animate-spin" />
            <PlusIcon v-else class="w-3.5 h-3.5" />
            Ajouter
          </button>
        </div>
        <p class="text-xs text-gz-muted mt-2">
          Astuce : si vous ne mettez pas de domaine, <code>@gz.local</code> sera ajouté automatiquement.
        </p>
      </section>

      <!-- Liste utilisateurs -->
      <section class="card reveal delay-1">
        <div class="flex flex-wrap items-center justify-between gap-3 mb-4">
          <h2 class="font-semibold text-gz-text">Utilisateurs enregistrés</h2>
          <div class="flex gap-2">
            <input v-model="search" type="text" class="input w-56" placeholder="Rechercher (email)…" />
            <button @click="loadUsers" class="btn flex items-center gap-1">
              <RefreshCwIcon class="w-3.5 h-3.5" /> Rafraîchir
            </button>
          </div>
        </div>

        <div class="overflow-x-auto table-shell">
          <table class="data-table">
            <thead>
              <tr>
                <th>Email</th>
                <th>Rôle</th>
                <th>Player ID</th>
                <th>Créé</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="loading">
                <td colspan="5" class="text-center text-gz-muted py-8">Chargement…</td>
              </tr>
              <tr v-else-if="!filtered.length">
                <td colspan="5" class="text-center text-gz-muted py-8">Aucun utilisateur.</td>
              </tr>
              <tr v-for="u in filtered" :key="u.id">
                <td class="font-medium">{{ u.email }}</td>
                <td>
                  <span :class="['badge text-xs font-bold px-2 py-0.5 rounded-full border',
                    u.role === 'admin'
                      ? 'bg-gz-red/15 text-gz-red border-gz-red/30'
                      : 'bg-gz-blue/15 text-gz-blue border-gz-blue/30']">
                    {{ u.role }}
                  </span>
                </td>
                <td class="text-gz-muted text-sm font-mono">{{ u.player_id || '—' }}</td>
                <td class="text-gz-muted text-xs whitespace-nowrap">{{ fmtDate(u.created_at) }}</td>
                <td>
                  <div class="flex gap-1">
                    <button @click="openEdit(u)" class="btn py-1 px-2 text-xs flex items-center gap-1">
                      <PencilIcon class="w-3 h-3" /> Modifier
                    </button>
                    <button @click="deleteUser(u.id)" class="btn-danger py-1 px-2 text-xs flex items-center gap-1">
                      <Trash2Icon class="w-3 h-3" /> Supprimer
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <p v-if="listStatus" class="text-xs text-gz-muted mt-2">{{ listStatus }}</p>
      </section>
    </div>

    <!-- Modal édition -->
    <BaseModal :open="modal" title="Modifier l'utilisateur" @close="modal = false">
      <div class="space-y-4">
        <div>
          <label class="label">Email</label>
          <input v-model="form.email" type="text" class="input" />
        </div>
        <div>
          <label class="label">Rôle</label>
          <select v-model="form.role" class="input">
            <option value="member">member</option>
            <option value="admin">admin</option>
          </select>
        </div>
        <div>
          <label class="label">Player ID (optionnel)</label>
          <input v-model="form.player_id" type="text" class="input" placeholder="ex: GPG-001"
                 :list="'playerList'" />
          <datalist id="playerList">
            <option v-for="p in players" :key="p.player_id" :value="p.player_id">
              {{ p.name || p.player_id }}
            </option>
          </datalist>
        </div>
        <div>
          <label class="label">Nouveau mot de passe (optionnel)</label>
          <input v-model="form.password" type="password" class="input" placeholder="laisser vide pour ne pas changer" />
        </div>
        <p v-if="editErr" class="text-gz-red text-sm">{{ editErr }}</p>
      </div>
      <template #footer>
        <button @click="modal = false" class="btn">Annuler</button>
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
import { PlusIcon, PencilIcon, Trash2Icon, RefreshCwIcon, Loader2Icon } from 'lucide-vue-next'

const api = useAPI()

const users      = ref([])
const players    = ref([])
const search     = ref('')
const loading    = ref(false)
const modal      = ref(false)
const saving     = ref(false)
const adding     = ref(false)
const listStatus = ref('')
const editErr    = ref('')
const editingId  = ref(null)

const newU = ref({ email: '', password: '', role: 'member' })
const form = ref({ email: '', role: 'member', player_id: '', password: '' })

useSessionState('efoot.ui.admin.utilisateurs.v1', {
  search,
  modal,
  editingId,
  newU,
  form,
})

const filtered = computed(() => {
  const q = search.value.toLowerCase()
  return users.value.filter(u => !q || (u.email || '').toLowerCase().includes(q))
})

onMounted(async () => {
  await Promise.all([loadUsers(), loadPlayers()])
})

async function loadUsers() {
  loading.value = true
  listStatus.value = ''
  try {
    const { data } = await api.get('/admin/users')
    users.value = data.users || []
  } catch (e) {
    listStatus.value = 'Chargement échoué : ' + (e.response?.data?.error || e.message)
  } finally {
    loading.value = false
  }
}

async function loadPlayers() {
  try {
    const { data } = await api.get('/players')
    players.value = data.players || []
  } catch (_) {}
}

function normEmail(x) {
  x = (x || '').trim()
  if (!x) return x
  if (x.includes('@')) return x.toLowerCase()
  return (x + '@gz.local').toLowerCase()
}

async function addUser() {
  const email    = normEmail(newU.value.email)
  const password = (newU.value.password || '').trim()
  const role     = newU.value.role
  if (!email || !password) { listStatus.value = 'Email et mot de passe requis'; return }
  adding.value = true
  listStatus.value = 'Ajout…'
  try {
    await api.post('/admin/users', { email, password, role })
    newU.value = { email: '', password: '', role: 'member' }
    listStatus.value = 'Utilisateur ajouté'
    await loadUsers()
  } catch (e) {
    listStatus.value = e.response?.data?.error || 'Erreur'
  } finally {
    adding.value = false
  }
}

function openEdit(u) {
  editingId.value = u.id
  form.value = { email: u.email || '', role: u.role || 'member', player_id: u.player_id || '', password: '' }
  editErr.value = ''
  modal.value = true
}

async function saveEdit() {
  saving.value = true
  editErr.value = ''
  try {
    const email = normEmail(form.value.email)
    const body  = { email, role: form.value.role }
    if (form.value.player_id) body.player_id = form.value.player_id
    if (form.value.password)  body.password  = form.value.password
    await api.put('/admin/users/' + editingId.value, body)
    modal.value = false
    listStatus.value = 'Utilisateur modifié'
    await loadUsers()
  } catch (e) {
    editErr.value = e.response?.data?.error || 'Erreur'
  } finally {
    saving.value = false
  }
}

async function deleteUser(id) {
  if (!confirm('Supprimer cet utilisateur ?')) return
  try {
    await api.delete('/admin/users/' + id)
    listStatus.value = 'Utilisateur supprimé'
    await loadUsers()
  } catch (e) {
    listStatus.value = e.response?.data?.error || 'Erreur'
  }
}

function fmtDate(s) {
  try { return new Date(s).toLocaleString('fr-FR') } catch (_) { return s || '—' }
}
</script>

<style scoped>
.admin-utilisateurs-wrap {
  width: 100%;
}

.admin-utilisateurs-wrap :deep(.card) {
  transition: transform 180ms ease, box-shadow 180ms ease, border-color 180ms ease;
}

.admin-utilisateurs-wrap :deep(.card:hover) {
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
  .admin-utilisateurs-wrap {
    max-width: none;
    padding: clamp(14px, 2.1vw, 30px);
  }
}

@media (prefers-reduced-motion: reduce) {
  .reveal {
    animation: none !important;
  }

  .admin-utilisateurs-wrap :deep(.card) {
    transition: none !important;
  }
}
</style>
