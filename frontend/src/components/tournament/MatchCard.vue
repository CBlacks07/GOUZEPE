<template>
  <div
    :class="[
      'match-card rounded-lg transition-all duration-200 overflow-hidden',
      isRrCompact && 'match-card--rr',
      isBracketCompact && 'match-card--bracket',
      isBracketCompact
        ? 'match-card--bracket-base'
        : (isCompleted ? 'border border-gz-border/60 bg-gz-panel' : 'border border-gz-border bg-gz-card'),
      isEditing && 'ring-2 ring-gz-green/40'
    ]"
  >
    <div v-if="groupLabel" class="match-meta">
      <span class="group-chip">{{ groupLabel }}</span>
    </div>

    <div :class="['match-row flex items-center justify-between px-2 py-1.5 gap-1.5', isCompleted && winner === 1 && 'bg-gz-green/8']">
      <span
        :title="match.p1_name || match.p1_id || 'TBD'"
        :class="[
          'player-name text-[0.84rem] font-medium truncate flex-1 leading-tight',
          isCompleted && winner === 1 ? 'text-gz-green font-bold' : 'text-gz-text',
          !match.p1_name && 'text-gz-muted italic'
        ]"
      >
        {{ match.p1_name || match.p1_id || 'TBD' }}
      </span>

      <template v-if="isEditing">
        <input
          v-model.number="localS1"
          type="number"
          min="0"
          step="1"
          inputmode="numeric"
          :class="['score-input text-center input py-0.5 text-[12px] font-semibold tabular-nums', isRrCompact ? 'w-9' : 'w-11']"
          @keydown.enter="submitScore"
          title="Score joueur 1"
        />
      </template>

      <span
        v-else-if="isCompleted"
        :class="['score-value text-[0.86rem] font-bold tabular-nums text-center', winner === 1 ? 'text-gz-green' : 'text-gz-muted']"
      >
        {{ match.score1 ?? '' }}
      </span>
    </div>

    <div class="h-px bg-gz-border/50 mx-2" />

    <div :class="['match-row flex items-center justify-between px-2 py-1.5 gap-1.5', isCompleted && winner === 2 && 'bg-gz-green/8']">
      <span
        :title="match.p2_name || match.p2_id || 'TBD'"
        :class="[
          'player-name text-[0.84rem] font-medium truncate flex-1 leading-tight',
          isCompleted && winner === 2 ? 'text-gz-green font-bold' : 'text-gz-text',
          !match.p2_name && 'text-gz-muted italic'
        ]"
      >
        {{ match.p2_name || match.p2_id || 'TBD' }}
      </span>

      <template v-if="isEditing">
        <input
          v-model.number="localS2"
          type="number"
          min="0"
          step="1"
          inputmode="numeric"
          :class="['score-input text-center input py-0.5 text-[12px] font-semibold tabular-nums', isRrCompact ? 'w-9' : 'w-11']"
          @keydown.enter="submitScore"
          title="Score joueur 2"
        />
      </template>

      <span
        v-else-if="isCompleted"
        :class="['score-value text-[0.86rem] font-bold tabular-nums text-center', winner === 2 ? 'text-gz-green' : 'text-gz-muted']"
      >
        {{ match.score2 ?? '' }}
      </span>
    </div>

    <div :class="['match-actions border-t border-gz-border/40 px-1.5 py-0.5 flex justify-end gap-1', isRrCompact && 'match-actions--rr']" v-if="adminMode && isEditable">
      <template v-if="isEditing">
        <button
          type="button"
          @click="submitScore"
          :disabled="saving"
          class="btn-primary py-0.5 px-1.5 text-[11px]"
          title="Valider le score"
        >
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
import { PencilIcon, Loader2Icon } from 'lucide-vue-next'

const props = defineProps({
  match: { type: Object, required: true },
  adminMode: { type: Boolean, default: false },
  density: { type: String, default: 'default' },
})

const emit = defineEmits(['score-saved'])

const isEditing = ref(false)
const localS1 = ref(0)
const localS2 = ref(0)
const saving = ref(false)

const isCompleted = computed(() => props.match.status === 'done' || props.match.status === 'completed')
const isEditable = computed(() => props.match.p1_id && props.match.p2_id)
const isRrCompact = computed(() => props.density === 'rr')
const isBracketCompact = computed(() => props.density === 'bracket')

const winner = computed(() => {
  if (!isCompleted.value) return null
  const s1 = +(props.match.score1 ?? 0)
  const s2 = +(props.match.score2 ?? 0)
  return s1 > s2 ? 1 : s2 > s1 ? 2 : null
})

const groupLabel = computed(() => {
  const g = props.match.group_no
  if (g === null || g === undefined || g === '') return ''
  const n = Number(g)
  if (!Number.isFinite(n) || n < 0) return ''
  return `Groupe ${String.fromCharCode(65 + n)}`
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
.match-card {
  backdrop-filter: blur(2px);
}

.match-card:hover {
  border-color: color-mix(in srgb, var(--border) 60%, var(--blue) 40%);
  box-shadow: 0 8px 18px rgba(2, 6, 23, 0.18);
}

.match-meta {
  padding: 0.22rem 0.45rem 0;
}

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

.score-value {
  width: 1.25rem;
}

.score-input {
  color: var(--text) !important;
  appearance: textfield;
  -moz-appearance: textfield;
}

.score-input::-webkit-outer-spin-button,
.score-input::-webkit-inner-spin-button {
  -webkit-appearance: none;
  margin: 0;
}

.match-card--rr .group-chip {
  font-size: 0.54rem;
  padding: 0.05rem 0.28rem;
}

.match-card--rr .match-row {
  padding: 0.28rem 0.45rem;
  gap: 0.3rem;
}

.match-card--rr .player-name {
  font-size: 0.78rem;
  line-height: 1.15;
}

.match-card--rr .score-value {
  width: 1.05rem;
  font-size: 0.79rem;
}

.match-card--rr .score-input {
  min-height: 1.2rem;
  padding-left: 0.1rem;
  padding-right: 0.1rem;
}

.match-card--rr .match-actions--rr {
  padding: 0.2rem 0.35rem;
}

.match-card--bracket .match-row {
  padding: 0.24rem 0.34rem;
  gap: 0.24rem;
}

.match-card--bracket .player-name {
  font-size: 0.78rem;
  line-height: 1.12;
}

.match-card--bracket .score-value {
  width: 0.95rem;
  font-size: 0.77rem;
}

.match-card--bracket .match-actions {
  padding: 0.12rem 0.26rem;
}

.match-card--bracket-base {
  background: color-mix(in srgb, var(--panel) 78%, transparent);
  border: 1px solid color-mix(in srgb, var(--border) 58%, transparent);
  box-shadow: none;
  width: 168px;
  max-width: 168px;
}

.match-card--bracket-base:hover {
  border-color: color-mix(in srgb, var(--blue) 48%, var(--border));
  box-shadow: none;
}

.match-card--bracket .score-input {
  min-height: 1.15rem;
  width: 2rem;
  padding-left: 0.08rem;
  padding-right: 0.08rem;
  font-size: 0.72rem;
}

.match-card--bracket .match-actions :deep(.btn),
.match-card--bracket .match-actions :deep(.btn-primary) {
  font-size: 0.63rem;
  padding: 0.07rem 0.24rem;
}
</style>
