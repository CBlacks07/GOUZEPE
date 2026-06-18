import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

/**
 * Contexte de jeu courant (eFootball / Tekken).
 * Pilote l'accent visuel via l'attribut data-game sur <html>.
 */
export const useGameStore = defineStore('game', () => {
  const current = ref(localStorage.getItem('gz.game') || 'efoot')

  const isTekken = computed(() => current.value === 'tekken')
  const isEfoot  = computed(() => current.value !== 'tekken')
  const label    = computed(() => (current.value === 'tekken' ? 'Tekken' : 'eFootball'))

  function apply(g = current.value) {
    const el = document.documentElement
    if (g === 'tekken') el.setAttribute('data-game', 'tekken')
    else el.removeAttribute('data-game')
  }

  function set(g) {
    current.value = g === 'tekken' ? 'tekken' : 'efoot'
    try { localStorage.setItem('gz.game', current.value) } catch (_) {}
    apply()
  }

  function toggle() {
    set(current.value === 'tekken' ? 'efoot' : 'tekken')
  }

  return { current, isTekken, isEfoot, label, apply, set, toggle }
})
