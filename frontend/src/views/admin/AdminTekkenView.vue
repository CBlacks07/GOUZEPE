<template>
  <AppLayout season-label="Admin Tekken">
    <div class="page-wrap tk-admin">
      <div class="mb-6">
        <RouterLink to="/admin" class="back">← Console</RouterLink>
        <h1 class="title">Pôle Tekken — administration</h1>
        <p class="sub">Le pôle combat du club est en préparation. Voici ce qui sera géré ici.</p>
      </div>

      <div class="feat-grid">
        <article class="feat">
          <ListOrderedIcon class="fic" />
          <h3>Ladder ELO</h3>
          <p>Classement basé sur les duels classés entre membres. Ajustements et reset de saison.</p>
          <span class="soon">Bientôt</span>
        </article>
        <article class="feat">
          <SwordsIcon class="fic" />
          <h3>Duels classés</h3>
          <p>Validation et historique des duels classés Tekken (résultats, contestations).</p>
          <span class="soon">Bientôt</span>
        </article>
        <article class="feat">
          <GamepadIcon class="fic" />
          <h3>Tournois Tekken</h3>
          <p>Brackets à élimination simple/double, via le moteur de tournois existant.</p>
          <span class="soon">Bientôt</span>
        </article>
      </div>

      <p class="note">
        Le moteur de tournois et de duels est déjà en place pour eFootball — l'activation de Tekken
        consistera surtout à taguer les compétitions par jeu et à brancher le ladder.
      </p>
    </div>
  </AppLayout>
</template>

<script setup>
import { RouterLink } from 'vue-router'
import AppLayout from '@/components/layout/AppLayout.vue'
import { ListOrderedIcon, SwordsIcon, GamepadIcon } from 'lucide-vue-next'
</script>

<style scoped>
.tk-admin { max-width: 60rem; }
.back { color: var(--muted); text-decoration: none; font-size: .85rem; font-weight: 600; }
.back:hover { color: var(--accent-l); }
.title { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .04em; font-size: 1.5rem; margin-top: .4rem; }
.sub { color: var(--muted); margin-top: .25rem; }

.feat-grid { display: grid; gap: 1rem; grid-template-columns: 1fr; }
.feat { position: relative; border: 1px solid var(--border); border-radius: 14px; background: var(--card); padding: 1.4rem 1.3rem; }
.fic { width: 1.8rem; height: 1.8rem; color: var(--accent); margin-bottom: .7rem; }
.feat h3 { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .03em; font-size: 1.15rem; margin: 0 0 .4rem; }
.feat p { color: var(--muted); line-height: 1.5; margin: 0 0 1rem; }
.soon { font-size: .68rem; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; color: #fff; background: var(--accent); padding: .2rem .6rem; border-radius: 999px; }
.note { color: var(--muted); font-size: .9rem; margin-top: 1.5rem; border-top: 1px solid var(--border); padding-top: 1rem; }

@media (min-width: 720px) { .feat-grid { grid-template-columns: repeat(3, 1fr); } }
</style>
