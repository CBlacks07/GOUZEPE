<template>
  <div class="hub">
    <PublicNav />

    <!-- Hero compact -->
    <section class="m-hero">
      <div class="m-hero-tint" aria-hidden="true"></div>
      <div class="m-hero-content">
        <span class="eyebrow">La communauté</span>
        <h1 class="m-title">Membres du club</h1>
        <p class="m-lead">Les joueurs qui font vivre la compétition eFootball &amp; Tekken.</p>
      </div>
    </section>

    <!-- Annuaire -->
    <section class="section">
      <div class="game-tabs">
        <button :class="['gt', { on: activeGame === 'efoot' }]" @click="selectGame('efoot')">eFootball</button>
        <button :class="['gt', { on: activeGame === 'tekken' }]" @click="selectGame('tekken')">Tekken</button>
      </div>

      <!-- Tekken : à venir -->
      <div v-if="activeGame === 'tekken'" class="soon-box">
        <TrophyIcon class="soon-ic" />
        <h3>Membres Tekken — bientôt</h3>
        <p>Le pôle Tekken se prépare. Les joueurs Tekken apparaîtront ici dès le lancement.</p>
        <RouterLink to="/inscription" class="btn-primary cta-lg">Rejoindre le club</RouterLink>
      </div>

      <template v-else>
        <div class="section-head">
          <h2>Annuaire</h2>
          <p v-if="!loading">{{ filtered.length }} membre(s)</p>
        </div>

        <div class="m-toolbar">
          <input v-model="search" type="text" class="input m-search" placeholder="Rechercher un membre…" />
        </div>

        <div v-if="loading" class="empty">Chargement…</div>
        <div v-else-if="!filtered.length" class="empty">Aucun membre trouvé.</div>
        <div v-else class="m-grid">
        <article v-for="m in filtered" :key="m.player_id" class="m-card">
          <div class="m-avatar">
            <img v-if="avatarUrl(m)" :src="avatarUrl(m)" :alt="m.name" />
            <span v-else>{{ initials(m.name) }}</span>
          </div>
          <div class="m-info">
            <span class="m-id">{{ m.player_id }}</span>
            <strong class="m-name">{{ m.name }}</strong>
            <span class="m-since">Membre depuis {{ m.admission_year || memberYear(m.created_at) }}</span>
          </div>
          <span v-if="isAdminRole(m.role)" class="m-badge">Admin</span>
        </article>
        </div>
      </template>
    </section>

    <section class="section join-band">
      <h2>Rejoins-les</h2>
      <p>Deviens membre et entre dans la compétition.</p>
      <RouterLink to="/inscription" class="btn-primary cta-lg">Devenir membre</RouterLink>
    </section>

    <PublicFooter />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { TrophyIcon } from 'lucide-vue-next'
import PublicNav from '@/components/public/PublicNav.vue'
import PublicFooter from '@/components/public/PublicFooter.vue'
import { useGameStore } from '@/stores/game'
import { resolveBaseURL } from '@/composables/useAPI'

const game = useGameStore()
const activeGame = ref(game.isTekken ? 'tekken' : 'efoot')
const members = ref([])
const loading = ref(true)
const search = ref('')

function selectGame(g) {
  if (activeGame.value === g) return
  activeGame.value = g
  game.set(g)
}

const filtered = computed(() => {
  const q = search.value.trim().toLowerCase()
  if (!q) return members.value
  return members.value.filter(m => (m.name || '').toLowerCase().includes(q) || (m.player_id || '').toLowerCase().includes(q))
})

function initials(name) {
  return String(name || '?').trim().split(/\s+/).slice(0, 2).map(w => w[0]).join('').toUpperCase()
}
function avatarUrl(m) {
  const u = m.profile_pic_url
  if (!u) return ''
  return /^https?:\/\//.test(u) ? u : resolveBaseURL() + (u.startsWith('/') ? u : '/' + u)
}
function isAdminRole(role) {
  return String(role || '').toUpperCase() === 'ADMIN'
}
function memberYear(d) {
  if (!d) return '—'
  try { return String(new Date(d).getFullYear()) } catch (_) { return '—' }
}

onMounted(async () => {
  game.set(activeGame.value)
  try {
    const r = await fetch(resolveBaseURL() + '/public/members', { headers: { Accept: 'application/json' } })
    if (r.ok) { const d = await r.json(); members.value = d.members || [] }
  } catch (_) {}
  loading.value = false
})
</script>

<style scoped>
.hub { position: relative; z-index: 1; color: var(--text); }

