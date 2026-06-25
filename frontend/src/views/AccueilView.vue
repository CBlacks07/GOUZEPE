<template>
  <AppLayout :season-label="currentSeason?.name || 'Saison'">
    <div class="home-page">
      <div class="home-content">

      <!-- HERO -->
      <section class="hero-section reveal">
        <!-- GOUZEPE Gaming Club — en haut -->
        <div class="hero-club">
          <span class="hero-club-name">GOUZEPE</span>
          <span class="hero-club-label">Gaming Club</span>
        </div>

        <!-- Bande photos défilante infinie -->
        <div class="hero-photos-track-wrap" aria-hidden="true">
          <div class="hero-photos-track">
            <div
              v-for="(src, i) in [...shuffledPhotos, ...shuffledPhotos]"
              :key="src + i"
              class="hero-photo-frame"
              :style="{ '--fi': i % shuffledPhotos.length }"
            >
              <div class="hero-photo-clip">
                <img :src="src" alt="" class="hero-photo-img" loading="lazy" />
              </div>
            </div>
          </div>
        </div>

        <!-- Corps : texte + visuel -->
        <div class="hero-body">
          <div class="hero-left">
            <h2 class="hero-title">
              Bienvenue au club
              <span class="hero-accent hero-typing">{{ typedText }}<span class="hero-cursor" aria-hidden="true">|</span></span>
            </h2>
            <p class="hero-sub reveal delay-1">Saisons intenses, matchs aller/retour, barrages, duels et classements en temps réel.</p>
            <div class="flex flex-wrap gap-2 reveal delay-2">
              <router-link to="/duel" class="btn-primary">Lancer un duel</router-link>
              <router-link to="/classement" class="btn">Voir le classement</router-link>
              <router-link to="/profil" class="btn-ghost">Mon espace</router-link>
            </div>
          </div>

          <!-- Visuel animé droite -->
          <div class="hero-visual" aria-hidden="true">
            <div class="hero-ring hero-ring-outer"></div>
            <div class="hero-ring hero-ring-inner"></div>
            <div class="hero-glow"></div>
            <Transition name="hero-img" mode="out-in">
              <div v-if="heroSlides[heroSlideIndex]" :key="heroSlideIndex" :class="['hero-img-wrap', heroSlides[heroSlideIndex].anim]">
                <img :src="heroSlides[heroSlideIndex].src" :alt="heroSlides[heroSlideIndex].alt" class="hero-slide-img" />
              </div>
            </Transition>
            <div class="hero-dots" aria-hidden="true">
              <span v-for="(_, i) in heroSlides" :key="i" :class="['hero-dot', { active: i === heroSlideIndex }]" />
            </div>
          </div>
        </div>
      </section>

      <!-- News + Next fixture -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-6 reveal delay-1">

        <!-- À la une — card redesignée -->
        <div class="news-card">
          <div class="news-card-header">
            <div class="news-card-title-wrap">
              <span class="news-card-label">À la une</span>
              <span class="live-badge"><span class="live-badge-dot" />LIVE</span>
            </div>
            <p v-if="headlineLastPublishedLabel" class="news-card-date">{{ headlineLastPublishedLabel }}</p>
          </div>

          <div v-if="loadingNews" class="news-loading"><div class="news-spinner" /></div>
          <div v-else class="news-body">
            <div v-if="!newsItems.length" class="news-empty">Aucune journée publiée.</div>
            <div v-else class="news-champions">
              <div v-for="(item, idx) in newsItems" :key="item.title" class="champion-row">
                <span class="champion-crown">{{ idx === 0 ? '★' : '●' }}</span>
                <div class="champion-info">
                  <span class="champion-div">{{ item.title }}</span>
                  <span class="champion-name">{{ item.meta }}</span>
                </div>
              </div>
            </div>

            <Transition name="insight-fade" mode="out-in">
              <div v-if="currentHeadlineFlash" :key="'headline-' + headlineFlashIndex" class="insight-pill">
                <span class="insight-pill-tag">{{ currentHeadlineFlash.tag }}</span>
                <p class="insight-pill-text">{{ currentHeadlineFlash.text }}</p>
              </div>
            </Transition>
          </div>
        </div>

        <div class="card card-next">
          <div class="mini-head">
            <h3 class="font-semibold">Prochaine journée</h3>
            <span class="next-pill">{{ nextFixtureStatus }}</span>
          </div>

          <div v-if="loadingNextFixture" class="text-sm" style="color:var(--muted)">Chargement…</div>
          <div v-else class="space-y-3">
            <div class="flex justify-between items-center">
              <div>
                <p class="font-medium">{{ nextFixtureLabel }}</p>
                <p v-if="nextFixtureMeta" class="text-sm" style="color:var(--muted)">{{ nextFixtureMeta }}</p>
              </div>
              <button v-if="nextFixtureDay" @click="goToDay(nextFixtureDay)" class="btn text-sm" title="Ouvrir cette journée">Voir</button>
            </div>
          </div>
        </div>
      </div>

      <!-- Pronostics -->
      <section v-if="hasPronostics" class="card pronos-card reveal delay-1">
        <div class="pronos-head">
          <h3 class="font-semibold">Pronostics</h3>
          <span class="pronos-sub">Estimations · prochaine journée</span>
        </div>

        <div class="pronos-grid">
          <!-- Course au titre -->
          <div v-if="titleRace.length" class="pronos-block">
            <div class="pronos-block-head">
              <span class="pronos-block-title">Course au titre</span>
              <span v-if="titleConfidence" class="pronos-chip" :class="`tone-${titleConfidence.tone}`">{{ titleConfidence.label }}</span>
            </div>
            <div class="title-race">
              <div v-for="row in titleRace" :key="row.id" class="tr-row" :class="{ leader: row.rank === 1 }">
                <span class="tr-rank">{{ row.rank }}</span>
                <span class="tr-name">{{ row.id }}</span>
                <span class="tr-moy">{{ row.moyenne.toFixed(2) }}</span>
                <span class="tr-gap">{{ row.rank === 1 ? 'leader' : '−' + row.gap.toFixed(2) }}</span>
              </div>
            </div>
            <p v-if="formPlayer" class="pronos-form-line">
              <span class="dot" /> En forme : <strong>{{ formPlayer.name }}</strong>
              <span class="muted">{{ formPlayer.pts }} pts · {{ formPlayer.bp }} buts (2 dern. J)</span>
            </p>

            <!-- Invités en vue (sous la course au titre) -->
            <div v-if="hasGuests" class="guests-inline">
              <div class="pronos-block-head">
                <span class="pronos-block-title">Invités en vue</span>
                <span class="pronos-count">{{ featuredGuests.length }} classé(s) · ≥5 sorties</span>
              </div>

              <div v-if="topGuest" class="guest-hero">
                <div class="guest-hero-id">
                  <span class="guest-avatar">{{ guestInitials(topGuest) }}</span>
                  <div class="min-w-0">
                    <div class="guest-hero-name">{{ topGuest.id }}</div>
                    <div class="guest-hero-sub">
                      {{ topGuest.apps }} sortie(s) · journées + tournois
                      <template v-if="topGuest.lastRank"> · dernière journée {{ rankLabel(topGuest.lastRank) }} en {{ topGuest.lastDivision || 'D?' }}</template>
                    </div>
                  </div>
                  <span class="guest-badge">Top invité</span>
                </div>
                <div v-if="topGuestStats" class="guest-hero-stats">
                  <div class="ghs"><span class="ghs-v">{{ topGuestStats.pts }}</span><span class="ghs-l">pts/J</span></div>
                  <div class="ghs"><span class="ghs-v">{{ topGuestStats.bp }}</span><span class="ghs-l">BP/J</span></div>
                  <div class="ghs"><span class="ghs-v">{{ topGuestStats.bc }}</span><span class="ghs-l">BC/J</span></div>
                  <div class="ghs"><span class="ghs-v" :class="topGuestStats.diffPos ? 'pos' : 'neg'">{{ topGuestStats.diff }}</span><span class="ghs-l">Diff/J</span></div>
                </div>
              </div>

              <div v-if="featuredGuests.length > 1" class="guest-list">
                <div v-for="(g, i) in featuredGuests.slice(1, 5)" :key="g.id" class="guest-row">
                  <span class="guest-rank">{{ i + 2 }}</span>
                  <span class="guest-name">{{ g.id }}</span>
                  <span class="guest-meta">{{ g.apps }} sorties · {{ diffPerJLabel(g) }} diff</span>
                  <span class="guest-avg">{{ g.avg.toFixed(1) }}<small> pts/J</small></span>
                </div>
              </div>
            </div>
          </div>

          <!-- Affiches de la journée -->
          <div class="pronos-block">
            <div class="pronos-block-head">
              <span class="pronos-block-title">Affiches de la journée</span>
              <span v-if="matchPredictions.length" class="pronos-count">{{ matchPredictions.length }}</span>
            </div>
            <div v-if="matchPredictions.length" class="pred-list">
              <div v-for="p in matchPredictions" :key="p.key" class="pred-row">
                <div class="pred-top">
                  <span class="pred-side" :class="{ fav: !p.close && p.favorite === p.p1 }">{{ p.p1 }}</span>
                  <span class="pred-div">{{ p.div }}</span>
                  <span class="pred-side right" :class="{ fav: !p.close && p.favorite === p.p2 }">{{ p.p2 }}</span>
                </div>
                <div class="pred-bar"><div class="pred-bar-fill" :style="{ width: p.prob1 + '%' }" /></div>
                <div class="pred-foot">
                  <span class="pred-pct">{{ p.prob1 }}%</span>
                  <span class="pred-verdict">
                    {{ p.unknown ? 'Incertain' : (p.close ? 'Match serré' : 'Favori : ' + p.favorite + ' · ' + p.favProb + '%') }}
                  </span>
                  <span class="pred-pct">{{ 100 - p.prob1 }}%</span>
                </div>
              </div>
            </div>
            <p v-else class="pronos-empty">Aucune affiche programmée pour l'instant. Les pronostics s'afficheront dès que la grille sera composée.</p>
          </div>
        </div>
      </section>

      <!-- Quick-link cards -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4 reveal delay-2">
        <router-link to="/journees" class="quick-card quick-card--journees">
          <CalendarDaysIcon class="quick-card-icon-svg" />
          <span class="quick-card-label">Journées</span>
          <span class="quick-card-desc">Gestion des matchdays</span>
        </router-link>
        <router-link to="/classement" class="quick-card quick-card--classement">
          <BarChart2Icon class="quick-card-icon-svg" />
          <span class="quick-card-label">Classement</span>
          <span class="quick-card-desc">Saison en cours</span>
        </router-link>
        <router-link to="/duel" class="quick-card quick-card--duels">
          <SwordsIcon class="quick-card-icon-svg" />
          <span class="quick-card-label">Duels</span>
          <span class="quick-card-desc">Défier un joueur</span>
        </router-link>
        <router-link to="/tournois" class="quick-card quick-card--tournois">
          <TrophyIcon class="quick-card-icon-svg" />
          <span class="quick-card-label">Tournois</span>
          <span class="quick-card-desc">Compétitions membre</span>
        </router-link>
      </div>

      </div><!-- /home-content -->
    </div><!-- /home-page -->
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import AppLayout from '@/components/layout/AppLayout.vue'
import { useAuthStore } from '@/stores/auth'
import { useAPI, mediaUrl } from '@/composables/useAPI'
import { useSiteSettings } from '@/stores/siteSettings'
import { onRealtimeEvent } from '@/composables/useRealtimeSocket'
import { CalendarDaysIcon, BarChart2Icon, SwordsIcon, TrophyIcon } from 'lucide-vue-next'

