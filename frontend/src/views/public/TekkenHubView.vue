<template>
  <div class="hub">
    <PublicNav />

    <!-- Hero -->
    <section class="hub-hero">
      <div class="hub-hero-bg" aria-hidden="true">
        <video ref="heroVideoEl" class="hub-hero-video" :key="heroVideo" :src="heroVideo" autoplay muted loop playsinline preload="none"></video>
        <div class="hub-hero-tint"></div>
      </div>
      <div class="hub-hero-content">
        <span class="eyebrow">Pôle combat</span>
        <h1 class="hub-title">Tekken</h1>
        <p class="hub-lead">
          L'arène versus du club : un <strong>championnat par journées</strong>, un <strong>ladder ELO</strong>
          alimenté par chaque match, des <strong>duels classés</strong> et des <strong>tournois</strong>.
        </p>
        <div class="hub-cta">
          <RouterLink to="/tekken/journees" class="btn-primary cta-lg">Voir les journées</RouterLink>
          <RouterLink to="/inscription" class="btn cta-lg">Rejoindre le club</RouterLink>
        </div>
      </div>
    </section>

    <!-- Journée en direct / dernière journée -->
    <section v-if="featured" class="section">
      <div class="section-head">
        <h2>{{ featured.status === 'live' ? 'Journée en direct' : 'Dernière journée' }}</h2>
        <p>{{ featured.name }}<template v-if="featured.starts_at"> · {{ fmtLong(featured.starts_at) }}</template></p>
      </div>
      <RouterLink :to="{ path: '/tekken/journees', query: { j: featured.id } }" class="live-card">
        <span :class="['live-pill', featured.status]">
          <span v-if="featured.status === 'live'" class="live-dot" aria-hidden="true" />
          {{ featured.status === 'live' ? 'En direct' : featured.status === 'completed' ? 'Terminée' : 'À venir' }}
        </span>
        <div class="live-body">
          <strong>{{ featured.name }}</strong>
          <span>{{ formatLabel(featured.format) }} · {{ featured.participants_count }} joueurs</span>
        </div>
        <div v-if="featured.winner_name" class="live-champ">
          <TrophyIcon class="w-4 h-4" aria-hidden="true" /> {{ featured.winner_name }}
        </div>
        <span class="live-go">{{ featured.status === 'live' ? 'Suivre en direct' : 'Voir la journée' }} <ArrowRightIcon class="w-4 h-4" /></span>
      </RouterLink>
    </section>

    <!-- Championnat + ladder -->
    <section class="section">
      <div class="boards">
        <div class="mini-board">
          <div class="mini-head">
            Championnat — saison en cours
            <RouterLink to="/tekken/classement" class="mini-link">Tout voir</RouterLink>
          </div>
          <div v-if="!season.length" class="mini-empty">Le classement démarre avec la première journée terminée.</div>
          <div v-for="r in season.slice(0, 5)" :key="r.player_id || r.name" class="mini-row">
            <span class="mini-rank">{{ r.rank }}</span>
            <span class="mini-name">{{ r.name }}</span>
            <span v-if="r.titles" class="mini-titles"><TrophyIcon class="w-3 h-3 inline" style="color:#eab308" /> {{ r.titles }}</span>
            <span class="mini-pts">{{ r.points }} pts</span>
          </div>
        </div>

        <div class="mini-board">
          <div class="mini-head">
            Ladder ELO
            <RouterLink to="/classements" class="mini-link">Tout voir</RouterLink>
          </div>
          <div v-if="!ladder.length" class="mini-empty">Aucun joueur classé pour le moment.</div>
          <div v-for="(p, i) in ladder.slice(0, 5)" :key="p.player_id" class="mini-row">
            <span class="mini-rank">{{ i + 1 }}</span>
            <span class="podium-avatar sm">
              <img v-if="p.profile_pic_url" :src="resolveUrl(p.profile_pic_url)" :alt="p.name" />
              <span v-else>{{ initials(p.name) }}</span>
            </span>
            <span class="mini-name">{{ p.name }}</span>
            <span class="mini-pts"><span class="pw">{{ p.wins }}V</span> / <span class="pl">{{ p.losses }}D</span></span>
            <span class="podium-elo">{{ p.elo }}</span>
          </div>
        </div>
      </div>
    </section>

    <!-- Tournois -->
    <section class="section">
      <div class="section-head"><h2>Tournois</h2><p>Les compétitions Tekken du club, brackets compris.</p></div>
      <div v-if="tournaments.length" class="tourn-grid">
        <RouterLink v-for="t in tournaments.slice(0, 6)" :key="t.id" :to="`/tournoi/${t.id}`" class="tourn-card">
          <div class="tourn-top">
            <span :class="['tourn-status', t.status === 'live' ? 'live' : '']">{{ t.status === 'live' ? 'En cours' : 'Terminé' }}</span>
            <span class="tourn-fmt">{{ formatLabel(t.format) }}</span>
          </div>
          <h3 class="tourn-name">{{ t.name }}</h3>
          <div class="tourn-meta">
            <span>{{ t.participants_count }} joueurs</span>
            <span v-if="t.winner_name"><TrophyIcon class="w-3 h-3 inline" style="color:#eab308" /> {{ t.winner_name }}</span>
          </div>
        </RouterLink>
      </div>
      <p v-else class="empty">Aucun tournoi pour le moment.</p>
    </section>

    <!-- Derniers duels -->
    <section v-if="duels.length" class="section">
      <div class="section-head"><h2>Derniers duels</h2><p>Les affrontements récents, ELO en jeu.</p></div>
      <div class="duels-list">
        <article v-for="d in duels.slice(0, 8)" :key="d.id" class="duel-card">
          <div class="duel-date">{{ fmtDate(d.played_at) }}</div>
          <div class="duel-match">
            <span :class="{ winner: d.winner_id === d.p1_id }">{{ d.p1_name }}</span>
            <span class="duel-score">{{ d.score_p1 }} - {{ d.score_p2 }}</span>
            <span :class="{ winner: d.winner_id === d.p2_id }">{{ d.p2_name }}</span>
          </div>
        </article>
      </div>
    </section>

    <!-- Comment ça marche -->
    <section class="section">
      <div class="feat-grid">
        <article class="feat-card">
          <CalendarDaysIcon class="feat-ic" />
          <h3>Championnat</h3>
          <p>Des journées tout au long de la saison. Chaque victoire rapporte des points, le champion du jour empoche un bonus.</p>
        </article>
        <article class="feat-card">
          <SwordsIcon class="feat-ic" />
          <h3>Ladder ELO</h3>
          <p>Chaque match joué au club, en journée, en duel ou en tournoi, fait bouger ton ELO.</p>
        </article>
        <article class="feat-card">
          <TrophyIcon class="feat-ic" />
          <h3>Tournois</h3>
          <p>Élimination simple ou double, toutes rondes, poules : les brackets sont à suivre en direct.</p>
        </article>
      </div>
    </section>

    <section class="section join-band">
      <h2>Rejoins l'arène</h2>
      <p>Inscris-toi et choisis Tekken comme jeu.</p>
      <RouterLink to="/inscription" class="btn-primary cta-lg">Devenir membre</RouterLink>
    </section>

    <PublicFooter />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { SwordsIcon, TrophyIcon, CalendarDaysIcon, ArrowRightIcon } from 'lucide-vue-next'
