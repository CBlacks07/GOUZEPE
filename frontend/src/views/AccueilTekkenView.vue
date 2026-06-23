<template>
  <AppLayout season-label="Tekken">
    <div class="home-page">
      <div class="home-content">

      <!-- HERO -->
      <section class="hero-section reveal">
        <div class="hero-club">
          <span class="hero-club-name">GOUZEPE</span>
          <span class="hero-club-label">Pole Combat</span>
        </div>

        <div class="hero-body">
          <div class="hero-left">
            <h2 class="hero-title">
              Bienvenue dans l'arene
              <span class="hero-accent">Tekken</span>
            </h2>
            <p class="hero-sub reveal delay-1">Ladder ELO, duels classes entre membres et tournois a elimination.</p>
            <div class="flex flex-wrap gap-2 reveal delay-2">
              <router-link to="/tekken-ladder" class="btn-primary">Voir le ladder</router-link>
              <router-link to="/profil" class="btn-ghost">Mon espace</router-link>
            </div>
          </div>
        </div>
      </section>

      <!-- Mon classement rapide -->
      <section v-if="myLadder" class="card reveal delay-1">
        <div class="mini-head">
          <h3 class="font-semibold">Mon classement</h3>
        </div>
        <div class="my-rank-row">
          <div class="my-rank-elo">
            <span class="my-rank-label">ELO</span>
            <span class="my-rank-val">{{ myLadder.elo }}</span>
          </div>
          <div class="my-rank-stats">
            <span class="my-stat"><span class="my-stat-n win">{{ myLadder.wins }}</span> V</span>
            <span class="my-stat"><span class="my-stat-n loss">{{ myLadder.losses }}</span> D</span>
            <span class="my-stat">Serie: <strong :class="myLadder.streak > 0 ? 'win' : myLadder.streak < 0 ? 'loss' : ''">
              {{ myLadder.streak > 0 ? 'W' + myLadder.streak : myLadder.streak < 0 ? 'L' + Math.abs(myLadder.streak) : '--' }}
            </strong></span>
            <span class="my-stat">Peak: <strong>{{ myLadder.peak_elo }}</strong></span>
          </div>
        </div>
      </section>

      <!-- Derniers duels -->
      <section class="card reveal delay-1">
        <div class="mini-head">
          <h3 class="font-semibold">Derniers duels</h3>
        </div>
        <div v-if="loadingDuels" class="text-sm" style="color:var(--muted)">Chargement...</div>
        <div v-else-if="!duels.length" class="text-sm" style="color:var(--muted)">Aucun duel enregistre.</div>
        <div v-else class="duels-feed">
          <div v-for="d in duels.slice(0, 6)" :key="d.id" class="duel-row">
            <span class="duel-date">{{ fmtDate(d.played_at) }}</span>
            <span :class="{ 'duel-winner': d.winner_id === d.p1_id }" class="duel-name">{{ d.p1_name }}</span>
            <span class="duel-score">{{ d.score_p1 }} - {{ d.score_p2 }}</span>
            <span :class="{ 'duel-winner': d.winner_id === d.p2_id }" class="duel-name right">{{ d.p2_name }}</span>
          </div>
        </div>
      </section>

      <!-- Quick links -->
      <div class="grid grid-cols-2 gap-4 reveal delay-2">
        <router-link to="/tekken-ladder" class="quick-card quick-card--tekken">
          <BarChart2Icon class="quick-card-icon-svg" />
          <span class="quick-card-label">Ladder</span>
          <span class="quick-card-desc">Classement ELO</span>
        </router-link>
        <router-link to="/profil" class="quick-card quick-card--profil">
          <UserIcon class="quick-card-icon-svg" />
          <span class="quick-card-label">Mon espace</span>
          <span class="quick-card-desc">Stats et parametres</span>
        </router-link>
      </div>

      </div>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import AppLayout from '@/components/layout/AppLayout.vue'
import { useAPI, resolveBaseURL } from '@/composables/useAPI'
import { useGameStore } from '@/stores/game'
import { BarChart2Icon, UserIcon } from 'lucide-vue-next'

const api = useAPI()
const game = useGameStore()

const myLadder = ref(null)
const duels = ref([])
const loadingDuels = ref(true)

function fmtDate(d) {
  if (!d) return ''
  return new Date(d).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short' })
}

