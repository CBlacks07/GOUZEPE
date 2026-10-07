<template>
  <div class="sk" role="status" aria-live="polite" aria-busy="true" :class="variant">
    <span class="sr-only">Chargement…</span>
    <div v-for="n in count" :key="n" class="sk-item" aria-hidden="true">
      <template v-if="variant === 'card'">
        <span class="sk-line sk-avatar"></span>
        <span class="sk-col">
          <span class="sk-line w-40"></span>
          <span class="sk-line w-70"></span>
        </span>
      </template>
      <span v-else class="sk-line w-100"></span>
    </div>
  </div>
</template>

<script setup>
defineProps({
  count: { type: Number, default: 5 },
  variant: { type: String, default: 'row' }, // 'row' (listes/tableaux) | 'card' (grilles)
})
</script>

<style scoped>
.sk { display: grid; gap: .6rem; }
.sk.card { grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: .9rem; }
.sk-item { border: 1px solid var(--border); background: var(--card); border-radius: .75rem; padding: .9rem 1rem; display: flex; align-items: center; gap: .8rem; min-height: 3.2rem; }
.sk-col { display: grid; gap: .45rem; flex: 1; }
.sk-line { display: block; height: .75rem; border-radius: 999px; background: linear-gradient(90deg, rgba(255,255,255,.04) 25%, rgba(255,255,255,.12) 50%, rgba(255,255,255,.04) 75%); background-size: 200% 100%; animation: sk-pulse 1.4s ease-in-out infinite; }
.sk-avatar { width: 2.6rem; height: 2.6rem; border-radius: 50%; flex: none; }
.w-40 { width: 40%; } .w-70 { width: 70%; } .w-100 { width: 100%; }
.sr-only { position: absolute; width: 1px; height: 1px; overflow: hidden; clip: rect(0 0 0 0); white-space: nowrap; }
@keyframes sk-pulse { to { background-position: -200% 0; } }
@media (prefers-reduced-motion: reduce) { .sk-line { animation: none; } }
</style>