const auth   = useAuthStore()
const api    = useAPI()
const site   = useSiteSettings()
const router = useRouter()

/* ====== State ====== */
const currentSeason   = ref(null)
const allPlayers      = ref([])
const playersRoleMap  = ref(new Map()) // id -> 'MEMBRE' | 'INVITE'

// News
const loadingNews       = ref(false)
const newsItems         = ref([])
const loadingNextFixture = ref(false)
const nextFixtureLabel  = ref('Prochaine journée')
const nextFixtureStatus = ref('')
const nextFixtureDay    = ref('')
const nextFixtureMeta   = ref('')
const nextFixtureTournaments = ref([])
const recentConfirmedDays = ref([])
const headlineFlashes   = ref([])
const headlineFlashIndex = ref(0)
const featuredInvite    = ref([])   // tableau trié avg desc
const guestStatsLoaded  = ref(false)

// Pronostics
const seasonStandings   = ref([])   // classement saison complet (moyenne par joueur)
const nextPayloadRef    = ref(null) // payload de la prochaine journée
const knownDaysCount    = ref(0)    // nb de journées connues (pour le seuil de classement)
let realtimeOffSeasonChanged = null
let realtimeOffTournamentChanged = null
let realtimeOffDayConfirmed = null

// Hero
const heroWords = ['Intensité', 'Compétition', 'Gloire']
const typedText = ref('')
let typingActive = false

function sleep(ms) { return new Promise(r => setTimeout(r, ms)) }

async function runTypingLoop() {
  typingActive = true
  let wordIdx = 0
  while (typingActive) {
    const word = heroWords[wordIdx]
    for (let i = 0; i <= word.length; i++) {
      if (!typingActive) return
      typedText.value = word.slice(0, i)
      await sleep(90)
    }
    await sleep(1800)
    for (let i = word.length; i >= 0; i--) {
      if (!typingActive) return
      typedText.value = word.slice(0, i)
      await sleep(52)
    }
    await sleep(320)
    wordIdx = (wordIdx + 1) % heroWords.length
  }
}

const shuffledPhotos = ref([])
const heroSlides     = ref([])

async function probeAssets(prefix, max = 99) {
  const v = Date.now()
  const results = await Promise.all(
    Array.from({ length: max }, (_, i) => {
      const n = i + 1
      const srcs = [
        `/assets/${prefix}${n}.jpg?v=${v}`,
        `/assets/${prefix}${String(n).padStart(2, '0')}.jpg?v=${v}`,
      ]
      return new Promise(resolve => {
        let resolved = false
        let pending = srcs.length
        for (const src of srcs) {
          const img = new Image()
          img.onload = () => {
            if (!resolved) { resolved = true; resolve(src) }
          }
          img.onerror = () => {
            pending--
            if (pending === 0 && !resolved) resolve(null)
          }
          img.src = src
        }
      })
    })
  )
  const found = []
  for (const r of results) {
    if (r === null) break
    found.push(r)
  }
  return found
}

function shuffle(arr) {
  const a = [...arr]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]]
  }
  return a
}
const heroSlideIndex = ref(0)
let heroSlideTimer = null
let cardsInsightsTimer = null

const currentHeadlineFlash = computed(() => headlineFlashes.value[headlineFlashIndex.value] || null)
const headlineLastPublishedLabel = computed(() => {
  const d = recentConfirmedDays.value[0]?.date
  return d ? fmtDate(d) : ''
})

/* ====== Pronostics : course au titre + prédictions journée + forme ====== */
const nameById = computed(() => {
  const m = new Map()
  for (const p of allPlayers.value) if (p?.player_id) m.set(String(p.player_id), p.name || p.player_id)
  for (const r of seasonStandings.value) if (r?.id && !m.has(String(r.id))) m.set(String(r.id), r.name || r.id)
  return m
})
// On affiche l'identifiant du joueur (player_id), pas le nom.
function labelOf(token) {
  return String(token || '')
}
const moyenneById = computed(() => {
  const m = new Map()
  for (const r of seasonStandings.value) m.set(String(r.id), Number(r.moyenne) || 0)
  return m
})
const titleThreshold = computed(() => (knownDaysCount.value ? Math.ceil(knownDaysCount.value * 0.25) : 0))

const titleRace = computed(() => {
  const classed = seasonStandings.value
    .filter(r => Number(r.participations || 0) >= titleThreshold.value)
    .slice()
    .sort((a, b) => Number(b.moyenne || 0) - Number(a.moyenne || 0) || Number(b.total || 0) - Number(a.total || 0))
  const leader = classed[0]
  return classed.slice(0, 3).map((r, i) => ({
    rank: i + 1,
    id: r.id,
    name: r.name || r.id,
    moyenne: Number(r.moyenne || 0),
    gap: leader ? +(Number(leader.moyenne || 0) - Number(r.moyenne || 0)).toFixed(2) : 0,
  }))
})

const titleConfidence = computed(() => {
  const r = titleRace.value
  if (r.length < 2) return r.length === 1 ? { label: 'Seul classé', tone: 'open' } : null
  const lead = r[1].gap // écart du 2e au leader = avance du leader
  if (lead >= 1.2) return { label: 'Quasi assuré', tone: 'strong' }
  if (lead >= 0.5) return { label: 'Favori', tone: 'mid' }
  return { label: 'Course ouverte', tone: 'open' }
})

