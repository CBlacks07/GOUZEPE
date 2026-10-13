<template>
  <AppLayout season-label="Utilisateurs">
    <div class="page-wrap admin-utilisateurs-wrap">

      <!-- En-tête -->
      <header class="al-head reveal">
        <div>
          <h1 class="al-title">Utilisateurs</h1>
          <p class="al-sub">Comptes de connexion, rôles et demandes d'adhésion.</p>
          <div class="al-stats">
            <span class="al-stat"><strong>{{ users.length }}</strong> comptes</span>
            <span class="al-stat"><strong>{{ users.filter(u => u.role === 'admin').length }}</strong> admins</span>
            <span class="al-stat"><strong>{{ users.filter(u => !u.player_id).length }}</strong> sans joueur lié</span>
          </div>
        </div>
        <button class="btn-primary flex items-center gap-1.5" :aria-expanded="String(showCreate)" @click="showCreate = !showCreate">
          <XIcon v-if="showCreate" class="w-4 h-4" />
          <UserPlusIcon v-else class="w-4 h-4" />
          {{ showCreate ? 'Fermer' : 'Nouvel utilisateur' }}
        </button>
      </header>

      <!-- Demandes d'adhésion (prioritaires, en haut de page) -->
      <section class="al-reqs reveal" :class="{ 'has-pending': reqFilter === 'pending' && requests.length }">
        <div class="al-reqs-head">
          <div>
            <h2 class="al-reqs-title">
              Demandes de membre
              <span v-if="reqFilter === 'pending' && requests.length" class="al-badge">{{ requests.length }} en attente</span>
            </h2>
            <p class="al-muted">Formulaires envoyés depuis la page publique</p>
          </div>
          <div class="al-seg" role="group" aria-label="Statut des demandes">
            <button v-for="o in reqOptions" :key="o.v" :class="{ on: reqFilter === o.v }" :aria-pressed="String(reqFilter === o.v)" @click="setReqFilter(o.v)">{{ o.l }}</button>
          </div>
        </div>

        <SkeletonBlock v-if="loadingReqs" :count="1" />
        <p v-else-if="!requests.length" class="al-reqs-empty">
          Aucune demande {{ reqFilter === 'pending' ? 'en attente' : reqFilter === 'approved' ? 'approuvée' : 'rejetée' }}.
        </p>
        <div v-else class="al-req-list">
          <article v-for="r in requests" :key="r.id" class="al-req">
            <span class="al-av" aria-hidden="true">{{ (r.name || '?')[0].toUpperCase() }}</span>
            <div class="al-req-body">
              <div class="al-req-top">
                <strong class="al-req-name">{{ r.name }}</strong>
                <span class="al-muted">{{ fmtShort(r.created_at) }}</span>
              </div>
              <div v-if="r.extra" class="al-req-chips">
                <span v-if="r.extra.birthdate || r.extra.age" class="al-chip">{{ r.extra.birthdate ? ageFromBirthdate(r.extra.birthdate) : r.extra.age }} ans</span>
                <span v-if="r.extra.platform" class="al-chip">{{ r.extra.platform }}</span>
                <span v-if="r.extra.frequency" class="al-chip">{{ freqLabel(r.extra.frequency) }}</span>
                <span v-if="r.extra.profession" class="al-chip">{{ r.extra.profession }}</span>
              </div>
              <dl class="al-req-contact">
                <div v-if="r.email"><dt>Email</dt><dd>{{ r.email }}</dd></div>
                <div v-if="r.extra && r.extra.phone"><dt>Tél.</dt><dd>{{ r.extra.phone }}</dd></div>
                <div v-if="r.extra && r.extra.address"><dt>Adresse</dt><dd>{{ r.extra.address }}</dd></div>
              </dl>
              <div v-if="r.message" class="al-req-msgbox">
                <span class="al-req-msglabel">Message de présentation</span>
                <span class="al-req-msghint">Réponse à : « Comment as-tu connu le club ? Ton niveau estimé… »</span>
                <p class="al-req-msg">{{ r.message }}</p>
              </div>
            </div>
            <div v-if="reqFilter === 'pending'" class="al-req-actions">
              <button @click="openApprove(r)" class="btn-primary al-req-btn">Approuver</button>
              <button @click="openReject(r)" class="btn al-req-btn al-req-reject">Rejeter</button>
            </div>
            <div v-else class="al-req-actions end">
              <span class="al-pill" :class="r.status === 'approved' ? 'ok' : 'admin'">{{ r.status === 'approved' ? 'Approuvée' : 'Rejetée' }}</span>
              <span v-if="r.player_id" class="al-id">{{ r.player_id }}</span>
              <span v-if="r.review_message" class="al-muted" style="font-style:italic;max-width:16rem;text-align:right">« {{ r.review_message }} »</span>
            </div>
          </article>
        </div>
      </section>

      <!-- Création -->
      <section v-if="showCreate" class="al-panel reveal">
        <h2 class="al-panel-title"><UserPlusIcon class="w-4 h-4" /> Créer un utilisateur</h2>
        <div class="al-form">
          <div>
            <label class="label">Email</label>
            <input v-model="newU.email" type="text" class="input" placeholder="ex: admin@gz ou user" autocomplete="off" name="new-user-email" />
          </div>
          <div>
            <label class="label">Mot de passe</label>
            <input v-model="newU.password" type="password" class="input" placeholder="mot de passe" autocomplete="new-password" name="new-user-password" />
          </div>
          <div>
            <label class="label">Rôle</label>
            <select v-model="newU.role" class="input">
              <option value="member">member</option>
              <option value="admin">admin</option>
            </select>
          </div>
          <button @click="addUser" :disabled="adding" class="btn-primary flex items-center justify-center gap-1.5">
            <Loader2Icon v-if="adding" class="w-3.5 h-3.5 animate-spin" />
            <PlusIcon v-else class="w-3.5 h-3.5" />
            Ajouter
          </button>
        </div>
        <p class="al-muted mt-2">Si vous ne mettez pas de domaine, <code>@gz.local</code> sera ajouté automatiquement.</p>
      </section>

      <!-- Barre d'outils -->
      <div class="al-toolbar reveal delay-1">
        <div class="al-seg" role="group" aria-label="Rôle">
          <button v-for="o in roleOptions" :key="o.v" :class="{ on: roleFilter === o.v }" :aria-pressed="String(roleFilter === o.v)" @click="roleFilter = o.v">{{ o.l }}</button>
        </div>
        <div class="al-search">
          <SearchIcon class="w-4 h-4" />
          <input v-model="search" type="search" class="input" placeholder="Rechercher un email…" aria-label="Rechercher un utilisateur" />
        </div>
        <span class="al-spacer"></span>
        <span class="al-muted">{{ filtered.length }} résultat(s)</span>
        <button @click="loadUsers" class="al-icon" title="Rafraîchir la liste" aria-label="Rafraîchir la liste">
          <RefreshCwIcon class="w-4 h-4" :class="{ 'animate-spin': loading }" />
        </button>
      </div>

      <!-- Liste -->
      <section class="al-card reveal delay-2">
        <SkeletonBlock v-if="loading && !users.length" :count="6" class="p-3" />
        <div v-else-if="!filtered.length" class="al-empty">
          <strong>{{ search || roleFilter !== 'all' ? 'Aucun résultat' : 'Aucun utilisateur' }}</strong>
          <span v-if="search || roleFilter !== 'all'">Essaie un autre email ou retire le filtre de rôle.</span>
          <span v-else>Utilise « Nouvel utilisateur » pour créer un compte.</span>
        </div>
        <div v-else class="overflow-x-auto">
          <table class="al-table">
            <thead>
              <tr>
                <th>Compte</th>
                <th>Rôle</th>
                <th class="hidden sm:table-cell">Joueur lié</th>
                <th class="hidden md:table-cell">Créé le</th>
                <th style="text-align:right">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="u in visibleUsers" :key="u.id">
                <td>
                  <div class="al-who">
                    <span class="al-av" aria-hidden="true">{{ (u.email || '?')[0].toUpperCase() }}</span>
                    <span class="min-w-0">
                      <span class="al-name">{{ u.email }}</span>
                    </span>
                  </div>
                </td>
                <td>
                  <span v-if="u.role === 'admin'" class="al-pill admin">admin</span>
                  <span v-else class="al-muted">Membre</span>
                </td>
                <td class="hidden sm:table-cell">
                  <span v-if="u.player_id" class="al-id" style="font-size:.8rem">{{ u.player_id }}</span>
                  <button v-else class="al-link" @click="openEdit(u)">Lier à un joueur</button>
                </td>
                <td class="al-muted hidden md:table-cell">{{ fmtShort(u.created_at) }}</td>
                <td>
                  <div class="al-actions">
                    <button @click="openEdit(u)" class="al-icon" :title="'Modifier ' + u.email" :aria-label="'Modifier ' + u.email"><PencilIcon class="w-4 h-4" /></button>
                    <button @click="deleteUser(u.id, u.email)" class="al-icon danger" :title="'Supprimer ' + u.email" :aria-label="'Supprimer ' + u.email"><Trash2Icon class="w-4 h-4" /></button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-if="filtered.length > visibleUsers.length" class="al-more">
          <button class="btn text-sm" @click="visibleCount += PAGE">Voir plus ({{ filtered.length - visibleUsers.length }} restants)</button>
        </div>
        <p v-if="listStatus" class="al-muted" style="padding:.6rem 1rem">{{ listStatus }}</p>
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

    <!-- Modal approbation demande : crée le joueur + le compte, liés -->
    <BaseModal :open="approveModal" title="Approuver la demande" @close="approveModal = false">
      <div v-if="approveTarget" class="space-y-4">
        <p class="text-xs text-gz-muted">
          Ceci crée le joueur et le compte de connexion, déjà liés. Vérifie/ajuste avant de confirmer.
        </p>
        <div>
          <label class="label">ID joueur</label>
          <input v-model="approveForm.player_id" type="text" class="input font-mono" placeholder="ex: Pseudo_GZ" />
        </div>
        <div>
          <label class="label">Nom</label>
          <input v-model="approveForm.name" type="text" class="input" />
        </div>
        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="label">Pôle</label>
            <select v-model="approveForm.main_game" class="input">
              <option value="efoot">eFootball</option>
              <option value="tekken">Tekken</option>
              <option value="both">Les deux</option>
            </select>
          </div>
          <div>
            <label class="label">Année d'admission</label>
            <input v-model.number="approveForm.admission_year" type="number" class="input" min="2000" :max="new Date().getFullYear()" />
          </div>
        </div>
        <div>
          <label class="label">Email (identifiant de connexion)</label>
          <input v-model="approveForm.email" type="text" class="input" />
        </div>
        <div>
          <label class="label">Mot de passe</label>
          <input v-model="approveForm.password" type="text" class="input font-mono" />
        </div>
        <p v-if="approveErr" class="text-gz-red text-sm">{{ approveErr }}</p>
      </div>
      <template #footer>
        <button @click="approveModal = false" class="btn">Annuler</button>
        <button @click="confirmApprove" :disabled="approving" class="btn-primary flex items-center gap-1.5">
          <Loader2Icon v-if="approving" class="w-3.5 h-3.5 animate-spin" />
          Créer le compte &amp; approuver
        </button>
      </template>
    </BaseModal>

    <!-- Modal rejet demande : message optionnel renvoyé par mail au demandeur -->
    <BaseModal :open="rejectModal" title="Rejeter la demande" @close="rejectModal = false">
      <div v-if="rejectTarget" class="space-y-4">
        <p class="text-xs text-gz-muted">
          {{ rejectTarget.name }} ({{ rejectTarget.email }}) recevra un email l'informant du refus.
          Le message ci-dessous y sera inclus si renseigné.
        </p>
        <div>
          <label class="label">Message au demandeur (optionnel)</label>
          <textarea v-model="rejectForm.message" class="input min-h-[110px]"
                    placeholder="ex : Merci pour ta demande, mais nous n'avons plus de place disponible actuellement..." />
        </div>
        <p v-if="rejectErr" class="text-gz-red text-sm">{{ rejectErr }}</p>
      </div>
      <template #footer>
        <button @click="rejectModal = false" class="btn">Annuler</button>
        <button @click="confirmReject" :disabled="rejecting" class="btn-primary flex items-center gap-1.5" style="background:#d43c49;border-color:#d43c49">
          <Loader2Icon v-if="rejecting" class="w-3.5 h-3.5 animate-spin" />
          Rejeter &amp; notifier
        </button>
      </template>
    </BaseModal>
  </AppLayout>
