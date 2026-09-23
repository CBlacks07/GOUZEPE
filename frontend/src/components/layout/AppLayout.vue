<template>
  <div class="min-h-dvh flex flex-col">
    <a href="#main-content" class="skip-link">Aller au contenu</a>
    <AppHeader :season-label="seasonLabel" :drawer-open="drawerOpen" @open-drawer="drawerOpen = true" />
    <AppDrawer :open="drawerOpen" @close="drawerOpen = false" />

    <!-- Espace admin : barre latérale commune à toutes les pages /admin -->
    <div v-if="isAdminArea" class="flex-1 flex flex-col lg:flex-row min-w-0">
      <AdminSidebar />
      <main id="main-content" tabindex="-1" class="flex-1 min-w-0">
        <slot />
      </main>
    </div>
    <main v-else id="main-content" tabindex="-1" class="flex-1">
      <slot />
    </main>

    <footer class="text-center text-xs text-gz-muted py-4 border-t border-gz-border/50">
      Copyright © GOUZEPE GAMING CLUB 2026
    </footer>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import AppHeader from './AppHeader.vue'
import AppDrawer from './AppDrawer.vue'
import AdminSidebar from './AdminSidebar.vue'
import { useMembershipNotif } from '@/composables/useMembershipNotif'
import { useGameStore } from '@/stores/game'
import { useAuthStore } from '@/stores/auth'

defineProps({
  seasonLabel: { type: String, default: 'Saison' }
})

const drawerOpen = ref(false)
const game = useGameStore()
const auth = useAuthStore()
const route = useRoute()

// Figé à la création : les pages sont gardées en cache (KeepAlive) et `route`
// suit la route courante ; une page admin mise en cache ne doit pas perdre sa barre.
const isAdminArea = auth.isAdmin && route.path.startsWith('/admin')

const tekkenRoutes = ['/tekken-ladder', '/tekken-tournois', '/accueil-tekken', '/admin/tekken']

const activePole = computed(() => {
  const p = route.path
  if (tekkenRoutes.some(r => p === r || p.startsWith(r))) return 'tekken'
  return 'efoot'
})

watch(activePole, (pole) => game.set(pole), { immediate: true })

const { fetchCount, setupRealtime } = useMembershipNotif()
let disposeRealtime = null

onMounted(async () => {
  await fetchCount()
  disposeRealtime = setupRealtime()
})

onUnmounted(() => {
  if (disposeRealtime) disposeRealtime()
})
</script>
