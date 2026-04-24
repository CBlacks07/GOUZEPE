import { onMounted, ref, unref, watch } from 'vue'

function canUseSessionStorage() {
  return typeof window !== 'undefined' && typeof window.sessionStorage !== 'undefined'
}

function safeParse(raw) {
  try {
    return JSON.parse(raw)
  } catch (_) {
    return null
  }
}

function safeStringify(value) {
  try {
    return JSON.stringify(value)
  } catch (_) {
    return ''
  }
}

export function useSessionState(storageKey, bindings = {}) {
  const restored = ref(false)
  const key = String(storageKey || '').trim()

  function snapshot() {
    const out = {}
    for (const [name, target] of Object.entries(bindings)) {
      out[name] = unref(target)
    }
    return out
  }

  function restore() {
    if (!key || !canUseSessionStorage()) return
    const raw = sessionStorage.getItem(key)
    if (!raw) return
    const parsed = safeParse(raw)
    if (!parsed || typeof parsed !== 'object') return

    for (const [name, value] of Object.entries(parsed)) {
      const target = bindings[name]
      if (!target || typeof target !== 'object' || !('value' in target)) continue
      target.value = value
    }
    restored.value = true
  }

  function persist(value) {
    if (!key || !canUseSessionStorage()) return
    const raw = safeStringify(value)
    if (!raw) return
    sessionStorage.setItem(key, raw)
  }

  onMounted(() => {
    restore()
  })

  watch(
    () => snapshot(),
    (val) => persist(val),
    { deep: true }
  )

  return { restored, restore }
}
