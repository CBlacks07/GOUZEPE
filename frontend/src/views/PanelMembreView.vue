<template>
  <AppLayout season-label="Mon espace">
    <div class="page-wrap panel-membre-wrap">

      <!-- ── Onglets ── -->
      <div class="profil-tabs reveal">
        <button :class="['profil-tab', activeTab === 'stats' && 'profil-tab--on']" @click="activeTab = 'stats'">
          <BarChart2Icon class="w-4 h-4" /> Statistiques
        </button>
        <button :class="['profil-tab', activeTab === 'settings' && 'profil-tab--on']" @click="activeTab = 'settings'">
          <SettingsIcon class="w-4 h-4" /> Parametres
        </button>
      </div>

      <!-- ── Hero profil ── -->
      <div class="profil-hero reveal">
        <div class="profil-avatar-col">
          <div class="profil-avatar" @click="activeTab === 'settings' && $refs.photoInput?.click()" :style="activeTab === 'settings' ? 'cursor:pointer' : ''">
            <img v-if="playerPhoto" :src="playerPhoto" alt="Avatar" class="profil-avatar-img" />
            <span v-else class="profil-avatar-letter">{{ (playerName?.[0] || linkedPlayerId?.[0] || '?').toUpperCase() }}</span>
            <div class="profil-avatar-ring" />
            <div v-if="activeTab === 'settings'" class="profil-avatar-overlay">
              <CameraIcon class="w-4 h-4" />
            </div>
          </div>
          <input ref="photoInput" type="file" accept="image/*" class="hidden" @change="uploadPhoto" />
          <button v-if="activeTab === 'settings'" class="profil-photo-btn" @click="$refs.photoInput?.click()">
            <CameraIcon class="w-3.5 h-3.5" /> Changer la photo
          </button>
        </div>
        <div class="profil-hero-info">
          <h1 class="profil-name">{{ playerName || linkedPlayerId || 'Mon espace' }}</h1>
          <p class="profil-sub">{{ userEmail }} · Membre GOUZEPE Gaming Club</p>
        </div>
        <div v-if="activeTab === 'stats'" class="profil-hero-right">
          <select v-model="selectedSeason" @change="load" class="input w-44 text-sm">
            <option v-for="s in seasons" :key="s.id" :value="s.id">{{ s.name }}</option>
          </select>
        </div>
      </div>

      <!-- ════════ ONGLET STATS ════════ -->
      <template v-if="activeTab === 'stats'">
        <div v-if="loading" class="profil-loading reveal delay-1">
          <div class="profil-spinner" />
          <span>Chargement…</span>
        </div>

        <div v-else-if="!stats" class="profil-unlinked reveal delay-1">
          <p class="text-gz-muted text-sm">Votre compte n'est lie a aucun joueur. Contactez un administrateur.</p>
        </div>

        <template v-else>
          <div class="profil-top-grid reveal delay-1">
            <div v-if="myRank" class="rank-showcase">
              <div class="rank-showcase-bg" />
              <span class="rank-label">Rang saison</span>
              <div class="rank-num">#{{ myRank.rank }}</div>
              <div class="rank-detail">
                <span class="rank-pts">{{ myRank.points }} pts</span>
                <span class="rank-sep">·</span>
                <span class="rank-played">{{ myRank.played }} participations</span>
              </div>
            </div>
            <div class="kpi-grid">
              <div v-for="kpi in kpis" :key="kpi.label" class="kpi-tile">
                <div class="kpi-icon-wrap" :style="`background:${kpi.bg}`">
                  <component :is="kpi.icon" class="w-5 h-5" :style="`color:${kpi.accent}`" />
                </div>
                <div :class="['kpi-val', kpi.valClass]">{{ kpi.value }}</div>
                <div class="kpi-label">{{ kpi.label }}</div>
              </div>
            </div>
          </div>

          <div class="profil-bottom-grid reveal delay-2">
            <div class="profil-card">
              <h3 class="profil-card-title">Statistiques</h3>
              <div class="stat-list">
                <div v-for="row in statRows" :key="row.label" class="stat-row">
                  <span class="stat-label">{{ row.label }}</span>
                  <div class="stat-bar-wrap">
                    <div v-if="row.pct != null" class="stat-bar">
                      <div class="stat-bar-fill" :style="`width:${row.pct}%;background:${row.accent || 'var(--green)'}`" />
                    </div>
                  </div>
                  <span :class="['stat-val', row.valClass]">{{ row.value }}</span>
                </div>
              </div>
            </div>

            <div class="profil-card">
              <h3 class="profil-card-title">Forme recente</h3>
              <div v-if="recentMatches.length" class="form-strip">
                <span v-for="m in recentMatches.slice(0,10)" :key="m.id"
                      :class="['form-dot', m.gf > m.ga ? 'dot-w' : m.gf < m.ga ? 'dot-l' : 'dot-d']"
                      :title="`${m.gf}-${m.ga} vs ${m.opponent_name}`">
                  {{ m.gf > m.ga ? 'V' : m.gf < m.ga ? 'D' : 'N' }}
                </span>
              </div>
              <div v-if="!recentMatches.length" class="text-gz-muted text-sm py-4">Aucun match recent.</div>
              <div v-else class="match-list">
                <div v-for="m in recentMatches.slice(0,8)" :key="m.id" class="match-row">
                  <span class="match-date">{{ fmtDate(m.match_date) }}</span>
                  <span :class="['match-badge', m.gf > m.ga ? 'badge-w' : m.gf < m.ga ? 'badge-l' : 'badge-d']">
                    {{ m.gf > m.ga ? 'V' : m.gf < m.ga ? 'D' : 'N' }}
                  </span>
                  <span class="match-vs">vs {{ m.opponent_name }}</span>
                  <span class="match-score">{{ m.gf }} – {{ m.ga }}</span>
                  <span class="match-div">{{ m.division }}</span>
                </div>
              </div>
            </div>
          </div>
        </template>
      </template>

      <!-- ════════ ONGLET PARAMETRES ════════ -->
      <template v-if="activeTab === 'settings'">
        <div class="settings-grid reveal delay-1">

          <!-- Informations personnelles -->
          <div class="profil-card">
            <h3 class="profil-card-title">Informations personnelles</h3>
            <div class="settings-form">
              <div class="setting-field">
                <label class="setting-label">Nom affiché</label>
                <div class="setting-row">
                  <input v-model="formName" class="input flex-1" placeholder="Votre nom" />
                  <button @click="saveName" class="btn text-sm" :disabled="savingName">
                    <Loader2Icon v-if="savingName" class="w-3.5 h-3.5 animate-spin" />
                    <template v-else>Enregistrer</template>
                  </button>
                </div>
              </div>
              <div class="setting-field">
                <label class="setting-label">Email</label>
                <div class="setting-row">
                  <input v-model="formEmail" type="email" class="input flex-1" placeholder="votre@email.com" />
                  <button @click="saveEmail" class="btn text-sm" :disabled="savingEmail">
                    <Loader2Icon v-if="savingEmail" class="w-3.5 h-3.5 animate-spin" />
                    <template v-else>Enregistrer</template>
                  </button>
                </div>
              </div>
              <div class="setting-field">
                <label class="setting-label">ID Joueur</label>
                <input :value="linkedPlayerId || '—'" class="input" disabled style="opacity:.6" />
                <p class="setting-hint">L'identifiant joueur est geré par l'administrateur.</p>
              </div>
            </div>
          </div>

          <!-- Mot de passe -->
          <div class="profil-card">
            <h3 class="profil-card-title">Mot de passe</h3>
            <div class="settings-form">
              <div class="setting-field">
                <label class="setting-label">Mot de passe actuel</label>
                <input v-model="formCurrentPwd" type="password" class="input" placeholder="••••••••" />
              </div>
              <div class="setting-field">
                <label class="setting-label">Nouveau mot de passe</label>
                <input v-model="formNewPwd" type="password" class="input" placeholder="6 caracteres minimum" />
              </div>
              <div class="setting-field">
                <label class="setting-label">Confirmer</label>
                <input v-model="formConfirmPwd" type="password" class="input" placeholder="Confirmer le nouveau mot de passe" />
              </div>
              <button @click="savePassword" class="btn-primary text-sm w-fit" :disabled="savingPwd">
                <Loader2Icon v-if="savingPwd" class="w-3.5 h-3.5 animate-spin" />
                <template v-else>Changer le mot de passe</template>
              </button>
            </div>
          </div>

          <!-- Apparence -->
          <div class="profil-card">
            <h3 class="profil-card-title">Apparence</h3>
            <div class="settings-form">
              <div class="setting-field">
                <label class="setting-label">Theme</label>
                <div class="theme-toggle-row">
                  <button @click="theme.set('light')" :class="['theme-btn', theme.mode === 'light' && 'theme-btn--on']">
                    <SunIcon class="w-4 h-4" /> Clair
                  </button>
                  <button @click="theme.set('dark')" :class="['theme-btn', theme.mode === 'dark' && 'theme-btn--on']">
                    <MoonIcon class="w-4 h-4" /> Sombre
                  </button>
                </div>
              </div>
            </div>
          </div>

        </div>
      </template>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import AppLayout from '@/components/layout/AppLayout.vue'
