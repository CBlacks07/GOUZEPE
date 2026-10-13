<template>
  <TransitionRoot as="template" :show="state.open">
    <Dialog as="div" class="relative z-200" :initial-focus="cancelRef" @close="answerConfirm(false)">
      <TransitionChild as="template"
        enter="ease-out duration-150" enter-from="opacity-0" enter-to="opacity-100"
        leave="ease-in duration-100" leave-from="opacity-100" leave-to="opacity-0"
      >
        <div class="fixed inset-0 bg-black/65 backdrop-blur-xs" />
      </TransitionChild>

      <div class="fixed inset-0 overflow-y-auto">
        <div class="flex min-h-full items-center justify-center p-4">
          <TransitionChild as="template"
            enter="ease-out duration-150" enter-from="opacity-0 scale-95" enter-to="opacity-100 scale-100"
            leave="ease-in duration-100" leave-from="opacity-100 scale-100" leave-to="opacity-0 scale-95"
          >
            <DialogPanel class="cf-panel">
              <div class="cf-head">
                <span class="cf-ic" :class="{ danger: state.danger }" aria-hidden="true">
                  <AlertTriangleIcon v-if="state.danger" class="w-5 h-5" />
                  <HelpCircleIcon v-else class="w-5 h-5" />
                </span>
                <DialogTitle as="h3" class="cf-title">{{ state.title || (state.danger ? 'Action irréversible' : 'Confirmation') }}</DialogTitle>
              </div>
              <p class="cf-msg">{{ state.message }}</p>
              <div class="cf-actions">
                <button ref="cancelRef" type="button" class="btn" @click="answerConfirm(false)">{{ state.cancelLabel }}</button>
                <button type="button" :class="state.danger ? 'btn-danger' : 'btn-primary'" @click="answerConfirm(true)">{{ state.confirmLabel }}</button>
              </div>
            </DialogPanel>
          </TransitionChild>
        </div>
      </div>
    </Dialog>
  </TransitionRoot>
</template>

<script setup>
import { ref } from 'vue'
import { Dialog, DialogPanel, DialogTitle, TransitionRoot, TransitionChild } from '@headlessui/vue'
import { AlertTriangleIcon, HelpCircleIcon } from 'lucide-vue-next'
import { useConfirm } from '@/composables/useConfirm'

const { state, answerConfirm } = useConfirm()
const cancelRef = ref(null)
</script>

<style scoped>
.cf-panel { width: 100%; max-width: 26rem; padding: 1.4rem 1.5rem 1.2rem; border-radius: 16px; border: 1px solid var(--border); background: var(--card); box-shadow: 0 24px 60px rgba(0, 0, 0, .55); }
.cf-head { display: flex; align-items: center; gap: .75rem; margin-bottom: .75rem; }
.cf-ic { flex: none; width: 2.4rem; height: 2.4rem; display: inline-flex; align-items: center; justify-content: center; border-radius: 50%; color: var(--accent-l); background: color-mix(in srgb, var(--accent) 16%, transparent); }
.cf-ic.danger { color: #f87171; background: rgba(248, 113, 113, .14); }
.cf-title { font-family: var(--font-title); font-weight: 700; font-size: 1.05rem; letter-spacing: .02em; color: var(--text); }
.cf-msg { margin: 0 0 1.2rem; color: var(--muted); font-size: .92rem; line-height: 1.55; white-space: pre-line; }
.cf-actions { display: flex; justify-content: flex-end; gap: .6rem; flex-wrap: wrap; }
</style>
