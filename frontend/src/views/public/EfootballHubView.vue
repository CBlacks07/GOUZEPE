<template>
  <div class="hub">
    <PublicNav />

    <!-- Hero -->
    <section class="hub-hero">
      <div class="hub-hero-bg" aria-hidden="true">
        <video ref="heroVideoEl" class="hub-hero-video" :key="heroVideo" :src="heroVideo" autoplay muted loop playsinline preload="none" poster="/assets/fond.png"></video>
        <div class="hub-hero-tint"></div>
      </div>
      <div class="hub-hero-content">
        <span class="eyebrow">Pôle compétition</span>
        <h1 class="hub-title">eFootball</h1>
        <p class="hub-lead">
          Le championnat du club : <strong>journées D1/D2</strong>, saisons, classement général,
          tournois et duels. Toute la rivalité, saison après saison.
        </p>
        <div class="hub-cta">
          <RouterLink to="/login" class="btn-primary cta-lg">Accéder à l'espace</RouterLink>
          <RouterLink to="/inscription" class="btn cta-lg">Rejoindre</RouterLink>
        </div>
      </div>
    </section>

    <!-- Saison en cours -->
    <section class="section">
      <div class="section-head">
        <h2>Saison en cours</h2>
        <p v-if="latestDay?.day">Dernière journée : {{ fmtDate(latestDay.day) }}</p>
        <p v-else>Pas encore de journée enregistrée.</p>
      </div>

      <div v-if="champions.length" class="champ-row">
        <div v-for="c in champions" :key="c.div" class="champ-card">
          <TrophyIcon class="champ-crown-icon" />
          <div><span class="champ-div">Champion {{ c.div }}</span><strong>{{ c.id }}</strong></div>
        </div>
      </div>

      <div class="boards">
        <div v-for="b in boards" :key="b.div" class="mini-board">
          <div class="mini-head">{{ b.div }} — Top {{ b.rows.length }}</div>
          <div v-if="!b.rows.length" class="mini-empty">Aucune donnée.</div>
          <div v-for="(r, i) in b.rows" :key="r.id" class="mini-row">
            <span class="mini-rank">{{ i + 1 }}</span>
            <span class="mini-name">{{ r.id }}</span>
            <span class="mini-pts">{{ r.PTS }} pts</span>
          </div>
        </div>
      </div>
    </section>

    <!-- Tournois -->
    <section class="section">
      <div class="section-head"><h2>Tournois</h2><p>Les compétitions du club.</p></div>
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
    </section>

    <section class="section join-band">
      <h2>Prêt à jouer la saison ?</h2>
      <p>Rejoins le championnat eFootball du club.</p>
      <RouterLink to="/inscription" class="btn-primary cta-lg">Devenir membre</RouterLink>
    </section>

    <PublicFooter />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import PublicNav from '@/components/public/PublicNav.vue'
import PublicFooter from '@/components/public/PublicFooter.vue'
import { useGameStore } from '@/stores/game'
import { useSiteSettings } from '@/stores/siteSettings'
import { resolveBaseURL, mediaUrl } from '@/composables/useAPI'
import { useHeroVideo } from '@/composables/useHeroVideo'
import { TrophyIcon } from 'lucide-vue-next'

const heroVideoEl = ref(null)
useHeroVideo(heroVideoEl)

const game = useGameStore()
const site = useSiteSettings()
const heroVideo = computed(() => mediaUrl(site.settings.efoot.heroVideo))
const tournaments = ref([])
const latestDay = ref(null)

const champions = computed(() => {
  const c = latestDay.value?.champions || {}
  const out = []
  if (c.d1?.id) out.push({ div: 'D1', id: c.d1.id })
  if (c.d2?.id) out.push({ div: 'D2', id: c.d2.id })
  return out
})
const boards = computed(() => ([
  { div: 'D1', rows: (latestDay.value?.d1?.members || []).slice(0, 5) },
  { div: 'D2', rows: (latestDay.value?.d2?.members || []).slice(0, 5) },
]))

const FORMAT_LABELS = { single_elimination: 'Élimination', double_elimination: 'Double élim.', round_robin: 'Round Robin', groups_knockout: 'Groupes + KO' }
const formatLabel = f => FORMAT_LABELS[f] || f || ''
function fmtDate(d) { if (!d) return '—'; try { return new Date(d + 'T12:00:00').toLocaleDateString('fr-FR', { day: '2-digit', month: 'long', year: 'numeric' }) } catch (_) { return d } }
async function getJSON(p) { const r = await fetch(resolveBaseURL() + p, { headers: { Accept: 'application/json' } }); if (!r.ok) throw new Error(String(r.status)); return r.json() }

onMounted(async () => {
  game.set('efoot')
  try { const d = await getJSON('/public/tournaments'); tournaments.value = d.tournaments || [] } catch (_) {}
  try { latestDay.value = await getJSON('/public/latest-day') } catch (_) {}
})
</script>

<style scoped>
.hub { position: relative; z-index: 1; color: var(--text); }

