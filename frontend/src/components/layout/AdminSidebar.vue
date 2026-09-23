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

  <!-- Mobile / tablette : barre d'onglets défilante -->
  <nav ref="stripEl" class="adm-strip" aria-label="Navigation admin">
    <RouterLink v-for="l in flatLinks" :key="l.to" :to="l.to" class="adm-chip" :class="{ on: active?.to === l.to }"
                :data-active="active?.to === l.to ? 'true' : null">
      <component :is="l.icon" class="w-3.5 h-3.5" />
      {{ l.short || l.label }}
      <span v-if="l.badge === 'membership' && pendingCount > 0" class="adm-badge">{{ pendingCount > 9 ? '9+' : pendingCount }}</span>
    </RouterLink>
  </nav>
</template>

<script setup>
import { computed, ref, watch, nextTick, onMounted } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { GlobeIcon } from 'lucide-vue-next'
import { ADMIN_HOME, ADMIN_GROUPS, bestMatch } from '@/composables/useNavigation'
import { useMembershipNotif } from '@/composables/useMembershipNotif'

const route = useRoute()
const { pendingCount } = useMembershipNotif()

// Sur mobile les libellés sont préfixés par le jeu, sinon « Tournois » apparaît deux fois.
const flatLinks = [
  { ...ADMIN_HOME, short: 'Accueil' },
  ...ADMIN_GROUPS.flatMap((g) => g.links.map((l) => ({
    ...l,
    short: g.key === 'club' ? l.label : `${g.key === 'efoot' ? 'eFoot' : 'Tekken'} · ${l.label}`,
  }))),
]

const active = computed(() => bestMatch(route.path, flatLinks))

// Garde l'onglet actif visible dans la barre défilante.
const stripEl = ref(null)
async function revealActive() {
  await nextTick()
  const el = stripEl.value?.querySelector('[data-active="true"]')
  if (el) el.scrollIntoView({ block: 'nearest', inline: 'center' })
}
onMounted(revealActive)
watch(() => route.path, revealActive)
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

.adm-strip {
  display: flex; gap: .4rem; overflow-x: auto; scrollbar-width: none;
  padding: .6rem 1rem; border-bottom: 1px solid var(--border);
  background: color-mix(in srgb, var(--panel) 70%, transparent);
  position: sticky; top: 3.5rem; z-index: 30; backdrop-filter: blur(10px);
}
.adm-strip::-webkit-scrollbar { display: none; }
.adm-chip {
  display: inline-flex; align-items: center; gap: .35rem; flex: none;
  padding: .35rem .7rem; border-radius: 999px;
  border: 1px solid var(--border); background: var(--card);
  font-size: .78rem; color: var(--muted); text-decoration: none; white-space: nowrap;
}
/* Le choix colonne / barre se fait ici et non via des classes Tailwind,
   que les règles scoped ci-dessus écraseraient. */
@media (min-width: 1024px) {
  .adm-side { display: flex; }
  .adm-strip { display: none; }
}
.adm-chip.on { color: var(--accent-l); border-color: color-mix(in srgb, var(--accent) 50%, var(--border)); background: color-mix(in srgb, var(--accent) 14%, var(--card)); }
</style>
