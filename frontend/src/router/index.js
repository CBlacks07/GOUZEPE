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
    path: '/',
    name: 'PublicHome',
    component: () => import('@/views/public/LandingView.vue'),
    meta: { requiresAuth: false, title: 'GOUZEPE Gaming Club', public: true },
  },
  {
    path: '/efootball',
    name: 'EfootballHub',
    component: () => import('@/views/public/EfootballHubView.vue'),
    meta: { requiresAuth: false, title: 'eFootball' },
  },
  {
    path: '/tekken',
    name: 'TekkenHub',
    component: () => import('@/views/public/TekkenHubView.vue'),
    meta: { requiresAuth: false, title: 'Tekken' },
  },
  {
    path: '/classements',
    name: 'ClassementsPublic',
    component: () => import('@/views/public/ClassementsPublicView.vue'),
    meta: { requiresAuth: false, title: 'Classements' },
  },
  {
    path: '/membres',
    name: 'Membres',
    component: () => import('@/views/public/MembresView.vue'),
    meta: { requiresAuth: false, title: 'Membres' },
  },
  {
    path: '/palmares',
    name: 'Palmares',
    component: () => import('@/views/public/PalmaresView.vue'),
    meta: { requiresAuth: false, title: 'Palmarès' },
  },
  {
    path: '/records',
    name: 'Records',
    component: () => import('@/views/public/RecordsView.vue'),
    meta: { requiresAuth: false, title: 'Records du club' },
  },
  {
    path: '/joueur/:id',
    name: 'PlayerProfile',
    component: () => import('@/views/public/PlayerProfileView.vue'),
    meta: { requiresAuth: false, title: 'Profil joueur' },
  },
  {
    path: '/mentions-legales',
    name: 'MentionsLegales',
    component: () => import('@/views/public/MentionsLegalesView.vue'),
    meta: { requiresAuth: false, title: 'Mentions légales' },
  },
  {
    path: '/confidentialite',
    name: 'PolitiqueConfidentialite',
    component: () => import('@/views/public/PolitiqueConfidentialiteView.vue'),
    meta: { requiresAuth: false, title: 'Politique de confidentialité' },
  },
  {
    path: '/reglement-championnat',
    name: 'ReglementChampionnat',
    component: () => import('@/views/public/ReglementChampionnatView.vue'),
    meta: { requiresAuth: false, title: 'Règlement du championnat eFootball' },
  },
  {
    path: '/inscription',
    name: 'Inscription',
    component: () => import('@/views/InscriptionView.vue'),
    meta: { requiresAuth: false, title: 'Demande de membre', public: true },
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/LoginView.vue'),
    meta: { requiresAuth: false, title: 'Connexion', keepAlive: false },
  },
  {
    path: '/accueil',
    name: 'Accueil',
    component: () => import('@/views/AccueilView.vue'),
    meta: { requiresAuth: true, title: 'Accueil' },
  },
  {
    path: '/accueil-tekken',
    name: 'AccueilTekken',
    component: () => import('@/views/AccueilTekkenView.vue'),
    meta: { requiresAuth: true, title: 'Accueil Tekken' },
  },
  {
    path: '/journees',
    name: 'Journees',
    component: () => import('@/views/JourneesView.vue'),
    meta: { requiresAuth: true, title: 'Journées' },
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
    path: '/invite/:id',
    name: 'GuestDetail',
    component: () => import('@/views/GuestDetailView.vue'),
    meta: { requiresAuth: true, title: 'Profil invité' },
  },

  {
    path: '/tekken-ladder',
    name: 'TekkenLadder',
    component: () => import('@/views/TekkenLadderView.vue'),
    meta: { requiresAuth: true, title: 'Tekken - Ladder' },
  },
  {
    path: '/tekken-tournois',
    name: 'TekkenTournois',
    component: () => import('@/views/TekkenTournoisView.vue'),
    meta: { requiresAuth: true, title: 'Tekken - Tournois' },
  },

  {
    path: '/admin',
    name: 'AdminConsole',
    component: () => import('@/views/admin/AdminConsoleView.vue'),
    meta: { requiresAuth: true, requiresAdmin: true, title: 'Administration' },
  },
  {
    path: '/admin/tekken',
    name: 'AdminTekken',
    component: () => import('@/views/admin/AdminTekkenView.vue'),
    meta: { requiresAuth: true, requiresAdmin: true, title: 'Admin - Tekken' },
  },
  {
    path: '/admin/tekken/tournois',
    name: 'AdminTekkenTournois',
    component: () => import('@/views/admin/AdminTekkenTournoisView.vue'),
    meta: { requiresAuth: true, requiresAdmin: true, title: 'Admin - Tournois Tekken' },
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
  {
    path: '/admin/site',
    name: 'AdminSite',
    component: () => import('@/views/admin/AdminSiteView.vue'),
    meta: { requiresAuth: true, requiresAdmin: true, title: 'Admin - Apparence du site' },
  },
  {
    path: '/admin/news',
    name: 'AdminNews',
    component: () => import('@/views/admin/AdminNewsView.vue'),
    meta: { requiresAuth: true, requiresAdmin: true, title: 'Admin - Actualités' },
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

  function homeRoute() {
    return auth.isAdmin ? '/admin' : '/profil'
  }

  document.title = to.meta.title
    ? `${to.meta.title} - GOUZEPE Gaming Club`
    : 'GOUZEPE Gaming Club'

  if (to.meta.requiresAuth !== false && !auth.isValid) {
    return '/'
  }

  if (auth.isValid && !auth.hydrated) {
    await auth.hydrateFromServer()
  }

  // Les membres connectés sont redirigés depuis les pages publiques (landing, inscription)
  // vers leur espace ; les admins en sont exemptés pour pouvoir prévisualiser le site public.
  if (auth.isValid && to.meta.public && !auth.isAdmin) {
    return homeRoute()
  }

  if (to.name === 'Login' && auth.isValid) {
    return homeRoute()
  }

  if (to.meta.requiresAdmin && !auth.isAdmin) {
    return '/'
  }

  return true
})

export default router