.hub-hero { position: relative; min-height: 60vh; display: grid; align-items: center; overflow: hidden; }
.hub-hero-bg { position: absolute; inset: 0; z-index: 0; }
.hub-hero-video { width: 100%; height: 100%; object-fit: cover; opacity: .4; }
.hub-hero-tint { position: absolute; inset: 0; background: radial-gradient(60vw 60vh at 20% 15%, rgba(var(--accent-rgb), .3), transparent 60%), linear-gradient(180deg, rgba(3,8,22,.55), rgba(3,8,22,.92)); }
.hub-hero-content { position: relative; z-index: 1; padding: 3.5rem clamp(1.25rem, 4vw, 4rem); }
.eyebrow { display: inline-block; font-family: var(--font-title); font-weight: 700; letter-spacing: .26em; text-transform: uppercase; font-size: .72rem; color: var(--accent-l); padding: .3rem .8rem; border: 1px solid color-mix(in srgb, var(--accent) 45%, transparent); border-radius: 999px; margin-bottom: 1rem; }
.hub-title { font-family: var(--font-title); font-weight: 700; font-size: clamp(2.6rem, 7vw, 5rem); line-height: 1; text-transform: uppercase; letter-spacing: .02em; margin: 0 0 1rem; }
.hub-lead { max-width: 40rem; color: var(--muted); font-size: clamp(1rem, 2vw, 1.15rem); line-height: 1.6; margin: 0 0 1.75rem; }
.hub-lead strong { color: var(--text); }
.hub-cta { display: flex; flex-wrap: wrap; gap: .8rem; }
.cta-lg { padding: .8rem 1.6rem; font-size: 1rem; border-radius: .7rem; }

.section { padding: 3.5rem clamp(1.25rem, 4vw, 4rem); }
.section-head { margin-bottom: 1.75rem; }
.section-head h2 { font-family: var(--font-title); font-weight: 700; font-size: clamp(1.6rem, 4vw, 2.2rem); text-transform: uppercase; letter-spacing: .04em; margin: 0 0 .4rem; }
.section-head h2::after { content: ''; display: block; width: 3rem; height: 3px; margin-top: .6rem; border-radius: 3px; background: var(--accent); }
.section-head p { color: var(--muted); margin: 0; }

.champ-row { display: flex; flex-wrap: wrap; gap: 1rem; margin-bottom: 1.5rem; }
.champ-card { display: flex; align-items: center; gap: .8rem; padding: .9rem 1.2rem; background: var(--card); border: 1px solid var(--border); border-radius: 12px; }
.champ-crown { font-size: 1.5rem; }
.champ-crown-icon { width: 1.5rem; height: 1.5rem; color: #eab308; }
.champ-div { display: block; font-size: .72rem; text-transform: uppercase; letter-spacing: .1em; color: var(--muted); }
.champ-card strong { font-family: var(--font-title); font-size: 1.15rem; }

.boards { display: grid; gap: 1rem; grid-template-columns: 1fr; }
.mini-board { border: 1px solid var(--border); border-radius: 12px; overflow: hidden; background: var(--card); }
.mini-head { padding: .6rem 1rem; font-family: var(--font-title); font-weight: 700; letter-spacing: .05em; text-transform: uppercase; font-size: .78rem; color: var(--muted); background: var(--panel); border-bottom: 1px solid var(--border); }
.mini-empty { padding: .8rem 1rem; color: var(--muted); font-size: .85rem; }
.mini-row { display: flex; align-items: center; gap: .9rem; padding: .55rem 1rem; border-bottom: 1px solid color-mix(in srgb, var(--border) 50%, transparent); }
.mini-row:last-child { border-bottom: none; }
.mini-rank { width: 1.4rem; text-align: center; font-family: var(--font-title); font-weight: 700; color: var(--accent-l); }
.mini-name { flex: 1; font-weight: 600; }
.mini-pts { color: var(--muted); font-size: .85rem; }

.tourn-grid { display: grid; gap: 1rem; grid-template-columns: 1fr; }
.tourn-card { border: 1px solid var(--border); border-radius: 14px; padding: 1.1rem 1.2rem; background: var(--card); transition: transform .18s, border-color .18s; }
.tourn-card:hover { transform: translateY(-3px); border-color: color-mix(in srgb, var(--accent) 45%, var(--border)); }
.tourn-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: .7rem; }
.tourn-status { font-size: .68rem; font-weight: 700; text-transform: uppercase; letter-spacing: .08em; color: var(--muted); padding: .2rem .6rem; border-radius: 999px; border: 1px solid var(--border); }
.tourn-status.live { color: #fff; background: var(--accent); border-color: var(--accent); }
.tourn-fmt { font-size: .75rem; color: var(--muted); }
.tourn-name { font-family: var(--font-title); font-weight: 700; font-size: 1.15rem; margin: 0 0 .6rem; }
.tourn-meta { display: flex; justify-content: space-between; color: var(--muted); font-size: .85rem; }
.empty { color: var(--muted); }

.join-band { text-align: center; }
.join-band h2 { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .04em; font-size: clamp(1.6rem, 4vw, 2.2rem); margin: 0 0 .6rem; }
.join-band p { color: var(--muted); margin: 0 0 1.5rem; }

@media (min-width: 720px) {
  .boards { grid-template-columns: 1fr 1fr; }
  .tourn-grid { grid-template-columns: repeat(2, 1fr); }
}
@media (min-width: 1100px) { .tourn-grid { grid-template-columns: repeat(3, 1fr); } }
</style>
