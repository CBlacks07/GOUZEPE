import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const SCROLL_STORAGE_KEY = 'efoot.scroll.positions.v1'

function loadScrollStore() {
  if (typeof window === 'undefined') return {}
  try {
    return JSON.parse(sessionStorage.getItem(SCROLL_STORAGE_KEY) || '{}') || {}
  } catch (_) {
    return {}
  }
}

function saveScrollStore(store) {
  if (typeof window === 'undefined') return
  try {
    sessionStorage.setItem(SCROLL_STORAGE_KEY, JSON.stringify(store || {}))
  } catch (_) {}
}

function saveScrollPosition(fullPath, x = 0, y = 0) {
  if (typeof window === 'undefined' || !fullPath) return
  const store = loadScrollStore()
  store[fullPath] = {
    left: Math.max(0, Number(x) || 0),
    top: Math.max(0, Number(y) || 0),
  }
  saveScrollStore(store)
}

function getScrollPosition(fullPath) {
  if (typeof window === 'undefined' || !fullPath) return null
  const store = loadScrollStore()
  const saved = store[fullPath]
  if (!saved || typeof saved !== 'object') return null
  const left = Number(saved.left)
  const top = Number(saved.top)
  if (!Number.isFinite(left) || !Number.isFinite(top)) return null
  return { left, top }
}

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/LoginView.vue'),
    meta: { requiresAuth: false, title: 'Connexion', keepAlive: false },
  },

  {
    path: '/',
    name: 'Accueil',
    component: () => import('@/views/AccueilView.vue'),
    meta: { requiresAuth: true, title: 'Accueil' },
  },
  {
    path: '/duel',
    name: 'Duel',
    component: () => import('@/views/DuelView.vue'),
    meta: { requiresAuth: true, title: 'Duels' },
  },
  {
    path: '/classement',
    name: 'Classement',
    component: () => import('@/views/ClassementView.vue'),
    meta: { requiresAuth: true, title: 'Classements' },
  },
  {
    path: '/profil',
    name: 'Profil',
    component: () => import('@/views/PanelMembreView.vue'),
    meta: { requiresAuth: true, title: 'Mon espace' },
  },
  {
    path: '/tournois',
    name: 'Tournois',
    component: () => import('@/views/TournoisView.vue'),
    meta: { requiresAuth: true, title: 'Tournois' },
  },

  {
    path: '/admin/joueurs',
    name: 'AdminJoueurs',
    component: () => import('@/views/admin/AdminJoueursView.vue'),
    meta: { requiresAuth: true, title: 'Admin - Joueurs' },
  },
  {
    path: '/admin/utilisateurs',
    name: 'AdminUtilisateurs',
    component: () => import('@/views/admin/AdminUtilisateursView.vue'),
    meta: { requiresAuth: true, requiresAdmin: true, title: 'Admin - Utilisateurs' },
  },
  {
    path: '/admin/tournois',
    name: 'AdminTournois',
    component: () => import('@/views/admin/AdminTournoisView.vue'),
    meta: { requiresAuth: true, requiresAdmin: true, title: 'Admin - Tournois' },
  },
  {
    path: '/admin/sauvegardes',
    name: 'AdminSauvegardes',
    component: () => import('@/views/admin/AdminSauvegardesView.vue'),
    meta: { requiresAuth: true, requiresAdmin: true, title: 'Admin - Sauvegardes' },
  },

  { path: '/:pathMatch(.*)*', redirect: '/' },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior: (to, from, savedPosition) => {
    if (savedPosition) return savedPosition
    const saved = getScrollPosition(to.fullPath)
    if (saved) return saved
    return false
  },
})

if (typeof window !== 'undefined') {
  let scrollRaf = 0
  const saveCurrentRouteScroll = () => {
    saveScrollPosition(
      router.currentRoute.value.fullPath,
      window.scrollX || window.pageXOffset || 0,
      window.scrollY || window.pageYOffset || 0
    )
  }
  const onScroll = () => {
    if (scrollRaf) cancelAnimationFrame(scrollRaf)
    scrollRaf = requestAnimationFrame(() => {
      scrollRaf = 0
      saveCurrentRouteScroll()
    })
  }
  window.addEventListener('scroll', onScroll, { passive: true })
  window.addEventListener('beforeunload', saveCurrentRouteScroll)

  // Hard refresh safety: enforce restore after initial route is ready.
  router.isReady().then(() => {
    const saved = getScrollPosition(router.currentRoute.value.fullPath)
    if (saved) {
      requestAnimationFrame(() => {
        window.scrollTo(saved.left || 0, saved.top || 0)
      })
    }
  }).catch(() => {})
}

router.beforeEach(async (to, from) => {
  if (typeof window !== 'undefined' && from?.fullPath) {
    saveScrollPosition(
      from.fullPath,
      window.scrollX || window.pageXOffset || 0,
      window.scrollY || window.pageYOffset || 0
    )
  }

  const auth = useAuthStore()

  document.title = to.meta.title
    ? `${to.meta.title} - GOUZEPE eFOOTBALL`
    : 'GOUZEPE eFOOTBALL'

  if (to.meta.requiresAuth !== false && !auth.isValid) {
    return '/login'
  }

  if (auth.isValid && !auth.hydrated) {
    await auth.hydrateFromServer()
  }

  if (to.name === 'Login' && auth.isValid) {
    return auth.isAdmin ? '/' : '/profil'
  }

  if (to.meta.requiresAdmin && !auth.isAdmin) {
    return '/'
  }

  return true
})

export default router
