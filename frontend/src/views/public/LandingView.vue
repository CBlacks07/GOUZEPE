<template>
  <div class="landing">

    <PublicNav />

    <!-- ── Hero ── -->
    <section id="top" class="hero">
      <div class="hero-bg" aria-hidden="true">
        <video class="hero-video" :key="heroVideo" :src="heroVideo" autoplay muted loop playsinline preload="metadata" poster="/assets/fond.png"></video>
        <div class="hero-tint"></div>
      </div>

      <div class="hero-content">
        <span class="hero-eyebrow">{{ s.home.eyebrow }}</span>
        <h1 class="hero-title">{{ s.home.title }}</h1>
        <p class="hero-lead">{{ s.home.lead }}</p>
        <div class="hero-cta">
          <RouterLink to="/inscription" class="btn-primary cta-lg">{{ s.home.ctaPrimary }}</RouterLink>
          <a href="#univers" class="btn cta-lg">{{ s.home.ctaSecondary }}</a>
        </div>

        <div class="hero-stats">
          <div class="hstat"><span class="hstat-n">{{ stats.players }}</span><span class="hstat-l">Joueurs</span></div>
          <div class="hstat"><span class="hstat-n">{{ stats.tournaments }}</span><span class="hstat-l">Tournois</span></div>
          <div class="hstat"><span class="hstat-n">2</span><span class="hstat-l">Jeux</span></div>
        </div>
      </div>
    </section>

    <!-- ── Les deux univers ── -->
    <section id="univers" class="section univers">
      <div class="section-head">
        <h2>Deux univers, un seul club</h2>
        <p>Choisis ton terrain de jeu.</p>
      </div>

      <div class="univers-grid">
        <article class="uni-card uni-efoot" @mouseenter="game.set('efoot')">
          <img class="uni-media" src="/fonds/efootball-bg.png" alt="eFootball" loading="lazy" />
          <div class="uni-body">
            <span class="uni-tag">eFootball</span>
            <h3>{{ s.efoot.cardTitle }}</h3>
            <p>{{ s.efoot.cardText }}</p>
            <RouterLink to="/efootball" class="btn-primary">Entrer <ArrowRightIcon class="w-4 h-4" /></RouterLink>
          </div>
        </article>

        <article class="uni-card uni-tekken" @mouseenter="game.set('tekken')">
          <img class="uni-media" src="/fonds/tekken-bg.png" alt="Tekken" loading="lazy" />
          <div class="uni-body">
            <span class="uni-tag tekken">Tekken</span>
            <h3>{{ s.tekken.cardTitle }}</h3>
            <p>{{ s.tekken.cardText }}</p>
            <RouterLink to="/tekken" class="btn-primary">Découvrir <ArrowRightIcon class="w-4 h-4" /></RouterLink>
          </div>
        </article>
      </div>
    </section>

    <!-- ── Compétition (eFootball / Tekken) ── -->
    <section id="resultats" class="section">
      <div class="section-head">
        <h2>Compétition</h2>
        <p>Résultats &amp; tournois du club.</p>
      </div>

      <div class="comp-tabs">
        <button :class="['ct', { on: feedGame === 'efoot' }]" @click="setFeed('efoot')">eFootball</button>
        <button :class="['ct', { on: feedGame === 'tekken' }]" @click="setFeed('tekken')">Tekken</button>
      </div>

      <!-- eFootball -->
      <template v-if="feedGame === 'efoot'">
        <h3 class="comp-sub">Derniers résultats <span v-if="latestDay?.day" class="comp-sub-day">· {{ fmtDate(latestDay.day) }}</span></h3>
        <div class="res-grid">
          <!-- Champions -->
          <div class="champs-col">
            <div v-if="latestDay?.champions?.d1?.id" class="champ-card">
              <TrophyIcon class="champ-crown-icon" />
              <div class="champ-meta"><span class="champ-div">Champion D1</span><strong>{{ latestDay.champions.d1.id }}</strong></div>
            </div>
            <div v-if="latestDay?.champions?.d2?.id" class="champ-card">
              <TrophyIcon class="champ-crown-icon" />
              <div class="champ-meta"><span class="champ-div">Champion D2</span><strong>{{ latestDay.champions.d2.id }}</strong></div>
            </div>
            <div v-if="!latestDay?.champions?.d1?.id && !latestDay?.champions?.d2?.id" class="champ-empty">
              Aucun champion enregistré.
            </div>
          </div>
          <!-- Top D1 -->
          <div class="mini-board">
            <div class="mini-head">Top D1</div>
            <div v-if="!topD1.length" class="mini-empty">Aucune donnée.</div>
            <div v-for="(r, i) in topD1" :key="r.id" class="mini-row">
              <span class="mini-rank">{{ i + 1 }}</span>
              <span class="mini-name">{{ r.id }}</span>
              <span class="mini-pts">{{ r.PTS }} pts</span>
            </div>
          </div>
          <!-- Top D2 -->
          <div class="mini-board">
            <div class="mini-head">Top D2</div>
            <div v-if="!topD2.length" class="mini-empty">Aucune donnée.</div>
            <div v-for="(r, i) in topD2" :key="r.id" class="mini-row">
              <span class="mini-rank">{{ i + 1 }}</span>
              <span class="mini-name">{{ r.id }}</span>
              <span class="mini-pts">{{ r.PTS }} pts</span>
            </div>
          </div>
        </div>

        <h3 class="comp-sub" style="margin-top:2.25rem">Tournois</h3>
        <div v-if="tournaments.length" class="tourn-grid">
          <article v-for="t in tournaments.slice(0, 6)" :key="t.id" class="tourn-card">
            <div class="tourn-top">
              <span :class="['tourn-status', t.status === 'live' ? 'live' : '']">{{ t.status === 'live' ? 'En cours' : 'Terminé' }}</span>
              <span class="tourn-fmt">{{ formatLabel(t.format) }}</span>
            </div>
            <h3 class="tourn-name">{{ t.name }}</h3>
            <div class="tourn-meta">
              <span>{{ t.participants_count }} joueurs</span>
              <span v-if="t.winner_name"><TrophyIcon class="w-3 h-3 inline" style="color:#eab308" /> {{ t.winner_name }}</span>
            </div>
          </article>
        </div>
        <p v-else class="empty">Aucun tournoi pour le moment.</p>
      </template>

      <!-- Tekken : à venir -->
      <div v-else class="soon-box">
        <TrophyIcon class="soon-ic" />
        <h3>Tekken — bientôt</h3>
        <p>Le ladder, les duels classés et les tournois Tekken arrivent. Le pôle combat du club se prépare.</p>
        <RouterLink to="/tekken" class="btn-primary cta-lg">Découvrir le pôle Tekken</RouterLink>
      </div>
    </section>

    <!-- ── CTA final ── -->
    <section class="section join-band">
      <h2>Prêt à rejoindre la communauté ?</h2>
      <p>Crée ta demande d'adhésion et entre dans la compétition.</p>
      <RouterLink to="/inscription" class="btn-primary cta-lg">Devenir membre</RouterLink>
    </section>

    <PublicFooter />

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { ArrowRightIcon, TrophyIcon } from 'lucide-vue-next'
import PublicNav from '@/components/public/PublicNav.vue'
import PublicFooter from '@/components/public/PublicFooter.vue'
import { useGameStore } from '@/stores/game'
import { useSiteSettings } from '@/stores/siteSettings'
import { resolveBaseURL, mediaUrl } from '@/composables/useAPI'

