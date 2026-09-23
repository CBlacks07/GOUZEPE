<template>
  <!-- Pages lisibles par tous : en-tête membre si connecté, en-tête public sinon. -->
  <AppLayout v-if="auth.isValid" :season-label="seasonLabel">
    <slot />
  </AppLayout>
  <PublicLayout v-else>
    <slot />
  </PublicLayout>
</template>

<script setup>
import AppLayout from './AppLayout.vue'
import PublicLayout from '@/components/public/PublicLayout.vue'
import { useAuthStore } from '@/stores/auth'

defineProps({ seasonLabel: { type: String, default: 'Saison' } })
const auth = useAuthStore()
</script>
