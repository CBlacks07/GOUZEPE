import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useThemeStore = defineStore('theme', () => {
  const mode = ref(localStorage.getItem('efoot.theme') || 'dark')

  function apply(m = mode.value) {
    document.documentElement.classList.toggle('light', m === 'light')
  }

  function toggle() {
    mode.value = mode.value === 'dark' ? 'light' : 'dark'
    localStorage.setItem('efoot.theme', mode.value)
    apply()
  }

  function set(m) {
    mode.value = m
    localStorage.setItem('efoot.theme', m)
    apply()
  }

  return { mode, apply, toggle, set }
})
