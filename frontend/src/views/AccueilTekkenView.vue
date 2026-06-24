<template>
  <AppLayout season-label="Tekken">
    <div class="home-page">
      <div class="home-content">

      <!-- HERO -->
      <section class="hero-section reveal">
        <div class="hero-club">
          <span class="hero-club-name">GOUZEPE</span>
          <span class="hero-club-label">{{ hero.eyebrow }}</span>
        </div>

        <!-- Bande photos defilante (si configuree) -->
        <div v-if="strip.length" class="hero-photos-track-wrap" aria-hidden="true">
          <div class="hero-photos-track">
            <div
              v-for="(src, i) in [...strip, ...strip]"
              :key="src + i"
              class="hero-photo-frame"
              :style="{ '--fi': i % strip.length }"
            >
              <div class="hero-photo-clip">
                <img :src="src" alt="" class="hero-photo-img" loading="lazy" />
              </div>
            </div>
          </div>
        </div>

        <div class="hero-body">
          <div class="hero-left">
            <h2 class="hero-title">
              {{ hero.title }}
              <span v-if="hero.titleAccent" class="hero-accent">{{ hero.titleAccent }}</span>
            </h2>
            <p class="hero-sub reveal delay-1">{{ hero.lead }}</p>
            <div class="flex flex-wrap gap-2 reveal delay-2">
              <router-link to="/tekken-ladder" class="btn-primary">{{ hero.ctaPrimary }}</router-link>
              <router-link to="/profil" class="btn-ghost">Mon espace</router-link>
            </div>
          </div>

          <!-- Visuel rotatif (si configure) -->
          <div v-if="heroSlides.length" class="hero-visual" aria-hidden="true">
            <div class="hero-ring hero-ring-outer"></div>
            <div class="hero-ring hero-ring-inner"></div>
            <div class="hero-glow"></div>
            <Transition name="hero-img" mode="out-in">
              <div v-if="heroSlides[heroSlideIndex]" :key="heroSlideIndex" :class="['hero-img-wrap', heroSlides[heroSlideIndex].anim]">
                <img :src="heroSlides[heroSlideIndex].src" :alt="heroSlides[heroSlideIndex].alt" class="hero-slide-img" />
              </div>
            </Transition>
            <div class="hero-dots">
              <span v-for="(_, i) in heroSlides" :key="i" :class="['hero-dot', { active: i === heroSlideIndex }]" />
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

      <!-- Tournoi en cours -->
      <section v-if="liveTournament" class="card reveal delay-2">
        <div class="mini-head">
          <h3 class="font-semibold">Tournoi en cours</h3>
          <router-link to="/tekken-tournois" class="text-xs font-semibold" style="color:var(--accent-l)">Voir tout</router-link>
        </div>
        <router-link to="/tekken-tournois" class="live-tournament-banner">
          <span class="live-dot-sm"></span>
          <span class="font-semibold">{{ liveTournament.name }}</span>
          <span class="text-xs" style="color:var(--muted)">{{ liveTournament.participants_count || 0 }} participants</span>
        </router-link>
      </section>

      <!-- Quick links -->
      <div class="grid grid-cols-3 gap-4 reveal delay-2">
        <router-link to="/tekken-ladder" class="quick-card quick-card--tekken">
          <BarChart2Icon class="quick-card-icon-svg" />
          <span class="quick-card-label">Ladder</span>
          <span class="quick-card-desc">Classement ELO</span>
        </router-link>
        <router-link to="/tekken-tournois" class="quick-card quick-card--tekken">
          <TrophyIcon class="quick-card-icon-svg" />
          <span class="quick-card-label">Tournois</span>
          <span class="quick-card-desc">Brackets et scores</span>
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
import { ref, computed, onMounted, onUnmounted } from 'vue'
import AppLayout from '@/components/layout/AppLayout.vue'
import { useAPI, resolveBaseURL, mediaUrl } from '@/composables/useAPI'
import { useGameStore } from '@/stores/game'
import { useSiteSettings, DEFAULTS } from '@/stores/siteSettings'
import { BarChart2Icon, UserIcon, TrophyIcon } from 'lucide-vue-next'

const api = useAPI()
const game = useGameStore()
const site = useSiteSettings()

const myLadder = ref(null)
const duels = ref([])
const loadingDuels = ref(true)
const liveTournament = ref(null)

