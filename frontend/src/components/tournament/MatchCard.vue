<template>
  <!-- ============ CARTE BRACKET PREMIUM ============ -->
  <div
    v-if="isBracketCompact"
    :class="[
      'mcb',
      isCompleted && 'mcb--done',
      isFinal && 'mcb--final',
      isEditing && 'mcb--editing',
      isLive && 'mcb--live',
    ]"
  >
    <span class="mcb-side" :data-state="sideState" />

    <div class="mcb-inner">
      <div v-if="groupLabel || matchTag" class="mcb-meta">
        <span v-if="groupLabel" class="mcb-group">{{ groupLabel }}</span>
        <span v-if="matchTag" class="mcb-tag">{{ matchTag }}</span>
      </div>

      <!-- Joueur 1 -->
      <div
        :class="[
          'mcb-row',
          isCompleted && (winner === 1 ? 'is-win' : 'is-loss'),
        ]"
      >
        <span v-if="seed1 != null" class="mcb-seed">{{ seed1 }}</span>
        <span
          :title="name1"
          :class="['mcb-name', !hasP1 && 'is-tbd']"
        >{{ name1 }}</span>
        <CrownIcon v-if="isFinal && isCompleted && winner === 1" class="mcb-crown" />

        <input
          v-if="isEditing"
          v-model.number="localS1"
          type="number" min="0" step="1" inputmode="numeric"
          class="mcb-input"
          @keydown.enter="submitScore"
          title="Score joueur 1"
        />
        <span
          v-else-if="isCompleted"
          :class="['mcb-score', winner === 1 ? 'is-win' : 'is-loss']"
        >{{ match.score1 ?? 0 }}</span>
        <span v-else class="mcb-score is-empty">–</span>
      </div>

      <!-- Joueur 2 -->
      <div
        :class="[
          'mcb-row',
          isCompleted && (winner === 2 ? 'is-win' : 'is-loss'),
        ]"
      >
        <span v-if="seed2 != null" class="mcb-seed">{{ seed2 }}</span>
        <span
          :title="name2"
          :class="['mcb-name', !hasP2 && 'is-tbd']"
        >{{ name2 }}</span>
        <CrownIcon v-if="isFinal && isCompleted && winner === 2" class="mcb-crown" />

        <input
          v-if="isEditing"
          v-model.number="localS2"
          type="number" min="0" step="1" inputmode="numeric"
          class="mcb-input"
          @keydown.enter="submitScore"
          title="Score joueur 2"
        />
        <span
          v-else-if="isCompleted"
          :class="['mcb-score', winner === 2 ? 'is-win' : 'is-loss']"
        >{{ match.score2 ?? 0 }}</span>
        <span v-else class="mcb-score is-empty">–</span>
      </div>
    </div>

    <div v-if="adminMode && isEditable" class="mcb-actions">
      <template v-if="isEditing">
        <button type="button" @click="submitScore" :disabled="saving" class="mcb-btn mcb-btn--ok" title="Valider le score">
          <Loader2Icon v-if="saving" class="w-3 h-3 animate-spin" />
          <CheckIcon v-else class="w-3 h-3" />
          Valider
        </button>
        <button type="button" @click="isEditing = false" class="mcb-btn" title="Annuler la saisie">Annuler</button>
      </template>
      <button v-else type="button" @click="startEdit" class="mcb-btn mcb-btn--edit" :title="isCompleted ? 'Modifier le score' : 'Saisir le score'">
        <PencilIcon class="w-3 h-3" />
        {{ isCompleted ? 'Modifier' : 'Saisir' }}
      </button>
    </div>
  </div>

  <!-- ============ CARTE GENERIQUE (rr / default) ============ -->
  <div
    v-else
    :class="[
      'match-card rounded-lg transition-all duration-200 overflow-hidden',
      isRrCompact && 'match-card--rr',
      isCompleted ? 'border border-gz-border/60 bg-gz-panel' : 'border border-gz-border bg-gz-card',
      isEditing && 'ring-2 ring-gz-green/40'
    ]"
  >
    <div v-if="groupLabel" class="match-meta">
      <span class="group-chip">{{ groupLabel }}</span>
    </div>

    <div :class="['match-row flex items-center justify-between px-2 py-1.5 gap-1.5', isCompleted && winner === 1 && 'bg-gz-green/8']">
      <span :title="name1" :class="['player-name text-[0.84rem] font-medium truncate flex-1 leading-tight', isCompleted && winner === 1 ? 'text-gz-green font-bold' : 'text-gz-text', !hasP1 && 'text-gz-muted italic']">
        {{ name1 }}
      </span>
      <input v-if="isEditing" v-model.number="localS1" type="number" min="0" step="1" inputmode="numeric" :class="['score-input text-center input py-0.5 text-[12px] font-semibold tabular-nums', isRrCompact ? 'w-9' : 'w-11']" @keydown.enter="submitScore" title="Score joueur 1" />
      <span v-else-if="isCompleted" :class="['score-value text-[0.86rem] font-bold tabular-nums text-center', winner === 1 ? 'text-gz-green' : 'text-gz-muted']">{{ match.score1 ?? '' }}</span>
    </div>

    <div class="h-px bg-gz-border/50 mx-2" />

    <div :class="['match-row flex items-center justify-between px-2 py-1.5 gap-1.5', isCompleted && winner === 2 && 'bg-gz-green/8']">
      <span :title="name2" :class="['player-name text-[0.84rem] font-medium truncate flex-1 leading-tight', isCompleted && winner === 2 ? 'text-gz-green font-bold' : 'text-gz-text', !hasP2 && 'text-gz-muted italic']">
        {{ name2 }}
      </span>
      <input v-if="isEditing" v-model.number="localS2" type="number" min="0" step="1" inputmode="numeric" :class="['score-input text-center input py-0.5 text-[12px] font-semibold tabular-nums', isRrCompact ? 'w-9' : 'w-11']" @keydown.enter="submitScore" title="Score joueur 2" />
      <span v-else-if="isCompleted" :class="['score-value text-[0.86rem] font-bold tabular-nums text-center', winner === 2 ? 'text-gz-green' : 'text-gz-muted']">{{ match.score2 ?? '' }}</span>
    </div>

    <div :class="['match-actions border-t border-gz-border/40 px-1.5 py-0.5 flex justify-end gap-1', isRrCompact && 'match-actions--rr']" v-if="adminMode && isEditable">
      <template v-if="isEditing">
        <button type="button" @click="submitScore" :disabled="saving" class="btn-primary py-0.5 px-1.5 text-[11px]" title="Valider le score">
          <Loader2Icon v-if="saving" class="w-3 h-3 animate-spin" />
          Valider
        </button>
        <button type="button" @click="isEditing = false" class="btn py-0.5 px-1.5 text-[11px]" title="Annuler la saisie">Annuler</button>
      </template>
      <button type="button" v-else @click="startEdit" class="btn py-0.5 px-1.5 text-[11px]" title="Saisir ou modifier le score">
        <PencilIcon class="w-3 h-3" />
        Saisir
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { PencilIcon, Loader2Icon, CheckIcon, CrownIcon } from 'lucide-vue-next'

