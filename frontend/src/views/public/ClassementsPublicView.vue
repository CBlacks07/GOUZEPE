<template>
  <div class="hub">
    <PublicNav />

    <section class="c-hero">
      <div class="c-hero-tint" aria-hidden="true"></div>
      <div class="c-hero-content">
        <span class="eyebrow">{{ activeGame === 'tekken' ? 'Tekken' : 'eFootball' }}</span>
        <h1 class="c-title">Classement — {{ activeGame === 'tekken' ? 'Tekken' : 'eFootball' }}</h1>
        <p class="c-lead" v-if="activeGame === 'efoot' && season">
          {{ cleanName(season.name) }}<span v-if="daysCount"> · {{ daysCount }} journée(s)</span>
        </p>
        <p class="c-lead" v-else-if="activeGame === 'tekken'">Le ladder Tekken est en préparation.</p>
      </div>
    </section>

    <section class="section">
      <!-- Onglets par jeu -->
      <div class="game-tabs">
        <button :class="['gt', { on: activeGame === 'efoot' }]" @click="selectGame('efoot')">eFootball</button>
        <button :class="['gt', { on: activeGame === 'tekken' }]" @click="selectGame('tekken')">Tekken</button>
      </div>

      <!-- Tekken : à venir -->
      <div v-if="activeGame === 'tekken'" class="soon-box">
        <TrophyIcon class="soon-ic" />
        <h3>Ladder Tekken — bientôt</h3>
        <p>Le classement Tekken (duels classés + tournois) arrive prochainement. En attendant, consulte le classement eFootball.</p>
        <RouterLink to="/inscription" class="btn-primary cta-lg">Devenir membre</RouterLink>
      </div>

      <!-- eFootball -->
      <template v-else>
        <div class="section-head">
          <h2>Top 10</h2>
          <p v-if="!loading">Minimum {{ threshold }} journée(s) jouée(s) pour être classé</p>
        </div>

        <div v-if="loading" class="empty">Chargement…</div>
        <div v-else-if="!classed.length" class="empty">Aucun joueur classé pour le moment.</div>
        <div v-else class="table-shell">
          <table class="data-table">
            <thead>
              <tr>
                <th class="text-center w-12">Rang</th>
                <th>Joueur</th>
                <th class="text-center">Total</th>
                <th class="text-center">Particip.</th>
                <th class="text-center">Moyenne</th>
                <th class="text-center">Titres</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(r, i) in classed" :key="r.id">
                <td class="text-center">
                  <span v-if="i === 0">🥇</span>
                  <span v-else-if="i === 1">🥈</span>
                  <span v-else-if="i === 2">🥉</span>
                  <span v-else style="color:var(--muted)">{{ i + 1 }}</span>
                </td>
                <td>
                  <div class="pl-name">{{ r.name || r.id }}</div>
                  <div v-if="r.name && r.id && r.name !== r.id" class="pl-id">{{ r.id }}</div>
                </td>
                <td class="text-center font-bold">{{ r.total }}</td>
                <td class="text-center">{{ r.participations }}</td>
                <td class="text-center">{{ Number(r.moyenne || 0).toFixed(2) }}</td>
                <td class="text-center" style="color:var(--muted)">{{ (r.won_d1 || 0) }}/{{ (r.won_d2 || 0) }}</td>
              </tr>
            </tbody>
          </table>
        </div>

        <p v-if="!loading && classedCount > classed.length" class="members-note">
          Classement complet ({{ classedCount }} joueurs classés) et détails par tournoi
          <RouterLink to="/login" class="members-link">dans l'espace membre</RouterLink>.
        </p>
      </template>
    </section>

    <section v-if="activeGame === 'efoot'" class="section join-band">
      <h2>Veux-tu y figurer ?</h2>
      <p>Rejoins le club et grimpe au classement.</p>
      <RouterLink to="/inscription" class="btn-primary cta-lg">Devenir membre</RouterLink>
    </section>

    <PublicFooter />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { TrophyIcon } from 'lucide-vue-next'
import PublicNav from '@/components/public/PublicNav.vue'
import PublicFooter from '@/components/public/PublicFooter.vue'
import { useGameStore } from '@/stores/game'
import { resolveBaseURL } from '@/composables/useAPI'

const game = useGameStore()
const activeGame = ref(game.isTekken ? 'tekken' : 'efoot')
const loading = ref(true)
const season = ref(null)
const daysCount = ref(0)
const standings = ref([])

const threshold = ref(0)
const classedCount = ref(0)
const classed = computed(() => standings.value) // le serveur renvoie déjà le Top 10 des classés

