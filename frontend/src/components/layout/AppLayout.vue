<template>
  <div class="min-h-dvh flex flex-col">
    <AppHeader :season-label="seasonLabel" @open-drawer="drawerOpen = true" />
    <AppDrawer :open="drawerOpen" @close="drawerOpen = false" />
    <main class="flex-1">
      <slot />
    </main>
    <footer class="text-center text-xs text-gz-muted py-4 border-t border-gz-border/50">
      Copyright © GOUZEPE GAMING CLUB 2026
    </footer>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import AppHeader from './AppHeader.vue'
import AppDrawer from './AppDrawer.vue'

defineProps({
  seasonLabel: { type: String, default: 'Saison' }
})

const drawerOpen = ref(false)
</script>
