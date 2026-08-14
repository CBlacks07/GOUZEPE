<template>
  <!-- Overlay -->
  <Transition name="fade">
    <div v-if="open" class="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm lg:hidden"
         @click="$emit('close')" />
  </Transition>

  <!-- Drawer -->
  <Transition name="slide-right">
    <aside v-if="open"
      id="app-drawer"
      ref="panelEl"
      role="dialog"
      aria-modal="true"
      aria-label="Menu de navigation"
      class="fixed top-0 right-0 h-full w-72 z-50 bg-gz-panel border-l border-gz-border
             flex flex-col shadow-2xl lg:hidden"
    >
      <!-- Header drawer -->
      <div class="flex items-center justify-between px-4 h-14 border-b border-gz-border">
        <span class="text-sm font-bold text-gz-text" style="font-family:var(--font-title);letter-spacing:.06em">GOUZEPE <span style="color:var(--muted);font-weight:600">GAMING CLUB</span></span>
        <button @click="$emit('close')" class="btn-ghost p-2" aria-label="Fermer le menu">
          <XIcon class="w-5 h-5" />
        </button>
      </div>

      <!-- Liens -->
      <nav class="flex-1 overflow-y-auto py-3 px-2">
        <template v-for="group in visibleGroups" :key="group.title || 'main'">
          <div v-if="group.title" class="drawer-group-title">{{ group.title }}</div>
          <RouterLink v-for="link in group.links" :key="link.to"
            :to="link.to"
            @click="$emit('close')"
            class="relative flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-gz-muted
                   hover:text-gz-text hover:bg-gz-border/20 transition-colors mb-0.5"
            active-class="nav-on"
          >
            <component :is="link.icon" class="w-4 h-4 shrink-0" />
            {{ link.label }}
            <span v-if="link.to === '/admin' && pendingCount > 0"
                  class="ml-auto min-w-[18px] h-[18px] px-1 rounded-full text-[10px] font-bold
                         flex items-center justify-center bg-gz-red text-white">
              {{ pendingCount > 9 ? '9+' : pendingCount }}
            </span>
          </RouterLink>
        </template>
      </nav>

      <!-- Footer drawer -->
      <div class="p-4 border-t border-gz-border space-y-2">
        <button @click="theme.toggle()" class="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg
               text-sm text-gz-muted hover:text-gz-text hover:bg-gz-border/20 transition-colors">
          <SunIcon v-if="theme.mode === 'dark'" class="w-4 h-4" />
          <MoonIcon v-else class="w-4 h-4" />
          {{ theme.mode === 'dark' ? 'Mode clair' : 'Mode sombre' }}
        </button>
        <button @click="handleLogout" class="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg
               text-sm text-gz-red hover:bg-gz-red/10 transition-colors">
          <LogOutIcon class="w-4 h-4" />
          Se deconnecter
        </button>
      </div>
    </aside>
  </Transition>
</template>

<script setup>
import { computed, ref, watch, nextTick, onBeforeUnmount } from 'vue'
import { RouterLink, useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useThemeStore } from '@/stores/theme'
import { useMembershipNotif } from '@/composables/useMembershipNotif'
import {
  HomeIcon, CalendarDaysIcon, SwordsIcon, BarChart2Icon, UserIcon, TrophyIcon,
  ShieldIcon, SunIcon, MoonIcon, LogOutIcon, XIcon, GamepadIcon, FootprintsIcon, GlobeIcon
} from 'lucide-vue-next'

const props = defineProps({ open: Boolean })
const emit = defineEmits(['close'])

/* Accessibilité : dialogue modal — Échap pour fermer, focus piégé, focus restauré */
const panelEl = ref(null)
let lastFocused = null

function focusables() {
  const root = panelEl.value
  if (!root) return []
  return [...root.querySelectorAll('a[href], button:not([disabled]), [tabindex]:not([tabindex="-1"])')]
    .filter((el) => el.offsetParent !== null)
}
function onKeydown(e) {
  if (e.key === 'Escape') { emit('close'); return }
  if (e.key !== 'Tab') return
  const f = focusables()
  if (!f.length) return
  const first = f[0]
  const last = f[f.length - 1]
  if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus() }
  else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus() }
}
watch(() => props.open, async (open) => {
  if (open) {
    lastFocused = document.activeElement
    document.addEventListener('keydown', onKeydown)
    await nextTick()
    focusables()[0]?.focus()
  } else {
    document.removeEventListener('keydown', onKeydown)
    if (lastFocused && typeof lastFocused.focus === 'function') lastFocused.focus()
    lastFocused = null
  }
})
onBeforeUnmount(() => document.removeEventListener('keydown', onKeydown))