// Reglages d'apparence de l'accueil Tekken (avec valeurs par defaut)
const hero = computed(() => ({ ...DEFAULTS.tekkenHome, ...(site.settings.tekkenHome || {}) }))
const strip = computed(() => (site.settings.tekkenHome?.slides || []).filter(Boolean).map(mediaUrl))

const HERO_ANIMS = ['slide-float', 'slide-zoom', 'slide-spin', 'slide-drift']
const heroSlides = ref([])
const heroSlideIndex = ref(0)
let heroSlideTimer = null

function fmtDate(d) {
  if (!d) return ''
  return new Date(d).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short' })
}

onMounted(async () => {
  game.set('tekken')

  const cmsHero = (site.settings.tekkenHome?.hero || []).filter(Boolean)
  heroSlides.value = cmsHero.map((src, i) => ({ src: mediaUrl(src), alt: `Tekken ${i + 1}`, anim: HERO_ANIMS[i % HERO_ANIMS.length] }))
  if (heroSlides.value.length > 1) {
    heroSlideTimer = setInterval(() => {
      heroSlideIndex.value = (heroSlideIndex.value + 1) % heroSlides.value.length
    }, 3600)
  }

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

  try {
    const { data } = await api.get('/tekken/tournaments')
    const live = (data.tournaments || []).find((t) => t.status === 'live')
    if (live) liveTournament.value = live
  } catch (_) {}
})