</template>

<script setup>
import { askConfirm } from '@/composables/useConfirm'
import { ref, computed, onMounted, watch } from 'vue'
import AppLayout from '@/components/layout/AppLayout.vue'
import BaseModal from '@/components/ui/BaseModal.vue'
import { useAPI } from '@/composables/useAPI'
import { useSessionState } from '@/composables/useSessionState'
import { useToast } from '@/composables/useToast'
import { PlusIcon, PencilIcon, Trash2Icon, RefreshCwIcon, Loader2Icon, ArrowLeftIcon, SearchIcon, UserPlusIcon, XIcon } from 'lucide-vue-next'
import SkeletonBlock from '@/components/ui/SkeletonBlock.vue'

const { success } = useToast()

const api = useAPI()

const users      = ref([])
const players    = ref([])
const search     = ref('')
const roleFilter = ref('all')
const PAGE = 10
const visibleCount = ref(PAGE)
const reqOptions = [{ v: 'pending', l: 'En attente' }, { v: 'approved', l: 'Approuvées' }, { v: 'rejected', l: 'Rejetées' }]
const showCreate = ref(false)
const roleOptions = [{ v: 'all', l: 'Tous' }, { v: 'admin', l: 'Admins' }, { v: 'member', l: 'Membres' }]
const loading    = ref(false)
const modal      = ref(false)
const saving     = ref(false)
const adding     = ref(false)
const listStatus = ref('')
const editErr    = ref('')
const editingId  = ref(null)

