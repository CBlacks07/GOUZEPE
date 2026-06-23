<template>
  <AppLayout season-label="Tekken">
    <div class="page-wrap tk-page">
      <div class="section-head">
        <h1>Tekken Ladder</h1>
        <p>Classement ELO des duels classes entre membres.</p>
      </div>

      <!-- Onglets -->
      <div class="tabs">
        <button :class="['tab', { on: tab === 'ladder' }]" @click="tab='ladder'">
          <ListOrderedIcon class="w-4 h-4" /> Classement
        </button>
        <button :class="['tab', { on: tab === 'history' }]" @click="tab='history'">
          <SwordsIcon class="w-4 h-4" /> Duels recents
        </button>
      </div>

      <!-- TAB: Ladder -->
      <section v-if="tab === 'ladder'" class="card">
        <div v-if="loading" class="empty">Chargement...</div>
        <div v-else-if="!ladder.length" class="empty">Aucun joueur dans le ladder Tekken.</div>
        <div v-else class="overflow-x-auto">
          <table class="data-table">
            <thead>
              <tr>
                <th class="w-10">#</th>
                <th>Joueur</th>
                <th class="text-center">ELO</th>
                <th class="text-center">V</th>
                <th class="text-center">D</th>
                <th class="text-center">%</th>
                <th class="text-center">Serie</th>
                <th class="text-center">Meilleure serie</th>
                <th class="text-center">Peak ELO</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(p, i) in ladder" :key="p.player_id" :class="{ 'row-highlight': i < 3 }">
                <td>
                  <span v-if="i === 0" class="rank-medal gold">1</span>
                  <span v-else-if="i === 1" class="rank-medal silver">2</span>
                  <span v-else-if="i === 2" class="rank-medal bronze">3</span>
                  <span v-else class="text-gz-muted font-bold">{{ i + 1 }}</span>
                </td>
                <td>
                  <div class="player-cell">
                    <div class="player-avatar">
                      <img v-if="p.profile_pic_url" :src="mediaUrl(p.profile_pic_url)" :alt="p.name" />
                      <span v-else>{{ initials(p.name) }}</span>
                    </div>
                    <div>
                      <span class="font-semibold">{{ p.name }}</span>
                      <span class="text-gz-muted text-xs block">{{ p.player_id }}</span>
                    </div>
                  </div>
                </td>
                <td class="text-center">
                  <span class="elo-badge">{{ p.elo }}</span>
                </td>
                <td class="text-center text-gz-green font-semibold">{{ p.wins }}</td>
                <td class="text-center text-gz-red font-semibold">{{ p.losses }}</td>
                <td class="text-center text-gz-muted">{{ winRate(p) }}%</td>
                <td class="text-center">
                  <span :class="p.streak > 0 ? 'streak-win' : p.streak < 0 ? 'streak-loss' : 'text-gz-muted'">
                    {{ p.streak > 0 ? 'W' + p.streak : p.streak < 0 ? 'L' + Math.abs(p.streak) : '--' }}
                  </span>
                </td>
                <td class="text-center font-semibold">{{ p.best_streak }}</td>
                <td class="text-center text-gz-muted">{{ p.peak_elo }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <!-- TAB: Duels recents -->
      <section v-if="tab === 'history'" class="card">
        <div v-if="duelsLoading" class="empty">Chargement...</div>
        <div v-else-if="!duels.length" class="empty">Aucun duel enregistre.</div>
        <div v-else class="duels-list">
          <article v-for="d in duels" :key="d.id" class="duel-card">
            <div class="duel-date">{{ fmtDate(d.played_at) }}</div>
            <div class="duel-match">
              <div :class="['duel-p', { winner: d.winner_id === d.p1_id }]">
                <span class="duel-pname">{{ d.p1_name }}</span>
                <span class="duel-elo-change" :class="eloDelta(d, d.p1_id) >= 0 ? 'up' : 'down'">
                  {{ eloDelta(d, d.p1_id) > 0 ? '+' : '' }}{{ eloDelta(d, d.p1_id) }}
                </span>
              </div>
              <div class="duel-score">{{ d.score_p1 }} - {{ d.score_p2 }}</div>
              <div :class="['duel-p right', { winner: d.winner_id === d.p2_id }]">
                <span class="duel-elo-change" :class="eloDelta(d, d.p2_id) >= 0 ? 'up' : 'down'">
                  {{ eloDelta(d, d.p2_id) > 0 ? '+' : '' }}{{ eloDelta(d, d.p2_id) }}
                </span>
                <span class="duel-pname">{{ d.p2_name }}</span>
              </div>
            </div>
            <div class="duel-bo">BO{{ d.best_of }}</div>
          </article>
        </div>
      </section>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import AppLayout from '@/components/layout/AppLayout.vue'
import { useAPI, mediaUrl } from '@/composables/useAPI'
import { ListOrderedIcon, SwordsIcon } from 'lucide-vue-next'

const api = useAPI()
const tab = ref('ladder')
const ladder = ref([])
const duels = ref([])
const loading = ref(true)
const duelsLoading = ref(true)

function initials(name) {
  return String(name || '?').trim().split(/\s+/).slice(0, 2).map(w => w[0]).join('').toUpperCase()
}

function winRate(p) {
  const total = p.wins + p.losses
  if (!total) return 0
  return Math.round((p.wins / total) * 100)
}

function fmtDate(d) {
  if (!d) return ''
  return new Date(d).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short', year: 'numeric' })
}

function eloDelta(d, pid) {
  if (pid === d.p1_id) return (d.elo_p1_after || 0) - (d.elo_p1_before || 0)
  return (d.elo_p2_after || 0) - (d.elo_p2_before || 0)
}

onMounted(async () => {
  try {
    const [ladderRes, duelsRes] = await Promise.all([
      api.get('/tekken/ladder'),
      api.get('/tekken/duels?limit=30'),
    ])
    ladder.value = ladderRes.data.ladder || []
    duels.value = duelsRes.data.duels || []
  } catch (_) {}
  loading.value = false
  duelsLoading.value = false
})
</script>

<style scoped>
.tk-page { max-width: 64rem; }
.section-head { margin-bottom: 1rem; }
.section-head h1 { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .04em; font-size: clamp(1.5rem, 3vw, 2rem); margin: 0 0 .3rem; }
.section-head h1::after { content: ''; display: block; width: 3rem; height: 3px; margin-top: .5rem; border-radius: 3px; background: var(--accent); }
.section-head p { color: var(--muted); margin: 0; }

.tabs { display: inline-flex; gap: .35rem; padding: 4px; border: 1px solid var(--border); border-radius: 999px; background: var(--card); margin-bottom: 1.2rem; }
.tab { display: flex; align-items: center; gap: .4rem; padding: .45rem 1rem; border: none; background: transparent; color: var(--muted); font-family: var(--font-title); font-weight: 700; letter-spacing: .03em; text-transform: uppercase; font-size: .8rem; border-radius: 999px; cursor: pointer; transition: all .18s; }
.tab.on { background: var(--accent); color: #fff; box-shadow: 0 3px 12px rgba(var(--accent-rgb), .35); }

.empty { color: var(--muted); padding: 2rem 0; text-align: center; }

.player-cell { display: flex; align-items: center; gap: .7rem; }
.player-avatar { width: 36px; height: 36px; border-radius: 50%; flex: none; display: grid; place-items: center; overflow: hidden; background: color-mix(in srgb, var(--accent) 18%, var(--panel)); color: var(--accent-l); font-family: var(--font-title); font-weight: 700; font-size: .75rem; }
.player-avatar img { width: 100%; height: 100%; object-fit: cover; }

.rank-medal { display: inline-flex; align-items: center; justify-content: center; width: 28px; height: 28px; border-radius: 50%; font-weight: 800; font-size: .82rem; }
.rank-medal.gold { background: linear-gradient(135deg, #ffd700, #f0c000); color: #1a1a2e; }
.rank-medal.silver { background: linear-gradient(135deg, #c0c0c0, #a8a8a8); color: #1a1a2e; }
.rank-medal.bronze { background: linear-gradient(135deg, #cd7f32, #b8722d); color: #1a1a2e; }

.elo-badge { font-weight: 800; font-size: 1.1rem; font-family: var(--font-title); color: var(--accent-l); }

.streak-win { color: var(--green, #22c55e); font-weight: 700; }
.streak-loss { color: var(--red, #ef4444); font-weight: 700; }

.row-highlight { background: color-mix(in srgb, var(--accent) 5%, transparent); }

/* Duels list */
.duels-list { display: flex; flex-direction: column; gap: .6rem; }
.duel-card { display: flex; align-items: center; gap: 1rem; padding: .85rem 1rem; background: var(--card); border: 1px solid var(--border); border-radius: 12px; transition: border-color .15s; }
.duel-card:hover { border-color: color-mix(in srgb, var(--accent) 40%, var(--border)); }
.duel-date { font-size: .72rem; color: var(--muted); min-width: 5.5rem; white-space: nowrap; }
.duel-match { flex: 1; display: flex; align-items: center; gap: .6rem; }
.duel-p { display: flex; align-items: center; gap: .4rem; flex: 1; }
.duel-p.right { justify-content: flex-end; text-align: right; }
.duel-pname { font-weight: 600; }
.duel-p.winner .duel-pname { color: var(--accent-l); }
.duel-score { font-family: var(--font-title); font-weight: 800; font-size: 1.2rem; min-width: 3.5rem; text-align: center; }
.duel-elo-change { font-size: .72rem; font-weight: 700; }
.duel-elo-change.up { color: var(--green, #22c55e); }
.duel-elo-change.down { color: var(--red, #ef4444); }
.duel-bo { font-size: .68rem; color: var(--muted); font-weight: 600; }

@media (max-width: 600px) {
  .duel-date { display: none; }
  .duel-match { flex-direction: column; gap: .3rem; }
  .duel-p.right { justify-content: flex-start; flex-direction: row-reverse; }
}
</style>
