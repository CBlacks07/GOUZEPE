<template>
  <!-- Desktop : colonne fixe -->
  <aside class="adm-side" aria-label="Navigation admin">
    <RouterLink :to="ADMIN_HOME.to" class="adm-link adm-home" :class="{ on: active?.to === ADMIN_HOME.to }">
      <component :is="ADMIN_HOME.icon" class="w-4 h-4" /> {{ ADMIN_HOME.label }}
    </RouterLink>

    <div v-for="g in ADMIN_GROUPS" :key="g.key" class="adm-group">
      <div class="adm-title"><span :class="['adm-dot', g.key]" />{{ g.title }}</div>
      <RouterLink v-for="l in g.links" :key="l.to" :to="l.to" class="adm-link" :class="{ on: active?.to === l.to }">
        <component :is="l.icon" class="w-4 h-4" />
        <span class="flex-1">{{ l.label }}</span>
        <span v-if="l.badge === 'membership' && pendingCount > 0" class="adm-badge">{{ pendingCount > 9 ? '9+' : pendingCount }}</span>
      </RouterLink>
    </div>

    <div class="adm-foot">
      <RouterLink to="/" class="adm-link">
        <GlobeIcon class="w-4 h-4" /> Voir le site public
      </RouterLink>
    </div>
  </aside>

  <!-- Mobile / tablette : un sélecteur de page (pas de défilement horizontal à deviner) -->
  <div ref="menuEl" class="adm-mobile">
    <button type="button" class="adm-current" :aria-expanded="String(menuOpen)" aria-haspopup="true" aria-controls="adm-mobile-list"
            @click="menuOpen = !menuOpen">
      <component :is="(active || ADMIN_HOME).icon" class="w-4 h-4" />
      <span class="adm-current-label">
        <span class="adm-current-kicker">{{ currentGroup }}</span>
        {{ (active || ADMIN_HOME).label }}
      </span>
      <span v-if="totalBadge > 0" class="adm-badge">{{ totalBadge > 9 ? '9+' : totalBadge }}</span>
      <ChevronDownIcon class="w-4 h-4 adm-chev" :class="{ open: menuOpen }" />
    </button>

    <Transition name="adm-drop">
      <div v-if="menuOpen" id="adm-mobile-list" class="adm-list" role="menu">
        <RouterLink :to="ADMIN_HOME.to" role="menuitem" class="adm-item" :class="{ on: active?.to === ADMIN_HOME.to }">
          <component :is="ADMIN_HOME.icon" class="w-4 h-4" /> {{ ADMIN_HOME.label }}
        </RouterLink>
        <div v-for="g in ADMIN_GROUPS" :key="g.key" class="adm-list-group">
          <div class="adm-title"><span :class="['adm-dot', g.key]" />{{ g.title }}</div>
          <RouterLink v-for="l in g.links" :key="l.to" :to="l.to" role="menuitem" class="adm-item" :class="{ on: active?.to === l.to }">
            <component :is="l.icon" class="w-4 h-4" />
            <span class="flex-1">{{ l.label }}</span>
            <span v-if="l.badge === 'membership' && pendingCount > 0" class="adm-badge">{{ pendingCount > 9 ? '9+' : pendingCount }}</span>
          </RouterLink>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup>
import { computed, ref, watch, onMounted, onBeforeUnmount } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { GlobeIcon, ChevronDownIcon } from 'lucide-vue-next'
import { ADMIN_HOME, ADMIN_GROUPS, bestMatch } from '@/composables/useNavigation'
import { useMembershipNotif } from '@/composables/useMembershipNotif'

const route = useRoute()
const { pendingCount } = useMembershipNotif()

const flatLinks = [ADMIN_HOME, ...ADMIN_GROUPS.flatMap((g) => g.links)]
const active = computed(() => bestMatch(route.path, flatLinks))
const currentGroup = computed(() => {
  const a = active.value
  if (!a || a.to === ADMIN_HOME.to) return 'Admin'
  return ADMIN_GROUPS.find((g) => g.links.some((l) => l.to === a.to))?.title || 'Admin'
})
const totalBadge = computed(() => pendingCount.value)