.m-hero { position: relative; overflow: hidden; padding: 3.5rem clamp(1.25rem, 4vw, 4rem); }
.m-hero-tint { position: absolute; inset: 0; background: radial-gradient(60vw 50vh at 20% 0%, rgba(var(--accent-rgb), .22), transparent 60%); }
.m-hero-content { position: relative; z-index: 1; }
.eyebrow { display: inline-block; font-family: var(--font-title); font-weight: 700; letter-spacing: .26em; text-transform: uppercase; font-size: .72rem; color: var(--accent-l); padding: .3rem .8rem; border: 1px solid color-mix(in srgb, var(--accent) 45%, transparent); border-radius: 999px; margin-bottom: 1rem; }
.m-title { font-family: var(--font-title); font-weight: 700; font-size: clamp(2.2rem, 5vw, 3.6rem); text-transform: uppercase; letter-spacing: .02em; margin: 0 0 .6rem; }
.m-lead { color: var(--muted); max-width: 40rem; margin: 0; }

.section { padding: 1rem clamp(1.25rem, 4vw, 4rem) 3.5rem; }
.section-head { margin-bottom: 1rem; }
.section-head h2 { font-family: var(--font-title); font-weight: 700; font-size: clamp(1.4rem, 3vw, 2rem); text-transform: uppercase; letter-spacing: .04em; margin: 0 0 .3rem; }
.section-head h2::after { content: ''; display: block; width: 3rem; height: 3px; margin-top: .6rem; border-radius: 3px; background: var(--accent); }
.section-head p { color: var(--muted); margin: 0; }

.game-tabs { display: inline-flex; gap: .4rem; padding: 4px; border: 1px solid var(--border); border-radius: 999px; background: var(--card); margin-bottom: 1.5rem; }
.gt { padding: .45rem 1.2rem; border: none; background: transparent; color: var(--muted); font-family: var(--font-title); font-weight: 700; letter-spacing: .03em; text-transform: uppercase; font-size: .84rem; border-radius: 999px; cursor: pointer; transition: all .18s; }
.gt.on { background: var(--accent); color: #fff; box-shadow: 0 3px 12px rgba(var(--accent-rgb), .35); }

.soon-box { text-align: center; border: 1px solid var(--border); border-radius: 16px; background: var(--card); padding: 3rem 1.5rem; }
.soon-ic { width: 2.4rem; height: 2.4rem; color: var(--accent); margin: 0 auto .8rem; }
.soon-box h3 { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .04em; font-size: 1.4rem; margin: 0 0 .5rem; }
.soon-box p { color: var(--muted); max-width: 34rem; margin: 0 auto 1.5rem; }

.m-toolbar { margin-bottom: 1.5rem; }
.m-search { max-width: 22rem; }

.m-grid { display: grid; gap: .9rem; grid-template-columns: 1fr; }
.m-card { display: flex; align-items: center; gap: .9rem; padding: .85rem 1rem; background: var(--card); border: 1px solid var(--border); border-radius: 14px; transition: transform .15s, border-color .15s; }
.m-card:hover { transform: translateY(-2px); border-color: color-mix(in srgb, var(--accent) 45%, var(--border)); }
.m-avatar { width: 46px; height: 46px; border-radius: 50%; flex: none; display: grid; place-items: center; overflow: hidden; background: color-mix(in srgb, var(--accent) 18%, var(--panel)); color: var(--accent-l); font-family: var(--font-title); font-weight: 700; }
.m-avatar img { width: 100%; height: 100%; object-fit: cover; }
.m-info { display: flex; flex-direction: column; min-width: 0; }
.m-id { font-size: .75rem; color: var(--accent-l); font-family: var(--font-title); font-weight: 600; letter-spacing: .02em; opacity: .85; }
.m-name { font-weight: 600; font-size: 1rem; }
.m-since { font-size: .75rem; color: var(--muted); }
.m-badge { margin-left: auto; font-size: .68rem; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; color: var(--accent-l); border: 1px solid color-mix(in srgb, var(--accent) 40%, transparent); padding: .15rem .55rem; border-radius: 999px; }
.empty { color: var(--muted); }

.join-band { text-align: center; }
.join-band h2 { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .04em; font-size: clamp(1.6rem, 4vw, 2.2rem); margin: 0 0 .6rem; }
.join-band p { color: var(--muted); margin: 0 0 1.5rem; }
.cta-lg { padding: .8rem 1.6rem; font-size: 1rem; border-radius: .7rem; }

@media (min-width: 560px) { .m-grid { grid-template-columns: 1fr 1fr; } }
@media (min-width: 960px) { .m-grid { grid-template-columns: repeat(3, 1fr); } }
@media (min-width: 1300px) { .m-grid { grid-template-columns: repeat(4, 1fr); } }
</style>
