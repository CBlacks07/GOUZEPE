<template>
  <AppLayout season-label="Actualités">
    <div class="page-wrap news-admin">

      <RouterLink to="/admin" class="inline-flex items-center gap-1.5 text-sm font-semibold text-gz-muted hover:text-gz-text mb-4">
        <ArrowLeftIcon class="w-3.5 h-3.5" /> Console
      </RouterLink>

      <!-- Créer / modifier -->
      <section class="card mb-4 reveal">
        <h2 class="font-semibold text-gz-text mb-4">{{ editingId ? 'Modifier l\'annonce' : 'Nouvelle annonce' }}</h2>
        <div class="grid gap-3">
          <div>
            <label class="label">Titre</label>
            <input v-model="form.title" type="text" class="input" placeholder="Titre de l'annonce" />
          </div>
          <div>
            <label class="label">Contenu</label>
            <textarea v-model="form.body" class="input" rows="4" style="resize:vertical" placeholder="Texte de l'annonce…" />
          </div>
          <div class="flex flex-wrap gap-3 items-end">
            <div class="flex-1 min-w-[160px]">
              <label class="label">Étiquette (optionnel)</label>
              <input v-model="form.tag" type="text" class="input" placeholder="ex: Événement, Info" />
            </div>
            <label class="flex items-center gap-2 text-sm">
              <input type="checkbox" v-model="form.pinned" /> Épinglée
            </label>
            <label class="flex items-center gap-2 text-sm">
              <input type="checkbox" v-model="form.published" /> Publiée
            </label>
          </div>
        </div>
        <div class="flex gap-2 mt-4">
          <button @click="submit" :disabled="saving" class="btn-primary flex items-center gap-1.5">
            <Loader2Icon v-if="saving" class="w-3.5 h-3.5 animate-spin" />
            <PlusIcon v-else-if="!editingId" class="w-3.5 h-3.5" />
            <CheckIcon v-else class="w-3.5 h-3.5" />
            {{ editingId ? 'Enregistrer' : 'Publier' }}
          </button>
          <button v-if="editingId" @click="cancelEdit" class="btn">Annuler</button>
        </div>
        <p v-if="msg" class="mt-2 text-sm" :class="msgOk ? 'text-gz-green' : 'text-gz-red'">{{ msg }}</p>
      </section>

      <!-- Liste -->
      <section class="card reveal delay-1">
        <div class="flex flex-wrap items-center justify-between gap-3 mb-4">
          <h2 class="font-semibold text-gz-text">Annonces</h2>
          <button @click="load" class="btn flex items-center gap-1">
            <RefreshCwIcon class="w-3.5 h-3.5" /> Rafraîchir
          </button>
        </div>

        <div v-if="loading" class="text-center text-gz-muted py-8">Chargement…</div>
        <div v-else-if="!items.length" class="text-center text-gz-muted py-8">Aucune annonce.</div>
        <div v-else class="flex flex-col gap-2">
          <div v-for="n in items" :key="n.id" class="news-row">
            <div class="news-row-main">
              <div class="news-row-head">
                <strong>{{ n.title }}</strong>
                <span v-if="n.pinned" class="tag gold">Épinglée</span>
                <span v-if="!n.published" class="tag muted">Brouillon</span>
                <span v-if="n.tag" class="tag">{{ n.tag }}</span>
              </div>
              <p class="news-row-body">{{ n.body }}</p>
              <span class="news-row-date">{{ fmtDate(n.created_at) }}</span>
            </div>
            <div class="flex gap-1">
              <button @click="openEdit(n)" class="btn py-1 px-2 text-xs flex items-center gap-1">
                <PencilIcon class="w-3 h-3" /> Modifier
              </button>
              <button @click="remove(n)" class="btn py-1 px-2 text-xs flex items-center gap-1 text-gz-red">
                <Trash2Icon class="w-3 h-3" /> Supprimer
              </button>
            </div>
          </div>
        </div>
      </section>

    </div>
  </AppLayout>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import AppLayout from '@/components/layout/AppLayout.vue'
import { useAPI } from '@/composables/useAPI'
import { Loader2Icon, PlusIcon, CheckIcon, RefreshCwIcon, PencilIcon, Trash2Icon, ArrowLeftIcon } from 'lucide-vue-next'

const api = useAPI()
const items = ref([])
const loading = ref(true)
const saving = ref(false)
const editingId = ref(null)
const msg = ref('')
const msgOk = ref(true)

const emptyForm = () => ({ title: '', body: '', tag: '', pinned: false, published: true })
const form = reactive(emptyForm())

function fmtDate(d) {
  if (!d) return ''
  try { return new Date(d).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short', year: 'numeric' }) } catch (_) { return d }
}

async function load() {
  loading.value = true
  try {
    const { data } = await api.get('/admin/news')
    items.value = data.news || []
  } catch (_) {}
  loading.value = false
}

function openEdit(n) {
  editingId.value = n.id
  Object.assign(form, { title: n.title, body: n.body, tag: n.tag || '', pinned: !!n.pinned, published: !!n.published })
  msg.value = ''
}

function cancelEdit() {
  editingId.value = null
  Object.assign(form, emptyForm())
  msg.value = ''
}

async function submit() {
  if (!form.title.trim()) { msg.value = 'Titre requis'; msgOk.value = false; return }
  saving.value = true; msg.value = ''
  try {
    if (editingId.value) {
      await api.put(`/admin/news/${editingId.value}`, { ...form })
      msg.value = 'Annonce modifiée ✓'
    } else {
      await api.post('/admin/news', { ...form })
      msg.value = 'Annonce publiée ✓'
    }
    msgOk.value = true
    cancelEdit()
    await load()
  } catch (err) {
    msg.value = err.response?.data?.error || 'Erreur lors de l\'enregistrement'; msgOk.value = false
  } finally {
    saving.value = false
  }
}

async function remove(n) {
  if (!confirm(`Supprimer l'annonce "${n.title}" ?`)) return
  try {
    await api.delete(`/admin/news/${n.id}`)
    await load()
  } catch (_) {}
}

onMounted(load)
</script>

<style scoped>
.news-admin { max-width: 50rem; }
.news-row { display: flex; align-items: flex-start; justify-content: space-between; gap: .8rem; padding: .8rem; border: 1px solid var(--border); border-radius: 12px; background: var(--panel); }
.news-row-main { min-width: 0; flex: 1; }
.news-row-head { display: flex; align-items: center; gap: .5rem; flex-wrap: wrap; margin-bottom: .3rem; }
.news-row-body { color: var(--muted); font-size: .85rem; margin: 0 0 .3rem; white-space: pre-wrap; }
.news-row-date { font-size: .72rem; color: var(--muted); }
.tag { font-size: .65rem; font-weight: 700; text-transform: uppercase; letter-spacing: .04em; padding: .1rem .5rem; border-radius: 999px; border: 1px solid var(--border); color: var(--muted); }
.tag.gold { color: #ca8a04; border-color: color-mix(in srgb, #eab308 40%, transparent); background: color-mix(in srgb, #eab308 10%, transparent); }
.tag.muted { opacity: .7; }
</style>