// Menu : fermé après navigation, au clic extérieur et avec Échap
const menuOpen = ref(false)
const menuEl = ref(null)
function onDocClick(e) { if (menuOpen.value && menuEl.value && !menuEl.value.contains(e.target)) menuOpen.value = false }
function onKey(e) { if (e.key === 'Escape') menuOpen.value = false }
watch(() => route.fullPath, () => { menuOpen.value = false })
onMounted(() => { document.addEventListener('click', onDocClick); document.addEventListener('keydown', onKey) })
onBeforeUnmount(() => { document.removeEventListener('click', onDocClick); document.removeEventListener('keydown', onKey) })
</script>

<style scoped>
.adm-side {
  display: none; flex-direction: column; gap: .15rem;
  width: 14.5rem; flex: none;
  position: sticky; top: 3.5rem; align-self: flex-start;
  height: calc(100dvh - 3.5rem); overflow-y: auto;
  padding: 1.25rem .75rem 1rem;
  border-right: 1px solid var(--border);
  background: color-mix(in srgb, var(--panel) 55%, transparent);
}
.adm-group { margin-top: .9rem; }
.adm-title {
  display: flex; align-items: center; gap: .45rem;
  font-size: .64rem; font-weight: 800; text-transform: uppercase; letter-spacing: .1em;
  color: var(--muted); padding: 0 .7rem .35rem;
}
.adm-dot { width: .45rem; height: .45rem; border-radius: 50%; background: var(--muted); }
.adm-dot.efoot { background: #3b82f6; }
.adm-dot.tekken { background: #ff5a2c; }

.adm-link {
  display: flex; align-items: center; gap: .6rem;
  padding: .5rem .7rem; border-radius: .55rem;
  font-size: .85rem; color: var(--muted); text-decoration: none;
  transition: color .15s, background-color .15s;
}
.adm-link:hover { color: var(--text); background: color-mix(in srgb, var(--border) 22%, transparent); }
.adm-link.on { color: var(--accent-l); background: color-mix(in srgb, var(--accent) 15%, transparent); font-weight: 600; }
.adm-home { font-weight: 600; }
.adm-foot { margin-top: auto; padding-top: 1rem; border-top: 1px solid var(--border); }

.adm-badge {
  display: inline-grid; place-items: center; min-width: 1.1rem; height: 1.1rem; padding: 0 .3rem;
  border-radius: 999px; background: var(--red); color: #fff; font-size: .68rem; font-weight: 700;
}

.adm-mobile {
  position: sticky; top: 3.5rem; z-index: 30;
  background: color-mix(in srgb, var(--panel) 88%, transparent); backdrop-filter: blur(10px);
  border-bottom: 1px solid var(--border);
}
.adm-current {
  width: 100%; display: flex; align-items: center; gap: .6rem;
  padding: .45rem 1rem; background: transparent; border: none; color: var(--accent-l); cursor: pointer; text-align: left;
}
.adm-current-label { flex: 1; min-width: 0; font-size: .9rem; font-weight: 700; line-height: 1.15; }
.adm-current-kicker { display: block; font-size: .6rem; font-weight: 800; text-transform: uppercase; letter-spacing: .1em; color: var(--muted); }
.adm-chev { color: var(--muted); transition: transform .15s; flex: none; }
.adm-chev.open { transform: rotate(180deg); }
.adm-list {
  position: absolute; left: 0; right: 0; top: 100%;
  max-height: calc(100dvh - 7rem); overflow-y: auto; overscroll-behavior: contain;
  padding: .4rem .6rem .7rem; background: var(--panel); border-bottom: 1px solid var(--border);
  box-shadow: 0 16px 32px rgba(0, 0, 0, .4);
}
.adm-list-group { margin-top: .5rem; }
.adm-item {
  display: flex; align-items: center; gap: .65rem; padding: .55rem .7rem; border-radius: .55rem;
  font-size: .9rem; color: var(--muted); text-decoration: none;
}
.adm-item:hover { color: var(--text); background: color-mix(in srgb, var(--border) 22%, transparent); }
.adm-item.on { color: var(--accent-l); background: color-mix(in srgb, var(--accent) 15%, transparent); font-weight: 600; }
.adm-drop-enter-active, .adm-drop-leave-active { transition: opacity .12s ease, transform .12s ease; }
.adm-drop-enter-from, .adm-drop-leave-to { opacity: 0; transform: translateY(-4px); }
/* Le choix colonne / barre se fait ici et non via des classes Tailwind,
   que les règles scoped ci-dessus écraseraient. */
@media (min-width: 1024px) {
  .adm-side { display: flex; }
  .adm-mobile { display: none; }
}
</style>
