import axios from 'axios'
import { useAuthStore } from '@/stores/auth'

// Résolution de l'URL base (compatible navigateur + Docker)
function resolveBaseURL() {
  if (import.meta.env.VITE_API_URL) return import.meta.env.VITE_API_URL
  const stored = localStorage.getItem('efoot.api')
  if (stored) return stored
  const host = (location.hostname && location.hostname !== '') ? location.hostname : 'localhost'
  return 'http://' + host + ':3005'
}

// Instance axios partagée (lazy — créée une seule fois)
let _instance = null

function createInstance() {
  const api = axios.create({ baseURL: resolveBaseURL() })

  // Injecter le token à chaque requête
  api.interceptors.request.use(config => {
    const tok = localStorage.getItem('efoot.token')
    if (tok) config.headers.Authorization = 'Bearer ' + tok
    return config
  })

  // Intercepteur réponse : 401 → logout + redirect
  api.interceptors.response.use(
    res => res,
    async err => {
      const status = err.response?.status
      const reqUrl = String(err.config?.url || '')
      const isLoginCall = reqUrl.includes('/auth/login')
      const onLoginRoute = window.location.pathname === '/login'

      if (status === 401 && !isLoginCall) {
        const auth = useAuthStore()
        await auth.logout({ remote: false })
        if (!onLoginRoute) {
          // Utiliser window.location pour éviter la dépendance circulaire avec le router
          window.location.replace('/login')
        }
      }
      return Promise.reject(err)
    }
  )
  return api
}

export function useAPI() {
  if (!_instance) _instance = createInstance()
  return _instance
}

// Helper raccourcis pour usage dans les vues
export function useGet(url, config) {
  return useAPI().get(url, config)
}
export function usePost(url, data, config) {
  return useAPI().post(url, data, config)
}
export function usePut(url, data, config) {
  return useAPI().put(url, data, config)
}
export function useDelete(url, config) {
  return useAPI().delete(url, config)
}
