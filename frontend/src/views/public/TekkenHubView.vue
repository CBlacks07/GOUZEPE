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
        <span class="eyebrow">Pole combat</span>
        <h1 class="hub-title">Tekken</h1>
        <p class="hub-lead">
          L'arene versus du club. <strong>Ladder ELO</strong>, <strong>duels classes</strong> et
          <strong>tournois a elimination</strong>.
        </p>
        <div class="hub-cta">
          <RouterLink to="/inscription" class="btn-primary cta-lg">Rejoindre le club</RouterLink>
        </div>
      </div>
    </section>

    <!-- Ladder Top -->
    <section class="section">
      <div class="section-head">
        <h2>Classement Ladder</h2>
        <p v-if="ladder.length">Top {{ ladder.length }} joueurs</p>
        <p v-else>Aucun joueur dans le ladder pour le moment.</p>
      </div>

      <div v-if="ladder.length" class="ladder-podium">
        <div v-for="(p, i) in ladder.slice(0, 5)" :key="p.player_id" class="podium-card" :class="'pos-' + (i+1)">
          <div class="podium-rank">
            <span v-if="i === 0" class="rank-medal gold">1</span>
            <span v-else-if="i === 1" class="rank-medal silver">2</span>
            <span v-else-if="i === 2" class="rank-medal bronze">3</span>
            <span v-else class="rank-num">{{ i + 1 }}</span>
          </div>
          <div class="podium-avatar">
            <img v-if="p.profile_pic_url" :src="resolveUrl(p.profile_pic_url)" :alt="p.name" />
            <span v-else>{{ initials(p.name) }}</span>
          </div>
          <div class="podium-info">
            <strong>{{ p.name }}</strong>
            <span class="podium-elo">{{ p.elo }} ELO</span>
          </div>
          <div class="podium-stats">
            <span class="pw">{{ p.wins }}V</span> / <span class="pl">{{ p.losses }}D</span>
          </div>
        </div>
      </div>
    </section>

    <!-- Derniers duels -->
    <section v-if="duels.length" class="section">
      <div class="section-head">
        <h2>Derniers duels</h2>
      </div>
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

    <!-- Features -->
    <section class="section">
      <div class="feat-grid">
        <article class="feat-card">
          <SwordsIcon class="feat-ic" />
          <h3>Ladder classe</h3>
          <p>Un classement ELO alimente par tes duels classes contre les autres membres.</p>
        </article>
        <article class="feat-card">
          <TrophyIcon class="feat-ic" />
          <h3>Tournois</h3>
          <p>Brackets a elimination simple et double -- le format roi du versus.</p>
        </article>
        <article class="feat-card">
          <UsersIcon class="feat-ic" />
          <h3>Face-a-face</h3>
          <p>Historique et statistiques de tes confrontations.</p>
        </article>
      </div>
    </section>

    <section class="section join-band">
      <h2>Rejoins l'arene</h2>
      <p>Inscris-toi et choisis Tekken comme jeu.</p>
      <RouterLink to="/inscription" class="btn-primary cta-lg">Devenir membre</RouterLink>
    </section>

    <PublicFooter />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { SwordsIcon, TrophyIcon, UsersIcon } from 'lucide-vue-next'
import PublicNav from '@/components/public/PublicNav.vue'
import PublicFooter from '@/components/public/PublicFooter.vue'
import { useGameStore } from '@/stores/game'
import { useSiteSettings } from '@/stores/siteSettings'
import { mediaUrl, resolveBaseURL } from '@/composables/useAPI'

const game = useGameStore()
const site = useSiteSettings()
const heroVideo = computed(() => mediaUrl(site.settings.tekken.heroVideo))

const ladder = ref([])
const duels = ref([])

function resolveUrl(u) {
  if (!u) return ''
  if (/^https?:\/\//.test(u)) return u
  return resolveBaseURL() + (u.startsWith('/') ? u : '/' + u)
}

function initials(name) {
  return String(name || '?').trim().split(/\s+/).slice(0, 2).map(w => w[0]).join('').toUpperCase()
}

function fmtDate(d) {
  if (!d) return ''
  return new Date(d).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short' })
}

onMounted(async () => {
  game.set('tekken')
  const base = resolveBaseURL()
  try {
    const [lr, dr] = await Promise.all([
      fetch(base + '/tekken/ladder').then(r => r.json()),
      fetch(base + '/tekken/duels?limit=8').then(r => r.json()),
    ])
    ladder.value = lr.ladder || []
    duels.value = dr.duels || []
  } catch (_) {}
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
</style>
