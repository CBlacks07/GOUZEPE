import { ref, onMounted, onUnmounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useAPI } from '@/composables/useAPI'
import { onRealtimeEvent } from '@/composables/useRealtimeSocket'
import { useToast } from '@/composables/useToast'

// Singleton partagé dans toute l'app
const pendingCount = ref(0)

export function useMembershipNotif() {
  const auth = useAuthStore()
  const api  = useAPI()
  const { success } = useToast()

  async function fetchCount() {
    if (!auth.isAdmin) return
    try {
      const { data } = await api.get('/admin/membership-requests/count')
      pendingCount.value = Number(data.count || 0)
    } catch (_) {}
  }

  function setupRealtime() {
    if (!auth.isAdmin) return () => {}
    return onRealtimeEvent('membership:new', (payload) => {
      pendingCount.value = Number(payload.pendingCount || 0)
      const who = payload.name || payload.email || 'Quelqu\'un'
      const platform = payload.platform ? ` (${payload.platform})` : ''
      success(`Nouvelle demande de membre : ${who}${platform}`)
    })
  }

  return { pendingCount, fetchCount, setupRealtime }
}
