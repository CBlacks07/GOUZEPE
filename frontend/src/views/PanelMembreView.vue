<template>
  <AppLayout season-label="Mon espace">
    <div class="page-wrap panel-membre-wrap space-y-4">
      <section class="card reveal">
        <div class="flex items-center justify-between gap-3 flex-wrap">
          <div>
            <h1 class="text-xl font-bold text-gz-text">Mon espace</h1>
            <p class="text-sm text-gz-muted">Suivi personnel de votre saison.</p>
          </div>
          <div class="flex items-center gap-2">
            <label class="label mb-0">Saison</label>
            <select v-model="selectedSeason" @change="load" class="input w-52" title="Choisir une saison">
              <option v-for="s in seasons" :key="s.id" :value="s.id">{{ s.name }}</option>
            </select>
          </div>
        </div>
      </section>

      <section v-if="loading" class="card reveal delay-1 text-gz-muted text-sm py-10 text-center">
        Chargement...
      </section>

      <section v-else-if="!stats" class="card reveal delay-1 text-gz-muted text-sm py-10 text-center">
        Votre compte n'est lie a aucun joueur. Contactez un administrateur.
      </section>

      <template v-else>
        <section v-if="myRank" class="card reveal delay-1 rank-card">
          <h3 class="font-semibold text-gz-text mb-3">Position au classement</h3>
          <div class="rank-main">
            <div class="rank-value">#{{ myRank.rank }}</div>
            <div class="rank-meta">
              <div class="text-sm text-gz-muted">{{ myRank.division }}</div>
              <div class="text-sm text-gz-text">{{ myRank.points }} pts • {{ myRank.played }} matchs</div>
            </div>
          </div>
        </section>

        <section class="grid grid-cols-2 lg:grid-cols-4 gap-4 reveal delay-1">
          <div v-for="kpi in kpis" :key="kpi.label" class="card text-center kpi-card">
            <div :class="['text-2xl font-bold mb-0.5', kpi.color]">{{ kpi.value }}</div>
            <div class="text-xs text-gz-muted uppercase tracking-wide">{{ kpi.label }}</div>
          </div>
        </section>

        <section class="grid grid-cols-1 xl:grid-cols-2 gap-4 reveal delay-2">
          <div class="card">
            <h3 class="font-semibold text-gz-text mb-4">Statistiques</h3>
            <div class="space-y-1">
              <div
                v-for="row in statRows"
                :key="row.label"
                class="flex justify-between items-center py-2 border-b border-gz-border/35 last:border-0"
              >
                <span class="text-sm text-gz-muted">{{ row.label }}</span>
                <span :class="['text-sm font-semibold', row.color || 'text-gz-text']">{{ row.value }}</span>
              </div>
            </div>
          </div>

          <div class="card">
            <h3 class="font-semibold text-gz-text mb-4">Forme recente</h3>
            <div v-if="!recentMatches.length" class="text-gz-muted text-sm">Aucun match recent.</div>
            <div v-else class="space-y-2">
              <div
                v-for="m in recentMatches"
                :key="m.id"
                class="recent-match border border-gz-border/40 rounded-lg bg-gz-panel"
              >
                <div class="recent-top">
                  <div class="text-xs text-gz-muted">{{ fmtDate(m.match_date) }}</div>
                  <div class="text-[11px] text-gz-muted">{{ m.division }} - {{ m.leg }}</div>
                </div>
                <div class="recent-main">
                  <span class="text-sm font-semibold truncate">Moi</span>
                  <span class="recent-score">{{ m.gf }} - {{ m.ga }}</span>
                  <span class="text-sm font-semibold truncate text-right">{{ m.opponent_name }}</span>
                  <BaseBadge :variant="matchResultVariant(m)">{{ matchResultLabel(m) }}</BaseBadge>
                </div>
              </div>
            </div>
          </div>
        </section>
      </template>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import AppLayout from '@/components/layout/AppLayout.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'
import { useAPI } from '@/composables/useAPI'