const props = defineProps({
  match: { type: Object, required: true },
  adminMode: { type: Boolean, default: false },
  density: { type: String, default: 'default' },
  isFinal: { type: Boolean, default: false },
})

const emit = defineEmits(['score-saved'])

const isEditing = ref(false)
const localS1 = ref(0)
const localS2 = ref(0)
const saving = ref(false)

const isCompleted = computed(() => props.match.status === 'done' || props.match.status === 'completed')
const isLive = computed(() => props.match.status === 'live')
const isEditable = computed(() => props.match.p1_id && props.match.p2_id)
const isRrCompact = computed(() => props.density === 'rr')
const isBracketCompact = computed(() => props.density === 'bracket')

const hasP1 = computed(() => !!(props.match.p1_name || props.match.p1_id))
const hasP2 = computed(() => !!(props.match.p2_name || props.match.p2_id))
const name1 = computed(() => props.match.p1_name || props.match.p1_id || 'À venir')
const name2 = computed(() => props.match.p2_name || props.match.p2_id || 'À venir')

const seed1 = computed(() => normalizeSeed(props.match.p1_seed ?? props.match.seed1 ?? props.match.p1_seed_no))
const seed2 = computed(() => normalizeSeed(props.match.p2_seed ?? props.match.seed2 ?? props.match.p2_seed_no))

function normalizeSeed(v) {
  if (v === null || v === undefined || v === '') return null
  const n = Number(v)
  return Number.isFinite(n) && n > 0 ? n : null
}

const winner = computed(() => {
  if (!isCompleted.value) return null
  const s1 = +(props.match.score1 ?? 0)
  const s2 = +(props.match.score2 ?? 0)
  return s1 > s2 ? 1 : s2 > s1 ? 2 : null
})

const sideState = computed(() => {
  if (isFinalDone.value) return 'final'
  if (isCompleted.value) return 'done'
  if (isLive.value) return 'live'
  if (isEditable.value) return 'ready'
  return 'pending'
})
const isFinalDone = computed(() => props.isFinal && isCompleted.value)

const groupLabel = computed(() => {
  const g = props.match.group_no
  if (g === null || g === undefined || g === '') return ''
  const n = Number(g)
  if (!Number.isFinite(n) || n < 0) return ''
  return `Groupe ${String.fromCharCode(65 + n)}`
})

const matchTag = computed(() => {
  if (props.isFinal) return 'Finale'
  return ''
})

