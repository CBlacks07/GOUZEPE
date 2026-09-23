<template>
  <div class="palm">
    <PublicNav />

    <section class="section">
      <div class="section-head">
        <h1>Palmarès</h1>
        <p>Les champions du club, saison après saison.</p>
      </div>

      <div class="game-tabs" role="tablist" aria-label="Jeu">
        <button role="tab" :aria-selected="String(activeGame === 'efoot')" :class="['gt', { on: activeGame === 'efoot' }]" @click="selectGame('efoot')">eFootball</button>
        <button role="tab" :aria-selected="String(activeGame === 'tekken')" :class="['gt', { on: activeGame === 'tekken' }]" @click="selectGame('tekken')">Tekken</button>
      </div>

      <div v-if="loading" class="empty">Chargement…</div>
      <div v-else-if="!seasons.length" class="empty">Aucune saison enregistrée.</div>

      <div v-else class="seasons">
        <article v-for="s in seasons" :key="s.id" class="season-card">
          <header class="season-head">
            <div>
              <h2 class="season-name">{{ cleanName(s.name) }}</h2>
              <p class="season-meta">
                {{ activeGame === 'tekken' ? s.tekken?.journees || 0 : s.journees }} journée(s)
                <span v-if="s.is_closed" class="tag closed">Terminée</span>
                <span v-else class="tag live">En cours</span>
              </p>
            </div>
            <TrophyIcon class="season-trophy" />
          </header>

          <!-- Tekken : championnat par journées (points à la victoire) -->
          <template v-if="activeGame === 'tekken'">
            <div v-if="!s.tekken?.podium?.length" class="season-empty">Pas encore de journée Tekken terminée.</div>
            <div v-else class="podium">
              <div v-for="(p, i) in s.tekken.podium" :key="p.id || p.name" class="pod-row" :class="['pos-' + (i + 1)]">
                <span class="pod-medal">{{ i + 1 }}</span>
                <div class="min-w-0 flex-1">
                  <div class="pod-name">{{ p.id || p.name }}</div>
                  <div class="pod-sub">{{ p.name }}<template v-if="p.titles"> · {{ p.titles }} titre(s)</template></div>
                </div>
                <div class="pod-stat">
                  <span class="pod-moy">{{ p.points }}</span>
                  <span class="pod-moy-l">points</span>
                </div>
              </div>
            </div>
          </template>

          <div v-else-if="!s.podium.length" class="season-empty">Pas encore de joueur classé.</div>
          <div v-else class="podium">
            <div v-for="(p, i) in s.podium" :key="p.id" class="pod-row" :class="['pos-' + (i + 1)]">
              <span class="pod-medal">{{ ['1','2','3'][i] }}</span>
              <div class="min-w-0 flex-1">
                <div class="pod-name">{{ p.id }}</div>
                <div class="pod-sub">{{ p.name }}</div>
              </div>
              <div class="pod-stat">
                <span class="pod-moy">{{ Number(p.moyenne).toFixed(2) }}</span>
                <span class="pod-moy-l">moyenne</span>
              </div>
            </div>
          </div>
        </article>
      </div>
    </section>

    <PublicFooter />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useGameStore } from '@/stores/game'
import PublicNav from '@/components/public/PublicNav.vue'
import PublicFooter from '@/components/public/PublicFooter.vue'
import { resolveBaseURL } from '@/composables/useAPI'
import { TrophyIcon } from 'lucide-vue-next'

const loading = ref(true)
const seasons = ref([])
const game = useGameStore()
const activeGame = ref(game.isTekken ? 'tekken' : 'efoot')
function selectGame(g) {
  activeGame.value = g
  game.set(g)
}

function cleanName(n) { return String(n || '').replace(/^"|"$/g, '') }

onMounted(async () => {
  try {
    const r = await fetch(resolveBaseURL() + '/public/palmares', { headers: { Accept: 'application/json' } })
    if (r.ok) { const d = await r.json(); seasons.value = d.seasons || [] }
  } catch (_) {}
  loading.value = false
})
</script>

