<template>
  <TransitionRoot as="template" :show="open">
    <Dialog as="div" class="relative z-[100]" @close="$emit('close')">
      <!-- Overlay -->
      <TransitionChild as="template"
        enter="ease-out duration-200" enter-from="opacity-0" enter-to="opacity-100"
        leave="ease-in duration-150"  leave-from="opacity-100" leave-to="opacity-0"
      >
        <div class="fixed inset-0 bg-black/60 backdrop-blur-sm" />
      </TransitionChild>

      <!-- Panel -->
      <div class="fixed inset-0 overflow-y-auto">
        <div class="flex min-h-full items-center justify-center p-4">
          <TransitionChild as="template"
            enter="ease-out duration-200" enter-from="opacity-0 scale-95" enter-to="opacity-100 scale-100"
            leave="ease-in duration-150"  leave-from="opacity-100 scale-100" leave-to="opacity-0 scale-95"
          >
            <DialogPanel :class="['w-full bg-gz-card border border-gz-border rounded-xl shadow-2xl', sizeClass]">
              <!-- Header -->
              <div v-if="title" class="flex items-center justify-between px-5 py-4 border-b border-gz-border">
                <DialogTitle as="h3" class="text-base font-semibold text-gz-text">{{ title }}</DialogTitle>
                <button @click="$emit('close')" class="btn-ghost p-1.5 text-gz-muted hover:text-gz-text">
                  <XIcon class="w-4 h-4" />
                </button>
              </div>

              <!-- Body -->
              <div class="p-5">
                <slot />
              </div>

              <!-- Footer -->
              <div v-if="$slots.footer" class="px-5 py-4 border-t border-gz-border flex justify-end gap-2">
                <slot name="footer" />
              </div>
            </DialogPanel>
          </TransitionChild>
        </div>
      </div>
    </Dialog>
  </TransitionRoot>
</template>

<script setup>
import { computed } from 'vue'
import {
  Dialog, DialogPanel, DialogTitle,
  TransitionRoot, TransitionChild
} from '@headlessui/vue'
import { XIcon } from 'lucide-vue-next'

const props = defineProps({
  open:  { type: Boolean, default: false },
  title: { type: String,  default: '' },
  size:  { type: String,  default: 'md' },
})
defineEmits(['close'])

const sizeClass = computed(() => ({
  sm: 'max-w-md',
  md: 'max-w-lg',
  lg: 'max-w-2xl',
  xl: 'max-w-4xl',
}[props.size] ?? 'max-w-lg'))
</script>