const game = useGameStore()
const site = useSiteSettings()
const s = computed(() => site.settings)

const heroVideo = computed(() => mediaUrl(game.isTekken ? s.value.tekken.heroVideo : s.value.efoot.heroVideo))

// Onglet de la section Compétition (résultats + tournois)
const feedGame = ref('efoot')
function setFeed(g) {
  feedGame.value = g
  game.set(g) // bascule l'accent (bleu / orange)
}

const tournaments = ref([])
const latestDay   = ref(null)
const topD1       = ref([])
const topD2       = ref([])
const stats       = ref({ players: '—', tournaments: '—' })

const FORMAT_LABELS = {
  single_elimination: 'Élimination',
  double_elimination: 'Double élim.',
  round_robin: 'Round Robin',
  groups_knockout: 'Groupes + KO',
}
const formatLabel = f => FORMAT_LABELS[f] || f || ''

function fmtDate(d) {
  if (!d) return '—'
  try {
    return new Date(d + 'T12:00:00').toLocaleDateString('fr-FR', { day: '2-digit', month: 'long', year: 'numeric' })
  } catch (_) { return d }
}

async function getJSON(path) {
  const r = await fetch(resolveBaseURL() + path, { headers: { Accept: 'application/json' } })
  if (!r.ok) throw new Error(String(r.status))
  return r.json()
}

