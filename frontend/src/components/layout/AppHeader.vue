<template>
  <header class="topbar">
    <!-- Logo -->
    <RouterLink :to="homeRoute" class="flex items-center gap-2.5 shrink-0 no-underline">
      <img src="/assets/icons/apple-touch-icon.png" alt="Logo" class="w-9 h-9 rounded-lg object-cover" />
      <div class="hidden sm:block leading-tight" style="font-family:var(--font-title)">
        <div class="text-sm font-bold text-gz-text" style="letter-spacing:.06em">GOUZEPE <span style="color:var(--muted);font-weight:600">GAMING CLUB</span></div>
        <div class="text-xs font-semibold" style="color:var(--accent-l)">{{ seasonLabel }}</div>
      </div>
    </RouterLink>

    <!-- Nav desktop : identique sur toutes les pages -->
    <nav ref="navEl" class="hidden lg:flex items-center gap-0.5 ml-4 flex-1" aria-label="Navigation principale">
      <RouterLink to="/profil" class="navlink" active-class="nav-on">
        <UserIcon class="w-3.5 h-3.5" /> Mon espace
      </RouterLink>

      <!-- Un seul jeu : liens à plat. Deux jeux : un menu déroulant par jeu. -->
      <template v-if="!bothGames">
        <span class="nav-sep" />
        <span class="nav-game">{{ showEfoot ? 'eFootball' : 'Tekken' }}</span>
        <RouterLink v-for="l in singleGameLinks" :key="l.to" :to="l.to" class="navlink"
                    :class="{ 'nav-on': isActive(l.to) }">
          <component :is="l.icon" class="w-3.5 h-3.5" /> {{ l.label }}
        </RouterLink>
      </template>

      <template v-else>
        <div v-for="g in gameMenus" :key="g.key" class="relative">
          <button type="button" class="navlink" :class="{ 'nav-on': groupActive(g.links), 'nav-open': openMenu === g.key }"
                  :aria-expanded="String(openMenu === g.key)" aria-haspopup="true"
                  @click="toggleMenu(g.key)">
            <component :is="g.icon" class="w-3.5 h-3.5" /> {{ g.label }}
            <ChevronDownIcon class="w-3 h-3 transition-transform" :class="{ 'rotate-180': openMenu === g.key }" />
          </button>
          <Transition name="dd">
            <div v-if="openMenu === g.key" class="dd-panel" role="menu">
              <RouterLink v-for="l in g.links" :key="l.to" :to="l.to" role="menuitem"
                          class="dd-item" :class="{ 'dd-on': isActive(l.to) }" @click="openMenu = null">
                <component :is="l.icon" class="w-4 h-4" /> {{ l.label }}
              </RouterLink>
            </div>
          </Transition>
        </div>
      </template>

      <template v-if="auth.isAdmin">
        <span class="nav-sep" />
        <RouterLink to="/admin" class="navlink relative" :class="{ 'nav-on': route.path.startsWith('/admin') }">
          <ShieldIcon class="w-3.5 h-3.5" /> Admin
          <span v-if="pendingCount > 0"
                class="absolute -top-1 -right-1 min-w-[16px] h-4 px-0.5 rounded-full text-[10px] font-bold
                       flex items-center justify-center bg-gz-red text-white leading-none">
            {{ pendingCount > 9 ? '9+' : pendingCount }}
          </span>
        </RouterLink>
      </template>
    </nav>

    <div class="ml-auto flex items-center gap-2">
      <button @click="theme.toggle()" class="btn-ghost p-2" :title="theme.mode === 'dark' ? 'Mode clair' : 'Mode sombre'" :aria-label="theme.mode === 'dark' ? 'Activer le mode clair' : 'Activer le mode sombre'">
        <SunIcon v-if="theme.mode === 'dark'" class="w-4 h-4" />
        <MoonIcon v-else class="w-4 h-4" />
      </button>

      <button @click="handleLogout" class="btn-ghost p-2 hidden lg:flex text-gz-muted hover:text-gz-red" title="Se déconnecter" aria-label="Se déconnecter">
        <LogOutIcon class="w-4 h-4" />
      </button>

      <button @click="$emit('open-drawer')" class="btn-ghost p-2 lg:hidden relative" aria-label="Ouvrir le menu" aria-controls="app-drawer" :aria-expanded="String(drawerOpen)">
        <MenuIcon class="w-5 h-5" />
        <span v-if="auth.isAdmin && pendingCount > 0" class="absolute top-1 right-1 w-2 h-2 rounded-full bg-gz-red" />
      </button>
    </div>
  </header>