function startEdit() {
  localS1.value = props.match.score1 ?? 0
  localS2.value = props.match.score2 ?? 0
  isEditing.value = true
}

function submitScore() {
  saving.value = true
  emit('score-saved', {
    matchId: props.match.id,
    score1: localS1.value,
    score2: localS2.value,
    done: () => {
      isEditing.value = false
      saving.value = false
    },
    fail: () => {
      saving.value = false
    },
  })
}
</script>

<style scoped>
/* ===================== CARTE BRACKET PREMIUM ===================== */
.mcb {
  position: relative;
  display: flex;
  flex-direction: column;
  width: 200px;
  max-width: 200px;
  border-radius: 10px;
  background:
    linear-gradient(180deg,
      color-mix(in srgb, var(--card) 96%, transparent),
      color-mix(in srgb, var(--panel) 92%, transparent));
  border: 1px solid color-mix(in srgb, var(--border) 70%, transparent);
  box-shadow: 0 1px 2px rgba(2, 6, 23, 0.18);
  overflow: hidden;
  transition: transform .16s ease, box-shadow .16s ease, border-color .16s ease;
  animation: mcb-in .32s ease both;
}

.mcb:hover {
  transform: translateY(-1px);
  border-color: color-mix(in srgb, var(--accent) 45%, var(--border));
  box-shadow: 0 8px 20px rgba(2, 6, 23, 0.28);
  z-index: 5;
}

.mcb--done {
  border-color: color-mix(in srgb, var(--accent) 24%, var(--border));
}

