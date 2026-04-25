<template>
  <AppLayout season-label="Sauvegardes">
    <div class="page-wrap backups-wrap space-y-4">
      <section class="grid grid-cols-1 xl:grid-cols-2 gap-4 reveal">
        <article class="card">
          <h2 class="font-semibold text-gz-text mb-3 flex items-center gap-2">
            <CalendarIcon class="w-4 h-4 text-gz-muted" /> Sauvegarde automatique
          </h2>

          <p v-if="scheduleLoading" class="text-gz-muted text-sm">Chargement...</p>
          <p v-else-if="!schedule || !schedule.enabled" class="text-gz-muted text-sm">
            Sauvegarde automatique desactivee.
          </p>
          <div v-else class="text-sm text-gz-text space-y-1.5">
            <p>
              Planification: samedi
              <strong>{{ pad(schedule.hour) }}:{{ pad(schedule.minute) }} UTC</strong>
            </p>
            <p v-if="schedule.nextRun" class="text-gz-muted">
              Prochaine execution: {{ fmtDate(schedule.nextRun) }} (local) • {{ fmtUTC(schedule.nextRun) }} UTC
            </p>
          </div>
        </article>

        <article class="card">
          <h2 class="font-semibold text-gz-text mb-4 flex items-center gap-2">
            <DatabaseIcon class="w-4 h-4 text-gz-muted" /> Actions
          </h2>

          <div class="space-y-3">
            <button
              @click="createBackup"
              :disabled="creating"
              class="btn-primary w-full sm:w-auto justify-center flex items-center gap-1.5"
              title="Creer une sauvegarde manuelle"
            >
              <Loader2Icon v-if="creating" class="w-3.5 h-3.5 animate-spin" />
              <DatabaseIcon v-else class="w-3.5 h-3.5" />
              Sauvegarde manuelle
            </button>

            <div class="restore-block border border-gz-border/45 rounded-lg p-3 bg-gz-panel/40">
              <label for="sqlFile" class="label mb-1">Fichier SQL a restaurer</label>
              <input
                id="sqlFile"
                ref="fileInput"
                type="file"
                accept=".sql"
                class="input w-full text-sm"
                @change="onFileChange"
              />
              <p v-if="selectedUploadName" class="text-xs text-gz-muted mt-1 truncate">
                Selection: {{ selectedUploadName }}
              </p>
              <button
                @click="restoreFromUpload"
                class="btn-danger mt-3 w-full sm:w-auto justify-center flex items-center gap-1.5"
                title="Restaurer depuis le fichier choisi"
              >
                <UploadIcon class="w-3.5 h-3.5" /> Restaurer ce fichier
              </button>
            </div>
          </div>

          <p v-if="status" :class="['text-sm mt-3', statusOk ? 'text-gz-green' : 'text-gz-red']">
            {{ status }}
          </p>
        </article>
      </section>

      <section class="card p-0 overflow-hidden reveal delay-1">
        <div class="px-4 py-3 border-b border-gz-border flex items-center justify-between gap-2 flex-wrap">
          <div class="flex items-center gap-3">
            <h2 class="font-semibold text-gz-text">Historique des sauvegardes</h2>
            <span class="text-xs text-gz-muted border border-gz-border rounded-full px-2 py-0.5">
              Etat: {{ running ? 'busy' : 'idle' }}
            </span>
          </div>
          <button @click="loadBackups" class="btn py-1 px-2 text-xs flex items-center gap-1" title="Rafraichir la liste">
            <RefreshCwIcon class="w-3 h-3" /> Rafraichir
          </button>
        </div>

        <div v-if="loadingList" class="text-center text-gz-muted py-8 text-sm">Chargement...</div>
        <div v-else-if="!backups.length" class="text-center text-gz-muted py-8 text-sm">
          Aucune sauvegarde disponible.
        </div>
        <div v-else class="overflow-x-auto">
          <table class="data-table">
            <thead>
              <tr>
                <th>Fichier</th>
                <th>Type</th>
                <th>Taille</th>
                <th>Date</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="b in backups" :key="b.name">
                <td class="font-mono text-xs">{{ b.name }}</td>
                <td class="text-gz-muted text-xs">{{ sourceLabel(b.source) }}</td>
                <td class="text-gz-muted text-xs">{{ bytesFmt(b.sizeBytes) }}</td>
                <td class="text-gz-muted text-xs whitespace-nowrap">{{ fmtDate(b.updatedAt) }}</td>
                <td>
                  <div class="flex flex-wrap gap-1">
                    <button
                      @click="downloadBackup(b.name)"
                      class="btn py-1 px-2 text-xs flex items-center gap-1"
                      title="Telecharger cette sauvegarde"
                    >
                      <DownloadIcon class="w-3 h-3" /> Telecharger
                    </button>
                    <button
                      @click="restoreExisting(b.name)"
                      class="btn-danger py-1 px-2 text-xs flex items-center gap-1"
                      title="Restaurer a partir de cette sauvegarde"
                    >
                      <RotateCcwIcon class="w-3 h-3" /> Restaurer
                    </button>
                    <button
                      @click="deleteBackup(b.name)"
                      class="btn-danger py-1 px-2 text-xs flex items-center gap-1"
                      title="Supprimer cette sauvegarde"
                    >
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
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import AppLayout from '@/components/layout/AppLayout.vue'
import { useAPI, resolveBaseURL } from '@/composables/useAPI'
import {
  CalendarIcon,
  DatabaseIcon,
  UploadIcon,
  RefreshCwIcon,
  DownloadIcon,
  RotateCcwIcon,
  Trash2Icon,
  Loader2Icon,
} from 'lucide-vue-next'