onMounted(async () => {
  try {
    const data = await getJSON('/public/tournaments')
    tournaments.value = data.tournaments || data || []
    stats.value.tournaments = tournaments.value.length || '—'
  } catch (_) {}

  try {
    const data = await getJSON('/public/latest-day')
    latestDay.value = data || null
    topD1.value = (data?.d1?.members || []).slice(0, 5)
    topD2.value = (data?.d2?.members || []).slice(0, 5)
  } catch (_) {}
})
</script>

<style scoped>
.landing { position: relative; z-index: 1; color: var(--text); }

/* ── Nav ── */
.lnav {
  position: sticky; top: 0; z-index: 50;
  background: color-mix(in srgb, var(--bg) 80%, transparent);
  backdrop-filter: blur(14px);
  border-bottom: 1px solid var(--border);
}
.lnav-inner {
  max-width: none; height: 4rem;
  display: flex; align-items: center; gap: 1.25rem; padding: 0 clamp(1.25rem, 4vw, 4rem);
}
.brand { display: inline-flex; align-items: center; gap: .55rem; text-decoration: none; color: var(--text); font-family: var(--font-title); }
.brand-mark { color: var(--accent); font-size: 1.3rem; line-height: 1; }
.brand-logo { width: 34px; height: 34px; border-radius: 8px; object-fit: cover; flex: none; }
.brand-text { display: flex; flex-direction: column; line-height: 1; font-weight: 700; letter-spacing: .06em; }
.brand-sub { font-size: .58rem; color: var(--muted); letter-spacing: .22em; margin-top: 2px; }

.lnav-links { display: none; gap: 1.4rem; margin-left: 1rem; }
.lnav-links a { color: var(--muted); text-decoration: none; font-size: .9rem; font-weight: 600; font-family: var(--font-title); letter-spacing: .03em; transition: color .15s; }
.lnav-links a:hover { color: var(--accent-l); }

.lnav-right { display: flex; align-items: center; gap: .6rem; margin-left: auto; }

