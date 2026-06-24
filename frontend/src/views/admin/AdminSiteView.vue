<template>
  <AppLayout season-label="Apparence du site">
    <div class="page-wrap site-admin">

      <div class="flex flex-wrap items-center justify-between gap-3 mb-5">
        <div>
          <h1 class="text-xl font-bold" style="font-family:var(--font-title);letter-spacing:.04em;text-transform:uppercase">Apparence &amp; Contenu du site</h1>
          <p class="text-sm" style="color:var(--muted)">Personnalise textes, logo, fond et couleurs. Les changements s'appliquent à tout le site.</p>
        </div>
        <div class="flex gap-2">
          <button class="btn" @click="resetDefaults">Réinitialiser</button>
          <button class="btn-primary" :disabled="saving" @click="save">
            <Loader2Icon v-if="saving" class="w-4 h-4 animate-spin" /> Enregistrer
          </button>
        </div>
      </div>

      <p v-if="msg" class="mb-4 text-sm" :class="msgOk ? 'text-gz-green' : 'text-gz-red'">{{ msg }}</p>

      <div class="grid gap-5" style="grid-template-columns:1fr">

        <!-- Marque -->
        <section class="card">
          <h2 class="sec-title">Marque</h2>
          <div class="grid2">
            <div><label class="label">Nom</label><input v-model="form.brand.name" class="input" /></div>
            <div><label class="label">Sous-titre</label><input v-model="form.brand.tagline" class="input" /></div>
          </div>
          <div class="mt-3">
            <label class="label">Logo</label>
            <div class="media-row">
              <img :src="resolveUrl(form.brand.logo)" alt="logo" class="media-prev logo" />
              <input v-model="form.brand.logo" class="input" placeholder="/assets/icons/..." />
              <label class="btn upload-btn">
                <UploadIcon class="w-4 h-4" /> Image
                <input type="file" accept="image/*" hidden @change="onUpload($event, v => form.brand.logo = v)" />
              </label>
            </div>
          </div>
        </section>

        <!-- Couleurs d'accent -->
        <section class="card">
          <h2 class="sec-title">Couleurs d'accent</h2>
          <div class="grid2">
            <div>
              <label class="label">eFootball</label>
              <div class="color-row"><input type="color" v-model="form.accent.efoot" /><input v-model="form.accent.efoot" class="input" /></div>
            </div>
            <div>
              <label class="label">Tekken</label>
              <div class="color-row"><input type="color" v-model="form.accent.tekken" /><input v-model="form.accent.tekken" class="input" /></div>
            </div>
          </div>
        </section>

        <!-- Fond global -->
        <section class="card">
          <h2 class="sec-title">Fond global (filigrane logo)</h2>
          <div class="media-row">
            <img :src="resolveUrl(form.background.logo)" alt="fond" class="media-prev" />
            <input v-model="form.background.logo" class="input" placeholder="/assets/fond1.png" />
            <label class="btn upload-btn">
              <UploadIcon class="w-4 h-4" /> Image
              <input type="file" accept="image/*" hidden @change="onUpload($event, v => form.background.logo = v)" />
            </label>
          </div>
          <div class="mt-3">
            <label class="label">Opacité : {{ Number(form.background.opacity).toFixed(2) }}</label>
            <input type="range" min="0" max="0.5" step="0.01" v-model.number="form.background.opacity" class="w-full" />
          </div>
        </section>

        <!-- Accueil -->
        <section class="card">
          <h2 class="sec-title">Accueil (hero)</h2>
          <div><label class="label">Eyebrow</label><input v-model="form.home.eyebrow" class="input" /></div>
          <div class="mt-3"><label class="label">Titre</label><input v-model="form.home.title" class="input" /></div>
          <div class="mt-3"><label class="label">Texte</label><textarea v-model="form.home.lead" class="input" rows="3" style="resize:vertical" /></div>
          <div class="grid2 mt-3">
            <div><label class="label">Bouton principal</label><input v-model="form.home.ctaPrimary" class="input" /></div>
            <div><label class="label">Bouton secondaire</label><input v-model="form.home.ctaSecondary" class="input" /></div>
          </div>
        </section>

        <!-- Univers eFootball -->
        <section class="card">
          <h2 class="sec-title">Univers eFootball</h2>
          <div><label class="label">Titre carte</label><input v-model="form.efoot.cardTitle" class="input" /></div>
          <div class="mt-3"><label class="label">Texte carte</label><textarea v-model="form.efoot.cardText" class="input" rows="2" style="resize:vertical" /></div>
          <div class="mt-3">
            <label class="label">Vidéo hero</label>
            <div class="media-row">
              <input v-model="form.efoot.heroVideo" class="input" placeholder="/fonds/bg.mp4" />
              <label class="btn upload-btn">
                <UploadIcon class="w-4 h-4" /> Vidéo
                <input type="file" accept="video/*" hidden @change="onUpload($event, v => form.efoot.heroVideo = v)" />
              </label>
            </div>
          </div>
        </section>

        <!-- Bande photos de l'accueil eFootball -->
        <section class="card">
          <h2 class="sec-title">Bande photos — accueil eFootball</h2>
          <p class="text-xs mb-3" style="color:var(--muted)">
            La bande de photos qui défile en haut de l'accueil membre. Laisse vide pour la découverte automatique.
            Tu peux coller des <strong>URLs</strong> (ex. Cloudinary) ou uploader.
          </p>
          <div v-for="(slide, i) in form.efootHome.slides" :key="i" class="media-row mt-2">
            <img :src="resolveUrl(form.efootHome.slides[i])" alt="" class="media-prev" />
            <input v-model="form.efootHome.slides[i]" class="input" placeholder="https://res.cloudinary.com/..." />
            <button class="btn" @click="removeAt(form.efootHome.slides, i)" title="Retirer"><XIcon class="w-4 h-4" /></button>
          </div>
          <div class="flex gap-2 mt-3 flex-wrap">
            <button class="btn" @click="addUrl(form.efootHome.slides)"><PlusIcon class="w-4 h-4" /> Ajouter une URL</button>
            <label class="btn upload-btn">
              <UploadIcon class="w-4 h-4" /> Uploader une image
              <input type="file" accept="image/*" hidden @change="onUpload($event, v => form.efootHome.slides.push(v))" />
            </label>
          </div>
        </section>

        <!-- Images du hero de l'accueil eFootball -->
        <section class="card">
          <h2 class="sec-title">Images du hero — accueil eFootball</h2>
          <p class="text-xs mb-3" style="color:var(--muted)">
            Le visuel rotatif du hero (à droite du titre « Bienvenue au club »). Laisse vide pour la découverte automatique.
            <strong>URLs</strong> Cloudinary ou upload.
          </p>
          <div v-for="(img, i) in form.efootHome.hero" :key="i" class="media-row mt-2">
            <img :src="resolveUrl(form.efootHome.hero[i])" alt="" class="media-prev" />
            <input v-model="form.efootHome.hero[i]" class="input" placeholder="https://res.cloudinary.com/..." />
            <button class="btn" @click="removeAt(form.efootHome.hero, i)" title="Retirer"><XIcon class="w-4 h-4" /></button>
          </div>
          <div class="flex gap-2 mt-3 flex-wrap">
            <button class="btn" @click="addUrl(form.efootHome.hero)"><PlusIcon class="w-4 h-4" /> Ajouter une URL</button>
            <label class="btn upload-btn">
              <UploadIcon class="w-4 h-4" /> Uploader une image
              <input type="file" accept="image/*" hidden @change="onUpload($event, v => form.efootHome.hero.push(v))" />
            </label>
          </div>
        </section>

        <!-- Univers Tekken -->
        <section class="card">
          <h2 class="sec-title">Univers Tekken</h2>
          <div><label class="label">Titre carte</label><input v-model="form.tekken.cardTitle" class="input" /></div>
          <div class="mt-3"><label class="label">Texte carte</label><textarea v-model="form.tekken.cardText" class="input" rows="2" style="resize:vertical" /></div>
          <div class="mt-3">
            <label class="label">Vidéo hero</label>
            <div class="media-row">
              <input v-model="form.tekken.heroVideo" class="input" placeholder="/fonds/bg-tekk.mp4" />
              <label class="btn upload-btn">
                <UploadIcon class="w-4 h-4" /> Vidéo
                <input type="file" accept="video/*" hidden @change="onUpload($event, v => form.tekken.heroVideo = v)" />
              </label>
            </div>
          </div>
        </section>

        <!-- Accueil Tekken (hero) -->
        <section class="card">
          <h2 class="sec-title">Accueil Tekken (hero)</h2>
          <div><label class="label">Eyebrow</label><input v-model="form.tekkenHome.eyebrow" class="input" /></div>
          <div class="grid2 mt-3">
            <div><label class="label">Titre</label><input v-model="form.tekkenHome.title" class="input" /></div>
            <div><label class="label">Mot accentué</label><input v-model="form.tekkenHome.titleAccent" class="input" /></div>
          </div>
          <div class="mt-3"><label class="label">Texte</label><textarea v-model="form.tekkenHome.lead" class="input" rows="2" style="resize:vertical" /></div>
          <div class="mt-3"><label class="label">Bouton principal</label><input v-model="form.tekkenHome.ctaPrimary" class="input" /></div>
        </section>

        <!-- Bande photos de l'accueil Tekken -->
        <section class="card">
          <h2 class="sec-title">Bande photos — accueil Tekken</h2>
          <p class="text-xs mb-3" style="color:var(--muted)">
            La bande de photos qui défile en haut de l'accueil Tekken. Laisse vide pour masquer.
            Tu peux coller des <strong>URLs</strong> (ex. Cloudinary) ou uploader.
          </p>
          <div v-for="(slide, i) in form.tekkenHome.slides" :key="i" class="media-row mt-2">
            <img :src="resolveUrl(form.tekkenHome.slides[i])" alt="" class="media-prev" />
            <input v-model="form.tekkenHome.slides[i]" class="input" placeholder="https://res.cloudinary.com/..." />
            <button class="btn" @click="removeAt(form.tekkenHome.slides, i)" title="Retirer"><XIcon class="w-4 h-4" /></button>
          </div>
          <div class="flex gap-2 mt-3 flex-wrap">
            <button class="btn" @click="addUrl(form.tekkenHome.slides)"><PlusIcon class="w-4 h-4" /> Ajouter une URL</button>
            <label class="btn upload-btn">
              <UploadIcon class="w-4 h-4" /> Uploader une image
              <input type="file" accept="image/*" hidden @change="onUpload($event, v => form.tekkenHome.slides.push(v))" />
            </label>
          </div>
        </section>

        <!-- Images du hero de l'accueil Tekken -->
        <section class="card">
          <h2 class="sec-title">Images du hero — accueil Tekken</h2>
          <p class="text-xs mb-3" style="color:var(--muted)">
            Le visuel rotatif du hero (à droite du titre). Laisse vide pour masquer.
            <strong>URLs</strong> Cloudinary ou upload.
          </p>
          <div v-for="(img, i) in form.tekkenHome.hero" :key="i" class="media-row mt-2">
            <img :src="resolveUrl(form.tekkenHome.hero[i])" alt="" class="media-prev" />
            <input v-model="form.tekkenHome.hero[i]" class="input" placeholder="https://res.cloudinary.com/..." />
            <button class="btn" @click="removeAt(form.tekkenHome.hero, i)" title="Retirer"><XIcon class="w-4 h-4" /></button>
          </div>
          <div class="flex gap-2 mt-3 flex-wrap">
            <button class="btn" @click="addUrl(form.tekkenHome.hero)"><PlusIcon class="w-4 h-4" /> Ajouter une URL</button>
            <label class="btn upload-btn">
              <UploadIcon class="w-4 h-4" /> Uploader une image
              <input type="file" accept="image/*" hidden @change="onUpload($event, v => form.tekkenHome.hero.push(v))" />
            </label>
          </div>
        </section>

      </div>

      <p v-if="uploading" class="mt-3 text-sm" style="color:var(--muted)">
        <Loader2Icon class="w-4 h-4 animate-spin inline" /> Upload en cours…
      </p>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import AppLayout from '@/components/layout/AppLayout.vue'
