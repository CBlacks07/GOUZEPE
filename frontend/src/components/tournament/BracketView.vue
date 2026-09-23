<template>
  <!-- Tableau d'un tournoi en lecture seule, quel que soit le format. -->
  <div v-if="!prepared.length" class="bv-empty">Le tableau n'est pas encore généré.</div>
  <BracketSE v-else-if="format === 'single_elimination'" :matches="prepared" :admin-mode="false" :persist-key="`${persistKey}-se`" />
  <BracketDE v-else-if="format === 'double_elimination'" :matches="prepared" :admin-mode="false" :persist-key="`${persistKey}-de`" />
  <BracketRR v-else-if="format === 'round_robin'" :matches="prepared" :standings="[]" :standings-mode="standingsMode" :admin-mode="false" />
  <div v-else-if="format === 'groups_knockout'" class="space-y-4">
    <div v-for="g in groups" :key="g.group_no">
      <h4 class="bv-sub">Groupe {{ String.fromCharCode(65 + g.group_no) }}</h4>
      <BracketRR :matches="g.matches" :standings="[]" :standings-mode="standingsMode" :admin-mode="false" />
    </div>
    <div>
      <h4 class="bv-sub">Phase finale</h4>
      <BracketSE v-if="knockout.length" :matches="knockout" :admin-mode="false" :persist-key="`${persistKey}-ko`" />
      <p v-else class="bv-empty">La phase finale commencera à la fin des groupes.</p>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import BracketSE from './BracketSE.vue'
import BracketDE from './BracketDE.vue'
import BracketRR from './BracketRR.vue'
import { normalizeBracketMatches, groupBuckets, isGroupMatch } from '@/utils/bracketMatches'

const props = defineProps({
  matches: { type: Array, default: () => [] }, // matchs bruts de l'API
  format: { type: String, required: true },
  standingsMode: { type: String, default: 'wins' },
  persistKey: { type: String, default: 'bv' },
})

const prepared = computed(() => normalizeBracketMatches(props.matches, props.format))
const groups = computed(() => groupBuckets(prepared.value))
const knockout = computed(() => prepared.value.filter((m) => !isGroupMatch(m)))
</script>

<style scoped>
.bv-empty { color: var(--muted); padding: 1.5rem 0; text-align: center; font-size: .9rem; }
.bv-sub { font-size: .72rem; font-weight: 800; text-transform: uppercase; letter-spacing: .08em; color: var(--muted); margin-bottom: .5rem; }
</style>