.game-switch { display: inline-flex; padding: 3px; border-radius: 999px; border: 1px solid var(--border); background: color-mix(in srgb, var(--card) 70%, transparent); }
.gs-btn { padding: .28rem .8rem; border: none; background: transparent; color: var(--muted); font-size: .8rem; font-weight: 700; font-family: var(--font-title); letter-spacing: .04em; border-radius: 999px; cursor: pointer; transition: all .18s; }
.gs-btn.active { background: var(--accent); color: #fff; box-shadow: 0 3px 12px rgba(var(--accent-rgb), .35); }

.btn-login { display: none; }
.btn-join { font-family: var(--font-title); letter-spacing: .03em; }

/* ── Hero ── */
.hero { position: relative; min-height: 88vh; display: grid; align-items: center; overflow: hidden; }
.hero-bg { position: absolute; inset: 0; z-index: 0; }
.hero-video { width: 100%; height: 100%; object-fit: cover; opacity: .42; }
.hero-tint {
  position: absolute; inset: 0;
  background:
    radial-gradient(70vw 60vh at 18% 12%, rgba(var(--accent-rgb), .28), transparent 60%),
    linear-gradient(180deg, rgba(3,8,22,.55), rgba(3,8,22,.9));
}
.hero-content { position: relative; z-index: 1; max-width: none; width: 100%; padding: 4rem clamp(1.25rem, 4vw, 4rem); }
.hero-eyebrow { display: inline-block; font-family: var(--font-title); font-weight: 700; letter-spacing: .28em; text-transform: uppercase; font-size: .72rem; color: var(--accent-l); padding: .3rem .8rem; border: 1px solid color-mix(in srgb, var(--accent) 45%, transparent); border-radius: 999px; margin-bottom: 1.25rem; }
.hero-title { font-family: var(--font-title); font-weight: 700; font-size: clamp(2.8rem, 8vw, 6rem); line-height: .96; letter-spacing: .02em; margin: 0 0 1.25rem; text-transform: uppercase; }
.hero-lead { max-width: 38rem; color: var(--muted); font-size: clamp(1rem, 2.2vw, 1.2rem); line-height: 1.6; margin: 0 0 2rem; }
.hero-lead strong { color: var(--text); }
.hero-cta { display: flex; flex-wrap: wrap; gap: .8rem; margin-bottom: 2.75rem; }
.cta-lg { padding: .8rem 1.6rem; font-size: 1rem; border-radius: .7rem; }

.hero-stats { display: flex; gap: 2.5rem; flex-wrap: wrap; }
.hstat { display: flex; flex-direction: column; }
.hstat-n { font-family: var(--font-title); font-weight: 700; font-size: 2rem; line-height: 1; color: var(--accent-l); }
.hstat-l { font-size: .8rem; color: var(--muted); text-transform: uppercase; letter-spacing: .12em; margin-top: .3rem; }

/* ── Sections ── */
.section { max-width: none; padding: 4rem clamp(1.25rem, 4vw, 4rem); }
.section-head { margin-bottom: 2rem; }
.section-head h2 { font-family: var(--font-title); font-weight: 700; font-size: clamp(1.6rem, 4vw, 2.4rem); text-transform: uppercase; letter-spacing: .04em; margin: 0 0 .4rem; }
.section-head h2::after { content: ''; display: block; width: 3rem; height: 3px; margin-top: .7rem; border-radius: 3px; background: var(--accent); }
.section-head p { color: var(--muted); margin: 0; }

/* ── Univers ── */
.univers-grid { display: grid; gap: 1.25rem; grid-template-columns: 1fr; }
.uni-card { position: relative; border: 1px solid var(--border); border-radius: 16px; overflow: hidden; background: var(--card); transition: transform .2s, border-color .2s, box-shadow .2s; }
.uni-card:hover { transform: translateY(-4px); border-color: color-mix(in srgb, var(--accent) 55%, var(--border)); box-shadow: 0 18px 40px rgba(3,8,24,.5); }
.uni-media { display: block; width: 100%; height: clamp(200px, 24vw, 320px); object-fit: cover; object-position: center; background: #0a1428; }
.uni-body { position: relative; padding: 1.25rem 1.4rem 1.5rem; border-top: 1px solid var(--border); }
.uni-tag { display: inline-block; font-family: var(--font-title); font-weight: 700; letter-spacing: .1em; text-transform: uppercase; font-size: .72rem; color: #fff; background: #3b82f6; padding: .25rem .7rem; border-radius: 999px; margin-bottom: .7rem; }
.uni-tag.tekken { background: #ff5a2c; }
.uni-body h3 { font-family: var(--font-title); font-weight: 700; font-size: 1.5rem; text-transform: uppercase; letter-spacing: .03em; margin: 0 0 .5rem; }
.uni-body p { color: var(--muted); line-height: 1.55; margin: 0 0 1.25rem; }
.soon { opacity: .6; cursor: not-allowed; }

/* ── Compétition (onglets) ── */
.comp-tabs { display: inline-flex; gap: .4rem; padding: 4px; border: 1px solid var(--border); border-radius: 999px; background: var(--card); margin-bottom: 1.75rem; }
.ct { padding: .45rem 1.2rem; border: none; background: transparent; color: var(--muted); font-family: var(--font-title); font-weight: 700; letter-spacing: .03em; text-transform: uppercase; font-size: .84rem; border-radius: 999px; cursor: pointer; transition: all .18s; }
.ct.on { background: var(--accent); color: #fff; box-shadow: 0 3px 12px rgba(var(--accent-rgb), .35); }
.comp-sub { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .04em; font-size: 1.1rem; margin: 0 0 1.1rem; }
.comp-sub-day { color: var(--muted); font-weight: 500; font-size: .85rem; }
.soon-box { text-align: center; border: 1px solid var(--border); border-radius: 16px; background: var(--card); padding: 3rem 1.5rem; }
.soon-ic { width: 2.4rem; height: 2.4rem; color: var(--accent); margin: 0 auto .8rem; }
.soon-box h3 { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .04em; font-size: 1.4rem; margin: 0 0 .5rem; }
.soon-box p { color: var(--muted); max-width: 34rem; margin: 0 auto 1.5rem; }

/* ── Résultats ── */
.res-grid { display: grid; gap: 1.1rem; grid-template-columns: 1fr; align-items: start; }
.champs-col { display: grid; gap: 1rem; align-content: start; }
.champ-card { display: flex; align-items: center; gap: .9rem; padding: 1.1rem 1.3rem; background: var(--card); border: 1px solid var(--border); border-radius: 14px; }
.champ-crown { font-size: 1.8rem; line-height: 1; }
.champ-crown-icon { width: 1.5rem; height: 1.5rem; color: #eab308; }
.champ-meta { display: flex; flex-direction: column; min-width: 0; }
.champ-div { font-size: .72rem; text-transform: uppercase; letter-spacing: .1em; color: var(--muted); }
.champ-card strong { font-family: var(--font-title); font-size: 1.3rem; letter-spacing: .02em; }
.champ-empty { color: var(--muted); padding: 1rem 0; }

.mini-board { border: 1px solid var(--border); border-radius: 12px; overflow: hidden; background: var(--card); }
.mini-empty { padding: .8rem 1rem; color: var(--muted); font-size: .85rem; }
.mini-head { padding: .6rem 1rem; font-family: var(--font-title); font-weight: 700; letter-spacing: .05em; text-transform: uppercase; font-size: .78rem; color: var(--muted); background: var(--panel); border-bottom: 1px solid var(--border); }
.mini-row { display: flex; align-items: center; gap: .9rem; padding: .55rem 1rem; border-bottom: 1px solid color-mix(in srgb, var(--border) 50%, transparent); }
.mini-row:last-child { border-bottom: none; }
.mini-rank { width: 1.4rem; text-align: center; font-family: var(--font-title); font-weight: 700; color: var(--accent-l); }
.mini-name { flex: 1; font-weight: 600; }
.mini-pts { color: var(--muted); font-size: .85rem; }

/* ── Tournois ── */
.tourn-grid { display: grid; gap: 1rem; grid-template-columns: 1fr; }
.tourn-card { border: 1px solid var(--border); border-radius: 14px; padding: 1.1rem 1.2rem; background: var(--card); transition: transform .18s, border-color .18s; }
.tourn-card:hover { transform: translateY(-3px); border-color: color-mix(in srgb, var(--accent) 45%, var(--border)); }
.tourn-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: .7rem; }
.tourn-status { font-size: .68rem; font-weight: 700; text-transform: uppercase; letter-spacing: .08em; color: var(--muted); padding: .2rem .6rem; border-radius: 999px; border: 1px solid var(--border); }
.tourn-status.live { color: #fff; background: var(--accent); border-color: var(--accent); }
.tourn-fmt { font-size: .75rem; color: var(--muted); }
.tourn-name { font-family: var(--font-title); font-weight: 700; font-size: 1.15rem; letter-spacing: .02em; margin: 0 0 .6rem; }
.tourn-meta { display: flex; justify-content: space-between; color: var(--muted); font-size: .85rem; }
.empty { color: var(--muted); }

/* ── Join band ── */
.join-band { text-align: center; }
.join-band h2 { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .04em; font-size: clamp(1.6rem, 4vw, 2.4rem); margin: 0 0 .6rem; }
.join-band p { color: var(--muted); margin: 0 0 1.6rem; }

/* ── Footer ── */
.lfoot { border-top: 1px solid var(--border); background: color-mix(in srgb, var(--bg) 85%, transparent); }
.lfoot-inner { max-width: none; padding: 1.5rem clamp(1.25rem, 4vw, 4rem); display: flex; flex-wrap: wrap; gap: .6rem; align-items: center; justify-content: space-between; }
.lfoot-copy { color: var(--muted); font-size: .85rem; }

/* ── Responsive ── */
@media (min-width: 720px) {
  .univers-grid { grid-template-columns: 1fr 1fr; }
  .tourn-grid { grid-template-columns: repeat(2, 1fr); }
  .res-grid { grid-template-columns: 1fr 1fr; }
}
@media (min-width: 1100px) {
  .lnav-links { display: flex; }
  .btn-login { display: inline-flex; }
  .tourn-grid { grid-template-columns: repeat(3, 1fr); }
  .res-grid { grid-template-columns: minmax(260px, 1fr) 1fr 1fr; }
}
@media (prefers-reduced-motion: reduce) {
  .uni-card, .tourn-card { transition: none; }
}
</style>