function cleanName(n) { return String(n || '').replace(/^"+|"+$/g, '') }

async function load() {
  loading.value = true
  try {
    const r = await fetch(resolveBaseURL() + '/public/standings?game=' + activeGame.value, { headers: { Accept: 'application/json' } })
    if (r.ok) {
      const d = await r.json()
      season.value = d.season
      daysCount.value = d.days_count || 0
      threshold.value = d.threshold || 0
      classedCount.value = d.classed_count || 0
      standings.value = d.standings || []
    }
  } catch (_) {}
  loading.value = false
}

function selectGame(g) {
  if (activeGame.value === g) return
  activeGame.value = g
  game.set(g)            // synchronise l'accent (bleu / orange)
  if (g === 'efoot') load()
}

onMounted(() => {
  game.set(activeGame.value)
  if (activeGame.value === 'efoot') load()
  else loading.value = false
})
</script>

<style scoped>
.hub { position: relative; z-index: 1; color: var(--text); }

.c-hero { position: relative; overflow: hidden; padding: 3.5rem clamp(1.25rem, 4vw, 4rem); }
.c-hero-tint { position: absolute; inset: 0; background: radial-gradient(60vw 50vh at 20% 0%, rgba(var(--accent-rgb), .22), transparent 60%); }
.c-hero-content { position: relative; z-index: 1; }
.eyebrow { display: inline-block; font-family: var(--font-title); font-weight: 700; letter-spacing: .26em; text-transform: uppercase; font-size: .72rem; color: var(--accent-l); padding: .3rem .8rem; border: 1px solid color-mix(in srgb, var(--accent) 45%, transparent); border-radius: 999px; margin-bottom: 1rem; }
.c-title { font-family: var(--font-title); font-weight: 700; font-size: clamp(2.2rem, 5vw, 3.6rem); text-transform: uppercase; letter-spacing: .02em; margin: 0 0 .6rem; }
.c-lead { color: var(--muted); margin: 0; }

.section { padding: 1rem clamp(1.25rem, 4vw, 4rem) 3.5rem; }

.game-tabs { display: inline-flex; gap: .4rem; padding: 4px; border: 1px solid var(--border); border-radius: 999px; background: var(--card); margin-bottom: 1.5rem; }
.gt { padding: .4rem 1.1rem; border: none; background: transparent; color: var(--muted); font-family: var(--font-title); font-weight: 700; letter-spacing: .03em; text-transform: uppercase; font-size: .82rem; border-radius: 999px; cursor: pointer; transition: all .18s; }
.gt.on { background: var(--accent); color: #fff; box-shadow: 0 3px 12px rgba(var(--accent-rgb), .35); }

.section-head { margin-bottom: 1.25rem; display: flex; flex-wrap: wrap; align-items: baseline; justify-content: space-between; gap: .5rem; }
.section-head h2 { font-family: var(--font-title); font-weight: 700; font-size: clamp(1.4rem, 3vw, 2rem); text-transform: uppercase; letter-spacing: .04em; margin: 0; }
.section-head p { color: var(--muted); margin: 0; font-size: .85rem; }

.table-shell { border: 1px solid var(--border); border-radius: 14px; background: var(--card); overflow-x: auto; }
.table-shell :deep(.data-table th),
.table-shell :deep(.data-table td) { text-align: left; }
.table-shell :deep(.data-table th.text-center),
.table-shell :deep(.data-table td.text-center) { text-align: center !important; }
.pl-name { font-weight: 600; }
.pl-id { font-size: .72rem; color: var(--muted); letter-spacing: .02em; }
.empty { color: var(--muted); }
.members-note { margin-top: 1rem; color: var(--muted); font-size: .9rem; }
.members-link { color: var(--accent-l); text-decoration: none; font-weight: 600; }
.members-link:hover { text-decoration: underline; }

.soon-box { text-align: center; border: 1px solid var(--border); border-radius: 16px; background: var(--card); padding: 3rem 1.5rem; }
.soon-ic { width: 2.4rem; height: 2.4rem; color: var(--accent); margin: 0 auto .8rem; }
.soon-box h3 { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .04em; font-size: 1.4rem; margin: 0 0 .5rem; }
.soon-box p { color: var(--muted); max-width: 32rem; margin: 0 auto 1.5rem; }

.join-band { text-align: center; }
.join-band h2 { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .04em; font-size: clamp(1.6rem, 4vw, 2.2rem); margin: 0 0 .6rem; }
.join-band p { color: var(--muted); margin: 0 0 1.5rem; }
.cta-lg { padding: .8rem 1.6rem; font-size: 1rem; border-radius: .7rem; }
</style>
