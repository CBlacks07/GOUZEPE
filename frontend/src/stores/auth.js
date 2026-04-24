import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('efoot.token') || '')
  const role = ref(localStorage.getItem('efoot.role') || 'member')
  const playerId = ref(localStorage.getItem('efoot.pid') || null)
  const expAt = ref(Number(localStorage.getItem('efoot.expAt') || 0))
  const hydrated = ref(false)
  const hydrationPromise = ref(null)

  const isAdmin = computed(() => role.value === 'admin')
  const isExpired = computed(() => expAt.value > 0 && Date.now() >= expAt.value)
  const isValid = computed(() => !!token.value && !isExpired.value)

  function persistSession() {
    if (token.value) localStorage.setItem('efoot.token', token.value)
    else localStorage.removeItem('efoot.token')
    localStorage.setItem('efoot.role', role.value)
    localStorage.setItem('efoot.expAt', String(expAt.value || 0))
    if (playerId.value) localStorage.setItem('efoot.pid', playerId.value)
    else localStorage.removeItem('efoot.pid')
  }

  function login({ token: tok, user, expHours }) {
    const exp = expHours ? Date.now() + expHours * 3600 * 1000 : 0
    token.value = tok
    role.value = (user?.role || 'member').toLowerCase()
    playerId.value = user?.player_id || null
    expAt.value = exp
    hydrated.value = false
    persistSession()
  }

  async function hydrateFromServer(force = false) {
    if (!token.value || isExpired.value) {
      await logout({ remote: false })
      return false
    }
    if (hydrated.value && !force) return true
    if (hydrationPromise.value) return hydrationPromise.value

    const base =
      (localStorage.getItem('efoot.api') || `http://${location.hostname || 'localhost'}:3005`)
        .replace(/\/+$/, '')

    hydrationPromise.value = (async () => {
      try {
        const res = await fetch(`${base}/auth/me`, {
          method: 'GET',
          headers: { Authorization: 'Bearer ' + token.value }
        })
        if (!res.ok) {
          await logout({ remote: false })
          return false
        }
        const data = await res.json().catch(() => ({}))
        const user = data.user || {}
        role.value = (user.role || role.value || 'member').toLowerCase()
        playerId.value = user.player_id || null
        hydrated.value = true
        persistSession()
        return true
      } catch (_) {
        return false
      } finally {
        hydrationPromise.value = null
      }
    })()

    return hydrationPromise.value
  }

  async function logout({ remote = true } = {}) {
    if (remote && token.value) {
      try {
        const apiBase =
          (localStorage.getItem('efoot.api') || `http://${location.hostname || 'localhost'}:3005`)
            .replace(/\/+$/, '')
        await fetch(`${apiBase}/auth/logout`, {
          method: 'POST',
          headers: { Authorization: 'Bearer ' + token.value }
        })
      } catch (_) {}
    }

    token.value = ''
    role.value = 'member'
    playerId.value = null
    expAt.value = 0
    hydrated.value = false
    hydrationPromise.value = null

    const preserve = new Set(['efoot.theme', 'efoot.api'])
    for (let i = localStorage.length - 1; i >= 0; i--) {
      const k = localStorage.key(i)
      if (k && !preserve.has(k)) localStorage.removeItem(k)
    }
    try {
      sessionStorage.clear()
    } catch (_) {}
  }

  return {
    token,
    role,
    playerId,
    expAt,
    hydrated,
    isAdmin,
    isExpired,
    isValid,
    login,
    hydrateFromServer,
    logout
  }
})