import PublicNav from '@/components/public/PublicNav.vue'
import PublicFooter from '@/components/public/PublicFooter.vue'
import { useGameStore } from '@/stores/game'
import { useSiteSettings } from '@/stores/siteSettings'
import { mediaUrl, resolveBaseURL } from '@/composables/useAPI'
import { useHeroVideo } from '@/composables/useHeroVideo'
import { FORMAT_LABELS } from '@/utils/bracketMatches'

const heroVideoEl = ref(null)
useHeroVideo(heroVideoEl)

const game = useGameStore()
const site = useSiteSettings()
const heroVideo = computed(() => mediaUrl(site.settings.tekken.heroVideo))

const ladder = ref([])
const duels = ref([])
const journees = ref([])
const season = ref([])
const tournaments = ref([])

// Mise en avant : la journée en direct, sinon la plus récente déjà jouée.
const featured = computed(() =>
  journees.value.find((j) => j.status === 'live')
  || journees.value.find((j) => j.status === 'completed')
  || journees.value[0]
  || null)

function resolveUrl(u) {
  if (!u) return ''
  if (/^https?:\/\//.test(u)) return u
  return resolveBaseURL() + (u.startsWith('/') ? u : '/' + u)
}
function initials(name) {
  return String(name || '?').trim().split(/\s+/).slice(0, 2).map((w) => w[0]).join('').toUpperCase()
}
function fmtDate(d) {
  if (!d) return ''
  return new Date(d).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short' })
}
function fmtLong(d) {
  return new Date(d).toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' })
}
function formatLabel(f) { return FORMAT_LABELS[f] || f || '' }

async function getJSON(path) {
  const r = await fetch(resolveBaseURL() + path, { headers: { Accept: 'application/json' } })
  if (!r.ok) throw new Error(String(r.status))
  return r.json()
}

onMounted(async () => {
  game.set('tekken')
  const [lr, dr, jr, sr, tr] = await Promise.allSettled([
    getJSON('/tekken/ladder'),
    getJSON('/tekken/duels?limit=8'),
    getJSON('/tekken/journees'),
    getJSON('/tekken/season-standings'),
    getJSON('/public/tekken/tournaments'),
  ])
  if (lr.status === 'fulfilled') ladder.value = lr.value.ladder || []
  if (dr.status === 'fulfilled') duels.value = dr.value.duels || []
  if (jr.status === 'fulfilled') journees.value = jr.value.journees || []
  if (sr.status === 'fulfilled') season.value = sr.value.standings || []
  if (tr.status === 'fulfilled') tournaments.value = tr.value.tournaments || []
})
</script>

<style scoped>
.hub { position: relative; z-index: 1; color: var(--text); }

.hub-hero { position: relative; min-height: 55vh; display: grid; align-items: center; overflow: hidden; }
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

.section { padding: 2.5rem clamp(1.25rem, 4vw, 4rem); }
.section-head { margin-bottom: 1.5rem; }
.section-head h2 { font-family: var(--font-title); font-weight: 700; font-size: clamp(1.4rem, 3vw, 2rem); text-transform: uppercase; letter-spacing: .04em; margin: 0 0 .3rem; }
.section-head h2::after { content: ''; display: block; width: 3rem; height: 3px; margin-top: .5rem; border-radius: 3px; background: var(--accent); }
.section-head p { color: var(--muted); margin: 0; }

/* Ladder podium */
.ladder-podium { display: flex; flex-direction: column; gap: .7rem; max-width: 36rem; }
.podium-card { display: flex; align-items: center; gap: .8rem; padding: .85rem 1rem; background: var(--card); border: 1px solid var(--border); border-radius: 14px; transition: transform .15s, border-color .15s; }
.podium-card:hover { transform: translateY(-2px); border-color: color-mix(in srgb, var(--accent) 40%, var(--border)); }
.podium-card.pos-1 { border-color: color-mix(in srgb, gold 30%, var(--border)); }
.podium-rank { width: 32px; flex: none; text-align: center; }
.rank-medal { display: inline-flex; align-items: center; justify-content: center; width: 28px; height: 28px; border-radius: 50%; font-weight: 800; font-size: .82rem; }
.rank-medal.gold { background: linear-gradient(135deg, #ffd700, #f0c000); color: #1a1a2e; }
.rank-medal.silver { background: linear-gradient(135deg, #c0c0c0, #a8a8a8); color: #1a1a2e; }
.rank-medal.bronze { background: linear-gradient(135deg, #cd7f32, #b8722d); color: #1a1a2e; }
.rank-num { font-weight: 800; color: var(--muted); }
.podium-avatar { width: 40px; height: 40px; border-radius: 50%; flex: none; display: grid; place-items: center; overflow: hidden; background: color-mix(in srgb, var(--accent) 18%, var(--panel)); color: var(--accent-l); font-family: var(--font-title); font-weight: 700; font-size: .75rem; }
.podium-avatar img { width: 100%; height: 100%; object-fit: cover; }
.podium-info { flex: 1; min-width: 0; }
.podium-info strong { display: block; font-weight: 700; }
.podium-elo { font-family: var(--font-title); font-weight: 800; color: var(--accent-l); font-size: .9rem; }
.podium-stats { font-size: .8rem; color: var(--muted); white-space: nowrap; }
.pw { color: var(--green, #22c55e); font-weight: 600; }
.pl { color: var(--red, #ef4444); font-weight: 600; }

/* Duels list */
.duels-list { display: flex; flex-direction: column; gap: .5rem; max-width: 36rem; }
.duel-card { display: flex; align-items: center; gap: .8rem; padding: .7rem 1rem; background: var(--card); border: 1px solid var(--border); border-radius: 10px; }
.duel-date { font-size: .72rem; color: var(--muted); min-width: 3.5rem; }
.duel-match { flex: 1; display: flex; align-items: center; justify-content: center; gap: .6rem; font-weight: 600; }
.duel-match .winner { color: var(--accent-l); }
.duel-score { font-family: var(--font-title); font-weight: 800; font-size: 1.1rem; }

.feat-grid { display: grid; gap: 1rem; grid-template-columns: 1fr; }
.feat-card { border: 1px solid var(--border); border-radius: 14px; padding: 1.5rem 1.4rem; background: var(--card); }
.feat-ic { width: 2rem; height: 2rem; color: var(--accent); margin-bottom: .8rem; }
.feat-card h3 { font-family: var(--font-title); font-weight: 700; font-size: 1.25rem; text-transform: uppercase; letter-spacing: .03em; margin: 0 0 .5rem; }
.feat-card p { color: var(--muted); line-height: 1.55; margin: 0; }

.join-band { text-align: center; }
.join-band h2 { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .04em; font-size: clamp(1.6rem, 4vw, 2.2rem); margin: 0 0 .6rem; }
.join-band p { color: var(--muted); margin: 0 0 1.5rem; }

@media (min-width: 720px) { .feat-grid { grid-template-columns: repeat(3, 1fr); } }

/* Journée mise en avant */
.live-card { display: grid; grid-template-columns: 1fr; gap: .6rem; align-items: center; max-width: 52rem; padding: 1.1rem 1.25rem;
  border-radius: 16px; border: 1px solid color-mix(in srgb, var(--accent) 40%, var(--border)); text-decoration: none; color: var(--text);
  background: linear-gradient(135deg, color-mix(in srgb, var(--accent) 14%, var(--card)), var(--card)); transition: transform .18s, border-color .18s; }
.live-card:hover { transform: translateY(-2px); border-color: color-mix(in srgb, var(--accent) 70%, var(--border)); }
.live-pill { justify-self: start; display: inline-flex; align-items: center; gap: .35rem; font-size: .66rem; font-weight: 800; text-transform: uppercase; letter-spacing: .08em;
  padding: .15rem .55rem; border-radius: 999px; background: color-mix(in srgb, var(--border) 45%, transparent); color: var(--muted); }
.live-pill.live { background: rgba(239, 68, 68, .16); color: #f87171; }
.live-pill.completed { background: rgba(34, 197, 94, .14); color: #4ade80; }
.live-dot { width: .45rem; height: .45rem; border-radius: 50%; background: #ef4444; animation: live-pulse 1.4s ease-in-out infinite; }
@keyframes live-pulse { 0%, 100% { opacity: 1; } 50% { opacity: .25; } }
@media (prefers-reduced-motion: reduce) { .live-dot { animation: none; } }
.live-body strong { display: block; font-family: var(--font-title); font-size: 1.35rem; text-transform: uppercase; letter-spacing: .03em; }
.live-body span { color: var(--muted); font-size: .88rem; }
.live-champ { display: inline-flex; align-items: center; gap: .4rem; color: #eab308; font-weight: 700; }
.live-go { display: inline-flex; align-items: center; gap: .35rem; color: var(--accent-l); font-weight: 700; font-size: .9rem; }
@media (min-width: 720px) { .live-card { grid-template-columns: auto 1fr auto auto; gap: 1.2rem; } }

/* Tableaux compacts (mêmes cartes que la page eFootball) */
.boards { display: grid; gap: 1rem; grid-template-columns: 1fr; }
@media (min-width: 900px) { .boards { grid-template-columns: 1fr 1fr; } }
.mini-board { border: 1px solid var(--border); border-radius: 12px; overflow: hidden; background: var(--card); }
.mini-head { display: flex; justify-content: space-between; align-items: center; gap: .5rem; padding: .6rem 1rem; font-family: var(--font-title); font-weight: 700; letter-spacing: .05em; text-transform: uppercase; font-size: .78rem; color: var(--muted); background: var(--panel); border-bottom: 1px solid var(--border); }
.mini-link { color: var(--accent-l); text-decoration: none; font-size: .72rem; }
.mini-link:hover { text-decoration: underline; }
.mini-empty { padding: .8rem 1rem; color: var(--muted); font-size: .85rem; }
.mini-row { display: flex; align-items: center; gap: .8rem; padding: .55rem 1rem; border-bottom: 1px solid color-mix(in srgb, var(--border) 50%, transparent); }
.mini-row:last-child { border-bottom: none; }
.mini-rank { width: 1.4rem; text-align: center; font-family: var(--font-title); font-weight: 700; color: var(--accent-l); }
.mini-name { flex: 1; min-width: 0; font-weight: 600; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.mini-pts { color: var(--muted); font-size: .85rem; white-space: nowrap; }
.mini-titles { font-size: .8rem; color: var(--muted); white-space: nowrap; }
.podium-avatar.sm { width: 28px; height: 28px; font-size: .62rem; }

.tourn-grid { display: grid; gap: 1rem; grid-template-columns: 1fr; }
@media (min-width: 720px) { .tourn-grid { grid-template-columns: repeat(2, 1fr); } }
@media (min-width: 1100px) { .tourn-grid { grid-template-columns: repeat(3, 1fr); } }
.tourn-card { display: block; text-decoration: none; color: var(--text); border: 1px solid var(--border); border-radius: 14px; padding: 1.1rem 1.2rem; background: var(--card); transition: transform .18s, border-color .18s; }
.tourn-card:hover { transform: translateY(-3px); border-color: color-mix(in srgb, var(--accent) 45%, var(--border)); }
.tourn-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: .7rem; }
.tourn-status { font-size: .68rem; font-weight: 700; text-transform: uppercase; letter-spacing: .08em; color: var(--muted); padding: .2rem .6rem; border-radius: 999px; border: 1px solid var(--border); }
.tourn-status.live { color: #fff; background: var(--accent); border-color: var(--accent); }
.tourn-fmt { font-size: .75rem; color: var(--muted); }
.tourn-name { font-family: var(--font-title); font-weight: 700; font-size: 1.15rem; margin: 0 0 .6rem; }
.tourn-meta { display: flex; justify-content: space-between; color: var(--muted); font-size: .85rem; }
.empty { color: var(--muted); }
</style>