const api = useAPI()

const backups = ref([])
const schedule = ref(null)
const running = ref(false)
const loadingList = ref(false)
const scheduleLoading = ref(true)
const creating = ref(false)
const status = ref('')
const statusOk = ref(true)
const fileInput = ref(null)
const selectedUploadName = ref('')

const apiBase = computed(() => resolveBaseURL())

onMounted(async () => {
  await loadBackups()
})

async function loadBackups() {
  loadingList.value = true
  scheduleLoading.value = true
  try {
    const { data } = await api.get('/admin/backups')
    backups.value = data.backups || []
    running.value = data.running || false
    schedule.value = data.schedule || null
  } catch (e) {
    toast('Erreur chargement: ' + (e.response?.data?.error || e.message), false)
  } finally {
    loadingList.value = false
    scheduleLoading.value = false
  }
}

async function createBackup() {
  creating.value = true
  try {
    const { data } = await api.post('/admin/backups/create', {})
    toast('Sauvegarde creee: ' + (data.backup?.name || ''), true)
    await loadBackups()
  } catch (e) {
    toast('Erreur: ' + (e.response?.data?.error || e.message), false)
  } finally {
    creating.value = false
  }
}

function onFileChange() {
  selectedUploadName.value = fileInput.value?.files?.[0]?.name || ''
}

async function downloadBackup(fileName) {
  try {
    const token = localStorage.getItem('efoot.token') || ''
    const url = `${apiBase.value}/admin/backups/${encodeURIComponent(fileName)}/download`
    const res = await fetch(url, { headers: { Authorization: 'Bearer ' + token } })
    if (!res.ok) throw new Error('HTTP ' + res.status)
    const blob = await res.blob()
    const a = document.createElement('a')
    a.href = URL.createObjectURL(blob)
    a.download = fileName
    document.body.appendChild(a)
    a.click()
    a.remove()
    URL.revokeObjectURL(a.href)
  } catch (e) {
    toast('Telechargement impossible: ' + e.message, false)
  }
}

async function restoreExisting(file) {
  if (!confirm(`Restaurer la base depuis ${file} ?`)) return
  try {
    const { data } = await api.post('/admin/backups/restore-existing', { file })
    toast('Restauration terminee depuis ' + (data.restoredFrom || file), true)
  } catch (e) {
    toast('Erreur restauration: ' + (e.response?.data?.error || e.message), false)
  }
}

async function deleteBackup(fileName) {
  if (!fileName) return
  if (!confirm(`Supprimer la sauvegarde ${fileName} ?`)) return
  try {
    const encoded = encodeURIComponent(fileName)
    const { data } = await api.delete(`/admin/backups/${encoded}`)
    toast('Sauvegarde supprimee: ' + (data.deleted || fileName), true)
    await loadBackups()
  } catch (e) {
    toast('Suppression impossible: ' + (e.response?.data?.error || e.message), false)
  }
}

async function restoreFromUpload() {
  const inp = fileInput.value
  if (!inp?.files?.length) {
    toast('Selectionne un fichier .sql', false)
    return
  }
  const file = inp.files[0]
  if (!confirm(`Restaurer la base depuis ${file.name} ?`)) return

  try {
    const fd = new FormData()
    fd.append('sqlFile', file)
    const token = localStorage.getItem('efoot.token') || ''
    const res = await fetch(`${apiBase.value}/admin/backups/restore-upload`, {
      method: 'POST',
      headers: { Authorization: 'Bearer ' + token },
      body: fd,
    })
    const data = await res.json().catch(() => ({}))
    if (!res.ok) throw new Error(data.error || 'HTTP ' + res.status)

    toast('Restauration terminee depuis ' + (data.restoredFrom || file.name), true)
    inp.value = ''
    selectedUploadName.value = ''
    await loadBackups()
  } catch (e) {
    toast('Erreur: ' + e.message, false)
  }
}

function toast(msg, ok = true) {
  status.value = msg
  statusOk.value = ok
}

function pad(n) {
  return String(n ?? 0).padStart(2, '0')
}

function fmtDate(s) {
  return s ? new Date(s).toLocaleString('fr-FR') : '-'
}

function fmtUTC(s) {
  return s ? new Date(s).toUTCString().slice(0, -4) : '-'
}

function bytesFmt(n) {
  const b = Number(n || 0)
  if (b < 1024) return b + ' B'
  if (b < 1048576) return (b / 1024).toFixed(1) + ' KB'
  return (b / 1048576).toFixed(1) + ' MB'
}

function sourceLabel(s) {
  return s === 'auto' ? 'Auto' : s === 'manual' ? 'Manuel' : s === 'uploaded' ? 'Upload' : (s || '-')
}
</script>

<style scoped>
.backups-wrap :deep(.card) {
  transition: transform 180ms ease, box-shadow 180ms ease, border-color 180ms ease;
}

.backups-wrap :deep(.card:hover) {
  transform: translateY(-1px);
  box-shadow: 0 12px 26px rgba(2, 6, 23, 0.2);
  border-color: color-mix(in srgb, var(--border) 68%, var(--blue) 32%);
}

.restore-block {
  background: color-mix(in srgb, var(--panel) 78%, transparent);
}
</style>