const newU = ref({ email: '', password: '', role: 'member' })
const form = ref({ email: '', role: 'member', player_id: '', password: '' })

const requests    = ref([])
const reqFilter   = ref('pending')
const loadingReqs = ref(false)

const approveModal  = ref(false)
const approveTarget = ref(null)
const approveForm   = ref({ player_id: '', name: '', main_game: 'efoot', admission_year: new Date().getFullYear(), email: '', password: '1234' })
const approveErr    = ref('')
const approving     = ref(false)

const rejectModal  = ref(false)
const rejectTarget = ref(null)
const rejectForm   = ref({ message: '' })
const rejectErr    = ref('')
const rejecting    = ref(false)

useSessionState('efoot.ui.admin.utilisateurs.v1', {
  search,
  modal,
  editingId,
  newU,
  form,
})

const filtered = computed(() => {
  const q = search.value.toLowerCase()
  return users.value.filter(u =>
    (roleFilter.value === 'all' || u.role === roleFilter.value) &&
    (!q || (u.email || '').toLowerCase().includes(q))
  )
})

const visibleUsers = computed(() => filtered.value.slice(0, visibleCount.value))
watch([search, roleFilter], () => { visibleCount.value = PAGE })

function setReqFilter(v) {
  if (reqFilter.value === v) return
  reqFilter.value = v
  loadRequests()
}

