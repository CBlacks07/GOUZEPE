<template>
  <div class="pub-shell">
    <PublicNav />
    <main id="main-content" tabindex="-1" class="pub-main">
      <slot />
    </main>
    <PublicFooter />
  </div>
</template>

<script setup>
import PublicNav from './PublicNav.vue'
import PublicFooter from './PublicFooter.vue'
</script>

<style scoped>
.pub-shell { position: relative; z-index: 1; color: var(--text); min-height: 100dvh; display: flex; flex-direction: column; }
.pub-main { flex: 1; }
</style>
