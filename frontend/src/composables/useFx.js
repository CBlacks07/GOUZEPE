// Petits effets d'interface réutilisables (accueil et pages publiques).
// Tous respectent « réduire les animations » et ne s'activent qu'avec une vraie souris.
import { ref, watch, onBeforeUnmount } from 'vue'

const hasFinePointer = () =>
  typeof window !== 'undefined' && window.matchMedia('(hover: hover) and (pointer: fine)').matches
const prefersReducedMotion = () =>
  typeof window !== 'undefined' && window.matchMedia('(prefers-reduced-motion: reduce)').matches

function track(el, tilt, max) {
  const move = (e) => {
    const r = el.getBoundingClientRect()
    const px = (e.clientX - r.left) / r.width
    const py = (e.clientY - r.top) / r.height
    el.style.setProperty('--mx', `${(px * 100).toFixed(1)}%`)
    el.style.setProperty('--my', `${(py * 100).toFixed(1)}%`)
    if (tilt) {
      el.style.setProperty('--rx', `${((0.5 - py) * max * 2).toFixed(2)}deg`)
      el.style.setProperty('--ry', `${((px - 0.5) * max * 2).toFixed(2)}deg`)
    }
  }
  const leave = () => {
    if (tilt) { el.style.setProperty('--rx', '0deg'); el.style.setProperty('--ry', '0deg') }
  }
  el.addEventListener('pointermove', move)
  el.addEventListener('pointerleave', leave)
  el._fx = { move, leave }
}
function untrack(el) {
  if (!el._fx) return
  el.removeEventListener('pointermove', el._fx.move)
  el.removeEventListener('pointerleave', el._fx.leave)
  el._fx = null
}

// v-tilt : carte qui s'incline en 3D vers la souris + halo lumineux qui la suit.  v-tilt="{ max: 6 }"
export const vTilt = {
  mounted(el, binding) {
    if (!hasFinePointer() || prefersReducedMotion()) return
    el.classList.add('fx-tilt', 'fx-spot')
    track(el, true, binding.value?.max ?? 6)
  },
  unmounted: untrack,
}

// v-spot : seulement le halo lumineux qui suit la souris (pour les cartes qui ont déjà leur propre survol).
export const vSpot = {
  mounted(el) {
    if (!hasFinePointer() || prefersReducedMotion()) return
    el.classList.add('fx-spot')
    track(el, false, 0)
  },
  unmounted: untrack,
}

// Compteur animé : useCountUp(ref(42)) -> ref qui monte de 0 à 42 ; les valeurs non numériques passent telles quelles.
export function useCountUp(source, duration = 1100) {
  const shown = ref(source.value)
  let raf = 0
  watch(source, (v) => {
    cancelAnimationFrame(raf)
    const target = Number(v)
    if (!Number.isFinite(target) || prefersReducedMotion()) { shown.value = v; return }
    const from = Number.isFinite(Number(shown.value)) ? Number(shown.value) : 0
    const t0 = performance.now()
    const tick = (t) => {
      const k = Math.min(1, (t - t0) / duration)
      shown.value = Math.round(from + (target - from) * (1 - Math.pow(1 - k, 3)))
      if (k < 1) raf = requestAnimationFrame(tick)
    }
    raf = requestAnimationFrame(tick)
  }, { immediate: true })
  onBeforeUnmount(() => cancelAnimationFrame(raf))
  return shown
}