<style scoped>
.palm { position: relative; z-index: 1; color: var(--text); min-height: 100dvh; }
.section { padding: 3rem clamp(1.25rem, 4vw, 4rem); }
.section-head { margin-bottom: 2rem; }
.section-head h1 { font-family: var(--font-title); font-weight: 700; font-size: clamp(2rem, 5vw, 3rem); text-transform: uppercase; letter-spacing: .03em; margin: 0 0 .4rem; }
.section-head h1::after { content: ''; display: block; width: 3rem; height: 3px; margin-top: .6rem; border-radius: 3px; background: var(--accent); }
.section-head p { color: var(--muted); margin: 0; }
.empty { color: var(--muted); padding: 2rem 0; }

.game-tabs { display: inline-flex; gap: .4rem; padding: 4px; border: 1px solid var(--border); border-radius: 999px; background: var(--card); margin-bottom: 1.5rem; }
.gt { padding: .45rem 1.2rem; border: none; background: transparent; color: var(--muted); font-family: var(--font-title); font-weight: 700; letter-spacing: .03em; text-transform: uppercase; font-size: .84rem; border-radius: 999px; cursor: pointer; transition: all .18s; }
.gt.on { background: var(--accent); color: #fff; box-shadow: 0 3px 12px rgba(var(--accent-rgb), .35); }
.seasons { display: grid; gap: 1.25rem; grid-template-columns: 1fr; }
@media (min-width: 720px) { .seasons { grid-template-columns: 1fr 1fr; } }
@media (min-width: 1200px) { .seasons { grid-template-columns: repeat(3, 1fr); } }

.season-card { border: 1px solid var(--border); border-radius: 16px; background: var(--card); padding: 1.1rem 1.25rem 1.25rem; }
.season-head { display: flex; align-items: flex-start; justify-content: space-between; gap: .5rem; margin-bottom: 1rem; }
.season-name { font-family: var(--font-title); font-weight: 700; font-size: 1.15rem; margin: 0; }
.season-meta { font-size: .8rem; color: var(--muted); margin: .2rem 0 0; display: flex; align-items: center; gap: .5rem; flex-wrap: wrap; }
.tag { font-size: .58rem; font-weight: 800; text-transform: uppercase; letter-spacing: .05em; padding: .1rem .45rem; border-radius: 999px; }
.tag.closed { color: var(--muted); background: color-mix(in srgb, var(--muted) 14%, transparent); }
.tag.live { color: #22c55e; background: color-mix(in srgb, #22c55e 15%, transparent); }
.season-trophy { width: 1.6rem; height: 1.6rem; color: #eab308; flex: none; }
.season-empty { color: var(--muted); font-size: .85rem; padding: .5rem 0; }

.podium { display: flex; flex-direction: column; gap: .45rem; }
.pod-row { display: flex; align-items: center; gap: .7rem; padding: .55rem .65rem; border-radius: 10px; border: 1px solid color-mix(in srgb, var(--border) 55%, transparent); }
.pod-row.pos-1 { border-color: color-mix(in srgb, #eab308 45%, var(--border)); background: color-mix(in srgb, #eab308 8%, transparent); }
.pod-medal { flex: none; width: 1.7rem; height: 1.7rem; display: grid; place-items: center; border-radius: 50%; font-weight: 800; font-size: .8rem; color: #fff; }
.pos-1 .pod-medal { background: linear-gradient(135deg, #fde68a, #ca8a04); }
.pos-2 .pod-medal { background: #94a3b8; }
.pos-3 .pod-medal { background: #b45309; }
.pod-name { font-weight: 700; font-size: .92rem; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.pod-sub { font-size: .72rem; color: var(--muted); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.pod-stat { flex: none; text-align: right; }
.pod-moy { display: block; font-family: var(--font-title); font-weight: 800; font-size: 1rem; line-height: 1; }
.pos-1 .pod-moy { color: #ca8a04; }
.pod-moy-l { font-size: .56rem; text-transform: uppercase; letter-spacing: .05em; color: var(--muted); }
</style>
