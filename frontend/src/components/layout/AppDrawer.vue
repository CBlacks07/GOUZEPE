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
        <!-- Bouton retour si dans un pole -->
        <button v-if="activePole" class="drawer-back" @click="goBack">
          <ArrowLeftIcon class="w-4 h-4" />
          Retour
        </button>

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
import { computed } from 'vue'
import { RouterLink, useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useThemeStore } from '@/stores/theme'
import { useMembershipNotif } from '@/composables/useMembershipNotif'
import {
  HomeIcon, CalendarDaysIcon, SwordsIcon, BarChart2Icon, UserIcon, TrophyIcon,
  ShieldIcon, SunIcon, MoonIcon, LogOutIcon, XIcon, GamepadIcon,
  ArrowLeftIcon, FootprintsIcon
} from 'lucide-vue-next'

defineProps({ open: Boolean })
const emit = defineEmits(['close'])

const auth   = useAuthStore()
const { pendingCount } = useMembershipNotif()
const theme  = useThemeStore()
const router = useRouter()
const route  = useRoute()

const efootRoutes = ['/journees', '/duel', '/classement', '/tournois']
const tekkenRoutes = ['/tekken-ladder']

const activePole = computed(() => {
  const p = route.path
  if (efootRoutes.some(r => p.startsWith(r))) return 'efoot'
  if (tekkenRoutes.some(r => p.startsWith(r))) return 'tekken'
  return null
})

const visibleGroups = computed(() => {
  const pole = activePole.value
  const groups = []

  if (!pole) {
    groups.push({
      title: '',
      links: [
        { to: '/accueil', label: 'Accueil',    icon: HomeIcon },
        { to: '/profil',  label: 'Mon espace', icon: UserIcon },
      ],
    })
    groups.push({
      title: 'Poles',
      links: [
        { to: '/journees',      label: 'eFootball', icon: FootprintsIcon },
        { to: '/tekken-ladder', label: 'Tekken',    icon: GamepadIcon },
      ],
    })
  } else if (pole === 'efoot') {
    groups.push({
      title: 'eFootball',
      links: [
        { to: '/journees',   label: 'Journees',   icon: CalendarDaysIcon },
        { to: '/duel',        label: 'Duel',        icon: SwordsIcon },
        { to: '/classement',  label: 'Classements', icon: BarChart2Icon },
        { to: '/tournois',    label: 'Tournois',    icon: TrophyIcon },
      ],
    })
  } else if (pole === 'tekken') {
    groups.push({
      title: 'Tekken',
      links: [
        { to: '/tekken-ladder', label: 'Ladder', icon: GamepadIcon },
      ],
    })
  }

  if (auth.isAdmin) {
    groups.push({
      title: '',
      links: [{ to: '/admin', label: 'Admin', icon: ShieldIcon }],
    })
  }

  return groups
})

function goBack() {
  router.push('/accueil')
  emit('close')
}

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
.drawer-back {
  display: flex; align-items: center; gap: .5rem;
  width: 100%; padding: .55rem .75rem; margin-bottom: .4rem;
  border-radius: 10px; border: 1px solid var(--border);
  background: transparent; color: var(--muted);
  font-size: .82rem; font-weight: 600; cursor: pointer;
  transition: color .15s, background .15s;
}
.drawer-back:hover { color: var(--text); background: color-mix(in srgb, var(--border) 25%, transparent); }
</style>
