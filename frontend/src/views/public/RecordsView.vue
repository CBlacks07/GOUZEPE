<template>
  <div class="rec">
    <PublicNav />

    <section class="section">
      <div class="section-head">
        <h1>Records du club</h1>
        <p>Les performances qui marquent l'histoire.</p>
      </div>

      <div v-if="loading" class="empty">Chargement…</div>
      <div v-else class="rec-grid">
        <article v-if="r.carton" class="rec-card">
          <div class="rec-icon icon-red"><ZapIcon class="w-5 h-5" /></div>
          <span class="rec-label">Plus large victoire</span>
          <div class="rec-value">{{ r.carton.winner_name }} <span class="score">{{ r.carton.wScore }}–{{ r.carton.lScore }}</span> {{ r.carton.loser_name }}</div>
          <div class="rec-sub">{{ r.carton.div }} · {{ fmtDate(r.carton.date) }}</div>
        </article>

        <article v-if="r.best_streak" class="rec-card">
          <div class="rec-icon icon-orange"><FlameIcon class="w-5 h-5" /></div>
          <span class="rec-label">Meilleure série</span>
          <div class="rec-value">{{ r.best_streak.name }}</div>
          <div class="rec-sub">{{ r.best_streak.streak }} journées gagnées d'affilée</div>
        </article>

        <article v-if="r.most_titles" class="rec-card">
          <div class="rec-icon icon-gold"><TrophyIcon class="w-5 h-5" /></div>
          <span class="rec-label">Plus de titres D1</span>
          <div class="rec-value">{{ r.most_titles.name }}</div>
          <div class="rec-sub">{{ r.most_titles.count }} journées remportées</div>
        </article>

        <article v-if="r.top_journee" class="rec-card">
          <div class="rec-icon icon-green"><TargetIcon class="w-5 h-5" /></div>
          <span class="rec-label">Festival offensif</span>
          <div class="rec-value">{{ r.top_journee.name }}</div>
          <div class="rec-sub">{{ r.top_journee.goals }} buts sur une journée · {{ fmtDate(r.top_journee.date) }}</div>
        </article>

        <article v-if="r.best_avg" class="rec-card">
          <div class="rec-icon icon-blue"><BarChart2Icon class="w-5 h-5" /></div>
          <span class="rec-label">Meilleure moyenne de saison</span>
          <div class="rec-value">{{ r.best_avg.name }}</div>
          <div class="rec-sub">{{ Number(r.best_avg.moyenne).toFixed(2) }} de moyenne · {{ r.best_avg.season }}</div>
        </article>

        <div v-if="!hasAny" class="empty">Pas encore de données pour établir des records.</div>
      </div>
    </section>

    <PublicFooter />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import PublicNav from '@/components/public/PublicNav.vue'
import PublicFooter from '@/components/public/PublicFooter.vue'
import { resolveBaseURL } from '@/composables/useAPI'
import { ZapIcon, FlameIcon, TrophyIcon, TargetIcon, BarChart2Icon } from 'lucide-vue-next'

const loading = ref(true)
const r = ref({})
const hasAny = computed(() => Object.values(r.value || {}).some(Boolean))

function fmtDate(d) {
  if (!d) return ''
  try { return new Date(d + 'T12:00:00').toLocaleDateString('fr-FR', { day: '2-digit', month: 'long', year: 'numeric' }) } catch (_) { return d }
}

onMounted(async () => {
  try {
    const res = await fetch(resolveBaseURL() + '/public/records', { headers: { Accept: 'application/json' } })
    if (res.ok) { const d = await res.json(); r.value = d.records || {} }
  } catch (_) {}
  loading.value = false
})
</script>

<style scoped>
.rec { position: relative; z-index: 1; color: var(--text); min-height: 100dvh; }
.section { padding: 3rem clamp(1.25rem, 4vw, 4rem); }
.section-head { margin-bottom: 2rem; }
.section-head h1 { font-family: var(--font-title); font-weight: 700; font-size: clamp(2rem, 5vw, 3rem); text-transform: uppercase; letter-spacing: .03em; margin: 0 0 .4rem; }
.section-head h1::after { content: ''; display: block; width: 3rem; height: 3px; margin-top: .6rem; border-radius: 3px; background: var(--accent); }
.section-head p { color: var(--muted); margin: 0; }
.empty { color: var(--muted); padding: 2rem 0; }

.rec-grid { display: grid; gap: 1.1rem; grid-template-columns: 1fr; }
@media (min-width: 720px) { .rec-grid { grid-template-columns: 1fr 1fr; } }
@media (min-width: 1100px) { .rec-grid { grid-template-columns: repeat(3, 1fr); } }

.rec-card { border: 1px solid var(--border); border-radius: 16px; background: var(--card); padding: 1.25rem; transition: transform .18s, border-color .18s; }
.rec-card:hover { transform: translateY(-3px); border-color: color-mix(in srgb, var(--accent) 45%, var(--border)); }
.rec-icon { width: 2.4rem; height: 2.4rem; border-radius: 12px; display: grid; place-items: center; margin-bottom: .8rem; }
.icon-red { color: #ef4444; background: color-mix(in srgb, #ef4444 14%, transparent); }
.icon-orange { color: #f97316; background: color-mix(in srgb, #f97316 14%, transparent); }
.icon-gold { color: #eab308; background: color-mix(in srgb, #eab308 15%, transparent); }
.icon-green { color: #22c55e; background: color-mix(in srgb, #22c55e 14%, transparent); }
.icon-blue { color: #3b82f6; background: color-mix(in srgb, #3b82f6 14%, transparent); }
.rec-label { font-size: .68rem; font-weight: 800; text-transform: uppercase; letter-spacing: .06em; color: var(--muted); }
.rec-value { font-family: var(--font-title); font-weight: 800; font-size: 1.15rem; margin: .35rem 0 .2rem; line-height: 1.2; }
.rec-value .score { color: var(--accent-l, var(--accent)); }
.rec-sub { font-size: .8rem; color: var(--muted); }
</style>
