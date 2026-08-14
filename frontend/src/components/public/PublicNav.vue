<template>
  <header class="pnav">
    <div class="pnav-inner">
      <RouterLink to="/" class="brand" @click="mobileOpen = false">
        <img class="brand-logo" :src="logo" alt="logo" />
        <span class="brand-text">{{ brand.name }}<span class="brand-sub">{{ brand.tagline }}</span></span>
      </RouterLink>

      <nav class="pnav-links">
        <RouterLink to="/" exact-active-class="on">Accueil</RouterLink>
        <RouterLink to="/efootball" active-class="on">eFootball</RouterLink>
        <RouterLink to="/tekken" active-class="on">Tekken</RouterLink>
        <RouterLink to="/classements" active-class="on">Classements</RouterLink>
        <RouterLink to="/palmares" active-class="on">Palmarès</RouterLink>
        <RouterLink to="/records" active-class="on">Records</RouterLink>
        <RouterLink to="/membres" active-class="on">Membres</RouterLink>
      </nav>

      <div class="pnav-right">
        <div class="game-switch" role="tablist" aria-label="Choix du jeu">
          <button :class="['gs-btn', { active: game.isEfoot }]" @click="pick('efoot')">eFoot</button>
          <button :class="['gs-btn', { active: game.isTekken }]" @click="pick('tekken')">Tekken</button>
        </div>
        <RouterLink to="/login" class="btn btn-login">Connexion</RouterLink>
        <RouterLink to="/inscription" class="btn-primary btn-join">Rejoindre</RouterLink>
        <button class="pnav-burger" :class="{ on: mobileOpen }" @click="mobileOpen = !mobileOpen"
                :aria-expanded="mobileOpen" aria-label="Menu">
          <MenuIcon v-if="!mobileOpen" class="w-5 h-5" />
          <XIcon v-else class="w-5 h-5" />
        </button>
      </div>
    </div>

    <!-- Menu mobile -->
    <Transition name="pnav-drop">
      <div v-if="mobileOpen" class="pnav-mobile">
        <RouterLink to="/" exact-active-class="on" @click="mobileOpen = false">Accueil</RouterLink>
        <RouterLink to="/efootball" active-class="on" @click="mobileOpen = false">eFootball</RouterLink>
        <RouterLink to="/tekken" active-class="on" @click="mobileOpen = false">Tekken</RouterLink>
        <RouterLink to="/classements" active-class="on" @click="mobileOpen = false">Classements</RouterLink>
        <RouterLink to="/palmares" active-class="on" @click="mobileOpen = false">Palmarès</RouterLink>
        <RouterLink to="/records" active-class="on" @click="mobileOpen = false">Records</RouterLink>
        <RouterLink to="/membres" active-class="on" @click="mobileOpen = false">Membres</RouterLink>
        <div class="pnav-mobile-sep"></div>
        <RouterLink to="/login" @click="mobileOpen = false">Connexion</RouterLink>
        <div class="pnav-mobile-sep pnav-mobile-sep--switch"></div>
        <div class="game-switch game-switch--mobile" role="tablist" aria-label="Choix du jeu">
          <button :class="['gs-btn', { active: game.isEfoot }]" @click="pick('efoot')">eFoot</button>
          <button :class="['gs-btn', { active: game.isTekken }]" @click="pick('tekken')">Tekken</button>
        </div>
      </div>
    </Transition>
  </header>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { MenuIcon, XIcon } from 'lucide-vue-next'
import { useGameStore } from '@/stores/game'
import { useSiteSettings } from '@/stores/siteSettings'
import { mediaUrl } from '@/composables/useAPI'

const game = useGameStore()
const router = useRouter()
const site = useSiteSettings()

const brand = computed(() => site.settings.brand)
const logo = computed(() => mediaUrl(site.settings.brand.logo))

const mobileOpen = ref(false)
watch(() => router.currentRoute.value.fullPath, () => { mobileOpen.value = false })

function pick(g) {
  game.set(g)
  router.push(g === 'tekken' ? '/tekken' : '/efootball')
  mobileOpen.value = false
}
</script>

