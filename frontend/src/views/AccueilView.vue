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

            <p class="text-xs" style="color:var(--muted)">Pronostics</p>
            <Transition name="insight-fade" mode="out-in">
              <div v-if="currentNextInsight" :key="'next-' + nextInsightIndex" class="insight-box insight-box--alt">
                <span class="insight-tag insight-tag--alt">{{ currentNextInsight.tag }}</span>
                <p class="insight-text">{{ currentNextInsight.text }}</p>
              </div>
            </Transition>
            <div v-if="nextInsights.length > 1" class="insight-dots" aria-hidden="true">
              <span
                v-for="(_, i) in nextInsights"
                :key="'dot-' + i"
                class="insight-dot"
                :class="{ active: i === nextInsightIndex }"
              />
            </div>
          </div>
        </div>
      </div>

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
const nextInsights      = ref([])
const nextInsightIndex  = ref(0)
const featuredInvite    = ref([])   // tableau trié avg desc
const guestStatsLoaded  = ref(false)
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
const currentNextInsight = computed(() => nextInsights.value[nextInsightIndex.value] || null)
const headlineLastPublishedLabel = computed(() => {
  const d = recentConfirmedDays.value[0]?.date
  return d ? fmtDate(d) : ''
})

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

function pickRandom(arr) {
  if (!Array.isArray(arr) || !arr.length) return ''
  return arr[Math.floor(Math.random() * arr.length)] || ''
}

function maybe(probability = 0.5) {
  return Math.random() < Math.max(0, Math.min(1, Number(probability) || 0))
}

function randomBetween(min, max) {
  const lo = Math.ceil(Number(min) || 0)
  const hi = Math.floor(Number(max) || 0)
  if (hi <= lo) return lo
  return lo + Math.floor(Math.random() * (hi - lo + 1))
}

function shuffleArray(arr) {
  const copy = [...arr]
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[copy[i], copy[j]] = [copy[j], copy[i]]
  }
  return copy
}

function takeRandom(arr, count) {
  return shuffleArray(arr).slice(0, Math.max(0, Math.min(arr.length, count)))
}

function averagePtsPerMatch(row) {
  const j = Number(row?.J || 0)
  if (!j) return 0
  return Number(row?.PTS || 0) / j
}

function formatAverage(value) {
  const n = Number(value || 0)
  return n.toFixed(2).replace('.', ',')
}

function rankLabel(rank) {
  if (!rank) return '—'
  return rank === 1 ? '1er' : `${rank}e`
}

