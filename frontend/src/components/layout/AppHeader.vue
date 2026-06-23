<template>
  <header class="topbar">
    <!-- Logo -->
    <RouterLink to="/" class="flex items-center gap-2.5 shrink-0 no-underline">
      <img src="/assets/icons/apple-touch-icon.png" alt="Logo" class="w-9 h-9 rounded-lg object-cover" />
      <div class="hidden sm:block leading-tight" style="font-family:var(--font-title)">
        <div class="text-sm font-bold text-gz-text" style="letter-spacing:.06em">GOUZEPE <span style="color:var(--muted);font-weight:600">GAMING CLUB</span></div>
        <div class="text-xs font-semibold" style="color:var(--accent-l)">{{ seasonLabel }}</div>
      </div>
    </RouterLink>

    <!-- Nav desktop -->
    <nav class="hidden lg:flex items-center gap-0.5 ml-4 flex-1 overflow-x-auto">
      <template v-for="(item, i) in visibleNav" :key="item.to || item.sep">
        <span v-if="item.sep" class="nav-sep" />
        <RouterLink v-else
          :to="item.to"
          class="navlink relative flex items-center gap-1.5 px-2 py-1.5 rounded-lg text-[13px] whitespace-nowrap text-gz-muted
                 hover:text-gz-text hover:bg-gz-border/20 transition-colors duration-150"
          active-class="nav-on"
        >
          <component :is="item.icon" class="w-3.5 h-3.5" />
          {{ item.label }}
          <span v-if="item.to === '/admin' && pendingCount > 0"
                class="absolute -top-1 -right-1 min-w-[16px] h-4 px-0.5 rounded-full text-[10px] font-bold
                       flex items-center justify-center bg-gz-red text-white leading-none">
            {{ pendingCount > 9 ? '9+' : pendingCount }}
          </span>
        </RouterLink>
      </template>
    </nav>

    <div class="ml-auto flex items-center gap-2">
      <!-- Bouton thème -->
      <button @click="theme.toggle()" class="btn-ghost p-2" :title="theme.mode === 'dark' ? 'Mode clair' : 'Mode sombre'">
        <SunIcon v-if="theme.mode === 'dark'" class="w-4 h-4" />
        <MoonIcon v-else class="w-4 h-4" />
      </button>

      <!-- Déconnexion (desktop) -->
      <button @click="handleLogout" class="btn-ghost p-2 hidden lg:flex text-gz-muted hover:text-gz-red" title="Se déconnecter">
        <LogOutIcon class="w-4 h-4" />
      </button>

      <!-- Hamburger (mobile) -->
      <button @click="$emit('open-drawer')" class="btn-ghost p-2 lg:hidden" aria-label="Menu">
        <MenuIcon class="w-5 h-5" />
      </button>
    </div>
  </header>
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
  LogOutIcon, MenuIcon, PaletteIcon, GamepadIcon
} from 'lucide-vue-next'

const props = defineProps({
  seasonLabel: { type: String, default: 'Saison' }
})
defineEmits(['open-drawer'])

const auth   = useAuthStore()
const theme  = useThemeStore()
const router = useRouter()
const { pendingCount } = useMembershipNotif()

const navStructure = [
  { to: '/accueil',       label: 'Accueil',      icon: HomeIcon },
  { to: '/profil',        label: 'Mon espace',   icon: UserIcon },
  { sep: 'efoot' },
  { to: '/journees',      label: 'Journees',     icon: CalendarDaysIcon },
  { to: '/duel',          label: 'Duel',          icon: SwordsIcon },
  { to: '/classement',    label: 'Classements',   icon: BarChart2Icon },
  { to: '/tournois',      label: 'Tournois',      icon: TrophyIcon },
  { sep: 'tekken' },
  { to: '/tekken-ladder', label: 'Tekken',        icon: GamepadIcon },
  { sep: 'admin' },
  { to: '/admin',         label: 'Admin',         icon: ShieldIcon, adminOnly: true },
]

const visibleNav = computed(() =>
  navStructure.filter((item, i, arr) => {
    if (item.adminOnly && !auth.isAdmin) return false
    if (item.sep) {
      const next = arr.slice(i + 1).find(x => !x.sep)
      if (next?.adminOnly && !auth.isAdmin) return false
    }
    return true
  })
)

async function handleLogout() {
  if (!confirm('Voulez-vous vraiment vous déconnecter ?')) return
  await auth.logout()
  router.push('/login')
}
</script>

<style scoped>
.nav-on {
  color: var(--accent-l) !important;
  background: color-mix(in srgb, var(--accent) 16%, transparent);
}
.nav-sep {
  width: 1px; height: 18px; margin: 0 .3rem;
  background: var(--border); flex-shrink: 0;
}
</style>
