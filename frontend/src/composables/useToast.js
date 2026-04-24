import { ref } from 'vue'

const toasts = ref([])
let nextId = 0

export function useToast() {
  function show(message, type = 'info', duration = 3500) {
    const id = ++nextId
    toasts.value.push({ id, message, type })
    setTimeout(() => dismiss(id), duration)
  }

  function dismiss(id) {
    const idx = toasts.value.findIndex(t => t.id === id)
    if (idx !== -1) toasts.value.splice(idx, 1)
  }

  function success(msg) { show(msg, 'success') }
  function error(msg)   { show(msg, 'error', 5000) }
  function info(msg)    { show(msg, 'info') }

  return { toasts, show, dismiss, success, error, info }
}