import { Loader2Icon, UploadIcon, PlusIcon, XIcon } from 'lucide-vue-next'
import { useAPI, mediaUrl } from '@/composables/useAPI'
import { useSiteSettings, DEFAULTS } from '@/stores/siteSettings'

const api = useAPI()
const site = useSiteSettings()

const clone = o => JSON.parse(JSON.stringify(o))
const form = ref(clone(DEFAULTS))
const saving = ref(false)
const uploading = ref(false)
const msg = ref('')
const msgOk = ref(true)

const resolveUrl = mediaUrl

async function onUpload(e, assign) {
  const file = e.target.files?.[0]
  if (!file) return
  uploading.value = true; msg.value = ''
  try {
    const fd = new FormData(); fd.append('file', file)
    const { data } = await api.post('/admin/site-media', fd, { headers: { 'Content-Type': 'multipart/form-data' } })
    assign(data.url)
  } catch (err) {
    msg.value = err.response?.data?.error || 'Upload impossible (taille/format ?)'; msgOk.value = false
  } finally {
    uploading.value = false
    e.target.value = ''
  }
}

async function save() {
  saving.value = true; msg.value = ''
  try {
    await api.put('/admin/site-settings', { settings: form.value })
    site.setLocal(clone(form.value))
    msg.value = 'Réglages enregistrés ✓'; msgOk.value = true
  } catch (err) {
    msg.value = err.response?.data?.error || 'Erreur lors de l\'enregistrement'; msgOk.value = false
  } finally {
    saving.value = false
  }
}