import { useAPI, mediaUrl } from '@/composables/useAPI'
import { useAuthStore } from '@/stores/auth'
import { useThemeStore } from '@/stores/theme'
import { useToast } from '@/composables/useToast'
import {
  SwordsIcon, TrophyIcon, MinusIcon, XIcon, TargetIcon, ShieldIcon,
  BarChart2Icon, SettingsIcon, CameraIcon, Loader2Icon, SunIcon, MoonIcon
} from 'lucide-vue-next'

const api = useAPI()
const auth = useAuthStore()
const theme = useThemeStore()
const { success, error: toastError } = useToast()

const activeTab = ref('stats')
const seasons = ref([])
const selectedSeason = ref(null)
const loading = ref(false)
const stats = ref(null)
const recentMatches = ref([])
const myRank = ref(null)
const linkedPlayerId = ref('')
const playerName = ref('')
const playerPhoto = ref('')
const userEmail = ref('')

const formName = ref('')
const formEmail = ref('')
const formCurrentPwd = ref('')
const formNewPwd = ref('')
const formConfirmPwd = ref('')
const savingName = ref(false)
const savingEmail = ref(false)
const savingPwd = ref(false)

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
    const p = data?.player
    linkedPlayerId.value = String(p?.player_id || '').trim()
    playerName.value = p?.name || ''
    playerPhoto.value = p?.profile_pic_url ? mediaUrl(p.profile_pic_url) : ''
    formName.value = p?.name || ''
  } catch (_) {
    linkedPlayerId.value = ''
  }
  try {
    const { data: meData } = await api.get('/auth/me')
    userEmail.value = meData?.user?.email || ''
    formEmail.value = userEmail.value
  } catch (_) {}
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
    { label: 'Matchs joués', value: s.played ?? 0, icon: SwordsIcon, bg: 'rgba(95,141,255,.12)', accent: '#5f8dff', valClass: 'text-gz-text' },
    { label: 'Victoires',    value: s.wins ?? 0,   icon: TrophyIcon,  bg: 'rgba(34,197,94,.12)', accent: '#22c55e', valClass: 'kpi-green' },
    { label: 'Nuls',         value: s.draws ?? 0,  icon: MinusIcon,   bg: 'rgba(148,163,184,.1)', accent: 'var(--muted)', valClass: 'text-gz-muted' },
    { label: 'Défaites',     value: s.losses ?? 0, icon: XIcon,       bg: 'rgba(212,60,73,.1)',   accent: '#d43c49', valClass: 'kpi-red' },
    { label: 'Buts marqués', value: s.goals_for ?? 0, icon: TargetIcon, bg: 'rgba(251,191,36,.1)', accent: '#fbbf24', valClass: 'kpi-amber' },
    { label: 'Buts encaissés', value: s.goals_against ?? 0, icon: ShieldIcon, bg: 'rgba(148,163,184,.08)', accent: 'var(--muted)', valClass: 'text-gz-muted' },
  ]
})

