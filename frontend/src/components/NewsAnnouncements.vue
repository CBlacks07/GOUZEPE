<template>
  <div v-if="loading || items.length" class="na-card">
    <div class="na-head">
      <span class="na-head-icon"><MegaphoneIcon class="w-4 h-4" /></span>
      <span class="na-label">Annonces du club</span>
      <span class="na-live"><span class="na-live-dot" /> Récent</span>
    </div>
    <div v-if="loading" class="na-empty">Chargement…</div>
    <TransitionGroup v-else name="na-row" tag="div" class="na-list">
      <div v-for="(n, i) in items" :key="n.id" class="na-row" :style="{ animationDelay: (i * 90) + 'ms' }">
        <span class="na-row-bar" :class="{ pinned: n.pinned }" />
        <div class="na-row-body">
          <div class="na-row-head">
            <strong class="na-title">{{ n.title }}</strong>
            <span v-if="n.pinned" class="na-pin"><PinIcon class="w-2.5 h-2.5" /> Épinglée</span>
            <span v-if="n.tag" class="na-tag">{{ n.tag }}</span>
          </div>
          <p class="na-body">{{ n.body }}</p>
          <span class="na-date">{{ fmtDate(n.created_at) }}</span>
        </div>
      </div>
    </TransitionGroup>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { MegaphoneIcon, PinIcon } from 'lucide-vue-next'
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
.na-card {
  position: relative;
  border: 1px solid var(--border); border-radius: 16px; background: var(--card);
  padding: 1.1rem 1.25rem; overflow: hidden;
  animation: na-rise .5s ease both;
}
.na-card::before {
  content: ''; position: absolute; top: 0; left: 0; right: 0; height: 2.5px;
  background: linear-gradient(90deg, var(--accent), var(--accent-l, var(--accent)), transparent);
  opacity: .8;
}

.na-head { display: flex; align-items: center; gap: .5rem; color: var(--accent-l, var(--accent)); margin-bottom: .9rem; }
.na-head-icon {
  display: inline-flex; align-items: center; justify-content: center;
  width: 1.6rem; height: 1.6rem; border-radius: 8px;
  background: color-mix(in srgb, var(--accent) 16%, transparent);
  animation: na-ring 2.6s ease-in-out .6s infinite;
}
.na-label { font-family: var(--font-title); font-weight: 800; text-transform: uppercase; letter-spacing: .08em; font-size: .78rem; }
.na-live {
  margin-left: auto; display: inline-flex; align-items: center; gap: .3rem;
  font-size: .62rem; font-weight: 700; text-transform: uppercase; letter-spacing: .05em;
  color: var(--muted);
}
.na-live-dot {
  width: 6px; height: 6px; border-radius: 50%; background: #22c55e; flex: none;
  box-shadow: 0 0 0 0 rgba(34,197,94,.6);
  animation: na-pulse 1.8s ease-out infinite;
}

.na-empty { color: var(--muted); font-size: .85rem; }
.na-list { display: flex; flex-direction: column; gap: .35rem; }

.na-row {
  position: relative; display: flex; gap: .7rem;
  padding: .65rem .6rem .65rem .8rem; margin: 0 -.6rem; border-radius: 10px;
  animation: na-rise .45s ease both;
  transition: background-color .18s, transform .18s;
}
.na-row:hover { background: color-mix(in srgb, var(--accent) 6%, transparent); transform: translateX(2px); }
.na-row + .na-row { border-top: 1px solid color-mix(in srgb, var(--border) 55%, transparent); }

.na-row-bar {
  flex: none; width: 3px; border-radius: 3px; align-self: stretch;
  background: color-mix(in srgb, var(--accent) 45%, transparent);
  transition: background-color .18s, width .18s;
}
.na-row-bar.pinned { background: #eab308; }
.na-row:hover .na-row-bar { width: 4px; background: var(--accent); }
.na-row:hover .na-row-bar.pinned { background: #ca8a04; }

.na-row-body { min-width: 0; flex: 1; }
.na-row-head { display: flex; align-items: center; gap: .4rem; flex-wrap: wrap; margin-bottom: .25rem; }
.na-title { font-size: .92rem; }
.na-pin, .na-tag {
  display: inline-flex; align-items: center; gap: .2rem;
  font-size: .62rem; font-weight: 700; text-transform: uppercase; letter-spacing: .04em;
  padding: .12rem .5rem; border-radius: 999px; border: 1px solid var(--border); color: var(--muted);
  white-space: normal; line-height: 1.3;
}
.na-pin { color: #ca8a04; border-color: color-mix(in srgb, #eab308 40%, transparent); background: color-mix(in srgb, #eab308 10%, transparent); }
.na-body { font-size: .82rem; color: var(--muted); margin: 0 0 .3rem; white-space: pre-wrap; }
.na-date { font-size: .7rem; color: var(--muted); opacity: .8; }

/* TransitionGroup (rafraîchissement de la liste) */
.na-row-enter-active { transition: opacity .35s ease, transform .35s ease; }
.na-row-enter-from { opacity: 0; transform: translateY(8px); }
.na-row-move { transition: transform .35s ease; }

@keyframes na-rise {
  from { opacity: 0; transform: translateY(10px); }
  to   { opacity: 1; transform: translateY(0); }
}
@keyframes na-ring {
  0%, 100% { transform: rotate(0deg); }
  4%  { transform: rotate(-12deg); }
  8%  { transform: rotate(10deg); }
  12% { transform: rotate(-8deg); }
  16% { transform: rotate(4deg); }
  20% { transform: rotate(0deg); }
}
@keyframes na-pulse {
  0%   { box-shadow: 0 0 0 0 rgba(34,197,94,.55); }
  70%  { box-shadow: 0 0 0 6px rgba(34,197,94,0); }
  100% { box-shadow: 0 0 0 0 rgba(34,197,94,0); }
}

@media (prefers-reduced-motion: reduce) {
  .na-card, .na-row, .na-head-icon, .na-live-dot { animation: none; }
}
</style>
