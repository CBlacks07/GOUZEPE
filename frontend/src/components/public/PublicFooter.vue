<template>
  <footer class="lfoot">
    <div class="lfoot-inner">
      <span class="brand"><img class="brand-logo" :src="logo" alt="logo" /> {{ brand.name }} {{ brand.tagline }}</span>
      <span class="lfoot-copy">© {{ year }} — eFootball &amp; Tekken</span>
    </div>
  </footer>
</template>

<script setup>
import { computed } from 'vue'
import { useSiteSettings } from '@/stores/siteSettings'
import { mediaUrl } from '@/composables/useAPI'

const year = new Date().getFullYear()
const site = useSiteSettings()
const brand = computed(() => site.settings.brand)
const logo = computed(() => mediaUrl(site.settings.brand.logo))
</script>

<style scoped>
.lfoot { border-top: 1px solid var(--border); background: color-mix(in srgb, var(--bg) 85%, transparent); }
.lfoot-inner { max-width: none; padding: 1.5rem clamp(1.25rem, 4vw, 4rem); display: flex; flex-wrap: wrap; gap: .6rem; align-items: center; justify-content: space-between; }
.brand { display: inline-flex; align-items: center; gap: .5rem; font-family: var(--font-title); font-weight: 700; letter-spacing: .05em; }
.brand-logo { width: 28px; height: 28px; border-radius: 7px; object-fit: cover; }
.lfoot-copy { color: var(--muted); font-size: .85rem; }
</style>
