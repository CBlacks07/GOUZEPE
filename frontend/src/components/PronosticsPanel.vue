<template>
  <section class="card pronos-card">
    <div class="pronos-head">
      <h3 class="font-semibold">Pronostics</h3>
      <span class="pronos-sub">{{ subtitle }}</span>
    </div>

    <div class="pronos-grid" :class="{ 'pronos-grid--solo': !titleRace.length && !flashes.length }">
      <!-- Course au titre -->
      <div v-if="titleRace.length || flashes.length" class="pronos-block">
        <div v-if="titleRace.length" class="pronos-block-head">
          <span class="pronos-block-title">Course au titre</span>
          <span v-if="titleConfidence" class="pronos-chip" :class="`tone-${titleConfidence.tone}`">{{ titleConfidence.label }}</span>
        </div>
        <div v-if="titleRace.length" class="title-race">
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
        <div v-if="flashes.length" class="pronos-flashes">
          <p v-for="f in flashes" :key="f.tag" class="pronos-flash">
            <span class="pronos-flash-tag">{{ f.tag }}</span>
            <span class="pronos-flash-text">{{ f.text }}</span>
          </p>
        </div>
        <slot name="left-extra" />
      </div>

      <!-- Affiches de la journée -->
      <div class="pronos-block">
        <div class="pronos-block-head">
          <span class="pronos-block-title">Affiches de la journée</span>
          <span v-if="matchPredictions.length" class="pronos-count">{{ matchPredictions.length }} · serrées en tête</span>
        </div>
        <div v-if="matchPredictions.length" class="pred-split">
          <div v-for="g in groups" :key="g.div" class="pred-col">
            <div class="pred-col-head">
              <span class="pred-div" :class="'pred-div--' + g.div.toLowerCase()">{{ g.div }}</span>
              <span class="pred-col-title">{{ g.label }}</span>
              <span class="pred-col-count">{{ g.items.length }}</span>
            </div>
            <div class="pred-list">
              <div v-for="p in g.items" :key="p.key" class="pred-row">
                <div class="pred-rowtop">
                  <span v-if="p.unknown" class="pred-tag tag-unknown">Incertain</span>
                  <span v-else class="pred-tag" :class="'tag-' + p.gapTone">{{ p.gapTier }}</span>
                </div>
                <div class="pred-vs">
                  <span class="pred-pname" :class="{ fav: !p.close && p.favorite === p.p1 }">{{ p.p1 }}</span>
                  <span class="pred-pct" :class="{ fav: !p.close && p.favorite === p.p1 }">{{ p.prob1 }}%</span>
                  <span class="pred-pct pred-pct--r" :class="{ fav: !p.close && p.favorite === p.p2 }">{{ 100 - p.prob1 }}%</span>
                  <span class="pred-pname pred-pname--r" :class="{ fav: !p.close && p.favorite === p.p2 }">{{ p.p2 }}</span>
                </div>
                <div class="pred-bar"><div class="pred-bar-fill" :style="{ width: p.prob1 + '%' }" /></div>
              </div>
            </div>
          </div>
        </div>
        <p v-else class="pronos-empty">Aucune affiche programmée pour l'instant. Les pronostics s'afficheront dès que la grille sera composée.</p>
      </div>
    </div>
  </section>
</template>

<script setup>
// Panneau « Pronostics » partagé : accueil membre et page Journées.
import { computed } from 'vue'
const props = defineProps({
  titleRace: { type: Array, default: () => [] },
  titleConfidence: { type: Object, default: null },
  formPlayer: { type: Object, default: null },
  matchPredictions: { type: Array, default: () => [] },
  flashes: { type: Array, default: () => [] },
  subtitle: { type: String, default: 'Estimations · prochaine journée' },
})
const groups = computed(() =>
  [['D1', 'Division 1'], ['D2', 'Division 2']]
    .map(([div, label]) => ({ div, label, items: props.matchPredictions.filter((p) => p.div === div) }))
    .filter((g) => g.items.length))
</script>

<style scoped>
/* ====== Pronostics ====== */
/* Contention : empêcher tout débordement horizontal (min-width:0 sur la chaîne flex/grid) */
.pronos-card, .guests-card { margin-bottom: 16px; overflow: hidden; min-width: 0; max-width: 100%; }
.pronos-grid, .pronos-block, .guests-inline, .title-race, .pred-list,
.guest-hero, .guest-hero-id, .guest-hero-stats, .pred-row, .pred-player, .tr-row, .guest-row { min-width: 0; max-width: 100%; }
.pronos-head { display: flex; align-items: baseline; justify-content: space-between; gap: .5rem; margin-bottom: 1rem; }
.pronos-sub { font-size: .72rem; color: var(--muted); text-transform: uppercase; letter-spacing: .05em; font-weight: 600; }
.pronos-grid { display: grid; grid-template-columns: minmax(0, 1fr); gap: 1.1rem; }
@media (min-width: 640px) { .pronos-grid:not(.pronos-grid--solo) { grid-template-columns: minmax(0, 0.8fr) minmax(0, 1.2fr); } }

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