const api = useAPI()

const seasons = ref([])
const selectedSeason = ref(null)
const loading = ref(false)
const stats = ref(null)
const recentMatches = ref([])
const myRank = ref(null)
const linkedPlayerId = ref('')

onMounted(async () => {
  try {
    const { data } = await api.get('/seasons')
    seasons.value = data.seasons || []
    if (seasons.value.length) selectedSeason.value = seasons.value[0].id
    await ensureLinkedPlayerId()
    await load()
  } catch (_) {}
})

async function ensureLinkedPlayerId() {
  if (linkedPlayerId.value) return linkedPlayerId.value
  try {
    const { data } = await api.get('/me/player')
    linkedPlayerId.value = String(data?.player?.player_id || '').trim()
  } catch (_) {
    linkedPlayerId.value = ''
  }
  return linkedPlayerId.value
}

async function load() {
  if (!selectedSeason.value) return
  loading.value = true
  stats.value = null
  myRank.value = null
  recentMatches.value = []
  try {
    const pid = await ensureLinkedPlayerId()
    if (!pid) {
      loading.value = false
      return
    }

    const [statsRes, matchRes, standingsRes] = await Promise.all([
      api.get('/me/stats', { params: { season: selectedSeason.value } }),
      api.get('/me/matches', { params: { season: selectedSeason.value } }),
      api.get('/standings', { params: { season: selectedSeason.value } }),
    ])

    const matchRows = Array.isArray(matchRes?.data?.matches) ? matchRes.data.matches : []
    const legs = mapMatchRowsToLegs(matchRows)
    recentMatches.value = legs.slice(0, 10)

    stats.value = buildStatsSummary(statsRes?.data || {}, legs)

    const rows = standingsRes?.data?.standings || []
    const idx = rows.findIndex((r) => String(r.id || r.player_id || '') === pid)
    if (idx !== -1) {
      const row = rows[idx]
      myRank.value = {
        rank: idx + 1,
        division: 'General',
        points: Number(row.total ?? row.points ?? 0) || 0,
        played: Number(row.participations ?? row.games ?? 0) || 0,
      }
    }
  } catch (_) {
    stats.value = null
  }
  loading.value = false
}

function mapMatchRowsToLegs(rows) {
  const out = []
  for (const r of rows || []) {
    const date = String(r?.date || '')
    const division = String(r?.division || '-').toUpperCase()
    const opponent = String(r?.opponent_name || r?.opponent || '-').trim() || '-'

    const addLeg = (legName, leg) => {
      const gf = Number(leg?.gf)
      const ga = Number(leg?.ga)
      if (!Number.isFinite(gf) || !Number.isFinite(ga)) return
      out.push({
        id: `${date}-${division}-${opponent}-${legName}`,
        match_date: date,
        division,
        leg: legName,
        opponent_name: opponent,
        gf,
        ga,
      })
    }

    addLeg('Aller', r?.aller)
    addLeg('Retour', r?.retour)
  }

  return out.sort((a, b) => new Date(b.match_date).getTime() - new Date(a.match_date).getTime())
}

function buildStatsSummary(rawStats, legs) {
  let wins = 0
  let draws = 0
  let losses = 0
  let pointsByLegs = 0
  let gfByLegs = 0
  let gaByLegs = 0

  for (const m of legs) {
    gfByLegs += m.gf
    gaByLegs += m.ga
    if (m.gf > m.ga) {
      wins += 1
      pointsByLegs += 3
    } else if (m.gf < m.ga) {
      losses += 1
    } else {
      draws += 1
      pointsByLegs += 1
    }
  }

  const played = Number(rawStats?.played_legs)
  const goalsFor = Number(rawStats?.goals_for)
  const goalsAgainst = Number(rawStats?.goals_against)
  const seasonPoints = Number(rawStats?.season_points)

  return {
    played: Number.isFinite(played) ? played : legs.length,
    wins,
    draws,
    losses,
    goals_for: Number.isFinite(goalsFor) ? goalsFor : gfByLegs,
    goals_against: Number.isFinite(goalsAgainst) ? goalsAgainst : gaByLegs,
    points: Number.isFinite(seasonPoints) ? seasonPoints : pointsByLegs,
  }
}