<style scoped>
.pnav {
  position: sticky; top: 0; z-index: 50;
  background: color-mix(in srgb, var(--bg) 80%, transparent);
  backdrop-filter: blur(14px);
  border-bottom: 1px solid var(--border);
}
.pnav-inner {
  max-width: none; height: 4rem;
  display: flex; align-items: center; gap: 1.25rem; padding: 0 clamp(1.25rem, 4vw, 4rem);
}
.brand { display: inline-flex; align-items: center; gap: .55rem; text-decoration: none; color: var(--text); font-family: var(--font-title); }
.brand-logo { width: 34px; height: 34px; border-radius: 8px; object-fit: cover; flex: none; }
.brand-text { display: flex; flex-direction: column; line-height: 1; font-weight: 700; letter-spacing: .06em; }
.brand-sub { font-size: .58rem; color: var(--muted); letter-spacing: .22em; margin-top: 2px; }

.pnav-links { display: none; gap: 1.4rem; margin-left: 1rem; }
.pnav-links a { color: var(--muted); text-decoration: none; font-size: .9rem; font-weight: 600; font-family: var(--font-title); letter-spacing: .03em; transition: color .15s; }
.pnav-links a:hover, .pnav-links a.on { color: var(--accent-l); }

.pnav-right { display: flex; align-items: center; gap: .6rem; margin-left: auto; }
.game-switch { display: inline-flex; padding: 3px; border-radius: 999px; border: 1px solid var(--border); background: color-mix(in srgb, var(--card) 70%, transparent); }
.gs-btn { padding: .28rem .8rem; border: none; background: transparent; color: var(--muted); font-size: .8rem; font-weight: 700; font-family: var(--font-title); letter-spacing: .04em; border-radius: 999px; cursor: pointer; transition: all .18s; }
.gs-btn.active { background: var(--accent); color: #fff; box-shadow: 0 3px 12px rgba(var(--accent-rgb), .35); }
.btn-login { display: none; }
.btn-join { font-family: var(--font-title); letter-spacing: .03em; }

.pnav-burger {
  display: inline-flex; align-items: center; justify-content: center;
  width: 2.2rem; height: 2.2rem; border-radius: 9px;
  border: 1px solid var(--border); background: color-mix(in srgb, var(--card) 70%, transparent);
  color: var(--text); cursor: pointer; flex: none;
}
.pnav-burger.on { color: var(--accent-l); border-color: color-mix(in srgb, var(--accent) 45%, var(--border)); }

.pnav-mobile {
  display: flex; flex-direction: column;
  padding: .6rem clamp(1.25rem, 4vw, 4rem) 1rem;
  border-top: 1px solid var(--border);
  background: color-mix(in srgb, var(--bg) 96%, transparent);
  backdrop-filter: blur(14px);
}
.pnav-mobile a {
  padding: .7rem .3rem; color: var(--muted); text-decoration: none;
  font-size: .95rem; font-weight: 600; font-family: var(--font-title); letter-spacing: .03em;
  border-bottom: 1px solid color-mix(in srgb, var(--border) 55%, transparent);
}
.pnav-mobile a:last-child { border-bottom: none; }
.pnav-mobile a.on { color: var(--accent-l); }
.pnav-mobile-sep { height: 1px; background: var(--border); margin: .3rem 0; }
.pnav-mobile-sep--switch { display: none; }
.game-switch--mobile { display: none; align-self: flex-start; margin-top: .2rem; }

.pnav-drop-enter-active, .pnav-drop-leave-active { transition: opacity .15s ease, transform .15s ease; }
.pnav-drop-enter-from, .pnav-drop-leave-to { opacity: 0; transform: translateY(-6px); }

/* Très petits écrans : le header (logo + switch + Rejoindre + burger) peut déborder.
   On masque le sélecteur de jeu dans l'en-tête (dupliqué dans le menu mobile) et on
   resserre les espacements pour garantir que tout tienne sans débordement horizontal. */
@media (max-width: 480px) {
  .pnav-inner { gap: .6rem; padding: 0 .9rem; }
  .pnav-right { gap: .4rem; }
  .game-switch { display: none; }
  .game-switch--mobile { display: inline-flex; }
  .pnav-mobile-sep--switch { display: block; }
  .brand-sub { display: none; }
}

@media (min-width: 960px) {
  .pnav-links { display: flex; }
  .btn-login { display: inline-flex; }
  .pnav-burger { display: none; }
  .pnav-mobile { display: none; }
}
</style>