function pickWeightedFromTop(sortedRows, topN = 5) {
  if (!Array.isArray(sortedRows) || !sortedRows.length) return null
  const cap = Math.max(1, Math.min(topN, sortedRows.length))
  const pool = sortedRows.slice(0, cap)
  const totalWeight = pool.reduce((sum, _, idx) => sum + (cap - idx), 0)
  let roll = Math.random() * totalWeight
  for (let idx = 0; idx < pool.length; idx++) {
    roll -= (cap - idx)
    if (roll <= 0) return pool[idx]
  }
  return pool[0]
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
  await Promise.all([loadSeason(), loadPlayers()])
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
    if (nextInsights.value.length > 1) {
      let nextIdx = Math.floor(Math.random() * nextInsights.value.length)
      if (nextIdx === nextInsightIndex.value) {
        nextIdx = (nextIdx + 1) % nextInsights.value.length
      }
      nextInsightIndex.value = nextIdx
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

function buildHeadlineFlashes(recentDays) {
  if (!featuredInvite.value || !featuredInvite.value.length) {
    return [{
      tag: 'Invité en vue',
      text: 'Aucun invité actif détecté sur la saison en cours.'
    }]
  }

  const inv = featuredInvite.value[0]
  const avgBP = inv.apps ? (inv.bp / inv.apps).toFixed(1) : '0'
  const avgBC = inv.apps ? (inv.bc / inv.apps).toFixed(1) : '0'
  return [{
    tag: 'Invité en vue',
    text: pickRandom([
      `${inv.id} domine les invités avec ${inv.avg.toFixed(1)} pts/journée sur les dernières journées (${inv.V}V, ${inv.bp}BP). ${rankLabel(inv.lastRank)} en ${inv.lastDivision || 'D?'} lors de sa dernière sortie.`,
      `${inv.id} s'impose comme l'invité le plus performant récemment — ${inv.pts} pts en ${inv.apps} journée(s), ${avgBP} buts/journée. Capable de bousculer la hiérarchie.`,
      `${inv.id} fait parler sur les dernières journées : ${inv.V} victoire(s), ${inv.diff > 0 ? '+' : ''}${inv.diff} de diff. Un invité qui pèse en ${inv.lastDivision || 'D?'}.`
    ])
  }]
}

function buildNextInsights(recentDays, nextPayload) {
  const tournamentPicks = []
  const nextTournaments = nextFixtureTournaments.value || []
  if (nextTournaments.length) {
    const sortedTournaments = [...nextTournaments].sort((a, b) =>
      new Date(a?.tournament?.starts_at || 0).getTime() - new Date(b?.tournament?.starts_at || 0).getTime()
    )
    const lead = sortedTournaments[0]?.tournament
    if (lead) {
      const participants = Number(lead.participants_count || 0) || 0
      const at = lead.starts_at ? ` • ${formatTournamentDateTime(lead.starts_at)}` : ''
      tournamentPicks.push({
        tag: 'Tournoi',
        text: `${lead.name} (${tournamentFormatLabel(lead.format)}) • ${tournamentStatusLabel(lead.status)}${participants ? ` • ${participants} participant(s)` : ''}${at}.`
      })
      const comment = String(lead.day_comment || '').trim()
      if (comment) {
        tournamentPicks.push({
          tag: 'Commentaire tournoi',
          text: comment
        })
      }
    }
    if (sortedTournaments.length > 1) {
      tournamentPicks.push({
        tag: 'Programme tournoi',
        text: `${sortedTournaments.length} tournoi(s) membre sont programmés sur cette date.`
      })
    }
  }

  const historyDays = Array.isArray(recentDays) ? recentDays : []
  const lastTwoDays = historyDays.slice(0, 2)
  const lastFourDays = historyDays.slice(0, 4)

  // Build a complete set of invite IDs across ALL recent days
  const allInviteIds = new Set()
  for (const day of historyDays) {
    for (const g of day.payload?.tempGuests || []) allInviteIds.add(String(g.player_id))
    for (const divKey of ['d1', 'd2']) {
      for (const m of day.payload?.[divKey] || []) {
        for (const pid of [m.p1, m.p2]) {
          if (pid && String(pid).startsWith('G_')) allInviteIds.add(String(pid))
        }
      }
    }
  }
  const isInviteId = (id) => allInviteIds.has(String(id)) || String(id).startsWith('G_') || inferRoleForPlayer(id) === 'INVITE'

  const form2D1 = collectDivisionForm(lastTwoDays, 'd1').filter(r => !isInviteId(r.id))
  const form2D2 = collectDivisionForm(lastTwoDays, 'd2').filter(r => !isInviteId(r.id))
  const form4D1 = collectDivisionForm(lastFourDays, 'd1').filter(r => !isInviteId(r.id))
  const form4D2 = collectDivisionForm(lastFourDays, 'd2').filter(r => !isInviteId(r.id))

  const picks = []
  const nextPlayers = new Set(
    [...(nextPayload?.d1 || []), ...(nextPayload?.d2 || [])]
      .flatMap(m => [m?.p1, m?.p2])
      .filter(Boolean)
      .map(v => String(v))
  )
  const focusRows = (rows) => {
    if (!nextPlayers.size) return rows
    const filtered = rows.filter(r => nextPlayers.has(String(r.id)))
    return filtered.length ? filtered : rows
  }

  const buildTopPick = (rows, metric = 'ppm') => {
    const pool = rows.slice()
    if (!pool.length) return null
    if (metric === 'attack') {
      pool.sort((a, b) => Number(b.BP || 0) - Number(a.BP || 0) || String(a.id).localeCompare(String(b.id)))
    } else if (metric === 'defense') {
      pool.sort((a, b) => Number(a.BC || 0) - Number(b.BC || 0) || Number(b.J || 0) - Number(a.J || 0))
    } else if (metric === 'draw') {
      pool.sort((a, b) => Number(b.N || 0) - Number(a.N || 0) || String(a.id).localeCompare(String(b.id)))
    } else {
      pool.sort((a, b) => averagePtsPerMatch(b) - averagePtsPerMatch(a) || Number(b.PTS || 0) - Number(a.PTS || 0))
    }
    return pickWeightedFromTop(pool, Math.min(5, pool.length))
  }

  if (form2D1[0] && maybe(0.95)) {
    picks.push({
      tag: 'Dynamique D1',
      text: pickRandom([
        `${form2D1[0].id} est en forme sur les 2 dernières journées (${form2D1[0].PTS} pts).`,
        `${form2D1[0].id} accélère en D1 sur les 2 dernières journées.`,
        `${form2D1[0].id} garde un rythme élevé récemment en D1.`
      ])
    })
  }
  if (form2D2[0] && maybe(0.95)) {
    picks.push({
      tag: 'Dynamique D2',
      text: pickRandom([
        `${form2D2[0].id} monte en puissance en D2 sur les 2 dernières journées.`,
        `${form2D2[0].id} imprime le rythme D2 récemment (${form2D2[0].PTS} pts).`,
        `${form2D2[0].id} enchaîne les bonnes sorties en D2.`
      ])
    })
  }

  const topD1Two = buildTopPick(focusRows(form2D1), 'ppm')
  if (topD1Two && maybe(0.95)) {
    const d1Moy = formatAverage(averagePtsPerMatch(topD1Two))
    picks.push({
      tag: 'Forme 2J D1',
      text: pickRandom([
        `${topD1Two.id} ressort sur 2 journées en D1 (moyenne ${d1Moy}).`,
        `${topD1Two.id} se détache en D1 sur les 2 dernières journées (${d1Moy} de moyenne).`
      ])
    })
  }

  const topD2Two = buildTopPick(focusRows(form2D2), 'ppm')
  if (topD2Two && maybe(0.95)) {
    const d2Moy = formatAverage(averagePtsPerMatch(topD2Two))
    picks.push({
      tag: 'Forme 2J D2',
      text: pickRandom([
        `${topD2Two.id} ressort sur 2 journées en D2 (moyenne ${d2Moy}).`,
        `${topD2Two.id} se détache en D2 sur les 2 dernières journées (${d2Moy} de moyenne).`
      ])
    })
  }

  const topD1Four = buildTopPick(focusRows(form4D1), 'ppm')
  if (topD1Four && maybe(0.9)) {
    const d1Moy4 = formatAverage(averagePtsPerMatch(topD1Four))
    picks.push({
      tag: 'Tendance 4J D1',
      text: pickRandom([
        `${topD1Four.id} tient une bonne cadence sur 4 journées en D1 (moyenne ${d1Moy4}).`,
        `${topD1Four.id} reste régulier sur le dernier mois D1 (${d1Moy4} de moyenne).`
      ])
    })
  }

  const topD2Four = buildTopPick(focusRows(form4D2), 'ppm')
  if (topD2Four && maybe(0.9)) {
    const d2Moy4 = formatAverage(averagePtsPerMatch(topD2Four))
    picks.push({
      tag: 'Tendance 4J D2',
      text: pickRandom([
        `${topD2Four.id} tient une bonne cadence sur 4 journées en D2 (moyenne ${d2Moy4}).`,
        `${topD2Four.id} reste régulier sur le dernier mois D2 (${d2Moy4} de moyenne).`
      ])
    })
  }

  const pool2 = focusRows([...form2D1, ...form2D2])
  const pool4 = focusRows([...form4D1, ...form4D2])

  const topAttack2 = buildTopPick(pool2, 'attack')
  if (topAttack2 && maybe(0.85)) {
    picks.push({
      tag: 'Attaque 2J',
      text: pickRandom([
        `${topAttack2.id} pourrait faire des différences offensives (2J: ${topAttack2.BP} buts marqués).`,
        `${topAttack2.id} arrive avec une attaque en forme sur 2 journées (${topAttack2.BP} buts).`
      ])
    })
  }

  const topAttack4 = buildTopPick(pool4, 'attack')
  if (topAttack4 && maybe(0.8)) {
    picks.push({
      tag: 'Attaque 4J',
      text: pickRandom([
        `${topAttack4.id} reste l'un des profils offensifs les plus actifs du dernier mois (${topAttack4.BP} buts).`,
        `${topAttack4.id} maintient un rythme élevé sur 4 journées (${topAttack4.BP} buts).`
      ])
    })
  }

  const bestDefense2 = buildTopPick(pool2.filter(r => Number(r.J || 0) > 0), 'defense')
  if (bestDefense2 && maybe(0.85)) {
    picks.push({
      tag: 'Défense 2J',
      text: pickRandom([
        `${bestDefense2.id} montre un profil défensif solide sur 2 journées (${bestDefense2.BC} but(s) concédé(s)).`,
        `${bestDefense2.id} peut fermer le jeu cette journée (2J: ${bestDefense2.BC} but(s) concédé(s)).`
      ])
    })
  }

  const bestDefense4 = buildTopPick(pool4.filter(r => Number(r.J || 0) > 0), 'defense')
  if (bestDefense4 && maybe(0.8)) {
    picks.push({
      tag: 'Défense 4J',
      text: pickRandom([
        `${bestDefense4.id} reste fiable défensivement sur 4 journées (${bestDefense4.BC} but(s) concédé(s)).`,
        `${bestDefense4.id} garde un bloc solide sur le dernier mois (${bestDefense4.BC} but(s) concédé(s)).`
      ])
    })
  }

  const drawMaster2 = buildTopPick(pool2, 'draw')
  if (drawMaster2 && Number(drawMaster2.N || 0) > 0 && maybe(0.75)) {
    picks.push({
      tag: 'Équilibre 2J',
      text: pickRandom([
        `${drawMaster2.id} gère bien les matchs serrés sur 2 journées (${drawMaster2.N} nul(s)).`,
        `${drawMaster2.id} est souvent dans des scénarios fermés récemment (${drawMaster2.N} nul(s)).`
      ])
    })
  }

  const drawMaster4 = buildTopPick(pool4, 'draw')
  if (drawMaster4 && Number(drawMaster4.N || 0) > 0 && maybe(0.7)) {
    picks.push({
      tag: 'Équilibre 4J',
      text: pickRandom([
        `${drawMaster4.id} a souvent été accroché sur 4 journées (${drawMaster4.N} nul(s)).`,
        `${drawMaster4.id} maîtrise bien les matchs fermés sur le dernier mois (${drawMaster4.N} nul(s)).`
      ])
    })
  }

  if (featuredInvite.value?.length && maybe(0.65)) {
    const top = featuredInvite.value[0]
    picks.push({
      tag: 'Invité en vue',
      text: `${top.id} est l'invité le plus en forme récemment (${top.pts} pts, ${top.V}V sur ${top.apps} journée(s)).`
    })
  }

  if (nextPayload) {
    const matchCount = (nextPayload.d1?.length || 0) + (nextPayload.d2?.length || 0)
    picks.push({ tag: 'Programme', text: `${matchCount} confrontation(s) sont déjà en place pour cette journée.` })

    const allNextMatches = [...(nextPayload.d1 || []), ...(nextPayload.d2 || [])]
      .filter(m => m?.p1 && m?.p2)
    const matchKey = pickRandom(allNextMatches)
    if (matchKey) {
      picks.push({
        tag: 'Match clé',
        text: pickRandom([
          `${matchKey.p1} vs ${matchKey.p2} peut clairement peser sur la journée.`,
          `${matchKey.p1} vs ${matchKey.p2} semble être l'affiche la plus ouverte de la journée.`,
          `${matchKey.p1} vs ${matchKey.p2} devrait compter dans la hiérarchie du week-end.`
        ])
      })
    }
  } else {
    picks.push({ tag: 'Planning', text: 'La grille est ouverte : compose les affiches pour lancer les pronostics du week-end.' })
  }

  if (!picks.length) {
    picks.push({ tag: 'Focus', text: 'Données insuffisantes sur les 2 et 4 dernières journées pour générer des pronostics.' })
  }
  const upperBound = Math.min(14, picks.length)
  const lowerBound = Math.min(8, upperBound)
  const targetCount = randomBetween(lowerBound, upperBound)
  const mixed = takeRandom(picks, targetCount)
  return [...shuffleArray(tournamentPicks), ...mixed].slice(0, 10)
}

/* ====== News (À la une) ====== */
async function loadHeadline() {
  loadingNews.value = true
  try {
    if (!currentSeason.value?.id) {
      newsItems.value = [{ title: 'À la une', meta: 'Aucune saison active' }]
      headlineFlashes.value = [{ tag: 'Invité en vue', text: 'Active une saison pour générer les tendances.' }]
      return
    }

    const { data: daysData } = await api.get(`/seasons/${currentSeason.value.id}/matchdays`)
    const days = (daysData.days || []).sort()
    if (!days.length) {
      newsItems.value = [{ title: 'À la une', meta: 'Aucune journée planifiée' }]
      headlineFlashes.value = [{ tag: 'Invité en vue', text: 'Ajoute une première journée pour alimenter les highlights.' }]
      return
    }

    recentConfirmedDays.value = await fetchRecentConfirmedDays(days, days.length)
    const latest = recentConfirmedDays.value[0]
    if (!latest?.payload) {
      newsItems.value = [{ title: 'À la une', meta: 'Aucune journée publiée' }]
      headlineFlashes.value = [{ tag: 'Invité en vue', text: 'Publie la prochaine journée pour afficher les tendances.' }]
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
    headlineFlashes.value = [{ tag: 'Invité en vue', text: 'Impossible de calculer les highlights pour le moment.' }]
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
    nextInsights.value = buildNextInsights(recentConfirmedDays.value, payload)
    nextInsightIndex.value = 0
  } catch (_) {
    nextInsights.value = [{ tag: 'Info', text: 'Pronostics indisponibles temporairement.' }]
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
</style>
