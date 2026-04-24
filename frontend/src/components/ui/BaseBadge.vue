<template>
  <span :class="['badge', variantClass]">
    <slot />
  </span>
</template>

<script setup>
import { computed } from 'vue'
const props = defineProps({
  variant: { type: String, default: 'muted' }
})
const variantClass = computed(() => ({
  green:  'badge-green',
  blue:   'badge-blue',
  red:    'badge-red',
  amber:  'badge-amber',
  muted:  'badge-muted',
}[props.variant] ?? 'badge-muted'))
</script>