const statRows = computed(() => {
  if (!stats.value) return []
  const s = stats.value
  const total = (s.wins ?? 0) + (s.draws ?? 0) + (s.losses ?? 0) || 1
  const avgFor = s.played ? ((s.goals_for || 0) / s.played).toFixed(2) : '0'
  const avgAga = s.played ? ((s.goals_against || 0) / s.played).toFixed(2) : '0'
  const winRate = Math.round(((s.wins ?? 0) / total) * 100)
  return [
    { label: 'Win rate',        value: winRate + '%',    pct: winRate,                               accent: '#22c55e', valClass: 'stat-green' },
    { label: 'Points saison',   value: s.points ?? 0,   pct: Math.min(100, (s.points ?? 0) / 2),   accent: '#22c55e', valClass: 'stat-green' },
    { label: 'Moy. buts +',     value: avgFor,           pct: Math.min(100, parseFloat(avgFor)*14),  accent: '#fbbf24' },
    { label: 'Moy. buts -',     value: avgAga,           pct: Math.min(100, parseFloat(avgAga)*14),  accent: '#d43c49' },
    { label: 'Diff. de buts',   value: (s.goals_for ?? 0) - (s.goals_against ?? 0), pct: null, valClass: (s.goals_for ?? 0) >= (s.goals_against ?? 0) ? 'stat-green' : 'stat-red' },
  ]
})

