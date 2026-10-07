<template>
  <div class="es" :class="{ compact }">
    <span class="es-ic" aria-hidden="true"><component :is="icon" class="w-5 h-5" /></span>
    <strong class="es-title">{{ title }}</strong>
    <p v-if="hint" class="es-hint">{{ hint }}</p>
    <RouterLink v-if="to" :to="to" class="btn es-cta">{{ cta }}</RouterLink>
  </div>
</template>

<script setup>
import { RouterLink } from 'vue-router'
import { InboxIcon } from 'lucide-vue-next'

defineProps({
  title: { type: String, required: true },
  hint: { type: String, default: '' },
  to: { type: [String, Object], default: null },
  cta: { type: String, default: 'Voir' },
  icon: { type: [Object, Function], default: () => InboxIcon },
  compact: { type: Boolean, default: false },
})
</script>

<style scoped>
.es { display: flex; flex-direction: column; align-items: center; text-align: center; gap: .35rem; padding: 2rem 1rem; border: 1px dashed var(--border); border-radius: 14px; background: color-mix(in srgb, var(--card) 55%, transparent); }
.es.compact { padding: 1.1rem .9rem; border-style: solid; border-radius: 0; border: none; background: transparent; }
.es-ic { width: 2.6rem; height: 2.6rem; display: inline-flex; align-items: center; justify-content: center; border-radius: 50%; color: var(--accent-l); background: color-mix(in srgb, var(--accent) 14%, transparent); margin-bottom: .2rem; }
.compact .es-ic { width: 2rem; height: 2rem; }
.es-title { font-family: var(--font-title); font-weight: 700; letter-spacing: .03em; color: var(--text); }
.es-hint { margin: 0; max-width: 28rem; color: var(--muted); font-size: .88rem; line-height: 1.5; }
.es-cta { margin-top: .6rem; }
</style>