</template>

<script setup>
import { computed, ref, watch, onMounted, onBeforeUnmount } from 'vue'
import { RouterLink, useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useThemeStore } from '@/stores/theme'
import { useMembershipNotif } from '@/composables/useMembershipNotif'
import { EFOOT_LINKS, TEKKEN_LINKS, bestMatch, useMemberNav } from '@/composables/useNavigation'
import {
  UserIcon, ShieldIcon, SunIcon, MoonIcon, LogOutIcon, MenuIcon, GamepadIcon, FootprintsIcon, ChevronDownIcon,
} from 'lucide-vue-next'

defineProps({
  seasonLabel: { type: String, default: 'Saison' },
  drawerOpen: { type: Boolean, default: false }
})
defineEmits(['open-drawer'])

const auth   = useAuthStore()
const theme  = useThemeStore()
const router = useRouter()
const route  = useRoute()
const { pendingCount } = useMembershipNotif()
const { showEfoot, showTekken, homeRoute } = useMemberNav()

const bothGames = computed(() => showEfoot.value && showTekken.value)
const singleGameLinks = computed(() => (showEfoot.value ? EFOOT_LINKS : TEKKEN_LINKS))
const gameMenus = [
  { key: 'efoot',  label: 'eFootball', icon: FootprintsIcon, links: EFOOT_LINKS },
  { key: 'tekken', label: 'Tekken',    icon: GamepadIcon,    links: TEKKEN_LINKS },
]

const ALL_GAME_LINKS = [...EFOOT_LINKS, ...TEKKEN_LINKS]
const activeLink = computed(() => bestMatch(route.path, ALL_GAME_LINKS))
function isActive(to) { return activeLink.value?.to === to }
function groupActive(links) { return links.some((l) => isActive(l.to)) }

/* Menus déroulants : un seul ouvert, fermé au clic extérieur, Échap ou navigation */
const openMenu = ref(null)
const navEl = ref(null)
function toggleMenu(key) { openMenu.value = openMenu.value === key ? null : key }
function onDocClick(e) { if (openMenu.value && navEl.value && !navEl.value.contains(e.target)) openMenu.value = null }
function onKey(e) { if (e.key === 'Escape') openMenu.value = null }
watch(() => route.fullPath, () => { openMenu.value = null })
onMounted(() => { document.addEventListener('click', onDocClick); document.addEventListener('keydown', onKey) })
onBeforeUnmount(() => { document.removeEventListener('click', onDocClick); document.removeEventListener('keydown', onKey) })

async function handleLogout() {
  if (!confirm('Voulez-vous vraiment vous déconnecter ?')) return
  await auth.logout()
  router.push('/login')
}
</script>

<style scoped>
.navlink {
  display: flex; align-items: center; gap: .375rem;
  padding: .375rem .5rem; border-radius: .5rem;
  font-size: 13px; white-space: nowrap; color: var(--muted);
  background: transparent; border: none; cursor: pointer;
  transition: color .15s, background-color .15s;
}
.navlink:hover, .navlink.nav-open { color: var(--text); background: color-mix(in srgb, var(--border) 20%, transparent); }
.nav-on {
  color: var(--accent-l) !important;
  background: color-mix(in srgb, var(--accent) 16%, transparent);
}
.nav-sep {
  width: 1px; height: 18px; margin: 0 .3rem;
  background: var(--border); flex-shrink: 0;
}
.nav-game {
  font-size: .62rem; font-weight: 800; text-transform: uppercase; letter-spacing: .1em;
  color: var(--muted); padding: 0 .35rem 0 .1rem;
}

.dd-panel {
  position: absolute; top: calc(100% + .4rem); left: 0; z-index: 60;
  min-width: 11rem; padding: .35rem;
  background: var(--panel); border: 1px solid var(--border); border-radius: .75rem;
  box-shadow: 0 12px 32px rgba(0, 0, 0, .35);
}
.dd-item {
  display: flex; align-items: center; gap: .6rem;
  padding: .5rem .65rem; border-radius: .5rem;
  font-size: 13px; color: var(--muted); text-decoration: none;
}
.dd-item:hover { color: var(--text); background: color-mix(in srgb, var(--border) 25%, transparent); }
.dd-on { color: var(--accent-l); background: color-mix(in srgb, var(--accent) 14%, transparent); }

.dd-enter-active, .dd-leave-active { transition: opacity .12s ease, transform .12s ease; }
.dd-enter-from, .dd-leave-to { opacity: 0; transform: translateY(-4px); }
</style>
