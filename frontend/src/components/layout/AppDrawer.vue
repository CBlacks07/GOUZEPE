<template>
  <!-- Overlay -->
  <Transition name="fade">
    <div v-if="open" class="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm lg:hidden"
         @click="$emit('close')" />
  </Transition>

  <!-- Drawer -->
  <Transition name="slide-right">
    <aside v-if="open"
      class="fixed top-0 right-0 h-full w-72 z-50 bg-gz-panel border-l border-gz-border
             flex flex-col shadow-2xl lg:hidden"
    >
      <!-- Header drawer -->
      <div class="flex items-center justify-between px-4 h-14 border-b border-gz-border">
        <span class="text-sm font-bold text-gz-text" style="font-family:var(--font-title);letter-spacing:.06em">GOUZEPE <span style="color:var(--muted);font-weight:600">GAMING CLUB</span></span>
        <button @click="$emit('close')" class="btn-ghost p-2">
          <XIcon class="w-5 h-5" />
        </button>
      </div>

      <!-- Liens -->
      <nav class="flex-1 overflow-y-auto py-3 px-2">
        <template v-for="group in visibleGroups" :key="group.title">
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
          Se déconnecter
        </button>
      </div>
    </aside>
  </Transition>
</template>

<script setup>
import { computed } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useThemeStore } from '@/stores/theme'
import { useMembershipNotif } from '@/composables/useMembershipNotif'
import {
  HomeIcon, CalendarDaysIcon, SwordsIcon, BarChart2Icon, UserIcon, TrophyIcon,
  UsersIcon, ShieldIcon, DatabaseIcon, SunIcon, MoonIcon,
  LogOutIcon, XIcon, PaletteIcon, GamepadIcon
} from 'lucide-vue-next'

defineProps({ open: Boolean })
defineEmits(['close'])

const auth   = useAuthStore()
const { pendingCount } = useMembershipNotif()
const theme  = useThemeStore()
const router = useRouter()

const navGroups = [
  {
    title: '',
    links: [
      { to: '/accueil', label: 'Accueil', icon: HomeIcon },
      { to: '/profil',  label: 'Mon espace', icon: UserIcon },
    ],
  },
  {
    title: 'eFootball',
    links: [
      { to: '/journees',   label: 'Journees',    icon: CalendarDaysIcon },
      { to: '/duel',        label: 'Duel',         icon: SwordsIcon },
      { to: '/classement',  label: 'Classements',  icon: BarChart2Icon },
      { to: '/tournois',    label: 'Tournois',     icon: TrophyIcon },
    ],
  },
  {
    title: 'Tekken',
    links: [
      { to: '/tekken-ladder', label: 'Ladder', icon: GamepadIcon },
    ],
  },
  {
    title: '',
    links: [
      { to: '/admin', label: 'Admin', icon: ShieldIcon, adminOnly: true },
    ],
  },
]

const visibleGroups = computed(() =>
  navGroups
    .map(g => ({ ...g, links: g.links.filter(l => !l.adminOnly || auth.isAdmin) }))
    .filter(g => g.links.length > 0)
)

async function handleLogout() {
  if (!confirm('Voulez-vous vraiment vous déconnecter ?')) return
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