function fmtDate(s) {
  if (!s) return '-'
  return new Date(s).toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit', year: 'numeric' })
}

async function saveName() {
  if (!formName.value.trim() || formName.value.trim().length < 2) return toastError('Nom trop court (2 caracteres min.)')
  savingName.value = true
  try {
    const { data } = await api.put('/me/name', { name: formName.value.trim() })
    playerName.value = data.player?.name || formName.value.trim()
    formName.value = playerName.value
    success('Nom mis a jour')
  } catch (e) {
    toastError(e?.response?.data?.error || 'Erreur')
  }
  savingName.value = false
}

async function saveEmail() {
  if (!formEmail.value.trim() || !formEmail.value.includes('@')) return toastError('Email invalide')
  savingEmail.value = true
  try {
    await api.put('/me/email', { email: formEmail.value.trim() })
    userEmail.value = formEmail.value.trim().toLowerCase()
    formEmail.value = userEmail.value
    success('Email mis a jour')
  } catch (e) {
    toastError(e?.response?.data?.error || 'Erreur')
  }
  savingEmail.value = false
}

async function savePassword() {
  if (!formNewPwd.value || formNewPwd.value.length < 6) return toastError('Mot de passe trop court (6 min.)')
  if (formNewPwd.value !== formConfirmPwd.value) return toastError('Les mots de passe ne correspondent pas')
  if (!formCurrentPwd.value) return toastError('Saisissez votre mot de passe actuel')
  savingPwd.value = true
  try {
    await api.put('/me/password', { currentPassword: formCurrentPwd.value, newPassword: formNewPwd.value })
    formCurrentPwd.value = ''
    formNewPwd.value = ''
    formConfirmPwd.value = ''
    success('Mot de passe change')
  } catch (e) {
    toastError(e?.response?.data?.error || 'Erreur')
  }
  savingPwd.value = false
}

