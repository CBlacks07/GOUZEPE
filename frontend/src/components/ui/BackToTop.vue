<template>
  <Teleport to="body">
  <Transition name="btt">
    <button v-if="visible" class="btt" type="button" aria-label="Revenir en haut de la page" title="Haut de page" @click="toTop">
      <ArrowUpIcon class="w-4 h-4" />
    </button>
  </Transition>
  </Teleport>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { ArrowUpIcon } from 'lucide-vue-next'

const visible = ref(false)
function onScroll() { visible.value = window.scrollY > 600 }
function toTop() {
  const reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches
  window.scrollTo({ top: 0, behavior: reduce ? 'auto' : 'smooth' })
}
onMounted(() => { onScroll(); window.addEventListener('scroll', onScroll, { passive: true }) })
onBeforeUnmount(() => window.removeEventListener('scroll', onScroll))
</script>

<style scoped>
.btt { position: fixed; right: 1rem; bottom: 1rem; z-index: 40; width: 2.6rem; height: 2.6rem; display: inline-flex; align-items: center; justify-content: center; border-radius: 50%; border: 1px solid var(--border); background: color-mix(in srgb, var(--card) 90%, transparent); color: var(--accent-l); cursor: pointer; backdrop-filter: blur(8px); box-shadow: 0 6px 18px rgba(0, 0, 0, .35); transition: transform .18s, border-color .18s; }
.btt:hover { transform: translateY(-2px); border-color: var(--accent); }
.btt:focus-visible { outline: 2px solid var(--accent-l); outline-offset: 3px; }
.btt-enter-active, .btt-leave-active { transition: opacity .2s, transform .2s; }
.btt-enter-from, .btt-leave-to { opacity: 0; transform: translateY(8px); }
@media (prefers-reduced-motion: reduce) { .btt, .btt-enter-active, .btt-leave-active { transition: none; } }
</style>