const auth   = useAuthStore()
const { pendingCount } = useMembershipNotif()
const theme  = useThemeStore()
const router = useRouter()
const route  = useRoute()

const mg = computed(() => auth.mainGame || 'efoot')
const hasEfoot  = computed(() => mg.value === 'efoot' || mg.value === 'both')
const hasTekken = computed(() => mg.value === 'tekken' || mg.value === 'both')
const hasBoth   = computed(() => mg.value === 'both')

const efootRoutes = ['/journees', '/duel', '/classement', '/tournois', '/accueil']
const tekkenRoutes = ['/tekken-ladder', '/tekken-tournois', '/accueil-tekken']

const activePole = computed(() => {
  const p = route.path
  if (efootRoutes.some(r => p === r || (r !== '/accueil' && p.startsWith(r)))) return 'efoot'
  if (tekkenRoutes.some(r => p === r || p.startsWith(r))) return 'tekken'
  return null
})

const visibleGroups = computed(() => {
  const pole = activePole.value
  const groups = []

  groups.push({ title: '', links: [{ to: '/profil', label: 'Mon espace', icon: UserIcon }] })

  if (pole === 'efoot') {
    groups.push({
      title: 'eFootball',
      links: [
        { to: '/accueil', label: 'Accueil', icon: HomeIcon },
        { to: '/journees', label: 'Journees', icon: CalendarDaysIcon },
        { to: '/duel', label: 'Duel', icon: SwordsIcon },
        { to: '/classement', label: 'Classements', icon: BarChart2Icon },
        { to: '/tournois', label: 'Tournois', icon: TrophyIcon },
      ],
    })
    if (hasBoth.value) groups.push({ title: '', links: [{ to: '/accueil-tekken', label: 'Tekken', icon: GamepadIcon }] })
  } else if (pole === 'tekken') {
    groups.push({
      title: 'Tekken',
      links: [
        { to: '/accueil-tekken', label: 'Accueil', icon: HomeIcon },
        { to: '/tekken-ladder', label: 'Ladder', icon: GamepadIcon },
        { to: '/tekken-tournois', label: 'Tournois', icon: TrophyIcon },
      ],
    })
    if (hasBoth.value) groups.push({ title: '', links: [{ to: '/accueil', label: 'eFootball', icon: FootprintsIcon }] })
  } else if (!route.path.startsWith('/admin') && !auth.isAdmin) {
    const poleLinks = []
    if (hasEfoot.value) poleLinks.push({ to: '/accueil', label: 'eFootball', icon: FootprintsIcon })
    if (hasTekken.value) poleLinks.push({ to: '/accueil-tekken', label: 'Tekken', icon: GamepadIcon })
    if (poleLinks.length) groups.push({ title: 'Poles', links: poleLinks })
  }

  if (auth.isAdmin) {
    groups.push({ title: '', links: [
      { to: '/admin', label: 'Admin', icon: ShieldIcon },
      { to: '/', label: 'Site public', icon: GlobeIcon },
    ] })
  }

  return groups
})

async function handleLogout() {
  if (!confirm('Voulez-vous vraiment vous deconnecter ?')) return
  await auth.logout()
  router.push('/login')
}
</script>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }

.slide-right-enter-active, .slide-right-leave-active { transition: transform 0.25s ease; }
.slide-right-enter-from, .slide-right-leave-to { transform: translateX(100%); }

.nav-on {
  color: var(--accent-l) !important;
  background: color-mix(in srgb, var(--accent) 16%, transparent);
}
.drawer-group-title {
  font-size: .65rem; font-weight: 800; text-transform: uppercase;
  letter-spacing: .1em; color: var(--muted); padding: .8rem .75rem .3rem;
}
</style>
