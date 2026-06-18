<template>
  <div :class="['min-h-screen text-gz-text app-root', themeClass]">
    <div class="app-bg-wrap" aria-hidden="true">
      <div class="app-bg-logo"></div>
      <div class="app-bg-overlay"></div>
      <div class="app-bg-vignette"></div>
    </div>

    <div class="app-shell">
      <RouterView v-slot="{ Component, route }">
        <Transition name="page" mode="out-in">
          <KeepAlive v-if="route.meta?.keepAlive !== false">
            <component :is="Component" :key="route.name || route.path" />
          </KeepAlive>
          <component v-else :is="Component" :key="route.fullPath" />
        </Transition>
      </RouterView>
      <AppToast />
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted } from 'vue'
import { RouterView } from 'vue-router'
import { useThemeStore } from '@/stores/theme'
import { useGameStore } from '@/stores/game'
import { useSiteSettings } from '@/stores/siteSettings'
import AppToast from '@/components/ui/AppToast.vue'
import { resolveBaseURL } from '@/composables/useAPI'

const theme = useThemeStore()
const game  = useGameStore()
const site  = useSiteSettings()
const themeClass = computed(() => theme.mode === 'light' ? 'light' : '')

// ── Keep-alive Render : ping toutes les 9 min pour éviter le cold start ──
// Render free endort l'API après 15 min sans requête.
// Ce ping silencieux maintient l'API éveillée tant que quelqu'un est sur le site.
const PING_INTERVAL = 9 * 60 * 1000 // 9 minutes
let pingTimer = null

function startKeepAlive() {
  if (pingTimer) return
  pingTimer = setInterval(() => {
    fetch(`${resolveBaseURL()}/health`, { method: 'GET' }).catch(() => {})
  }, PING_INTERVAL)
}

function stopKeepAlive() {
  if (pingTimer) { clearInterval(pingTimer); pingTimer = null }
}

onMounted(() => {
  theme.apply()
  game.apply()
  site.load()
  startKeepAlive()
})

onUnmounted(() => {
  stopKeepAlive()
})
</script>

<style scoped>
.app-root {
  position: relative;
  min-height: 100vh;
  overflow: hidden;
}

.app-shell {
  position: relative;
  z-index: 1;
  min-height: 100vh;
}

.app-bg-wrap {
  position: fixed;
  inset: 0;
  z-index: 0;
  pointer-events: none;
}

.app-bg-logo {
  position: absolute;
  inset: 0;
  background-image: var(--app-bg-logo, url('/assets/fond1.png'));
  background-repeat: no-repeat;
  background-position: center;
  background-size: min(46vmin, 520px);   /* largeur fixe, hauteur auto → aspect préservé */
  opacity: var(--app-bg-logo-opacity, 0.16);
}

.app-bg-overlay {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(70vw 55vh at 10% 0%, rgba(59, 130, 246, 0.14), transparent 58%),
    radial-gradient(70vw 58vh at 90% 100%, rgba(34, 197, 94, 0.12), transparent 58%);
}

.app-bg-vignette {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(2, 6, 23, 0.45), rgba(2, 6, 23, 0.62));
}

:root.light .app-bg-logo {
  opacity: 0.10;
}

:root.light .app-bg-overlay {
  background:
    radial-gradient(68vw 54vh at 10% 0%, rgba(93, 116, 185, 0.08), transparent 60%),
    radial-gradient(68vw 56vh at 90% 100%, rgba(110, 132, 201, 0.07), transparent 60%);
}

:root.light .app-bg-vignette {
  background: linear-gradient(180deg, rgba(238, 241, 246, 0.58), rgba(238, 241, 246, 0.74));
}

/* ── Transitions de page ── */
.page-enter-active { animation: pageIn .22s ease both; }
.page-leave-active { animation: pageOut .18s ease both; }
@keyframes pageIn {
  from { opacity: 0; transform: translateY(8px); }
  to   { opacity: 1; transform: translateY(0); }
}
@keyframes pageOut {
  from { opacity: 1; transform: translateY(0); }
  to   { opacity: 0; transform: translateY(-6px); }
}
</style>
