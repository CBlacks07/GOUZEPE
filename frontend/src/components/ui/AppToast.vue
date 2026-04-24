<template>
  <Teleport to="body">
    <div class="fixed bottom-4 right-4 z-[200] flex flex-col gap-2 max-w-sm w-full pointer-events-none">
      <TransitionGroup name="toast">
        <div
          v-for="t in toasts"
          :key="t.id"
          :class="['pointer-events-auto flex items-start gap-3 px-4 py-3 rounded-xl border shadow-xl text-sm',
                   toastClass(t.type)]"
        >
          <component :is="toastIcon(t.type)" class="w-4 h-4 mt-0.5 shrink-0" />
          <span class="flex-1">{{ t.message }}</span>
          <button @click="dismiss(t.id)" class="opacity-60 hover:opacity-100 transition-opacity shrink-0">
            <XIcon class="w-3.5 h-3.5" />
          </button>
        </div>
      </TransitionGroup>
    </div>
  </Teleport>
</template>

<script setup>
import { useToast } from '@/composables/useToast'
import { CheckCircleIcon, XCircleIcon, InfoIcon, XIcon } from 'lucide-vue-next'

const { toasts, dismiss } = useToast()

function toastClass(type) {
  return {
    success: 'bg-gz-card border-gz-green/30 text-gz-text',
    error:   'bg-gz-card border-gz-red/30 text-gz-text',
    info:    'bg-gz-card border-gz-border text-gz-text',
  }[type] ?? 'bg-gz-card border-gz-border text-gz-text'
}

function toastIcon(type) {
  return { success: CheckCircleIcon, error: XCircleIcon, info: InfoIcon }[type] ?? InfoIcon
}
</script>

<style scoped>
.toast-enter-active { transition: all 0.25s ease; }
.toast-leave-active { transition: all 0.2s ease; }
.toast-enter-from   { opacity: 0; transform: translateY(8px) scale(0.97); }
.toast-leave-to     { opacity: 0; transform: translateX(20px); }
</style>