onMounted(async () => {
  game.set('tekken')

  try {
    const { data } = await api.get('/me/player')
    const pid = data?.player?.player_id
    if (pid) {
      try {
        const base = resolveBaseURL()
        const r = await fetch(base + '/tekken/player/' + encodeURIComponent(pid) + '/stats', { headers: { Accept: 'application/json' } })
        if (r.ok) {
          const d = await r.json()
          myLadder.value = d.ladder || null
        }
      } catch (_) {}
    }
  } catch (_) {}

  try {
    const base = resolveBaseURL()
    const r = await fetch(base + '/tekken/duels?limit=6', { headers: { Accept: 'application/json' } })
    if (r.ok) {
      const d = await r.json()
      duels.value = d.duels || []
    }
  } catch (_) {}
  loadingDuels.value = false
})
</script>

<style scoped>
.home-page { min-height: 70vh; }
.home-content { display: flex; flex-direction: column; gap: 1.5rem; }

.hero-section {
  position: relative; overflow: hidden; border-radius: 20px;
  background: linear-gradient(135deg, rgba(255,90,44,.08), rgba(255,90,44,.02));
  border: 1px solid rgba(255,90,44,.2); padding: 2.5rem 2rem;
}
.hero-club { display: flex; align-items: baseline; gap: .5rem; margin-bottom: 1.25rem; }
.hero-club-name { font-family: var(--font-title); font-weight: 800; font-size: 1rem; letter-spacing: .1em; text-transform: uppercase; }
.hero-club-label { font-size: .75rem; color: var(--muted); font-weight: 600; text-transform: uppercase; letter-spacing: .08em; }
.hero-body { display: flex; align-items: center; gap: 2rem; flex-wrap: wrap; }
.hero-left { flex: 1; min-width: 260px; }
.hero-title { font-family: var(--font-title); font-weight: 800; font-size: clamp(1.6rem, 4vw, 2.4rem); line-height: 1.15; text-transform: uppercase; letter-spacing: .02em; margin: 0 0 .8rem; }
.hero-accent { color: var(--accent-l); display: block; }
.hero-sub { color: var(--muted); font-size: clamp(.88rem, 2vw, 1rem); line-height: 1.5; margin: 0 0 1.25rem; }

.mini-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: .8rem; }

/* Mon classement */
.my-rank-row { display: flex; align-items: center; gap: 2rem; flex-wrap: wrap; }
.my-rank-elo { display: flex; flex-direction: column; align-items: center; }
.my-rank-label { font-size: .6rem; font-weight: 800; text-transform: uppercase; letter-spacing: .1em; color: var(--muted); }
.my-rank-val { font-family: var(--font-title); font-weight: 900; font-size: 2.5rem; line-height: 1; color: var(--accent-l); }
.my-rank-stats { display: flex; gap: 1.5rem; flex-wrap: wrap; font-size: .88rem; color: var(--muted); }
.my-stat { display: flex; align-items: center; gap: .25rem; }
.my-stat-n { font-weight: 800; font-size: 1.1rem; }
.my-stat-n.win, .win { color: var(--green, #22c55e); }
.my-stat-n.loss, .loss { color: var(--red, #ef4444); }

/* Duels feed */
.duels-feed { display: flex; flex-direction: column; gap: .4rem; }
.duel-row {
  display: grid; grid-template-columns: 3.5rem 1fr auto 1fr; align-items: center; gap: .5rem;
  padding: .5rem .7rem; border-radius: 8px; background: rgba(148,163,184,.04); font-size: .85rem;
}
.duel-row:hover { background: rgba(148,163,184,.08); }
.duel-date { font-size: .7rem; color: var(--muted); }
.duel-name { font-weight: 600; }
.duel-name.right { text-align: right; }
.duel-score { font-family: var(--font-title); font-weight: 800; font-size: 1rem; text-align: center; min-width: 3rem; }
.duel-winner { color: var(--accent-l); }

/* Quick cards */
.quick-card {
  display: flex; flex-direction: column; gap: .5rem;
  padding: 1.25rem; border-radius: 16px; text-decoration: none;
  border: 1px solid var(--border); background: var(--card);
  transition: transform .18s, border-color .18s;
}
.quick-card:hover { transform: translateY(-3px); border-color: color-mix(in srgb, var(--accent) 50%, var(--border)); }
.quick-card-icon-svg { width: 1.5rem; height: 1.5rem; color: var(--accent); }
.quick-card-label { font-family: var(--font-title); font-weight: 700; font-size: 1rem; text-transform: uppercase; letter-spacing: .03em; }
.quick-card-desc { font-size: .75rem; color: var(--muted); }

.reveal { animation: riseIn .4s ease both; }
.delay-1 { animation-delay: 80ms; }
.delay-2 { animation-delay: 160ms; }
@keyframes riseIn { from{opacity:0;transform:translateY(10px)} to{opacity:1;transform:translateY(0)} }
</style>