const PRED_K = 2.2 // sensibilité moyenne -> probabilité (logistique)
const matchPredictions = computed(() => {
  const p = nextPayloadRef.value
  if (!p) return []
  const out = []
  for (const div of ['d1', 'd2']) {
    for (const m of (p[div] || [])) {
      if (!m?.p1 || !m?.p2) continue
      const r1 = moyenneById.value.get(String(m.p1))
      const r2 = moyenneById.value.get(String(m.p2))
      const has1 = r1 != null && r1 > 0
      const has2 = r2 != null && r2 > 0
      let prob1
      if (!has1 && !has2) {
        prob1 = 0.5
      } else {
        const a = has1 ? r1 : Math.max(1, (r2 || 6) - 2)
        const b = has2 ? r2 : Math.max(1, (r1 || 6) - 2)
        prob1 = 1 / (1 + Math.exp(-(a - b) / PRED_K))
      }
      const favIsP1 = prob1 >= 0.5
      out.push({
        key: `${div}-${m.p1}-${m.p2}`,
        div: div.toUpperCase(),
        p1: labelOf(m.p1),
        p2: labelOf(m.p2),
        prob1: Math.round(prob1 * 100),
        favorite: favIsP1 ? labelOf(m.p1) : labelOf(m.p2),
        favProb: Math.round((favIsP1 ? prob1 : 1 - prob1) * 100),
        close: Math.abs(prob1 - 0.5) < 0.06,
        unknown: !has1 && !has2,
      })
    }
  }
  return out
})

const formPlayer = computed(() => {
  const days = recentConfirmedDays.value.slice(0, 2)
  if (!days.length) return null
  const rows = [...collectDivisionForm(days, 'd1'), ...collectDivisionForm(days, 'd2')]
    .filter(r => inferRoleForPlayer(r.id) !== 'INVITE')
  if (!rows.length) return null
  rows.sort((a, b) => averagePtsPerMatch(b) - averagePtsPerMatch(a) || Number(b.PTS || 0) - Number(a.PTS || 0))
  const t = rows[0]
  return { id: t.id, name: labelOf(t.id), pts: Number(t.PTS || 0), bp: Number(t.BP || 0) }
})

const hasPronostics = computed(() => titleRace.value.length > 0 || matchPredictions.value.length > 0)

async function loadStandings() {
  try {
    const { data } = await api.get('/standings')
    seasonStandings.value = Array.isArray(data.standings) ? data.standings : []
  } catch (_) {
    seasonStandings.value = []
  }
}

/* ====== Invités en vue ====== */
const featuredGuests = computed(() =>
  (featuredInvite.value || [])
    .filter(g => Number(g.apps || 0) > 0)
    .slice()
    .sort((a, b) => Number(b.avg || 0) - Number(a.avg || 0) || Number(b.pts || 0) - Number(a.pts || 0))
)
const topGuest = computed(() => featuredGuests.value[0] || null)
const hasGuests = computed(() => featuredGuests.value.length > 0)

// Stats du top invité, exprimées en moyenne par journée (équitable entre invités)
const topGuestStats = computed(() => {
  const g = topGuest.value
  if (!g || !g.apps) return null
  const bpj = g.bp / g.apps
  const bcj = g.bc / g.apps
  const diffj = g.diff / g.apps
  return {
    pts: g.avg.toFixed(1),
    bp: bpj.toFixed(1),
    bc: bcj.toFixed(1),
    diff: (diffj > 0 ? '+' : '') + diffj.toFixed(1),
    diffPos: diffj >= 0,
  }
})

function perJ(value, apps) {
  const a = Number(apps || 0)
  return a > 0 ? Number(value || 0) / a : 0
}
function diffPerJLabel(g) {
  const v = perJ(g.diff, g.apps)
  return (v > 0 ? '+' : '') + v.toFixed(1)
}

function guestInitials(g) {
  const s = String(g?.id || g?.name || '').replace(/[^A-Za-z0-9]/g, '')
  return (s.slice(0, 2) || '?').toUpperCase()
}

/* ====== Helpers ====== */
function fmtDate(d) {
  if (!d) return '—'
  try {
    return new Date(d + 'T12:00:00').toLocaleDateString('fr-FR', {
      weekday: 'long', day: '2-digit', month: 'long', year: 'numeric'
    })
  } catch (_) { return d }
}

function sc(v) {
  if (v === null || v === undefined || v === '') return null
  const n = Number(v)
  return isNaN(n) ? null : n
}

function inferRoleForPlayer(id) {
  const key = String(id || '')
  if (!key) return 'MEMBRE'
  if (key.startsWith('G_')) return 'INVITE'
  return playersRoleMap.value.get(key) || 'MEMBRE'
}