.mcb--final {
  border-color: color-mix(in srgb, #fbbf24 55%, var(--border));
  box-shadow:
    0 0 0 1px color-mix(in srgb, #fbbf24 28%, transparent),
    0 6px 22px color-mix(in srgb, #fbbf24 18%, transparent);
}

.mcb--editing {
  border-color: color-mix(in srgb, var(--accent) 70%, transparent);
  box-shadow: 0 0 0 2px color-mix(in srgb, var(--accent) 30%, transparent);
}

/* Barre latérale d'état */
.mcb-side {
  position: absolute;
  left: 0; top: 0; bottom: 0;
  width: 3px;
  border-radius: 10px 0 0 10px;
}
.mcb-side[data-state="pending"] { background: color-mix(in srgb, var(--border) 90%, transparent); }
.mcb-side[data-state="ready"]   { background: color-mix(in srgb, var(--accent) 55%, var(--border)); }
.mcb-side[data-state="live"]    { background: #22c55e; animation: mcb-pulse 1.4s infinite; }
.mcb-side[data-state="done"]    { background: var(--accent); }
.mcb-side[data-state="final"]   { background: linear-gradient(180deg, #fde68a, #f59e0b); }

.mcb-inner {
  display: flex;
  flex-direction: column;
  padding-left: 3px;
}

.mcb-meta {
  display: flex;
  align-items: center;
  gap: .3rem;
  padding: .2rem .5rem 0;
}
.mcb-group, .mcb-tag {
  font-size: .54rem;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: .06em;
  padding: .06rem .34rem;
  border-radius: 999px;
  line-height: 1.4;
}
.mcb-group {
  color: var(--muted);
  border: 1px solid color-mix(in srgb, var(--border) 75%, transparent);
  background: color-mix(in srgb, var(--panel) 80%, transparent);
}
.mcb-tag {
  color: #b8860b;
  background: color-mix(in srgb, #fbbf24 16%, transparent);
  border: 1px solid color-mix(in srgb, #fbbf24 40%, transparent);
}

/* Ligne joueur */
.mcb-row {
  position: relative;
  display: flex;
  align-items: center;
  gap: .4rem;
  padding: .4rem .5rem .4rem .55rem;
  min-height: 30px;
}
.mcb-row + .mcb-row {
  border-top: 1px solid color-mix(in srgb, var(--border) 45%, transparent);
}
.mcb-row.is-win {
  background: color-mix(in srgb, var(--accent) 9%, transparent);
}
.mcb-row.is-loss .mcb-name { color: var(--muted); }
.mcb-row.is-loss .mcb-seed { opacity: .5; }

.mcb-seed {
  flex: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 1.05rem;
  height: 1.05rem;
  padding: 0 .2rem;
  font-size: .58rem;
  font-weight: 800;
  font-variant-numeric: tabular-nums;
  color: var(--muted);
  background: color-mix(in srgb, var(--panel) 70%, transparent);
  border: 1px solid color-mix(in srgb, var(--border) 70%, transparent);
  border-radius: 5px;
}

.mcb-name {
  flex: 1;
  min-width: 0;
  font-size: .8rem;
  font-weight: 600;
  line-height: 1.15;
  color: var(--text);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.mcb-row.is-win .mcb-name {
  font-weight: 800;
  color: var(--text);
}
.mcb-name.is-tbd {
  color: var(--muted);
  font-style: italic;
  font-weight: 500;
}

.mcb-crown {
  flex: none;
  width: .82rem;
  height: .82rem;
  color: #f59e0b;
}

/* Score */
.mcb-score {
  flex: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 1.4rem;
  height: 1.35rem;
  padding: 0 .3rem;
  font-size: .82rem;
  font-weight: 800;
  font-variant-numeric: tabular-nums;
  border-radius: 6px;
}
.mcb-score.is-win {
  color: #fff;
  background: var(--accent);
  box-shadow: 0 1px 3px color-mix(in srgb, var(--accent) 40%, transparent);
}
.mcb--final .mcb-score.is-win {
  background: linear-gradient(135deg, #f59e0b, #d97706);
  box-shadow: 0 1px 4px color-mix(in srgb, #f59e0b 45%, transparent);
}
.mcb-score.is-loss {
  color: var(--muted);
  background: color-mix(in srgb, var(--panel) 78%, transparent);
}
.mcb-score.is-empty {
  color: var(--muted);
  opacity: .4;
  background: transparent;
  font-weight: 600;
}

.mcb-input {
  flex: none;
  width: 2.1rem;
  height: 1.4rem;
  text-align: center;
  font-size: .78rem;
  font-weight: 800;
  font-variant-numeric: tabular-nums;
  color: var(--text);
  border: 1px solid color-mix(in srgb, var(--accent) 55%, transparent);
  border-radius: 6px;
  background: color-mix(in srgb, var(--accent) 10%, var(--card));
  appearance: textfield;
  -moz-appearance: textfield;
}
.mcb-input::-webkit-outer-spin-button,
.mcb-input::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }

.mcb-actions {
  display: flex;
  justify-content: flex-end;
  gap: .3rem;
  padding: .25rem .4rem;
  border-top: 1px solid color-mix(in srgb, var(--border) 45%, transparent);
  background: color-mix(in srgb, var(--panel) 55%, transparent);
}
.mcb-btn {
  display: inline-flex;
  align-items: center;
  gap: .2rem;
  font-size: .64rem;
  font-weight: 700;
  padding: .16rem .42rem;
  border-radius: 5px;
  border: 1px solid color-mix(in srgb, var(--border) 70%, transparent);
  background: color-mix(in srgb, var(--card) 90%, transparent);
  color: var(--muted);
  cursor: pointer;
  transition: color .15s, border-color .15s, background .15s;
}
.mcb-btn:hover { color: var(--text); border-color: color-mix(in srgb, var(--accent) 45%, var(--border)); }
.mcb-btn--edit:hover { color: var(--accent-l, var(--accent)); }
.mcb-btn--ok {
  color: #fff;
  background: var(--accent);
  border-color: var(--accent);
}
.mcb-btn--ok:hover { color: #fff; filter: brightness(1.05); }
.mcb-btn:disabled { opacity: .6; cursor: not-allowed; }

@keyframes mcb-in {
  from { opacity: 0; transform: translateY(6px) scale(.985); }
  to   { opacity: 1; transform: translateY(0) scale(1); }
}
@keyframes mcb-pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: .35; }
}
@media (prefers-reduced-motion: reduce) {
  .mcb { animation: none; }
  .mcb-side[data-state="live"] { animation: none; }
}

/* ===================== CARTE GENERIQUE (rr / default) ===================== */
.match-card { backdrop-filter: blur(2px); }
.match-card:hover {
  border-color: color-mix(in srgb, var(--border) 60%, var(--blue) 40%);
  box-shadow: 0 8px 18px rgba(2, 6, 23, 0.18);
}
.match-meta { padding: 0.22rem 0.45rem 0; }
.group-chip {
  display: inline-block;
  font-size: 0.58rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--muted);
  border: 1px solid color-mix(in srgb, var(--border) 75%, transparent);
  border-radius: 999px;
  padding: 0.08rem 0.36rem;
  background: color-mix(in srgb, var(--panel) 80%, transparent);
}
.score-value { width: 1.25rem; }
.score-input {
  color: var(--text) !important;
  appearance: textfield;
  -moz-appearance: textfield;
}
.score-input::-webkit-outer-spin-button,
.score-input::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }
.match-card--rr .group-chip { font-size: 0.54rem; padding: 0.05rem 0.28rem; }
.match-card--rr .match-row { padding: 0.28rem 0.45rem; gap: 0.3rem; }
.match-card--rr .player-name { font-size: 0.78rem; line-height: 1.15; }
.match-card--rr .score-value { width: 1.05rem; font-size: 0.79rem; }
.match-card--rr .score-input { min-height: 1.2rem; padding-left: 0.1rem; padding-right: 0.1rem; }
.match-card--rr .match-actions--rr { padding: 0.2rem 0.35rem; }
</style>