function fmtShort(s) {
  if (!s) return '—'
  const d = new Date(s)
  if (Number.isNaN(d.getTime())) return String(s)
  return d.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short', year: 'numeric' })
}

onMounted(async () => {
  await Promise.all([loadUsers(), loadPlayers(), loadRequests()])
})

async function loadRequests() {
  loadingReqs.value = true
  try {
    const { data } = await api.get(`/admin/membership-requests?status=${reqFilter.value}`)
    requests.value = (data.requests || []).map(r => ({
      ...r,
      extra: r.extra ? (typeof r.extra === 'string' ? JSON.parse(r.extra) : r.extra) : null
    }))
  } catch (_) {}
  loadingReqs.value = false
}

function openReject(r) {
  rejectTarget.value = r
  rejectErr.value = ''
  rejectForm.value = { message: '' }
  rejectModal.value = true
}

async function confirmReject() {
  if (!rejectTarget.value) return
  rejectErr.value = ''
  rejecting.value = true
  try {
    await api.patch(`/admin/membership-requests/${rejectTarget.value.id}`, {
      status: 'rejected',
      message: rejectForm.value.message.trim(),
    })
    rejectModal.value = false
    success('Demande rejetée, le demandeur a été notifié par mail')
    await loadRequests()
  } catch (e) {
    rejectErr.value = e.response?.data?.error || 'Erreur lors du rejet de la demande'
  } finally {
    rejecting.value = false
  }
}

