<template>
  <div v-if="loading || items.length" class="na-card">
    <div class="na-head">
      <MegaphoneIcon class="w-4 h-4" />
      <span class="na-label">Annonces du club</span>
    </div>
    <div v-if="loading" class="na-empty">Chargement…</div>
    <div v-else class="na-list">
      <div v-for="n in items" :key="n.id" class="na-row">
        <div class="na-row-head">
          <strong class="na-title">{{ n.title }}</strong>
          <span v-if="n.pinned" class="na-pin">Épinglée</span>
          <span v-if="n.tag" class="na-tag">{{ n.tag }}</span>
        </div>
        <p class="na-body">{{ n.body }}</p>
        <span class="na-date">{{ fmtDate(n.created_at) }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { MegaphoneIcon } from 'lucide-vue-next'
import { resolveBaseURL } from '@/composables/useAPI'

const items = ref([])
const loading = ref(true)

function fmtDate(d) {
  if (!d) return ''
  try { return new Date(d).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short', year: 'numeric' }) } catch (_) { return d }
}

onMounted(async () => {
  try {
    const r = await fetch(resolveBaseURL() + '/public/news', { headers: { Accept: 'application/json' } })
    if (r.ok) { const d = await r.json(); items.value = (d.news || []).slice(0, 4) }
  } catch (_) {}
  loading.value = false
})
</script>

<style scoped>
.na-card { border: 1px solid var(--border); border-radius: 16px; background: var(--card); padding: 1.1rem 1.25rem; }
.na-head { display: flex; align-items: center; gap: .45rem; color: var(--accent-l, var(--accent)); margin-bottom: .8rem; }
.na-label { font-family: var(--font-title); font-weight: 800; text-transform: uppercase; letter-spacing: .08em; font-size: .78rem; }
.na-empty { color: var(--muted); font-size: .85rem; }
.na-list { display: flex; flex-direction: column; gap: .8rem; }
.na-row { padding-bottom: .8rem; border-bottom: 1px solid color-mix(in srgb, var(--border) 60%, transparent); }
.na-row:last-child { border-bottom: none; padding-bottom: 0; }
.na-row-head { display: flex; align-items: center; gap: .4rem; flex-wrap: wrap; margin-bottom: .25rem; }
.na-title { font-size: .92rem; }
.na-pin, .na-tag { font-size: .62rem; font-weight: 700; text-transform: uppercase; letter-spacing: .04em; padding: .1rem .45rem; border-radius: 999px; border: 1px solid var(--border); color: var(--muted); }
.na-pin { color: #ca8a04; border-color: color-mix(in srgb, #eab308 40%, transparent); background: color-mix(in srgb, #eab308 10%, transparent); }
.na-body { font-size: .82rem; color: var(--muted); margin: 0 0 .3rem; white-space: pre-wrap; }
.na-date { font-size: .7rem; color: var(--muted); opacity: .8; }
</style>
