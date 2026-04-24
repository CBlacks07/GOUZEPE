<template>
  <div :class="['min-h-screen text-gz-text app-root', themeClass]">
    <div class="app-bg-wrap" aria-hidden="true">
      <video class="app-bg-video" autoplay muted loop playsinline preload="metadata" poster="/assets/fond.png">
        <source src="/fonds/bg.mp4" type="video/mp4" />
      </video>
      <div class="app-bg-overlay"></div>
      <div class="app-bg-vignette"></div>
    </div>

    <div class="app-shell">
      <RouterView v-slot="{ Component, route }">
        <KeepAlive>
          <component
            :is="Component"
            v-if="route.meta?.keepAlive !== false"
            :key="route.name || route.path"
          />
        </KeepAlive>
        <component
          :is="Component"
          v-if="route.meta?.keepAlive === false"
          :key="route.fullPath"
        />
      </RouterView>
      <AppToast />
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { RouterView } from 'vue-router'
import { useThemeStore } from '@/stores/theme'
import AppToast from '@/components/ui/AppToast.vue'

const theme = useThemeStore()
const themeClass = computed(() => theme.mode === 'light' ? 'light' : '')

onMounted(() => {
  theme.apply()
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

.app-bg-video {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  opacity: 0.22;
  filter: saturate(0.95) contrast(1.03);
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

:root.light .app-bg-video {
  opacity: 0.12;
}

:root.light .app-bg-overlay {
  background:
    radial-gradient(68vw 54vh at 10% 0%, rgba(93, 116, 185, 0.08), transparent 60%),
    radial-gradient(68vw 56vh at 90% 100%, rgba(110, 132, 201, 0.07), transparent 60%);
}

:root.light .app-bg-vignette {
  background: linear-gradient(180deg, rgba(238, 241, 246, 0.58), rgba(238, 241, 246, 0.74));
}
</style>