function formatTournamentDateTime(value) {
  if (!value) return '—'
  const d = new Date(value)
  if (Number.isNaN(d.getTime())) return String(value)
  return d.toLocaleString('fr-FR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function tournamentFormatLabel(format) {
  return {
    single_elimination: 'Elimination simple',
    double_elimination: 'Double elimination',
    round_robin: 'Round Robin',
    groups_knockout: 'Groupes + Finales'
  }[format] || format || 'Tournoi'
}

function tournamentStatusLabel(status) {
  return {
    draft: 'Brouillon',
    live: 'LIVE',
    completed: 'Terminé',
    archived: 'Archivé'
  }[status] || String(status || '').trim() || '—'
}

function averagePtsPerMatch(row) {
  const j = Number(row?.J || 0)
  if (!j) return 0
  return Number(row?.PTS || 0) / j
}

function rankLabel(rank) {
  if (!rank) return '—'
  return rank === 1 ? '1er' : `${rank}e`
}

function addLegToForm(agg, homeId, awayId, homeGoals, awayGoals) {
  if (!homeId || !awayId) return
  if (homeGoals === null || homeGoals === undefined || awayGoals === null || awayGoals === undefined) return

  const ensure = (id) => {
    if (!agg.has(id)) agg.set(id, { id, J: 0, V: 0, N: 0, D: 0, BP: 0, BC: 0 })
    return agg.get(id)
  }

  const home = ensure(homeId)
  const away = ensure(awayId)
  home.J++; away.J++
  home.BP += homeGoals; home.BC += awayGoals
  away.BP += awayGoals; away.BC += homeGoals

  if (homeGoals > awayGoals) {
    home.V++; away.D++
  } else if (homeGoals < awayGoals) {
    away.V++; home.D++
  } else {
    home.N++; away.N++
  }
}

function collectDivisionForm(recentDays, divisionKey) {
  const agg = new Map()
  for (const day of recentDays) {
    const matches = day?.payload?.[divisionKey] || []
    for (const m of matches) {
      const a1 = sc(m.a1), a2 = sc(m.a2), r1 = sc(m.r1), r2 = sc(m.r2)
      if (a1 !== null && a2 !== null) addLegToForm(agg, m.p1, m.p2, a1, a2)
      if (r1 !== null && r2 !== null) addLegToForm(agg, m.p2, m.p1, r2, r1)
    }
  }
  return [...agg.values()]
    .map(r => ({ ...r, PTS: r.V * 3 + r.N, DIFF: r.BP - r.BC }))
    .sort((a, b) => b.PTS - a.PTS || b.DIFF - a.DIFF || b.BP - a.BP || String(a.id).localeCompare(String(b.id)))
}

function extractInviteIdsFromPayload(payload) {
  const ids = new Set((payload?.tempGuests || []).map(g => String(g.player_id)))
  const scan = (matches) => {
    for (const m of matches || []) {
      for (const id of [m.p1, m.p2]) {
        if (!id) continue
        const key = String(id)
        if (key.startsWith('G_')) ids.add(key)
      }
    }
  }
  scan(payload?.d1)
  scan(payload?.d2)
  return [...ids]
}

/* ====== Navigation ====== */
function goToDay(day) {
  router.push({ path: '/journees', query: { day } })
}

/* ====== Realtime ====== */
function bindRealtimeListeners() {
  realtimeOffDayConfirmed = onRealtimeEvent('day:confirmed', async () => {
    await loadHeadline()
    await loadNextFixture()
  })

  realtimeOffTournamentChanged = onRealtimeEvent('tournament:changed', async () => {
    await loadNextFixture()
  })

  realtimeOffSeasonChanged = onRealtimeEvent('season:changed', async () => {
    await loadHeadline()
    await loadNextFixture()
  })
}

function unbindRealtimeListeners() {
  if (realtimeOffDayConfirmed) realtimeOffDayConfirmed()
  if (realtimeOffTournamentChanged) realtimeOffTournamentChanged()
  if (realtimeOffSeasonChanged) realtimeOffSeasonChanged()
  realtimeOffDayConfirmed = null
  realtimeOffTournamentChanged = null
  realtimeOffSeasonChanged = null
}

/* ====== Lifecycle ====== */
onMounted(async () => {
  await Promise.all([loadSeason(), loadPlayers(), loadStandings()])
  bindRealtimeListeners()
  await loadHeadline()
  await loadNextFixture()
  restartCardInsightsTicker()
  runTypingLoop()

  // Médias de l'accueil : URLs du CMS (Cloudinary) sinon découverte auto des assets.
  const anims = ['slide-float', 'slide-zoom', 'slide-spin', 'slide-drift']
  const cmsPhotos = (site.settings.efootHome?.slides || []).filter(Boolean)
  const cmsHero   = (site.settings.efootHome?.hero  || []).filter(Boolean)

  // Bande photos défilante
  if (cmsPhotos.length) {
    shuffledPhotos.value = shuffle(cmsPhotos.map(mediaUrl))
  } else {
    shuffledPhotos.value = shuffle(await probeAssets('Photo'))
  }

  // Hero (visuel rotatif)
  if (cmsHero.length) {
    heroSlides.value = cmsHero.map((src, i) => ({ src: mediaUrl(src), alt: `GOUZEPE ${i + 1}`, anim: anims[i % anims.length] }))
  } else {
    const imgs = await probeAssets('image')
    heroSlides.value = imgs.map((src, i) => ({ src, alt: `GOUZEPE ${i + 1}`, anim: anims[i % anims.length] }))
  }

  if (heroSlides.value.length) {
    heroSlideTimer = setInterval(() => {
      heroSlideIndex.value = (heroSlideIndex.value + 1) % heroSlides.value.length
    }, 3600)
  }
})

onUnmounted(() => {
  typingActive = false
  if (heroSlideTimer) clearInterval(heroSlideTimer)
  if (cardsInsightsTimer) clearInterval(cardsInsightsTimer)
  unbindRealtimeListeners()
})

/* ====== API calls ====== */
async function loadSeason() {
  try {
    const { data } = await api.get('/season/current')
    currentSeason.value = data
  } catch (_) {}
}

async function loadPlayers() {
  try {
    const { data } = await api.get('/players')
    allPlayers.value = data.players || []
    playersRoleMap.value = new Map(
      (data.players || []).map(p => [String(p.player_id), (p.role || 'MEMBRE').toUpperCase()])
    )
  } catch (_) {}
}

function restartCardInsightsTicker() {
  if (cardsInsightsTimer) clearInterval(cardsInsightsTimer)
  cardsInsightsTimer = setInterval(() => {
    if (headlineFlashes.value.length > 1) {
      let nextIdx = Math.floor(Math.random() * headlineFlashes.value.length)
      if (nextIdx === headlineFlashIndex.value) {
        nextIdx = (nextIdx + 1) % headlineFlashes.value.length
      }
      headlineFlashIndex.value = nextIdx
    }
  }, 3600)
}

async function fetchRecentConfirmedDays(days, limit = Number.POSITIVE_INFINITY) {
  const out = []
  const max = Number.isFinite(limit) ? Math.max(0, limit) : Number.POSITIVE_INFINITY
  for (let i = days.length - 1; i >= 0 && out.length < max; i--) {
    try {
      const { data } = await api.get(`/matchdays/${days[i]}`)
      out.push({ date: days[i], payload: data })
    } catch (_) {}
  }
  return out
}

async function loadGuestStats() {
  try {
    const { data } = await api.get('/season/guest-stats')
    featuredInvite.value = (data.guests || []).map(g => ({
      id:         g.player_id,
      name:       g.name || '',
      pts:        +g.pts,
      V:          +g.wins,
      n:          +g.draws,
      d:          +g.losses,
      bp:         +g.bp,
      bc:         +g.bc,
      apps:       +g.journees,
      avg:        +g.avg_pts,
      diff:       +g.bp - +g.bc,
      lastDate:   g.last_date ? String(g.last_date).slice(0, 10) : '',
      lastDivision: g.last_div || '',
      lastRank:   g.last_rank,
      lastTotal:  g.last_total,
    }))
    guestStatsLoaded.value = true
  } catch (_) {}
}

// Temps forts de la dernière journée publiée (récap "À la une").
function buildHeadlineFlashes(recentDays) {
  const latest = (recentDays || [])[0]
  const p = latest?.payload
  if (!p) return [{ tag: 'À la une', text: 'Publie une journée pour afficher les temps forts.' }]

  const flashes = []
  const allMatches = [...(p.d1 || []), ...(p.d2 || [])].filter(m => m?.p1 && m?.p2)

  // Carton du jour : plus large écart sur une manche
  let best = null
  for (const m of allMatches) {
    const legs = [
      { a: sc(m.a1), b: sc(m.a2) },
      { a: sc(m.r1), b: sc(m.r2) },
    ]
    for (const leg of legs) {
      if (leg.a === null || leg.b === null) continue
      const margin = Math.abs(leg.a - leg.b)
      if (margin <= 0) continue
      if (!best || margin > best.margin) {
        const p1Win = leg.a > leg.b
        best = {
          margin,
          winner: p1Win ? m.p1 : m.p2,
          loser: p1Win ? m.p2 : m.p1,
          wScore: Math.max(leg.a, leg.b),
          lScore: Math.min(leg.a, leg.b),
        }
      }
    }
  }
  if (best) {
    flashes.push({ tag: 'Carton du jour', text: `${labelOf(best.winner)} s'impose ${best.wScore}–${best.lScore} face à ${labelOf(best.loser)}.` })
  }

  // Buteur & patron du jour (membres uniquement, pour ne pas doublonner les invités)
  const agg = [...computeStandingsSimple(p.d1 || []), ...computeStandingsSimple(p.d2 || [])]
    .filter(r => inferRoleForPlayer(r.id) !== 'INVITE')
  if (agg.length) {
    const scorer = agg.slice().sort((a, b) => Number(b.BP || 0) - Number(a.BP || 0))[0]
    if (scorer && Number(scorer.BP || 0) > 0) {
      flashes.push({ tag: 'Buteur du jour', text: `${labelOf(scorer.id)} a fait trembler les filets : ${scorer.BP} but(s) sur la journée.` })
    }
    const boss = agg.slice().sort((a, b) =>
      Number(b.V || 0) - Number(a.V || 0) || (Number(b.BP || 0) - Number(b.BC || 0)) - (Number(a.BP || 0) - Number(a.BC || 0)))[0]
    if (boss && Number(boss.V || 0) > 0) {
      flashes.push({ tag: 'En patron', text: `${labelOf(boss.id)} a dominé sa journée (${boss.V} victoire(s)).` })
    }
  }

  if (!flashes.length) flashes.push({ tag: 'À la une', text: 'Journée publiée — temps forts à venir.' })
  return flashes
}

/* ====== News (À la une) ====== */
async function loadHeadline() {
  loadingNews.value = true
  try {
    if (!currentSeason.value?.id) {
      newsItems.value = [{ title: 'À la une', meta: 'Aucune saison active' }]
      headlineFlashes.value = [{ tag: 'À la une', text: 'Active une saison pour générer les tendances.' }]
      return
    }

    const { data: daysData } = await api.get(`/seasons/${currentSeason.value.id}/matchdays`)
    const days = (daysData.days || []).sort()
    if (!days.length) {
      newsItems.value = [{ title: 'À la une', meta: 'Aucune journée planifiée' }]
      headlineFlashes.value = [{ tag: 'À la une', text: 'Ajoute une première journée pour alimenter les highlights.' }]
      return
    }

    recentConfirmedDays.value = await fetchRecentConfirmedDays(days, days.length)
    const latest = recentConfirmedDays.value[0]
    if (!latest?.payload) {
      newsItems.value = [{ title: 'À la une', meta: 'Aucune journée publiée' }]
      headlineFlashes.value = [{ tag: 'À la une', text: 'Publie la prochaine journée pour afficher les tendances.' }]
      return
    }

    const st1 = computeStandingsSimple(latest.payload.d1 || []).filter(r => inferRoleForPlayer(r.id) !== 'INVITE')
    const st2 = computeStandingsSimple(latest.payload.d2 || []).filter(r => inferRoleForPlayer(r.id) !== 'INVITE')
    const fallbackChampionD1 = st1[0]?.id || '—'
    const fallbackChampionD2 = st2[0]?.id || '—'

    const championD1Label = latest.payload.champions?.d1?.id
      ? latest.payload.champions.d1.id + (latest.payload.champions.d1.team ? ` (${latest.payload.champions.d1.team})` : '')
      : fallbackChampionD1
    const championD2Label = latest.payload.champions?.d2?.id
      ? latest.payload.champions.d2.id + (latest.payload.champions.d2.team ? ` (${latest.payload.champions.d2.team})` : '')
      : fallbackChampionD2

    newsItems.value = [
      { title: 'Champion D1', meta: championD1Label },
      { title: 'Champion D2', meta: championD2Label }
    ]

    await loadGuestStats()
    headlineFlashes.value = buildHeadlineFlashes(recentConfirmedDays.value)
    headlineFlashIndex.value = 0
  } catch (_) {
    newsItems.value = [{ title: 'À la une', meta: 'Erreur de chargement' }]
    headlineFlashes.value = [{ tag: 'À la une', text: 'Impossible de calculer les highlights pour le moment.' }]
  } finally {
    loadingNews.value = false
    restartCardInsightsTicker()
  }
}

function computeStandingsSimple(matches) {
  const agg = new Map()
  const ensure = id => { if (!agg.has(id)) agg.set(id, { id, V: 0, N: 0, D: 0, BP: 0, BC: 0 }); return agg.get(id) }
  for (const m of matches) {
    if (!m.p1 || !m.p2) continue
    const a1 = sc(m.a1), a2 = sc(m.a2), r1 = sc(m.r1), r2 = sc(m.r2)
    if (a1 !== null && a2 !== null) {
      const A = ensure(m.p1), B = ensure(m.p2)
      if (a1 > a2) { A.V++; B.D++ } else if (a1 < a2) { B.V++; A.D++ } else { A.N++; B.N++ }
      A.BP += a1; A.BC += a2; B.BP += a2; B.BC += a1
    }
    if (r1 !== null && r2 !== null) {
      const A = ensure(m.p2), B = ensure(m.p1)
      if (r2 > r1) { A.V++; B.D++ } else if (r2 < r1) { B.V++; A.D++ } else { A.N++; B.N++ }
      A.BP += r2; A.BC += r1; B.BP += r1; B.BC += r2
    }
  }
  return [...agg.values()]
    .map(r => ({ ...r, PTS: r.V * 3 + r.N, DIFF: r.BP - r.BC }))
    .sort((a, b) => b.PTS - a.PTS || b.DIFF - a.DIFF || b.BP - a.BP)
}

/* ====== Next fixture ====== */
async function loadNextFixture() {
  loadingNextFixture.value = true
  nextFixtureMeta.value = ''
  nextFixtureTournaments.value = []
  try {
    const now = new Date()
    const dow = now.getDay()
    const add = ((6 - dow + 7) % 7) || 7
    const next = new Date(now)
    next.setDate(now.getDate() + add)
    const y = next.getFullYear()
    const m = String(next.getMonth() + 1).padStart(2, '0')
    const d = String(next.getDate()).padStart(2, '0')
    const target = `${y}-${m}-${d}`

    nextFixtureLabel.value = next.toLocaleDateString('fr-FR', { weekday: 'long', day: '2-digit', month: 'long', year: 'numeric' })

    // Charger d'abord la liste des journées connues de la saison
    let knownDays = []
    if (currentSeason.value?.id) {
      try {
        const { data: daysData } = await api.get(`/seasons/${currentSeason.value.id}/matchdays`)
        knownDays = daysData.days || []
        knownDaysCount.value = knownDays.length
        if (!recentConfirmedDays.value.length) {
          recentConfirmedDays.value = await fetchRecentConfirmedDays([...knownDays].sort(), knownDays.length)
        }
      } catch (_) {}
    }

    let payload = null
    if (knownDays.includes(target)) {
      try {
        const { data } = await api.get(`/matchdays/${target}`)
        nextFixtureStatus.value = 'Journée confirmée'
        nextFixtureDay.value = target
        payload = data
      } catch (_) {}
    } else {
      try {
        const { data } = await api.get(`/matchdays/draft/${target}`)
        nextFixtureStatus.value = 'Brouillon disponible'
        nextFixtureDay.value = target
        payload = data.payload || null
      } catch (_) {
        nextFixtureStatus.value = 'Pas encore créée'
        nextFixtureDay.value = ''
      }
    }

    // Tournois membre programmés le même jour
    try {
      const { data: tournamentDay } = await api.get(`/tournaments/member/day/${target}`)
      nextFixtureTournaments.value = Array.isArray(tournamentDay?.tournaments) ? tournamentDay.tournaments : []
    } catch (_) {
      nextFixtureTournaments.value = []
    }

    const tournamentCount = nextFixtureTournaments.value.length
    if (!payload && tournamentCount > 0) {
      nextFixtureStatus.value = 'Tournoi programmé'
      nextFixtureDay.value = target
    }

    if (payload) {
      const matchCount = (payload.d1?.length || 0) + (payload.d2?.length || 0)
      const inviteCount = extractInviteIdsFromPayload(payload).length
      nextFixtureMeta.value = `${matchCount} confrontation(s) prévues${inviteCount ? ` • ${inviteCount} invité(s)` : ''}${tournamentCount ? ` • ${tournamentCount} tournoi(s)` : ''}`
    } else if (tournamentCount > 0) {
      nextFixtureMeta.value = `${tournamentCount} tournoi(s) membre programmé(s)`
    } else {
      nextFixtureMeta.value = 'Aucune confrontation enregistrée pour le moment'
    }
    nextPayloadRef.value = payload
  } catch (_) {
  } finally {
    loadingNextFixture.value = false
    restartCardInsightsTicker()
  }
}
</script>

<style scoped>
.home-page {
  position: relative;
  width: 100%;
  min-height: calc(100dvh - 56px);
  overflow: hidden;
}

.home-content {
  position: relative;
  z-index: 1;
  width: 100%;
  min-width: 0;
  max-width: 100%;
  padding: clamp(14px, 2.2vw, 30px);
}

.home-content :deep(.card) {
  transition: transform 180ms ease, box-shadow 180ms ease, border-color 180ms ease;
}

.home-content :deep(.card:hover) {
  transform: translateY(-2px);
  box-shadow: 0 16px 34px rgba(2, 6, 23, 0.24);
  border-color: color-mix(in srgb, var(--border) 70%, #60a5fa 30%);
}

/* ── News card redesign ── */
.news-card {
  background: color-mix(in srgb, var(--card) 90%, transparent);
  border: 1px solid rgba(148,163,184,.15);
  border-radius: 18px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}
.news-card-header {
  padding: 1rem 1.25rem 0.75rem;
  border-bottom: 1px solid rgba(148,163,184,.1);
  background: rgba(148,163,184,.03);
}
.news-card-title-wrap { display: flex; align-items: center; justify-content: space-between; margin-bottom: 2px; }
.news-card-label { font-size: .75rem; font-weight: 800; text-transform: uppercase; letter-spacing: .1em; color: var(--muted); }
.news-card-date { font-size: .72rem; color: var(--muted); }
.live-badge {
  display: inline-flex; align-items: center; gap: .3rem;
  font-size: .62rem; font-weight: 800; letter-spacing: .1em;
  color: #22c55e; background: rgba(34,197,94,.1); padding: 2px 7px; border-radius: 99px;
}
.live-badge-dot { width: 5px; height: 5px; border-radius: 50%; background: #22c55e; animation: pulse 1.5s infinite; }
@keyframes pulse { 0%,100%{opacity:1} 50%{opacity:.4} }

.news-loading { display: flex; align-items: center; justify-content: center; padding: 2rem; }
.news-spinner { width: 20px; height: 20px; border: 2px solid rgba(34,197,94,.2); border-top-color: #22c55e; border-radius: 50%; animation: spin .6s linear infinite; }
@keyframes spin { to{transform:rotate(360deg)} }
.news-body { padding: 1rem 1.25rem; display: flex; flex-direction: column; gap: .75rem; flex: 1; }
.news-empty { font-size: .85rem; color: var(--muted); }

.news-champions { display: flex; flex-direction: column; gap: .5rem; }
.champion-row { display: flex; align-items: center; gap: .65rem; }
.champion-crown { font-size: 1.1rem; }
.champion-info { display: flex; flex-direction: column; gap: 1px; }
.champion-div { font-size: .65rem; font-weight: 800; text-transform: uppercase; letter-spacing: .08em; color: var(--muted); }
.champion-name { font-size: .92rem; font-weight: 700; }

.insight-pill {
  margin-top: .25rem;
  background: rgba(148,163,184,.06);
  border: 1px solid rgba(148,163,184,.12);
  border-radius: 10px; padding: .6rem .85rem;
  display: flex; align-items: flex-start; gap: .5rem;
}
.insight-pill-tag {
  font-size: .62rem; font-weight: 800; text-transform: uppercase; letter-spacing: .08em;
  color: #22c55e; white-space: nowrap; padding-top: 1px;
}
.insight-pill-text { font-size: .8rem; color: var(--muted); line-height: 1.5; }

.mini-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.next-pill {
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  padding: 4px 8px;
  border-radius: 999px;
  border: 1px solid var(--border);
  color: var(--muted);
  background: rgba(148, 163, 184, 0.08);
}

.card-next {
  position: relative;
  overflow: hidden;
}

.card-next::before {
  content: '';
  position: absolute;
  inset: 0 0 auto 0;
  height: 1px;
  background: linear-gradient(90deg, rgba(59, 130, 246, 0), rgba(59, 130, 246, 0.45), rgba(59, 130, 246, 0));
}

.insight-box {
  margin-top: 10px;
  padding: 10px 12px;
  border-radius: 12px;
  border: 1px solid rgba(59, 130, 246, 0.22);
  background: linear-gradient(140deg, rgba(59, 130, 246, 0.1), rgba(2, 132, 199, 0.06));
  min-height: 68px;
}

.insight-box--alt {
  border-color: rgba(34, 197, 94, 0.25);
  background: linear-gradient(140deg, rgba(34, 197, 94, 0.1), rgba(14, 116, 144, 0.05));
}

.insight-tag {
  display: inline-flex;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  color: #93c5fd;
  margin-bottom: 4px;
}

.insight-tag--alt {
  color: #86efac;
}

.insight-text {
  margin: 0;
  line-height: 1.35;
  font-size: 13px;
}

.insight-dots {
  display: flex;
  gap: 6px;
}

.insight-dot {
  width: 7px;
  height: 7px;
  border-radius: 999px;
  background: rgba(148, 163, 184, 0.3);
}

.insight-dot.active {
  background: var(--green);
}

.insight-fade-enter-active,
.insight-fade-leave-active {
  transition: opacity 220ms ease, transform 220ms ease;
}

.insight-fade-enter-from {
  opacity: 0;
  transform: translateY(8px);
}

.insight-fade-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}

/* ── Quick-link cards ── */
.quick-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 1.25rem 1rem;
  border-radius: 16px;
  border: 1px solid rgba(148, 163, 184, 0.12);
  background: color-mix(in srgb, var(--card) 90%, transparent);
  text-decoration: none;
  color: var(--text);
  transition: transform 180ms ease, box-shadow 180ms ease, border-color 180ms ease;
}

.quick-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 12px 28px rgba(2, 6, 23, 0.22);
  border-color: color-mix(in srgb, var(--border) 60%, #60a5fa 40%);
}

.quick-card-icon {
  font-size: 1.8rem;
}

.quick-card-icon-svg {
  width: 1.8rem;
  height: 1.8rem;
  color: var(--accent);
}

.quick-card-label {
  font-size: .9rem;
  font-weight: 700;
}

.quick-card-desc {
  font-size: .7rem;
  color: var(--muted);
  text-align: center;
}

.quick-card--journees:hover { border-color: color-mix(in srgb, var(--green) 50%, transparent); }
.quick-card--classement:hover { border-color: color-mix(in srgb, #f59e0b 50%, transparent); }
.quick-card--duels:hover { border-color: color-mix(in srgb, #ef4444 50%, transparent); }
.quick-card--tournois:hover { border-color: color-mix(in srgb, #3b82f6 50%, transparent); }

/* ── Hero section ── */
.hero-section {
  width: 100%;
  padding: clamp(18px, 3vw, 36px);
  border: 1px solid var(--border);
  border-radius: 16px;
  background: color-mix(in srgb, var(--panel) 78%, transparent);
  backdrop-filter: blur(5px);
  margin-bottom: 16px;
  display: flex;
  flex-direction: column;
  gap: clamp(12px, 2vw, 20px);
}

/* ── Corps : texte + visuel côte à côte ── */
.hero-body {
  display: flex;
  align-items: center;
  gap: clamp(20px, 4vw, 48px);
}

.hero-left {
  flex: 1 1 0;
  min-width: 0;
}

/* ── Visuel animé ── */
.hero-visual {
  flex: 0 0 clamp(160px, 28vw, 340px);
  height: clamp(160px, 28vw, 340px);
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Anneaux rotatifs */
.hero-ring {
  position: absolute;
  inset: 0;
  border-radius: 50%;
  border: 1.5px solid transparent;
  pointer-events: none;
}
.hero-ring-outer {
  border-color: rgba(22, 163, 74, 0.22);
  animation: ring-cw 12s linear infinite;
  box-shadow: 0 0 18px rgba(22, 163, 74, 0.08);
}
.hero-ring-outer::before {
  content: '';
  position: absolute;
  top: -4px; left: 40%;
  width: 8px; height: 8px;
  border-radius: 50%;
  background: #16a34a;
  box-shadow: 0 0 10px 3px rgba(22, 163, 74, 0.6);
}
.hero-ring-inner {
  inset: 18px;
  border-color: rgba(59, 130, 246, 0.18);
  animation: ring-ccw 9s linear infinite;
}
.hero-ring-inner::before {
  content: '';
  position: absolute;
  bottom: -4px; right: 38%;
  width: 6px; height: 6px;
  border-radius: 50%;
  background: #3b82f6;
  box-shadow: 0 0 8px 2px rgba(59, 130, 246, 0.55);
}

/* Halo de fond */
.hero-glow {
  position: absolute;
  inset: 15%;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(22, 163, 74, 0.18) 0%, transparent 72%);
  animation: glow-pulse 3.5s ease-in-out infinite;
  pointer-events: none;
}

/* Conteneur image — remplit le cercle intérieur */
.hero-img-wrap {
  position: relative;
  z-index: 2;
  width: calc(100% - 44px);
  height: calc(100% - 44px);
  border-radius: 50%;
  overflow: hidden;
  box-shadow: 0 0 32px rgba(22, 163, 74, 0.28);
}
.hero-slide-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center;
  display: block;
}

/* Animation par slide */
.slide-float .hero-slide-img { animation: float-anim 4s ease-in-out infinite; }
.slide-zoom  .hero-slide-img { animation: zoom-pulse 3.5s ease-in-out infinite; }
.slide-spin  .hero-slide-img { animation: spin-float 7s ease-in-out infinite; }
.slide-drift .hero-slide-img { animation: drift-anim 5s ease-in-out infinite; }

/* Dots */
.hero-dots {
  position: absolute;
  bottom: -18px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 6px;
  z-index: 3;
}
.hero-dot {
  width: 6px; height: 6px;
  border-radius: 50%;
  background: rgba(148, 163, 184, 0.4);
  transition: background 0.3s, transform 0.3s;
}
.hero-dot.active {
  background: var(--green);
  transform: scale(1.35);
  box-shadow: 0 0 6px rgba(22, 163, 74, 0.6);
}

/* ── Transitions image ── */
.hero-img-enter-active { animation: img-in  0.65s cubic-bezier(0.22,1,0.36,1) both; }
.hero-img-leave-active { animation: img-out 0.4s ease both; }

/* ── Keyframes ── */
@keyframes ring-cw  { from { transform: rotate(0deg); }   to { transform: rotate(360deg); } }
@keyframes ring-ccw { from { transform: rotate(0deg); }   to { transform: rotate(-360deg); } }

@keyframes glow-pulse {
  0%, 100% { opacity: 0.6; transform: scale(1); }
  50%       { opacity: 1;   transform: scale(1.12); }
}
@keyframes float-anim {
  0%, 100% { transform: translateY(0); }
  50%       { transform: translateY(-14px); }
}
@keyframes zoom-pulse {
  0%, 100% { transform: scale(1);    filter: drop-shadow(0 8px 24px rgba(22,163,74,.35)); }
  50%       { transform: scale(1.07); filter: drop-shadow(0 12px 32px rgba(22,163,74,.55)); }
}
@keyframes spin-float {
  0%   { transform: translateY(0)    rotate(0deg); }
  25%  { transform: translateY(-8px) rotate(5deg); }
  50%  { transform: translateY(-14px) rotate(0deg); }
  75%  { transform: translateY(-6px) rotate(-5deg); }
  100% { transform: translateY(0)    rotate(0deg); }
}
@keyframes drift-anim {
  0%, 100% { transform: translateX(0); }
  50%       { transform: translateX(10px); }
}
@keyframes img-in {
  from { opacity: 0; transform: scale(0.88) translateY(14px); }
  to   { opacity: 1; transform: scale(1)    translateY(0); }
}
@keyframes img-out {
  from { opacity: 1; transform: scale(1); }
  to   { opacity: 0; transform: scale(1.06) translateY(-10px); }
}

/* Cache le visuel sur très petit écran */
@media (max-width: 540px) {
  .hero-visual { display: none; }
}

/* === Bande photos défilante infinie === */
.hero-photos-track-wrap {
  overflow: hidden;
  padding: 10px 0;
  mask-image: linear-gradient(to right, transparent 0%, black 6%, black 94%, transparent 100%);
  -webkit-mask-image: linear-gradient(to right, transparent 0%, black 6%, black 94%, transparent 100%);
}

.hero-photos-track-wrap:hover .hero-photos-track {
  animation-play-state: paused;
}

.hero-photos-track {
  display: flex;
  gap: 14px;
  width: max-content;
  animation: photo-scroll 28s linear infinite;
}

@keyframes photo-scroll {
  0%   { transform: translateX(0); }
  100% { transform: translateX(-50%); }
}

/* frame : gère seulement le flottement */
.hero-photo-frame {
  flex: 0 0 clamp(90px, 10vw, 130px);
  height: clamp(90px, 10vw, 130px);
  animation: photo-float calc(3s + var(--fi, 0) * 0.4s) ease-in-out infinite alternate;
  animation-delay: calc(var(--fi, 0) * -0.35s);
  will-change: transform;
  z-index: 1;
}

.hero-photo-frame:hover {
  animation-play-state: paused;
  z-index: 5;
}

.hero-photo-frame:hover .hero-photo-clip {
  box-shadow: 0 10px 32px rgba(22, 163, 74, 0.4);
  border-color: rgba(22, 163, 74, 0.5);
  transform: scale(1.1);
}

/* clip : gère le masque, la bordure et le contenu */
.hero-photo-clip {
  width: 100%;
  height: 100%;
  border-radius: 12px;
  overflow: hidden;
  border: 2px solid rgba(255, 255, 255, 0.07);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.45);
  transition: transform 0.3s ease, box-shadow 0.3s ease, border-color 0.3s ease;
  background: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
}

@keyframes photo-float {
  0%   { transform: translateY(-5px) rotate(-1.5deg); }
  50%  { transform: translateY(2px)  rotate(0.5deg);  }
  100% { transform: translateY(6px)  rotate(1.8deg);  }
}

.hero-photo-img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  object-position: center;
  display: block;
  background: #ffffff;
}

/* === GOUZEPE Gaming Club === */
.hero-club {
  margin: 0;
  display: flex;
  align-items: baseline;
  gap: 10px;
  flex-wrap: wrap;
}

.hero-club-name {
  display: inline;
  font-size: clamp(26px, 3.8vw, 48px);
  font-weight: 900;
  letter-spacing: -0.02em;
  background: linear-gradient(105deg, #16a34a 0%, #4ade80 30%, #22d3ee 58%, #60a5fa 80%, #16a34a 100%);
  background-size: 300% 100%;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: club-reveal 0.65s cubic-bezier(0.16, 1, 0.3, 1) both,
             shimmer-club 4.5s linear 0.8s infinite;
}

.hero-club-label {
  display: inline;
  font-size: clamp(12px, 1.6vw, 18px);
  font-weight: 700;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: var(--text);
  opacity: 0.72;
  animation: club-reveal 0.65s cubic-bezier(0.16, 1, 0.3, 1) 0.18s both;
}

@keyframes club-reveal {
  from { opacity: 0; transform: translateY(18px); }
  to   { opacity: 1; transform: translateY(0); }
}

@keyframes shimmer-club {
  0%   { background-position: 300% 0; }
  100% { background-position: -300% 0; }
}

/* === Bienvenue au club === */
.hero-title {
  margin: 0;
  font-size: clamp(20px, 3vw, 36px);
  line-height: 1.12;
  font-weight: 800;
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  gap: 10px;
}

.hero-accent {
  color: var(--green);
  text-shadow: 0 8px 22px color-mix(in srgb, var(--green) 35%, transparent);
}

.hero-sub {
  margin: 12px 0 0;
  max-width: 920px;
  color: var(--muted);
  font-size: clamp(14px, 1.8vw, 18px);
}

:root.light .hero-section {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: none;
}

:root.light .hero-sub {
  color: #475569;
}

:root.light .home-content :deep(.card) {
  background: rgba(255, 255, 255, 0.94);
  border-color: rgba(148, 163, 184, 0.28);
}

:root.light .home-content :deep(.card:hover) {
  box-shadow: 0 10px 24px rgba(15, 23, 42, 0.12);
}

:root.light .insight-box {
  border-color: rgba(59, 130, 246, 0.3);
  background: linear-gradient(140deg, rgba(59, 130, 246, 0.09), rgba(2, 132, 199, 0.04));
}

:root.light .insight-box--alt {
  border-color: rgba(22, 163, 74, 0.28);
  background: linear-gradient(140deg, rgba(34, 197, 94, 0.1), rgba(14, 116, 144, 0.04));
}

:root.light .insight-text {
  color: #1f2937;
}

.reveal {
  animation: rise-in 520ms ease both;
}

.delay-1 {
  animation-delay: 110ms;
}

.delay-2 {
  animation-delay: 200ms;
}

.hero-typing {
  white-space: nowrap;
  display: inline;
}

.hero-cursor {
  display: inline-block;
  margin-left: 1px;
  color: var(--green);
  font-weight: 400;
  animation: cursor-blink 0.75s step-end infinite;
}

@keyframes cursor-blink {
  0%, 100% { opacity: 1; }
  50%       { opacity: 0; }
}

@keyframes rise-in {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes pulse-live {
  0%,
  100% { box-shadow: 0 0 0 0 rgba(22, 163, 74, 0.24); }
  50% { box-shadow: 0 0 0 8px rgba(22, 163, 74, 0); }
}

@media (prefers-reduced-motion: reduce) {
  .reveal,
  .delay-1,
  .delay-2 {
    animation: none !important;
  }

  .home-content :deep(.card),
  .insight-fade-enter-active,
  .insight-fade-leave-active,
  .hero-cursor {
    transition: none !important;
    animation: none !important;
  }
}

/* ====== Pronostics ====== */
/* Contention : empêcher tout débordement horizontal (min-width:0 sur la chaîne flex/grid) */
.pronos-card, .guests-card { margin-bottom: 16px; overflow: hidden; min-width: 0; max-width: 100%; }
.pronos-grid, .pronos-block, .guests-inline, .title-race, .pred-list,
.guest-hero, .guest-hero-id, .guest-hero-stats, .pred-row, .pred-top, .tr-row, .guest-row { min-width: 0; max-width: 100%; }
.pronos-head { display: flex; align-items: baseline; justify-content: space-between; gap: .5rem; margin-bottom: 1rem; }
.pronos-sub { font-size: .72rem; color: var(--muted); text-transform: uppercase; letter-spacing: .05em; font-weight: 600; }
.pronos-grid { display: grid; grid-template-columns: minmax(0, 1fr); gap: 1.1rem; }
@media (min-width: 900px) { .pronos-grid { grid-template-columns: minmax(0, 0.85fr) minmax(0, 1.15fr); } }

.pronos-block-head { display: flex; align-items: center; justify-content: space-between; gap: .5rem; margin-bottom: .6rem; }
.pronos-block-title { font-size: .72rem; font-weight: 800; text-transform: uppercase; letter-spacing: .06em; color: var(--muted); }
.pronos-count { font-size: .68rem; font-weight: 700; color: var(--muted); background: color-mix(in srgb, var(--panel) 70%, transparent); border: 1px solid var(--border); border-radius: 999px; padding: .05rem .45rem; }

.pronos-chip { font-size: .62rem; font-weight: 800; text-transform: uppercase; letter-spacing: .05em; padding: .12rem .5rem; border-radius: 999px; }
.pronos-chip.tone-strong { color: #22c55e; background: color-mix(in srgb, #22c55e 16%, transparent); border: 1px solid color-mix(in srgb, #22c55e 35%, transparent); }
.pronos-chip.tone-mid { color: var(--accent-l, var(--accent)); background: color-mix(in srgb, var(--accent) 14%, transparent); border: 1px solid color-mix(in srgb, var(--accent) 32%, transparent); }
.pronos-chip.tone-open { color: #f59e0b; background: color-mix(in srgb, #f59e0b 14%, transparent); border: 1px solid color-mix(in srgb, #f59e0b 32%, transparent); }

/* Course au titre */
.title-race { display: flex; flex-direction: column; gap: .3rem; }
.tr-row { display: grid; grid-template-columns: 1.4rem minmax(0, 1fr) auto auto; align-items: center; gap: .55rem; padding: .4rem .55rem; border-radius: 9px; border: 1px solid color-mix(in srgb, var(--border) 55%, transparent); background: color-mix(in srgb, var(--panel) 55%, transparent); }
.tr-row.leader { border-color: color-mix(in srgb, #22c55e 40%, var(--border)); background: color-mix(in srgb, #22c55e 8%, transparent); }
.tr-rank { font-weight: 800; font-size: .8rem; color: var(--muted); text-align: center; }
.tr-row.leader .tr-rank { color: #22c55e; }
.tr-name { font-weight: 600; font-size: .88rem; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.tr-moy { font-family: var(--font-title); font-weight: 800; font-size: .9rem; font-variant-numeric: tabular-nums; }
.tr-gap { font-size: .7rem; color: var(--muted); font-variant-numeric: tabular-nums; min-width: 3.2rem; text-align: right; }
.tr-row.leader .tr-gap { color: #22c55e; font-weight: 700; }

.pronos-form-line { margin-top: .65rem; font-size: .78rem; display: flex; align-items: center; gap: .35rem; flex-wrap: wrap; }
.pronos-form-line .dot { width: 7px; height: 7px; border-radius: 50%; background: var(--accent); flex: none; }
.pronos-form-line .muted { color: var(--muted); }

/* Affiches */
.pred-list { display: flex; flex-direction: column; gap: .6rem; max-height: 360px; overflow-y: auto; padding-right: .35rem; scrollbar-width: thin; }
.pred-list::-webkit-scrollbar { width: 7px; }
.pred-list::-webkit-scrollbar-thumb { background: color-mix(in srgb, var(--muted) 35%, transparent); border-radius: 999px; }
.pred-list::-webkit-scrollbar-track { background: transparent; }
.pred-row { padding: .55rem .6rem; border-radius: 10px; border: 1px solid color-mix(in srgb, var(--border) 55%, transparent); background: color-mix(in srgb, var(--panel) 50%, transparent); }
.pred-top { display: grid; grid-template-columns: minmax(0, 1fr) auto minmax(0, 1fr); align-items: center; gap: .5rem; margin-bottom: .4rem; }
.pred-side { font-size: .85rem; font-weight: 600; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.pred-side.right { text-align: right; }
.pred-side.fav { color: var(--accent-l, var(--accent)); font-weight: 800; }
.pred-div { font-size: .58rem; font-weight: 800; letter-spacing: .06em; color: var(--muted); border: 1px solid var(--border); border-radius: 999px; padding: .04rem .4rem; }
.pred-bar { height: 7px; border-radius: 999px; overflow: hidden; background: color-mix(in srgb, var(--muted) 22%, transparent); }
.pred-bar-fill { height: 100%; border-radius: 999px; background: linear-gradient(90deg, var(--accent), var(--accent-l, var(--accent))); transition: width .4s ease; }
.pred-foot { display: flex; align-items: center; justify-content: space-between; gap: .5rem; margin-top: .32rem; }
.pred-pct { font-size: .72rem; font-weight: 700; font-variant-numeric: tabular-nums; color: var(--muted); }
.pred-verdict { font-size: .72rem; color: var(--muted); text-align: center; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

.pronos-empty { font-size: .82rem; color: var(--muted); line-height: 1.5; padding: .4rem 0; }

/* ====== Invités en vue ====== */
.guests-card { margin-bottom: 16px; }
.guests-inline { margin-top: 1.1rem; padding-top: .9rem; border-top: 1px solid color-mix(in srgb, var(--border) 60%, transparent); }
.guests-inline .pronos-block-head { margin-bottom: .6rem; }
.guests-inline .guest-hero-stats { gap: .85rem; }
.guest-hero {
  display: flex; align-items: center; justify-content: space-between; gap: 1rem; flex-wrap: wrap;
  padding: .85rem 1rem; border-radius: 12px;
  border: 1px solid color-mix(in srgb, var(--accent) 28%, var(--border));
  background: color-mix(in srgb, var(--accent) 7%, transparent);
}
.guest-hero-id { display: flex; align-items: center; gap: .7rem; min-width: 0; flex: 1; }
.guest-avatar {
  flex: none; width: 2.4rem; height: 2.4rem; border-radius: 50%;
  display: inline-flex; align-items: center; justify-content: center;
  font-family: var(--font-title); font-weight: 800; font-size: .85rem; color: #fff;
  background: linear-gradient(135deg, var(--accent), var(--accent-l, var(--accent)));
}
.guest-hero-name { font-weight: 800; font-size: 1rem; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.guest-hero-sub { font-size: .72rem; color: var(--muted); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.guest-badge {
  flex: none; font-size: .58rem; font-weight: 800; text-transform: uppercase; letter-spacing: .06em;
  color: var(--accent-l, var(--accent)); border: 1px solid color-mix(in srgb, var(--accent) 35%, transparent);
  background: color-mix(in srgb, var(--accent) 12%, transparent); border-radius: 999px; padding: .12rem .5rem;
}
.guest-hero-stats { display: flex; gap: 1.1rem; flex-wrap: wrap; }
.ghs { display: flex; flex-direction: column; align-items: center; }
.ghs-v { font-family: var(--font-title); font-weight: 900; font-size: 1.15rem; line-height: 1; font-variant-numeric: tabular-nums; }
.ghs-v.pos { color: #22c55e; }
.ghs-v.neg { color: var(--red, #ef4444); }
.ghs-l { font-size: .58rem; font-weight: 700; text-transform: uppercase; letter-spacing: .05em; color: var(--muted); margin-top: .15rem; }

.guest-list { display: flex; flex-direction: column; gap: .25rem; margin-top: .7rem; }
.guest-row {
  display: grid; grid-template-columns: 1.4rem minmax(0, 1fr) auto auto; align-items: center; gap: .55rem;
  padding: .4rem .55rem; border-radius: 8px; border: 1px solid color-mix(in srgb, var(--border) 50%, transparent);
}
.guest-rank { font-weight: 800; font-size: .78rem; color: var(--muted); text-align: center; }
.guest-name { font-weight: 600; font-size: .86rem; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.guest-meta { font-size: .72rem; color: var(--muted); }
.guest-avg { font-family: var(--font-title); font-weight: 800; font-size: .9rem; font-variant-numeric: tabular-nums; }
.guest-avg small { font-size: .58rem; font-weight: 600; color: var(--muted); }

/* ====== Responsive mobile — Pronostics & Invités ====== */
@media (max-width: 640px) {
  .pronos-grid { gap: .9rem; }
  .pronos-head { flex-wrap: wrap; gap: .15rem; }
  .pronos-block-head { flex-wrap: wrap; gap: .25rem; }

  /* Course au titre */
  .tr-row { grid-template-columns: 1.3rem minmax(0, 1fr) auto auto; gap: .45rem; padding: .4rem .5rem; }
  .tr-name { font-size: .82rem; }
  .tr-moy { font-size: .85rem; }
  .tr-gap { min-width: 2.8rem; font-size: .66rem; }

  /* Affiches : verdict sur sa propre ligne (plus de troncature) */
  .pred-list { max-height: 46vh; }
  .pred-row { padding: .55rem; }
  .pred-side { font-size: .82rem; }
  .pred-foot { flex-wrap: wrap; row-gap: .15rem; }
  .pred-verdict { order: 3; flex: 1 0 100%; white-space: normal; text-align: center; line-height: 1.3; margin-top: .15rem; }

  /* Invité vedette : stats réparties sur toute la largeur */
  .guest-hero { gap: .7rem; padding: .75rem .85rem; }
  .guest-hero-id { width: 100%; }
  .guest-hero-stats { width: 100%; justify-content: space-between; gap: .4rem; }
  .ghs-v { font-size: 1.05rem; }
  .ghs-l { font-size: .54rem; }

  /* Liste des invités */
  .guest-row { grid-template-columns: 1.3rem minmax(0, 1fr) auto; gap: .45rem; }
  .guest-meta { display: none; }
  .guest-avg { font-size: .85rem; }
}

@media (max-width: 380px) {
  .guest-badge { display: none; }
  .guest-hero-stats { gap: .25rem; }
  .ghs-v { font-size: .95rem; }
  .pred-div { display: none; }
}
</style>