function addUrl(list) {
  if (Array.isArray(list)) list.push('')
}
function removeAt(list, i) {
  if (Array.isArray(list)) list.splice(i, 1)
}

function resetDefaults() {
  if (!confirm('Réinitialiser tous les réglages aux valeurs par défaut ?')) return
  form.value = clone(DEFAULTS)
}

onMounted(() => {
  // Part des réglages actuels (déjà chargés au démarrage)
  form.value = clone({ ...DEFAULTS, ...site.settings })
})
</script>

<style scoped>
.site-admin { max-width: 60rem; }
.sec-title { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .05em; font-size: 1rem; margin-bottom: 1rem; padding-bottom: .5rem; border-bottom: 1px solid var(--border); }
.grid2 { display: grid; gap: .9rem; grid-template-columns: 1fr; }
.media-row { display: flex; gap: .6rem; align-items: center; flex-wrap: wrap; }
.media-row .input { flex: 1; min-width: 12rem; }
.media-prev { width: 48px; height: 48px; border-radius: 8px; object-fit: contain; background: var(--panel); border: 1px solid var(--border); flex: none; }
.media-prev.logo { object-fit: cover; }
.upload-btn { cursor: pointer; }
.color-row { display: flex; gap: .5rem; align-items: center; }
.color-row input[type="color"] { width: 42px; height: 38px; border: 1px solid var(--border); border-radius: 8px; background: var(--input); cursor: pointer; padding: 2px; }
.color-row .input { flex: 1; }
@media (min-width: 640px) { .grid2 { grid-template-columns: 1fr 1fr; } }
</style>