/* Temps forts de la journée */
.pronos-flashes { margin-top: .7rem; display: flex; flex-direction: column; gap: .35rem; }
.pronos-flash { display: flex; align-items: baseline; gap: .6rem; padding: .5rem .7rem; border-radius: 10px; border: 1px solid color-mix(in srgb, var(--border) 55%, transparent); background: color-mix(in srgb, var(--panel) 55%, transparent); font-size: .82rem; line-height: 1.35; }
.pronos-flash-tag { flex: none; font-size: .62rem; font-weight: 800; text-transform: uppercase; letter-spacing: .06em; color: #22c55e; }
.pronos-flash-text { min-width: 0; color: var(--text); opacity: .85; }

/* Affiches : grille de cartes compactes, sans défilement interne */
.pred-split { display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 250px), 1fr)); gap: .8rem; }
.pred-col { min-width: 0; }
.pred-col-head { display: flex; align-items: center; gap: .45rem; margin-bottom: .45rem; }
.pred-col-title { font-size: .74rem; font-weight: 800; letter-spacing: .04em; }
.pred-col-count { margin-left: auto; font-size: .66rem; font-weight: 700; color: var(--muted); }
.pred-div--d1 { color: #22c55e; border-color: color-mix(in srgb, #22c55e 40%, var(--border)); }
.pred-div--d2 { color: #5f8dff; border-color: color-mix(in srgb, #5f8dff 40%, var(--border)); }
.pred-list { display: flex; flex-direction: column; gap: .5rem; max-height: 360px; overflow-y: auto; padding-right: .35rem; scrollbar-width: thin; }
.pred-row { padding: .5rem .65rem .6rem; border-radius: 10px; border: 1px solid color-mix(in srgb, var(--border) 55%, transparent); background: color-mix(in srgb, var(--panel) 50%, transparent); }
.pred-rowtop { display: flex; align-items: center; gap: .4rem; margin-bottom: .3rem; }
.pred-div { font-size: .56rem; font-weight: 800; letter-spacing: .06em; color: var(--muted); border: 1px solid var(--border); border-radius: 999px; padding: .04rem .42rem; }
.pred-tag { margin-left: auto; font-size: .56rem; font-weight: 800; text-transform: uppercase; letter-spacing: .05em; padding: .06rem .42rem; border-radius: 999px; }
.tag-close { color: #f59e0b; background: color-mix(in srgb, #f59e0b 15%, transparent); }
.tag-mid { color: var(--accent-l, var(--accent)); background: color-mix(in srgb, var(--accent) 14%, transparent); }
.tag-strong { color: #22c55e; background: color-mix(in srgb, #22c55e 15%, transparent); }
.tag-unknown { color: var(--muted); background: color-mix(in srgb, var(--muted) 15%, transparent); }
.pred-vs { display: grid; grid-template-columns: minmax(0, 1fr) auto auto minmax(0, 1fr); align-items: baseline; gap: .35rem; }
.pred-pname { font-size: .85rem; font-weight: 600; color: var(--text); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; min-width: 0; }
.pred-pname--r { text-align: right; }
.pred-pct { font-size: .8rem; font-weight: 800; font-variant-numeric: tabular-nums; color: var(--muted); }
.pred-pname.fav, .pred-pct.fav { color: var(--accent-l, var(--accent)); font-weight: 800; }
.pred-bar { height: 5px; border-radius: 999px; overflow: hidden; background: color-mix(in srgb, #f59e0b 55%, transparent); margin-top: .4rem; }
.pred-bar-fill { height: 100%; background: linear-gradient(90deg, var(--accent), var(--accent-l, var(--accent))); transition: width .4s ease; }

.pronos-empty { font-size: .82rem; color: var(--muted); line-height: 1.5; padding: .4rem 0; }


@media (max-width: 640px) {
  .pronos-grid { gap: .9rem; }
  .pronos-head { flex-wrap: wrap; gap: .15rem; }
  .pronos-block-head { flex-wrap: wrap; gap: .25rem; }
  .tr-row { grid-template-columns: 1.3rem minmax(0, 1fr) auto auto; gap: .45rem; padding: .4rem .5rem; }
  .tr-name { font-size: .82rem; }
  .tr-moy { font-size: .85rem; }
  .tr-gap { min-width: 2.8rem; font-size: .66rem; }
  .pred-row { padding: .6rem .65rem; }
  .pred-pname { font-size: .86rem; }
}
</style>
