<template>
  <div class="hub">
    <PublicNav />

    <!-- Hero -->
    <section class="hub-hero">
      <div class="hub-hero-bg" aria-hidden="true">
        <video class="hub-hero-video" :key="heroVideo" :src="heroVideo" autoplay muted loop playsinline preload="metadata"></video>
        <div class="hub-hero-tint"></div>
      </div>
      <div class="hub-hero-content">
        <span class="eyebrow">Pôle combat</span>
        <h1 class="hub-title">Tekken</h1>
        <p class="hub-lead">
          L'arène versus du club. <strong>Ladder</strong>, <strong>duels classés</strong> et
          <strong>tournois à élimination</strong> arrivent. Prépare tes combos.
        </p>
        <div class="hub-cta">
          <span class="soon-badge">Bientôt disponible</span>
          <RouterLink to="/inscription" class="btn cta-lg">Rejoindre le club</RouterLink>
        </div>
      </div>
    </section>

    <!-- À venir -->
    <section class="section">
      <div class="section-head">
        <h2>Ce qui arrive</h2>
        <p>Le pôle Tekken est en préparation.</p>
      </div>

      <div class="feat-grid">
        <article class="feat-card">
          <SwordsIcon class="feat-ic" />
          <h3>Ladder classé</h3>
          <p>Un classement ELO alimenté par tes duels classés contre les autres membres.</p>
        </article>
        <article class="feat-card">
          <TrophyIcon class="feat-ic" />
          <h3>Tournois</h3>
          <p>Brackets à élimination simple et double — le format roi du versus.</p>
        </article>
        <article class="feat-card">
          <UsersIcon class="feat-ic" />
          <h3>Face-à-face</h3>
          <p>Historique et statistiques de tes confrontations, comme en eFootball.</p>
        </article>
      </div>
    </section>

    <section class="section join-band">
      <h2>Sois prêt pour le lancement</h2>
      <p>Inscris-toi dès maintenant et choisis Tekken comme jeu.</p>
      <RouterLink to="/inscription" class="btn-primary cta-lg">Devenir membre</RouterLink>
    </section>

    <PublicFooter />
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { SwordsIcon, TrophyIcon, UsersIcon } from 'lucide-vue-next'
import PublicNav from '@/components/public/PublicNav.vue'
import PublicFooter from '@/components/public/PublicFooter.vue'
import { useGameStore } from '@/stores/game'
import { useSiteSettings } from '@/stores/siteSettings'
import { mediaUrl } from '@/composables/useAPI'

const game = useGameStore()
const site = useSiteSettings()
const heroVideo = computed(() => mediaUrl(site.settings.tekken.heroVideo))
onMounted(() => game.set('tekken'))
</script>

<style scoped>
.hub { position: relative; z-index: 1; color: var(--text); }

.hub-hero { position: relative; min-height: 62vh; display: grid; align-items: center; overflow: hidden; }
.hub-hero-bg { position: absolute; inset: 0; z-index: 0; }
.hub-hero-video { width: 100%; height: 100%; object-fit: cover; opacity: .42; }
.hub-hero-tint { position: absolute; inset: 0; background: radial-gradient(60vw 60vh at 20% 15%, rgba(var(--accent-rgb), .32), transparent 60%), linear-gradient(180deg, rgba(3,8,22,.55), rgba(3,8,22,.92)); }
.hub-hero-content { position: relative; z-index: 1; padding: 3.5rem clamp(1.25rem, 4vw, 4rem); }
.eyebrow { display: inline-block; font-family: var(--font-title); font-weight: 700; letter-spacing: .26em; text-transform: uppercase; font-size: .72rem; color: var(--accent-l); padding: .3rem .8rem; border: 1px solid color-mix(in srgb, var(--accent) 45%, transparent); border-radius: 999px; margin-bottom: 1rem; }
.hub-title { font-family: var(--font-title); font-weight: 700; font-size: clamp(2.6rem, 7vw, 5rem); line-height: 1; text-transform: uppercase; letter-spacing: .02em; margin: 0 0 1rem; }
.hub-lead { max-width: 40rem; color: var(--muted); font-size: clamp(1rem, 2vw, 1.15rem); line-height: 1.6; margin: 0 0 1.75rem; }
.hub-lead strong { color: var(--text); }
.hub-cta { display: flex; flex-wrap: wrap; align-items: center; gap: .8rem; }
.cta-lg { padding: .8rem 1.6rem; font-size: 1rem; border-radius: .7rem; }
.soon-badge { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .08em; font-size: .8rem; color: #fff; background: var(--accent); padding: .55rem 1.1rem; border-radius: .7rem; box-shadow: 0 6px 18px rgba(var(--accent-rgb), .3); }

.section { padding: 3.5rem clamp(1.25rem, 4vw, 4rem); }
.section-head { margin-bottom: 1.75rem; }
.section-head h2 { font-family: var(--font-title); font-weight: 700; font-size: clamp(1.6rem, 4vw, 2.2rem); text-transform: uppercase; letter-spacing: .04em; margin: 0 0 .4rem; }
.section-head h2::after { content: ''; display: block; width: 3rem; height: 3px; margin-top: .6rem; border-radius: 3px; background: var(--accent); }
.section-head p { color: var(--muted); margin: 0; }

.feat-grid { display: grid; gap: 1rem; grid-template-columns: 1fr; }
.feat-card { border: 1px solid var(--border); border-radius: 14px; padding: 1.5rem 1.4rem; background: var(--card); }
.feat-ic { width: 2rem; height: 2rem; color: var(--accent); margin-bottom: .8rem; }
.feat-card h3 { font-family: var(--font-title); font-weight: 700; font-size: 1.25rem; text-transform: uppercase; letter-spacing: .03em; margin: 0 0 .5rem; }
.feat-card p { color: var(--muted); line-height: 1.55; margin: 0; }

.join-band { text-align: center; }
.join-band h2 { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .04em; font-size: clamp(1.6rem, 4vw, 2.2rem); margin: 0 0 .6rem; }
.join-band p { color: var(--muted); margin: 0 0 1.5rem; }

@media (min-width: 720px) { .feat-grid { grid-template-columns: repeat(3, 1fr); } }
</style>
