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
        <p class="c-lead" v-else-if="activeGame === 'tekken'">Classement ELO des duels classes.</p>
      </div>
    </section>

    <section class="section">
      <!-- Onglets par jeu -->
      <div class="game-tabs">
        <button :class="['gt', { on: activeGame === 'efoot' }]" @click="selectGame('efoot')">eFootball</button>
        <button :class="['gt', { on: activeGame === 'tekken' }]" @click="selectGame('tekken')">Tekken</button>
      </div>

      <!-- Tekken ladder -->
      <template v-if="activeGame === 'tekken'">
        <div class="section-head">
          <h2>Ladder ELO</h2>
        </div>
        <div v-if="loading" class="empty">Chargement...</div>
        <div v-else-if="!tekkenLadder.length" class="empty">Aucun joueur dans le ladder Tekken.</div>
        <div v-else class="overflow-x-auto tk-table-wrap">
          <table class="tk-table">
            <thead>
              <tr><th>#</th><th>Joueur</th><th>ELO</th><th>V</th><th>D</th><th>Serie</th></tr>
            </thead>
            <tbody>
              <tr v-for="(p, i) in tekkenLadder" :key="p.player_id">
                <td>
                  <span v-if="i === 0" class="rank-medal gold">1</span>
                  <span v-else-if="i === 1" class="rank-medal silver">2</span>
                  <span v-else-if="i === 2" class="rank-medal bronze">3</span>
                  <span v-else class="text-muted font-bold">{{ i + 1 }}</span>
                </td>
                <td class="font-semibold">{{ p.name }}</td>
                <td class="font-bold tk-elo">{{ p.elo }}</td>
                <td class="tk-w">{{ p.wins }}</td>
                <td class="tk-l">{{ p.losses }}</td>
                <td>
                  <span :class="p.streak > 0 ? 'tk-w' : p.streak < 0 ? 'tk-l' : 'text-muted'">
                    {{ p.streak > 0 ? 'W' + p.streak : p.streak < 0 ? 'L' + Math.abs(p.streak) : '--' }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>

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
                  <span v-if="i === 0" class="rank-medal rank-gold">1</span>
                  <span v-else-if="i === 1" class="rank-medal rank-silver">2</span>
                  <span v-else-if="i === 2" class="rank-medal rank-bronze">3</span>
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
const classed = computed(() => standings.value)
const tekkenLadder = ref([])

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

async function loadTekken() {
  loading.value = true
  try {
    const r = await fetch(resolveBaseURL() + '/tekken/ladder', { headers: { Accept: 'application/json' } })
    if (r.ok) { const d = await r.json(); tekkenLadder.value = d.ladder || [] }
  } catch (_) {}
  loading.value = false
}

function selectGame(g) {
  if (activeGame.value === g) return
  activeGame.value = g
  game.set(g)
  if (g === 'efoot') load()
  else loadTekken()
}

onMounted(() => {
  game.set(activeGame.value)
  if (activeGame.value === 'efoot') load()
  else loadTekken()
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

.rank-medal { display: inline-flex; align-items: center; justify-content: center; width: 22px; height: 22px; border-radius: 50%; font-size: 11px; font-weight: 800; }
.rank-gold { background: #ca8a04; color: #fff; }
.rank-silver { background: #94a3b8; color: #fff; }
.rank-bronze { background: #b45309; color: #fff; }

.tk-table-wrap { border: 1px solid var(--border); border-radius: 14px; background: var(--card); overflow-x: auto; }
.tk-table { width: 100%; border-collapse: collapse; font-size: .9rem; }
.tk-table th, .tk-table td { padding: .65rem .8rem; text-align: left; border-bottom: 1px solid var(--border); }
.tk-table th { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; font-size: .72rem; letter-spacing: .04em; color: var(--muted); }
.tk-table tbody tr:last-child td { border-bottom: none; }
.tk-table tbody tr:hover { background: color-mix(in srgb, var(--accent) 6%, transparent); }
.tk-elo { color: var(--accent-l); font-family: var(--font-title); font-weight: 800; }
.tk-w { color: var(--green, #22c55e); font-weight: 600; }
.tk-l { color: var(--red, #ef4444); font-weight: 600; }
.text-muted { color: var(--muted); }
.rank-medal.gold { background: linear-gradient(135deg, #ffd700, #f0c000); color: #1a1a2e; }
.rank-medal.silver { background: linear-gradient(135deg, #c0c0c0, #a8a8a8); color: #1a1a2e; }
.rank-medal.bronze { background: linear-gradient(135deg, #cd7f32, #b8722d); color: #1a1a2e; }
</style>