onUnmounted(() => {
  if (heroSlideTimer) clearInterval(heroSlideTimer)
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

/* === Bande photos defilante === */
.hero-photos-track-wrap {
  overflow: hidden; padding: 10px 0; margin-bottom: 1.25rem;
  mask-image: linear-gradient(to right, transparent 0%, black 6%, black 94%, transparent 100%);
  -webkit-mask-image: linear-gradient(to right, transparent 0%, black 6%, black 94%, transparent 100%);
}
.hero-photos-track-wrap:hover .hero-photos-track { animation-play-state: paused; }
.hero-photos-track { display: flex; gap: 14px; width: max-content; animation: photo-scroll 28s linear infinite; }
@keyframes photo-scroll { 0% { transform: translateX(0); } 100% { transform: translateX(-50%); } }
.hero-photo-frame {
  flex: 0 0 clamp(90px, 10vw, 130px); height: clamp(90px, 10vw, 130px);
  animation: photo-float calc(3s + var(--fi, 0) * 0.4s) ease-in-out infinite alternate;
  animation-delay: calc(var(--fi, 0) * -0.35s); will-change: transform; z-index: 1;
}
.hero-photo-frame:hover { animation-play-state: paused; z-index: 5; }
.hero-photo-frame:hover .hero-photo-clip {
  box-shadow: 0 10px 32px color-mix(in srgb, var(--accent) 40%, transparent);
  border-color: color-mix(in srgb, var(--accent) 50%, transparent); transform: scale(1.1);
}
.hero-photo-clip {
  width: 100%; height: 100%; border-radius: 12px; overflow: hidden;
  border: 2px solid rgba(255,255,255,.07); box-shadow: 0 6px 20px rgba(0,0,0,.45);
  transition: transform .3s ease, box-shadow .3s ease, border-color .3s ease;
  background: #fff; display: flex; align-items: center; justify-content: center;
}
@keyframes photo-float {
  0% { transform: translateY(-5px) rotate(-1.5deg); }
  50% { transform: translateY(2px) rotate(.5deg); }
  100% { transform: translateY(6px) rotate(1.8deg); }
}
.hero-photo-img { width: 100%; height: 100%; object-fit: contain; object-position: center; display: block; background: #fff; }

/* === Visuel rotatif === */
.hero-visual {
  flex: 0 0 clamp(160px, 26vw, 300px); height: clamp(160px, 26vw, 300px);
  position: relative; display: flex; align-items: center; justify-content: center;
}
.hero-ring { position: absolute; inset: 0; border-radius: 50%; border: 1.5px solid transparent; pointer-events: none; }
.hero-ring-outer {
  border-color: color-mix(in srgb, var(--accent) 28%, transparent);
  animation: ring-cw 12s linear infinite; box-shadow: 0 0 18px color-mix(in srgb, var(--accent) 14%, transparent);
}
.hero-ring-outer::before {
  content: ''; position: absolute; top: -4px; left: 40%; width: 8px; height: 8px; border-radius: 50%;
  background: var(--accent); box-shadow: 0 0 10px 3px color-mix(in srgb, var(--accent) 60%, transparent);
}
.hero-ring-inner { inset: 18px; border-color: color-mix(in srgb, var(--accent) 18%, transparent); animation: ring-ccw 9s linear infinite; }
.hero-glow {
  position: absolute; inset: 15%; border-radius: 50%;
  background: radial-gradient(circle, color-mix(in srgb, var(--accent) 20%, transparent) 0%, transparent 72%);
  animation: glow-pulse 3.5s ease-in-out infinite; pointer-events: none;
}
.hero-img-wrap {
  position: relative; z-index: 2; width: calc(100% - 44px); height: calc(100% - 44px);
  border-radius: 50%; overflow: hidden; box-shadow: 0 0 32px color-mix(in srgb, var(--accent) 30%, transparent);
}
.hero-slide-img { width: 100%; height: 100%; object-fit: cover; object-position: center; display: block; }
.slide-float .hero-slide-img { animation: float-anim 4s ease-in-out infinite; }
.slide-zoom .hero-slide-img { animation: zoom-pulse 3.5s ease-in-out infinite; }
.slide-spin .hero-slide-img { animation: spin-float 7s ease-in-out infinite; }
.slide-drift .hero-slide-img { animation: drift-anim 5s ease-in-out infinite; }
.hero-dots { position: absolute; bottom: -18px; left: 50%; transform: translateX(-50%); display: flex; gap: 6px; z-index: 3; }
.hero-dot { width: 6px; height: 6px; border-radius: 50%; background: rgba(148,163,184,.4); transition: background .3s, transform .3s; }
.hero-dot.active { background: var(--accent); transform: scale(1.35); box-shadow: 0 0 6px color-mix(in srgb, var(--accent) 60%, transparent); }
.hero-img-enter-active { animation: img-in .65s cubic-bezier(.22,1,.36,1) both; }
.hero-img-leave-active { animation: img-out .4s ease both; }
@keyframes ring-cw { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
@keyframes ring-ccw { from { transform: rotate(0deg); } to { transform: rotate(-360deg); } }
@keyframes glow-pulse { 0%,100% { opacity: .6; transform: scale(1); } 50% { opacity: 1; transform: scale(1.12); } }
@keyframes float-anim { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-14px); } }
@keyframes zoom-pulse { 0%,100% { transform: scale(1); } 50% { transform: scale(1.07); } }
@keyframes spin-float { 0% { transform: translateY(0) rotate(0); } 25% { transform: translateY(-8px) rotate(5deg); } 50% { transform: translateY(-14px) rotate(0); } 75% { transform: translateY(-6px) rotate(-5deg); } 100% { transform: translateY(0) rotate(0); } }
@keyframes drift-anim { 0%,100% { transform: translateX(0); } 50% { transform: translateX(10px); } }
@keyframes img-in { from { opacity: 0; transform: scale(.88) translateY(14px); } to { opacity: 1; transform: scale(1) translateY(0); } }
@keyframes img-out { from { opacity: 1; transform: scale(1); } to { opacity: 0; transform: scale(1.06) translateY(-10px); } }
@media (max-width: 540px) { .hero-visual { display: none; } }

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

.live-tournament-banner {
  display: flex; align-items: center; gap: .6rem; padding: .7rem 1rem;
  border-radius: 10px; border: 1px solid rgba(255,90,44,.2);
  background: rgba(255,90,44,.05); text-decoration: none; color: var(--text);
  transition: border-color .2s, background .2s;
}
.live-tournament-banner:hover { border-color: rgba(255,90,44,.4); background: rgba(255,90,44,.08); }
.live-dot-sm { width: 6px; height: 6px; border-radius: 50%; background: #22c55e; animation: pulse 1.5s infinite; flex-shrink: 0; }
@keyframes pulse { 0%,100%{opacity:1} 50%{opacity:.4} }

.reveal { animation: riseIn .4s ease both; }
.delay-1 { animation-delay: 80ms; }
.delay-2 { animation-delay: 160ms; }
@keyframes riseIn { from{opacity:0;transform:translateY(10px)} to{opacity:1;transform:translateY(0)} }
</style>
