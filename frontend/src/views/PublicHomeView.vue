<template>
  <div class="pub-root">

    <!-- ═══ HEADER ═══ -->
    <header class="pub-header">
      <div class="pub-header-inner">
        <RouterLink to="/" class="pub-logo">
          <img src="/assets/icons/apple-touch-icon.png" alt="GGC" class="pub-logo-img" />
          <div>
            <p class="pub-logo-name">GOUZEPE</p>
            <p class="pub-logo-tag">eFOOTBALL CLUB</p>
          </div>
        </RouterLink>
        <nav class="pub-nav">
          <button @click="goto('journee')" class="pub-nav-btn">Journée</button>
          <button @click="goto('tournois')" class="pub-nav-btn">Tournois</button>
          <RouterLink to="/login" class="pub-nav-btn">Connexion</RouterLink>
          <RouterLink to="/inscription" class="pub-cta-btn">
            Devenir membre
          </RouterLink>
        </nav>
      </div>
    </header>

    <!-- ═══ HERO ═══ -->
    <section class="pub-hero">
      <!-- Vidéo de fond -->
      <video class="hero-video" autoplay muted loop playsinline>
        <source src="/fonds/bg.mp4" type="video/mp4" />
      </video>
      <!-- Overlay dégradé -->
      <div class="hero-overlay" />
      <!-- Blobs lumineux -->
      <div class="hero-blob blob-1" />
      <div class="hero-blob blob-2" />
      <div class="hero-blob blob-3" />

      <!-- Contenu -->
      <div class="hero-content">
        <div class="hero-badge">
          <span class="hero-badge-dot" />
          Saison 2025 — 2026 en cours
        </div>
        <img src="/assets/icons/icon-192x192.png" alt="GGC" class="hero-logo" />
        <h1 class="hero-title">
          <span class="hero-title-main">GOUZEPE</span>
          <span class="hero-title-sub">GAMING CLUB</span>
        </h1>
        <p class="hero-desc">
          Compétition eFootball interne — journées officielles, tournois membres,<br class="hidden sm:block" />
          classement général de saison.
        </p>
        <div class="hero-actions">
          <RouterLink to="/inscription" class="hero-btn-primary">
            <span>Rejoindre le club</span>
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3" /></svg>
          </RouterLink>
          <RouterLink to="/login" class="hero-btn-ghost">Se connecter</RouterLink>
        </div>
        <!-- Stats rapides -->
        <div class="hero-stats">
          <div class="hero-stat">
            <span class="hero-stat-num">2</span>
            <span class="hero-stat-label">Divisions</span>
          </div>
          <div class="hero-stat-sep" />
          <div class="hero-stat">
            <span class="hero-stat-num">{{ playerCount || '—' }}</span>
            <span class="hero-stat-label">Membres</span>
          </div>
          <div class="hero-stat-sep" />
          <div class="hero-stat">
            <span class="hero-stat-num">{{ tournamentCount || '—' }}</span>
            <span class="hero-stat-label">Tournois</span>
          </div>
        </div>
      </div>

      <!-- Scroll indicator -->
      <div class="hero-scroll" @click="goto('journee')">
        <span>Découvrir</span>
        <div class="hero-scroll-icon">
          <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" /></svg>
        </div>
      </div>
    </section>

    <!-- ═══ JOURNÉE EN COURS ═══ -->
    <section id="journee" class="pub-section">
      <div class="pub-section-inner">
        <div class="section-label">
          <div class="section-label-line" />
          <span>Résultats</span>
          <div class="section-label-line" />
        </div>
        <h2 class="section-title">Journée en cours</h2>

        <div v-if="loadingDay" class="pub-loading-spinner">
          <div class="spinner" />
        </div>

        <template v-else-if="latestDay">
          <!-- Date + Champions -->
          <div class="day-meta">
            <div class="day-date-tag">{{ fmtDate(latestDay.day) }}</div>
            <div class="day-champions">
              <div v-if="latestDay.champions?.d1?.id" class="champ-card">
                <span class="champ-crown">👑</span>
                <div class="champ-info">
                  <span class="champ-div">Champion D1</span>
                  <span class="champ-name">{{ latestDay.champions.d1.id }}</span>
                  <span v-if="latestDay.champions.d1.team" class="champ-team">{{ latestDay.champions.d1.team }}</span>
                </div>
              </div>
              <div v-if="latestDay.champions?.d2?.id" class="champ-card champ-d2">
                <span class="champ-crown">🥇</span>
                <div class="champ-info">
                  <span class="champ-div">Champion D2</span>
                  <span class="champ-name">{{ latestDay.champions.d2.id }}</span>
                  <span v-if="latestDay.champions.d2.team" class="champ-team">{{ latestDay.champions.d2.team }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Tables D1 / D2 -->
          <div class="standings-grid">
            <div v-for="(div, key) in { D1: latestDay.d1, D2: latestDay.d2 }" :key="key" class="standings-card">
              <div class="standings-card-header">
                <span class="standings-div-badge" :class="key === 'D1' ? 'badge-d1' : 'badge-d2'">{{ key }}</span>
                <span class="standings-title">Division {{ key === 'D1' ? '1' : '2' }}</span>
              </div>
              <template v-if="div?.members?.length">
                <div class="standings-scroll">
                  <table class="st-table">
                    <thead>
                      <tr>
                        <th class="th-rank">#</th>
                        <th class="th-name">Joueur</th>
                        <th>J</th><th class="th-v">V</th><th>N</th><th class="th-d">D</th>
                        <th>Diff</th><th class="th-pts">Pts</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="r in div.members" :key="r.id" class="st-row" :class="r.rank === 1 ? 'row-champ' : ''">
                        <td class="td-rank">
                          <span v-if="r.rank === 1" class="rank-gold">1</span>
                          <span v-else-if="r.rank === 2" class="rank-silver">2</span>
                          <span v-else-if="r.rank === 3" class="rank-bronze">3</span>
                          <span v-else class="rank-num">{{ r.rank }}</span>
                        </td>
                        <td class="td-name">{{ r.id }}</td>
                        <td>{{ r.J }}</td>
                        <td class="td-v">{{ r.V }}</td>
                        <td>{{ r.N }}</td>
                        <td class="td-d">{{ r.D }}</td>
                        <td :class="r.DIFF > 0 ? 'td-pos' : r.DIFF < 0 ? 'td-neg' : ''">{{ r.DIFF > 0 ? '+' : '' }}{{ r.DIFF }}</td>
                        <td class="td-pts">{{ r.PTS }}</td>
                      </tr>
                      <tr v-if="div.guests?.length" class="invite-sep-row">
                        <td colspan="8">Invités</td>
                      </tr>
                      <tr v-for="r in div.guests" :key="'g'+r.id" class="st-row invite-row">
                        <td class="td-rank">—</td>
                        <td class="td-name">{{ r.id }}</td>
                        <td>{{ r.J }}</td>
                        <td class="td-v">{{ r.V }}</td>
                        <td>{{ r.N }}</td>
                        <td class="td-d">{{ r.D }}</td>
                        <td>{{ r.DIFF > 0 ? '+' : '' }}{{ r.DIFF }}</td>
                        <td class="td-pts">{{ r.PTS }}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </template>
              <div v-else class="standings-empty">Aucun résultat {{ key }}.</div>
            </div>
          </div>

          <div class="day-cta">
            <RouterLink to="/login" class="hero-btn-ghost text-sm">
              Voir le classement général de saison →
            </RouterLink>
          </div>
        </template>

        <div v-else class="empty-state">
          <p>Aucune journée en cours pour le moment.</p>
        </div>
      </div>
    </section>

    <!-- ═══ TOURNOIS ═══ -->
    <section id="tournois" class="pub-section pub-section-alt">
      <div class="pub-section-inner">
        <div class="section-label">
          <div class="section-label-line" />
          <span>Compétitions</span>
          <div class="section-label-line" />
        </div>
        <h2 class="section-title">Tournois</h2>

        <div v-if="loadingTournaments" class="pub-loading-spinner"><div class="spinner" /></div>

        <template v-else-if="tournaments.length">
          <div class="tournaments-grid">
            <div v-for="t in tournaments" :key="t.id" class="tournament-card" :class="t.status === 'live' ? 'card-live' : ''">
              <div class="tc-glow" />
              <div class="tc-top">
                <span class="tc-status" :class="t.status === 'live' ? 'st-live' : 'st-done'">
                  <span v-if="t.status === 'live'" class="st-pulse" />
                  {{ t.status === 'live' ? 'En cours' : 'Terminé' }}
                </span>
                <span class="tc-format">{{ fmtFormat(t) }}</span>
              </div>
              <h3 class="tc-name">{{ t.name }}</h3>
              <p v-if="t.winner_name && t.status === 'completed'" class="tc-winner">
                Vainqueur — <strong>{{ t.winner_name }}</strong>
              </p>
              <RouterLink to="/login" class="tc-link">Voir le bracket →</RouterLink>
            </div>
          </div>
        </template>

        <div v-else class="empty-state"><p>Aucun tournoi en cours pour le moment.</p></div>
      </div>
    </section>

    <!-- ═══ REJOINDRE ═══ -->
    <section class="pub-join">
      <div class="pub-join-inner">
        <div class="join-blob-1" /><div class="join-blob-2" />
        <img src="/assets/icons/icon-192x192.png" alt="" class="join-logo" />
        <h2 class="join-title">Prêt à rejoindre le club ?</h2>
        <p class="join-desc">Participe aux journées officielles D1 et D2, affronte les membres, grimpe dans le classement de saison.</p>
        <RouterLink to="/inscription" class="hero-btn-primary mt-4">
          <span>Faire une demande de membre</span>
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3" /></svg>
        </RouterLink>
      </div>
    </section>

    <!-- ═══ FOOTER ═══ -->
    <footer class="pub-footer">
      <div class="pub-footer-inner">
        <div class="footer-logo">
          <img src="/assets/icons/apple-touch-icon.png" alt="" class="footer-logo-img" />
          <span>GOUZEPE eFOOTBALL CLUB</span>
        </div>
        <div class="footer-links">
          <RouterLink to="/login" class="footer-link">Espace membres</RouterLink>
          <RouterLink to="/inscription" class="footer-link">Devenir membre</RouterLink>
        </div>
        <p class="footer-copy">© GOUZEPE GAMING CLUB 2026</p>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import axios from 'axios'
import { resolveBaseURL } from '@/composables/useAPI'

const base = resolveBaseURL()
const latestDay = ref(null)
const tournaments = ref([])
const loadingDay = ref(true)
const loadingTournaments = ref(true)
const playerCount = ref(null)
const tournamentCount = ref(null)

function fmtDate(d) {
  if (!d) return ''
  return new Date(d + 'T12:00:00').toLocaleDateString('fr-FR', { weekday: 'long', day: '2-digit', month: 'long', year: 'numeric' })
}

function fmtFormat(t) {
  const f = { single_elimination: 'Élimination simple', double_elimination: 'Double élimination', round_robin: 'Round Robin', groups_knockout: 'Groupes + Finales' }[t.format] || t.format
  if (t.format === 'round_robin') return f + (t.rr_match_mode === 'home_away' ? ' · Aller/Retour' : '')
  return f
}

function goto(id) { document.getElementById(id)?.scrollIntoView({ behavior: 'smooth', block: 'start' }) }

onMounted(async () => {
  try {
    const { data } = await axios.get(`${base}/public/latest-day`)
    latestDay.value = data.day ? data : null
  } catch (_) {}
  loadingDay.value = false

  try {
    const { data } = await axios.get(`${base}/public/tournaments`)
    tournaments.value = data.tournaments || []
    tournamentCount.value = tournaments.value.length
  } catch (_) {}
  loadingTournaments.value = false

  try {
    const { data } = await axios.get(`${base}/players`)
    playerCount.value = (data.players || []).filter(p => p.role !== 'INVITE').length
  } catch (_) {}
})
</script>

<style scoped>
/* ── Reset & Base ── */
.pub-root { min-height: 100dvh; display: flex; flex-direction: column; background: #060f22; color: #eef4ff; font-family: var(--font-body, 'Inter', sans-serif); }

/* ── Header ── */
.pub-header {
  position: fixed; top: 0; left: 0; right: 0; z-index: 100;
  background: rgba(6,15,34,.8);
  backdrop-filter: blur(16px);
  border-bottom: 1px solid rgba(255,255,255,.07);
}
.pub-header-inner {
  max-width: 1200px; margin: 0 auto; padding: 0 1.5rem;
  height: 64px; display: flex; align-items: center; justify-content: space-between; gap: 1rem;
}
.pub-logo { display: flex; align-items: center; gap: 0.65rem; text-decoration: none; color: inherit; }
.pub-logo-img { width: 36px; height: 36px; border-radius: 10px; object-fit: cover; box-shadow: 0 0 12px rgba(34,197,94,.4); }
.pub-logo-name { font-weight: 900; font-size: 1rem; letter-spacing: 0.08em; line-height: 1; }
.pub-logo-tag { font-size: 0.58rem; font-weight: 700; color: #22c55e; letter-spacing: 0.14em; text-transform: uppercase; }
.pub-nav { display: flex; align-items: center; gap: 0.5rem; }
.pub-nav-btn { background: none; border: none; color: rgba(238,244,255,.6); font-size: 0.85rem; cursor: pointer; padding: 0.4rem 0.75rem; border-radius: 8px; transition: color .15s, background .15s; font-family: inherit; text-decoration: none; }
.pub-nav-btn:hover { color: #eef4ff; background: rgba(255,255,255,.06); }
.pub-cta-btn {
  background: linear-gradient(135deg, #22c55e, #16a34a);
  color: #fff; font-weight: 700; font-size: 0.85rem;
  padding: 0.45rem 1rem; border-radius: 8px;
  text-decoration: none; transition: opacity .15s, transform .15s;
  box-shadow: 0 4px 14px rgba(34,197,94,.35);
}
.pub-cta-btn:hover { opacity: .9; transform: translateY(-1px); }

/* ── Hero ── */
.pub-hero {
  position: relative; min-height: 100dvh;
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  overflow: hidden; padding: 80px 1.5rem 4rem;
}
.hero-video {
  position: absolute; inset: 0; width: 100%; height: 100%;
  object-fit: cover; z-index: 0; opacity: .25;
}
.hero-overlay {
  position: absolute; inset: 0; z-index: 1;
  background: linear-gradient(180deg, rgba(6,15,34,.5) 0%, rgba(6,15,34,.85) 70%, #060f22 100%);
}
.hero-blob {
  position: absolute; border-radius: 50%; filter: blur(80px); z-index: 1; pointer-events: none;
  animation: blobFloat 8s ease-in-out infinite;
}
.blob-1 { width: 500px; height: 500px; background: rgba(34,197,94,.12); top: -100px; right: -100px; animation-delay: 0s; }
.blob-2 { width: 400px; height: 400px; background: rgba(95,141,255,.1); bottom: 50px; left: -80px; animation-delay: -3s; }
.blob-3 { width: 300px; height: 300px; background: rgba(34,197,94,.08); top: 40%; left: 60%; animation-delay: -6s; }
@keyframes blobFloat {
  0%,100% { transform: translate(0,0) scale(1); }
  33% { transform: translate(20px,-15px) scale(1.05); }
  66% { transform: translate(-10px,20px) scale(.95); }
}

.hero-content { position: relative; z-index: 2; text-align: center; max-width: 680px; animation: fadeUp .8s ease both; }
@keyframes fadeUp { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }

.hero-badge {
  display: inline-flex; align-items: center; gap: 0.5rem;
  background: rgba(34,197,94,.1); border: 1px solid rgba(34,197,94,.3);
  border-radius: 99px; padding: 0.3rem 1rem; font-size: 0.78rem; font-weight: 600;
  color: #22c55e; margin-bottom: 1.5rem; animation: fadeUp .8s .1s ease both;
}
.hero-badge-dot { width: 6px; height: 6px; border-radius: 50%; background: #22c55e; box-shadow: 0 0 8px #22c55e; animation: pulse 2s infinite; }
@keyframes pulse { 0%,100% { opacity: 1; } 50% { opacity: .4; } }

.hero-logo { width: 90px; height: 90px; border-radius: 22px; margin: 0 auto 1.25rem; display: block; box-shadow: 0 0 40px rgba(34,197,94,.35), 0 12px 32px rgba(0,0,0,.5); animation: fadeUp .8s .2s ease both; }
.hero-title { margin-bottom: 0.25rem; animation: fadeUp .8s .3s ease both; }
.hero-title-main {
  display: block; font-size: clamp(2.8rem, 7vw, 5rem); font-weight: 900;
  letter-spacing: 0.06em; line-height: 1;
  background: linear-gradient(135deg, #fff 0%, #22c55e 50%, #5f8dff 100%);
  -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
  font-family: var(--font-title, 'Exo 2', sans-serif);
}
.hero-title-sub {
  display: block; font-size: clamp(.9rem, 2.5vw, 1.3rem); font-weight: 700;
  letter-spacing: 0.18em; color: rgba(238,244,255,.5); text-transform: uppercase; margin-top: .25rem;
}
.hero-desc { font-size: 1rem; color: rgba(238,244,255,.6); line-height: 1.65; margin: 1rem 0 2rem; animation: fadeUp .8s .4s ease both; }
.hero-actions { display: flex; gap: .75rem; justify-content: center; flex-wrap: wrap; margin-bottom: 2.5rem; animation: fadeUp .8s .5s ease both; }

.hero-btn-primary {
  display: inline-flex; align-items: center; gap: .5rem;
  background: linear-gradient(135deg, #22c55e, #16a34a);
  color: #fff; font-weight: 700; font-size: .9rem;
  padding: .7rem 1.5rem; border-radius: 10px; text-decoration: none;
  box-shadow: 0 4px 20px rgba(34,197,94,.4); transition: transform .15s, box-shadow .15s;
}
.hero-btn-primary:hover { transform: translateY(-2px); box-shadow: 0 8px 28px rgba(34,197,94,.5); }
.hero-btn-ghost {
  display: inline-flex; align-items: center; gap: .5rem;
  background: rgba(255,255,255,.07); border: 1px solid rgba(255,255,255,.15);
  color: #eef4ff; font-weight: 600; font-size: .9rem;
  padding: .7rem 1.5rem; border-radius: 10px; text-decoration: none;
  transition: background .15s, border-color .15s;
}
.hero-btn-ghost:hover { background: rgba(255,255,255,.12); border-color: rgba(255,255,255,.25); }

.hero-stats { display: flex; align-items: center; gap: 1.5rem; justify-content: center; animation: fadeUp .8s .6s ease both; }
.hero-stat { text-align: center; }
.hero-stat-num { display: block; font-size: 1.6rem; font-weight: 900; color: #22c55e; }
.hero-stat-label { display: block; font-size: 0.72rem; color: rgba(238,244,255,.45); text-transform: uppercase; letter-spacing: .08em; }
.hero-stat-sep { width: 1px; height: 36px; background: rgba(255,255,255,.1); }

.hero-scroll {
  position: absolute; bottom: 2rem; left: 50%; transform: translateX(-50%);
  z-index: 2; display: flex; flex-direction: column; align-items: center; gap: .35rem;
  cursor: pointer; color: rgba(238,244,255,.35); font-size: .72rem; letter-spacing: .08em; text-transform: uppercase;
  animation: bounce 2.5s ease-in-out infinite;
}
@keyframes bounce { 0%,100% { transform: translateX(-50%) translateY(0); } 50% { transform: translateX(-50%) translateY(6px); } }
.hero-scroll-icon { background: rgba(255,255,255,.06); border: 1px solid rgba(255,255,255,.1); border-radius: 50%; padding: .35rem; }

/* ── Sections ── */
.pub-section { padding: 5rem 1.5rem; }
.pub-section-alt { background: rgba(255,255,255,.02); }
.pub-section-inner { max-width: 1100px; margin: 0 auto; }
.section-label { display: flex; align-items: center; gap: .75rem; margin-bottom: .75rem; }
.section-label-line { flex: 1; height: 1px; background: linear-gradient(90deg, transparent, rgba(34,197,94,.3), transparent); }
.section-label span { font-size: .68rem; font-weight: 800; letter-spacing: .14em; text-transform: uppercase; color: #22c55e; white-space: nowrap; }
.section-title { font-size: clamp(1.5rem, 3vw, 2rem); font-weight: 900; margin-bottom: 2rem; font-family: var(--font-title, sans-serif); }

/* ── Loading ── */
.pub-loading-spinner { display: flex; justify-content: center; padding: 3rem; }
.spinner { width: 36px; height: 36px; border: 3px solid rgba(34,197,94,.2); border-top-color: #22c55e; border-radius: 50%; animation: spin .7s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }

/* ── Journée ── */
.day-meta { margin-bottom: 1.5rem; }
.day-date-tag {
  display: inline-block; background: rgba(34,197,94,.1); border: 1px solid rgba(34,197,94,.25);
  color: #22c55e; font-size: .82rem; font-weight: 700; padding: .35rem 1rem; border-radius: 99px; margin-bottom: 1rem;
}
.day-champions { display: flex; flex-wrap: wrap; gap: .75rem; }
.champ-card {
  display: flex; align-items: center; gap: .75rem;
  background: rgba(255,255,255,.04); border: 1px solid rgba(255,255,255,.08);
  border-radius: 12px; padding: .7rem 1.1rem;
  backdrop-filter: blur(8px);
}
.champ-d2 { border-color: rgba(95,141,255,.2); }
.champ-crown { font-size: 1.3rem; }
.champ-info { display: flex; flex-direction: column; gap: 1px; }
.champ-div { font-size: .62rem; font-weight: 800; text-transform: uppercase; letter-spacing: .1em; color: #22c55e; }
.champ-d2 .champ-div { color: #5f8dff; }
.champ-name { font-size: .92rem; font-weight: 700; }
.champ-team { font-size: .75rem; color: rgba(238,244,255,.45); }

.standings-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1.25rem; margin-bottom: 1.5rem; }
.standings-card {
  background: rgba(13,27,54,.6); border: 1px solid rgba(255,255,255,.07);
  border-radius: 14px; overflow: hidden;
  backdrop-filter: blur(8px);
  transition: border-color .2s;
}
.standings-card:hover { border-color: rgba(34,197,94,.2); }
.standings-card-header {
  display: flex; align-items: center; gap: .6rem;
  padding: .7rem 1rem; border-bottom: 1px solid rgba(255,255,255,.06);
  background: rgba(255,255,255,.03);
}
.standings-div-badge {
  font-size: .65rem; font-weight: 800; letter-spacing: .08em; text-transform: uppercase;
  padding: 2px 8px; border-radius: 99px;
}
.badge-d1 { background: rgba(34,197,94,.15); color: #22c55e; }
.badge-d2 { background: rgba(95,141,255,.15); color: #5f8dff; }
.standings-title { font-size: .8rem; font-weight: 700; color: rgba(238,244,255,.7); }
.standings-scroll { overflow-x: auto; -webkit-overflow-scrolling: touch; }
.standings-empty { padding: 2rem; text-align: center; color: rgba(238,244,255,.35); font-size: .88rem; }

.st-table { width: 100%; min-width: 380px; border-collapse: collapse; font-size: .82rem; }
.st-table thead th { padding: .45rem .6rem; text-align: center; font-size: .62rem; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; color: rgba(238,244,255,.3); border-bottom: 1px solid rgba(255,255,255,.06); }
.th-rank,.th-name { text-align: left; }
.th-name { min-width: 90px; }
.th-v { color: rgba(34,197,94,.6) !important; }
.th-d { color: rgba(212,60,73,.6) !important; }
.th-pts { color: #eef4ff !important; }
.st-row { border-bottom: 1px solid rgba(255,255,255,.04); transition: background .12s; }
.st-row:hover { background: rgba(255,255,255,.03); }
.row-champ { background: rgba(34,197,94,.05) !important; }
.st-table tbody td { padding: .4rem .6rem; text-align: center; }
.td-rank { text-align: left; }
.td-name { text-align: left; font-weight: 600; }
.rank-gold { color: #fbbf24; font-weight: 900; }
.rank-silver { color: #9ca3af; font-weight: 700; }
.rank-bronze { color: #b45309; font-weight: 700; }
.rank-num { color: rgba(238,244,255,.3); font-size: .75rem; }
.td-v { color: #22c55e; font-weight: 700; }
.td-d { color: #d43c49; }
.td-pos { color: #22c55e; font-weight: 700; }
.td-neg { color: #d43c49; }
.td-pts { font-weight: 800; color: #eef4ff; }
.invite-sep-row td { padding: .3rem .6rem; font-size: .62rem; font-weight: 800; text-transform: uppercase; letter-spacing: .08em; color: rgba(238,244,255,.3); background: rgba(255,255,255,.02); }
.invite-row td { opacity: .5; font-style: italic; }
.day-cta { display: flex; gap: .75rem; flex-wrap: wrap; }

/* ── Tournois ── */
.tournaments-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 1rem; }
.tournament-card {
  position: relative; overflow: hidden;
  background: rgba(13,27,54,.6); border: 1px solid rgba(255,255,255,.07);
  border-radius: 14px; padding: 1.25rem;
  backdrop-filter: blur(8px); transition: border-color .2s, transform .2s;
}
.tournament-card:hover { border-color: rgba(34,197,94,.25); transform: translateY(-2px); }
.card-live { border-color: rgba(34,197,94,.2) !important; }
.tc-glow {
  position: absolute; top: 0; right: 0; width: 120px; height: 120px;
  background: radial-gradient(circle, rgba(34,197,94,.08) 0%, transparent 70%);
  pointer-events: none;
}
.tc-top { display: flex; align-items: center; justify-content: space-between; margin-bottom: .6rem; }
.tc-status { display: inline-flex; align-items: center; gap: .4rem; font-size: .68rem; font-weight: 700; padding: 2px 8px; border-radius: 99px; }
.st-live { background: rgba(34,197,94,.15); color: #22c55e; }
.st-done { background: rgba(255,255,255,.06); color: rgba(238,244,255,.4); }
.st-pulse { width: 6px; height: 6px; border-radius: 50%; background: #22c55e; animation: pulse 1.5s infinite; }
.tc-format { font-size: .68rem; color: rgba(238,244,255,.3); }
.tc-name { font-size: .95rem; font-weight: 800; margin-bottom: .35rem; font-family: var(--font-title, sans-serif); }
.tc-winner { font-size: .78rem; color: rgba(238,244,255,.45); margin-bottom: .5rem; }
.tc-link { font-size: .78rem; color: #22c55e; font-weight: 700; text-decoration: none; }
.tc-link:hover { text-decoration: underline; }

/* ── Rejoindre ── */
.pub-join {
  position: relative; overflow: hidden;
  background: linear-gradient(135deg, rgba(13,27,54,1) 0%, rgba(6,20,44,1) 100%);
  border-top: 1px solid rgba(34,197,94,.15);
  padding: 5rem 1.5rem; text-align: center;
}
.pub-join-inner { max-width: 560px; margin: 0 auto; position: relative; z-index: 1; display: flex; flex-direction: column; align-items: center; }
.join-blob-1 { position: absolute; width: 400px; height: 400px; background: rgba(34,197,94,.08); border-radius: 50%; filter: blur(80px); top: -100px; left: -100px; }
.join-blob-2 { position: absolute; width: 300px; height: 300px; background: rgba(95,141,255,.06); border-radius: 50%; filter: blur(60px); bottom: -80px; right: -80px; }
.join-logo { width: 80px; height: 80px; border-radius: 20px; box-shadow: 0 0 40px rgba(34,197,94,.3); margin-bottom: 1.25rem; }
.join-title { font-size: clamp(1.5rem,3vw,2rem); font-weight: 900; margin-bottom: .6rem; font-family: var(--font-title, sans-serif); }
.join-desc { font-size: .95rem; color: rgba(238,244,255,.5); line-height: 1.65; }

/* ── Empty ── */
.empty-state { text-align: center; padding: 3rem; color: rgba(238,244,255,.35); font-size: .9rem; border: 1px dashed rgba(255,255,255,.08); border-radius: 12px; }

/* ── Footer ── */
.pub-footer { background: rgba(3,8,24,.95); border-top: 1px solid rgba(255,255,255,.06); padding: 1.5rem; }
.pub-footer-inner { max-width: 1100px; margin: 0 auto; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 1rem; }
.footer-logo { display: flex; align-items: center; gap: .5rem; font-size: .78rem; font-weight: 700; color: rgba(238,244,255,.4); }
.footer-logo-img { width: 24px; height: 24px; border-radius: 6px; opacity: .6; }
.footer-links { display: flex; gap: 1rem; }
.footer-link { font-size: .78rem; color: rgba(238,244,255,.35); text-decoration: none; transition: color .15s; }
.footer-link:hover { color: #22c55e; }
.footer-copy { font-size: .72rem; color: rgba(238,244,255,.2); }

/* ── Mobile ── */
@media (max-width: 640px) {
  .pub-nav .pub-nav-btn:not(.pub-cta-btn) { display: none; }
  .hero-stats { gap: 1rem; }
}
</style>