const DIACRITICS_RE = /[\u0300-\u036f]/g
function slugifyPlayerId(name) {
  const base = String(name || '').trim()
    .normalize('NFD').replace(DIACRITICS_RE, '')
    .replace(/[^a-zA-Z0-9]+/g, '')
  return (base || 'Membre') + '_GZ'
}

function openApprove(r) {
  approveTarget.value = r
  approveErr.value = ''
  const games = r.extra?.games || []
  const hasEfoot = games.includes('efoot')
  const hasTekken = games.includes('tekken')
  approveForm.value = {
    player_id: slugifyPlayerId(r.name),
    name: r.name,
    main_game: hasEfoot && hasTekken ? 'both' : hasTekken ? 'tekken' : 'efoot',
    admission_year: new Date().getFullYear(),
    email: r.email,
    password: '1234',
  }
  approveModal.value = true
}

async function confirmApprove() {
  if (!approveTarget.value) return
  approveErr.value = ''
  approving.value = true
  try {
    const { data } = await api.post(`/admin/membership-requests/${approveTarget.value.id}/approve`, approveForm.value)
    approveModal.value = false
    success(`Compte créé : ${data.user.email} / ${data.user.password} — à communiquer au nouveau membre`)
    await loadRequests()
    await loadPlayers()
  } catch (e) {
    approveErr.value = e.response?.data?.error || 'Erreur lors de l\'approbation'
  } finally {
    approving.value = false
  }
}

function freqLabel(f) {
  return { daily: 'Tous les jours', several_week: 'Plusieurs fois/sem.', weekly: '1 fois/sem.', occasional: 'Occasionnellement' }[f] || f
}

function ageFromBirthdate(d) {
  try {
    const b = new Date(d)
    if (Number.isNaN(b.getTime())) return '—'
    const now = new Date()
    let age = now.getFullYear() - b.getFullYear()
    const m = now.getMonth() - b.getMonth()
    if (m < 0 || (m === 0 && now.getDate() < b.getDate())) age--
    return age
  } catch (_) { return '—' }
}

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
    const body  = { email, role: form.value.role, player_id: form.value.player_id ? form.value.player_id.trim() : '' }
    if (form.value.password) body.password = form.value.password
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

async function deleteUser(id, email) {
  if (!(await askConfirm({ title: 'Supprimer l\'utilisateur', message: `Supprimer l'utilisateur "${email}" ? Cette action est définitive.`, confirmLabel: 'Supprimer', danger: true }))) return
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