const kpis = computed(() => {
  if (!stats.value) return []
  const s = stats.value
  return [
    { label: 'Matchs joues', value: s.played ?? 0, color: 'text-gz-text' },
    { label: 'Victoires', value: s.wins ?? 0, color: 'text-gz-green' },
    { label: 'Nuls', value: s.draws ?? 0, color: 'text-gz-muted' },
    { label: 'Defaites', value: s.losses ?? 0, color: 'text-[var(--blue-l)]' },
  ]
})

const statRows = computed(() => {
  if (!stats.value) return []
  const s = stats.value
  const avgFor = s.played ? ((s.goals_for || 0) / s.played).toFixed(2) : '-'
  const avgAga = s.played ? ((s.goals_against || 0) / s.played).toFixed(2) : '-'
  return [
    { label: 'Buts marques', value: s.goals_for ?? '-' },
    { label: 'Buts encaisses', value: s.goals_against ?? '-' },
    { label: 'Moy. buts +', value: avgFor },
    { label: 'Moy. buts -', value: avgAga },
    { label: 'Points saison', value: s.points ?? '-', color: 'text-gz-green' },
  ]
})

function fmtDate(s) {
  if (!s) return '-'
  return new Date(s).toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit', year: 'numeric' })
}

function matchResultVariant(m) {
  const gf = Number(m?.gf)
  const ga = Number(m?.ga)
  if (!Number.isFinite(gf) || !Number.isFinite(ga)) return 'muted'
  return gf > ga ? 'green' : gf < ga ? 'red' : 'muted'
}

function matchResultLabel(m) {
  const gf = Number(m?.gf)
  const ga = Number(m?.ga)
  if (!Number.isFinite(gf) || !Number.isFinite(ga)) return '-'
  return gf > ga ? 'V' : gf < ga ? 'D' : 'N'
}
</script>

<style scoped>
.panel-membre-wrap :deep(.card) {
  transition: transform 180ms ease, box-shadow 180ms ease, border-color 180ms ease;
}

.panel-membre-wrap :deep(.card:hover) {
  transform: translateY(-1px);
  box-shadow: 0 12px 26px rgba(2, 6, 23, 0.2);
  border-color: color-mix(in srgb, var(--border) 68%, var(--blue) 32%);
}

.kpi-card {
  min-height: 94px;
  display: grid;
  place-content: center;
}

.rank-card {
  margin-bottom: 0.25rem;
}

.rank-main {
  display: flex;
  align-items: center;
  gap: 0.9rem;
}

.rank-value {
  font-size: 2.1rem;
  line-height: 1;
  font-weight: 800;
  color: var(--green);
}

.recent-match {
  padding: 0.58rem 0.75rem;
}

.recent-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.5rem;
  margin-bottom: 0.35rem;
}

.recent-main {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto minmax(0, 1fr) auto;
  align-items: center;
  gap: 0.5rem;
}

.recent-score {
  font-size: 0.96rem;
  font-weight: 800;
  line-height: 1;
  padding: 0 0.2rem;
  font-variant-numeric: tabular-nums;
}

@media (max-width: 640px) {
  .rank-main {
    align-items: flex-start;
  }

  .recent-main {
    grid-template-columns: minmax(0, 1fr) auto;
    grid-template-areas:
      "me score"
      "opp badge";
    row-gap: 0.4rem;
  }

  .recent-main > :nth-child(1) {
    grid-area: me;
  }

  .recent-main > :nth-child(2) {
    grid-area: score;
    justify-self: end;
  }

  .recent-main > :nth-child(3) {
    grid-area: opp;
    text-align: left !important;
  }

  .recent-main > :nth-child(4) {
    grid-area: badge;
    justify-self: end;
  }
}
</style>