async function uploadPhoto(e) {
  const file = e.target?.files?.[0]
  if (!file) return
  const form = new FormData()
  form.append('photo', file)
  try {
    const { data } = await api.post('/me/photo', form)
    playerPhoto.value = data.player?.profile_pic_url ? mediaUrl(data.player.profile_pic_url) : ''
    success('Photo mise a jour')
  } catch (err) {
    toastError(err?.response?.data?.error || 'Erreur upload')
  }
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
/* ── Hero profil ── */
.panel-membre-wrap { display: flex; flex-direction: column; gap: 1.25rem; }
.profil-hero {
  display: flex; align-items: center; gap: 1.25rem; flex-wrap: wrap;
  background: color-mix(in srgb, var(--panel) 85%, transparent);
  border: 1px solid rgba(148,163,184,.14); border-radius: 20px; padding: 1.5rem 1.75rem;
}
.profil-avatar {
  position: relative; flex-shrink: 0;
  width: 64px; height: 64px; border-radius: 18px;
  background: linear-gradient(135deg, rgba(34,197,94,.25), rgba(95,141,255,.2));
  display: flex; align-items: center; justify-content: center;
}
.profil-avatar-letter { font-size: 1.6rem; font-weight: 900; color: #22c55e; }
.profil-avatar-ring {
  position: absolute; inset: -3px; border-radius: 21px;
  border: 2px solid rgba(34,197,94,.35);
  animation: ringPulse 3s ease-in-out infinite;
}
@keyframes ringPulse { 0%,100%{opacity:.5;transform:scale(1)} 50%{opacity:1;transform:scale(1.03)} }
.profil-hero-info { flex: 1; }
.profil-name { font-size: 1.3rem; font-weight: 800; font-family: var(--font-title); line-height: 1.1; }
.profil-sub { font-size: 0.78rem; color: var(--muted); margin-top: 2px; }
.profil-hero-right { margin-left: auto; }

.profil-loading { display: flex; align-items: center; gap: .75rem; color: var(--muted); font-size: .88rem; padding: 2rem; }
.profil-spinner { width: 24px; height: 24px; border: 2px solid rgba(34,197,94,.2); border-top-color: #22c55e; border-radius: 50%; animation: spin .6s linear infinite; }
@keyframes spin { to{transform:rotate(360deg)} }
.profil-unlinked { padding: 2.5rem; text-align: center; }

/* ── Rank + KPIs ── */
.profil-top-grid { display: grid; grid-template-columns: 200px 1fr; gap: 1.25rem; align-items: start; }
@media(max-width:768px) { .profil-top-grid { grid-template-columns: 1fr; } }

.rank-showcase {
  position: relative; overflow: hidden;
  background: linear-gradient(135deg, rgba(34,197,94,.12), rgba(34,197,94,.04));
  border: 1px solid rgba(34,197,94,.25); border-radius: 18px;
  padding: 1.5rem; text-align: center; min-height: 160px;
  display: flex; flex-direction: column; align-items: center; justify-content: center; gap: .35rem;
}
.rank-showcase-bg {
  position: absolute; inset: 0; border-radius: 50%;
  background: radial-gradient(circle, rgba(34,197,94,.08) 0%, transparent 70%);
  pointer-events: none;
}
.rank-label { font-size: .65rem; font-weight: 800; text-transform: uppercase; letter-spacing: .1em; color: rgba(34,197,94,.7); }
.rank-num { font-size: 3rem; font-weight: 900; color: #22c55e; line-height: 1; font-family: var(--font-title); }
.rank-detail { display: flex; gap: .4rem; align-items: center; font-size: .78rem; color: var(--muted); }
.rank-pts { font-weight: 700; color: var(--text); }
.rank-sep { color: var(--muted); }
.rank-played { }

.kpi-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: .75rem; }
@media(max-width:480px) { .kpi-grid { grid-template-columns: repeat(2,1fr); } }
.kpi-tile {
  background: color-mix(in srgb, var(--card) 90%, transparent);
  border: 1px solid rgba(148,163,184,.12); border-radius: 14px;
  padding: .9rem; display: flex; flex-direction: column; gap: .3rem;
  transition: border-color .2s, transform .2s;
}
.kpi-tile:hover { border-color: rgba(148,163,184,.25); transform: translateY(-1px); }
.kpi-icon-wrap { width: 32px; height: 32px; border-radius: 9px; display: flex; align-items: center; justify-content: center; margin-bottom: .1rem; }
.kpi-val { font-size: 1.5rem; font-weight: 900; line-height: 1; }
.kpi-label { font-size: .65rem; color: var(--muted); text-transform: uppercase; letter-spacing: .07em; font-weight: 600; }
.kpi-green { color: #22c55e; }
.kpi-red { color: #d43c49; }
.kpi-amber { color: #fbbf24; }

/* ── Bottom grid ── */
.profil-bottom-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1.25rem; }
.profil-card {
  background: color-mix(in srgb, var(--card) 90%, transparent);
  border: 1px solid rgba(148,163,184,.12); border-radius: 18px; padding: 1.25rem 1.5rem;
}
.profil-card-title { font-size: .8rem; font-weight: 800; text-transform: uppercase; letter-spacing: .08em; color: var(--muted); margin-bottom: 1rem; }

/* Stats avec barres */
.stat-list { display: flex; flex-direction: column; gap: .7rem; }
.stat-row { display: grid; grid-template-columns: 110px 1fr 60px; align-items: center; gap: .6rem; }
.stat-label { font-size: .78rem; color: var(--muted); }
.stat-bar-wrap { flex: 1; }
.stat-bar { height: 5px; background: rgba(148,163,184,.12); border-radius: 99px; overflow: hidden; }
.stat-bar-fill { height: 100%; border-radius: 99px; transition: width .6s ease; }
.stat-val { font-size: .88rem; font-weight: 700; text-align: right; }
.stat-green { color: #22c55e; }
.stat-red { color: #d43c49; }

/* Forme récente */
.form-strip { display: flex; gap: .3rem; flex-wrap: wrap; margin-bottom: .85rem; }
.form-dot {
  width: 26px; height: 26px; border-radius: 7px;
  font-size: .68rem; font-weight: 800; display: flex; align-items: center; justify-content: center; cursor: default;
}
.dot-w { background: rgba(34,197,94,.15); color: #22c55e; }
.dot-d { background: rgba(148,163,184,.12); color: var(--muted); }
.dot-l { background: rgba(212,60,73,.12); color: #d43c49; }

.match-list { display: flex; flex-direction: column; gap: .35rem; }
.match-row {
  display: grid; grid-template-columns: 70px 22px 1fr 60px 28px;
  align-items: center; gap: .5rem;
  padding: .4rem .5rem; border-radius: 8px;
  background: rgba(148,163,184,.04);
  font-size: .78rem; transition: background .12s;
}
.match-row:hover { background: rgba(148,163,184,.08); }
.match-date { color: var(--muted); font-size: .72rem; }
.match-badge { width: 20px; height: 20px; border-radius: 5px; font-size: .65rem; font-weight: 800; display: flex; align-items: center; justify-content: center; }
.badge-w { background: rgba(34,197,94,.15); color: #22c55e; }
.badge-d { background: rgba(148,163,184,.12); color: var(--muted); }
.badge-l { background: rgba(212,60,73,.12); color: #d43c49; }
.match-vs { font-weight: 600; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.match-score { font-weight: 800; text-align: center; font-variant-numeric: tabular-nums; }
.match-div { font-size: .65rem; color: var(--muted); text-align: right; }

/* ── Onglets ── */
.profil-tabs {
  display: flex; gap: .5rem; margin-bottom: .25rem;
}
.profil-tab {
  display: flex; align-items: center; gap: .4rem;
  padding: .5rem 1rem; border-radius: 10px;
  font-size: .82rem; font-weight: 600;
  background: transparent; border: 1px solid var(--border); color: var(--muted);
  cursor: pointer; transition: all .15s;
}
.profil-tab:hover { color: var(--text); border-color: rgba(148,163,184,.3); }
.profil-tab--on {
  background: color-mix(in srgb, var(--accent) 14%, transparent);
  border-color: var(--accent); color: var(--accent);
}

/* ── Avatar photo ── */
.profil-avatar { position: relative; }
.profil-avatar-img {
  width: 64px; height: 64px; border-radius: 18px; object-fit: cover;
}
.profil-avatar-overlay {
  position: absolute; inset: 0; border-radius: 18px;
  background: rgba(0,0,0,.45); display: flex; align-items: center; justify-content: center;
  color: #fff; opacity: 0; transition: opacity .15s;
}
.profil-avatar:hover .profil-avatar-overlay { opacity: 1; }

.profil-avatar-col {
  display: flex; flex-direction: column; align-items: center; gap: .4rem; flex-shrink: 0;
}
.profil-photo-btn {
  display: flex; align-items: center; gap: .3rem;
  font-size: .68rem; font-weight: 600; color: var(--accent);
  background: none; border: none; cursor: pointer; padding: 0;
  white-space: nowrap;
}
.profil-photo-btn:hover { text-decoration: underline; }

/* ── Parametres ── */
.settings-grid {
  display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 1.25rem;
}
.settings-form { display: flex; flex-direction: column; gap: 1rem; }
.setting-field { display: flex; flex-direction: column; gap: .3rem; }
.setting-label { font-size: .75rem; font-weight: 700; color: var(--muted); text-transform: uppercase; letter-spacing: .06em; }
.setting-row { display: flex; gap: .5rem; align-items: center; }
.setting-hint { font-size: .7rem; color: var(--muted); }

.theme-toggle-row { display: flex; gap: .5rem; }
.theme-btn {
  display: flex; align-items: center; gap: .4rem;
  padding: .5rem 1rem; border-radius: 10px;
  font-size: .82rem; font-weight: 600;
  background: transparent; border: 1px solid var(--border); color: var(--muted);
  cursor: pointer; transition: all .15s;
}
.theme-btn:hover { border-color: rgba(148,163,184,.3); color: var(--text); }
.theme-btn--on {
  background: color-mix(in srgb, var(--accent) 14%, transparent);
  border-color: var(--accent); color: var(--accent);
}

.reveal { animation: riseIn .4s ease both; }
.delay-1 { animation-delay: 80ms; }
.delay-2 { animation-delay: 160ms; }
@keyframes riseIn { from{opacity:0;transform:translateY(10px)} to{opacity:1;transform:translateY(0)} }

/* ancien compat */
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
