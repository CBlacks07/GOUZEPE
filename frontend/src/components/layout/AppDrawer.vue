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
        <span class="text-sm font-bold text-gz-text">GOUZEPE eFOOTBALL</span>
        <button @click="$emit('close')" class="btn-ghost p-2">
          <XIcon class="w-5 h-5" />
        </button>
      </div>

      <!-- Liens -->
      <nav class="flex-1 overflow-y-auto py-3 px-2">
        <RouterLink v-for="link in visibleLinks" :key="link.to"
          :to="link.to"
          @click="$emit('close')"
          class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-gz-muted
                 hover:text-gz-text hover:bg-gz-border/20 transition-colors mb-0.5"
          active-class="!text-gz-text bg-gz-border/20"
        >
          <component :is="link.icon" class="w-4 h-4 shrink-0" />
          {{ link.label }}
        </RouterLink>
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
import {
  HomeIcon, SwordsIcon, BarChart2Icon, UserIcon, TrophyIcon,
  UsersIcon, ShieldIcon, DatabaseIcon, SunIcon, MoonIcon,
  LogOutIcon, XIcon
} from 'lucide-vue-next'

defineProps({ open: Boolean })
defineEmits(['close'])

const auth   = useAuthStore()
const theme  = useThemeStore()
const router = useRouter()

const allLinks = [
  { to: '/',                   label: 'Accueil',        icon: HomeIcon },
  { to: '/duel',               label: 'Duel',           icon: SwordsIcon },
  { to: '/classement',         label: 'Classements',    icon: BarChart2Icon },
  { to: '/profil',             label: 'Mon espace',     icon: UserIcon },
  { to: '/tournois',           label: 'Tournois',       icon: TrophyIcon },
  { to: '/admin/joueurs',      label: 'Joueurs',        icon: UsersIcon,   adminOnly: false },
  { to: '/admin/utilisateurs', label: 'Utilisateurs',   icon: ShieldIcon,  adminOnly: true },
  { to: '/admin/tournois',     label: 'Admin Tournois', icon: TrophyIcon,  adminOnly: true },
  { to: '/admin/sauvegardes',  label: 'Sauvegardes',    icon: DatabaseIcon, adminOnly: true },
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

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }

.slide-right-enter-active, .slide-right-leave-active { transition: transform 0.25s ease; }
.slide-right-enter-from, .slide-right-leave-to { transform: translateX(100%); }
</style>
