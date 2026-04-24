<template>
  <header class="topbar">
    <!-- Logo -->
    <RouterLink to="/" class="flex items-center gap-2.5 shrink-0 no-underline">
      <img src="/assets/icons/apple-touch-icon.png" alt="Logo" class="w-8 h-8 rounded-lg object-cover" />
      <div class="hidden sm:block leading-tight">
        <div class="text-sm font-bold text-gz-text">GOUZEPE eFOOTBALL</div>
        <div class="text-xs text-gz-green font-semibold">{{ seasonLabel }}</div>
      </div>
    </RouterLink>

    <!-- Nav desktop -->
    <nav class="hidden lg:flex items-center gap-0.5 ml-4 flex-1 overflow-x-auto">
      <RouterLink v-for="link in visibleLinks" :key="link.to"
        :to="link.to"
        class="flex items-center gap-1.5 px-2 py-1.5 rounded-lg text-[13px] whitespace-nowrap text-gz-muted
               hover:text-gz-text hover:bg-gz-border/20 transition-colors duration-150"
        active-class="!text-gz-text bg-gz-border/20"
      >
        <component :is="link.icon" class="w-3.5 h-3.5" />
        {{ link.label }}
      </RouterLink>
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
import {
  HomeIcon, SwordsIcon, BarChart2Icon, UserIcon, TrophyIcon,
  UsersIcon, ShieldIcon, DatabaseIcon, SunIcon, MoonIcon,
  LogOutIcon, MenuIcon
} from 'lucide-vue-next'

const props = defineProps({
  seasonLabel: { type: String, default: 'Saison' }
})
defineEmits(['open-drawer'])

const auth   = useAuthStore()
const theme  = useThemeStore()
const router = useRouter()

const allLinks = [
  { to: '/',                   label: 'Accueil',          icon: HomeIcon,     adminOnly: false },
  { to: '/duel',               label: 'Duel',             icon: SwordsIcon,   adminOnly: false },
  { to: '/classement',         label: 'Classements',      icon: BarChart2Icon, adminOnly: false },
  { to: '/profil',             label: 'Mon espace',       icon: UserIcon,     adminOnly: false },
  { to: '/tournois',           label: 'Tournois',         icon: TrophyIcon,   adminOnly: false },
  { to: '/admin/joueurs',      label: 'Joueurs',          icon: UsersIcon,    adminOnly: false },
  { to: '/admin/utilisateurs', label: 'Utilisateurs',     icon: ShieldIcon,   adminOnly: true },
  { to: '/admin/tournois',     label: 'Admin Tournois',   icon: TrophyIcon,   adminOnly: true },
  { to: '/admin/sauvegardes',  label: 'Sauvegardes',      icon: DatabaseIcon, adminOnly: true },
]

const visibleLinks = computed(() =>
  allLinks.filter(l => !l.adminOnly || auth.isAdmin)
)

async function handleLogout() {
  if (!confirm('Voulez-vous vraiment vous déconnecter ?')) return
  await auth.logout()
  router.push('/login')
}
</script>
