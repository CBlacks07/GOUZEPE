import { onMounted, onBeforeUnmount } from 'vue'

// Optimise une vidéo hero en arrière-plan :
// - met en pause quand elle sort de l'écran (IntersectionObserver)
// - met en pause quand l'onglet est masqué (visibilitychange)
// - respecte prefers-reduced-motion (pas d'autoplay, le poster suffit)
export function useHeroVideo(videoRef) {
  let io = null
  const reduce = typeof window !== 'undefined'
    && typeof window.matchMedia === 'function'
    && window.matchMedia('(prefers-reduced-motion: reduce)').matches

  const safePlay = () => {
    const v = videoRef.value
    if (!v || reduce) return
    const p = v.play()
    if (p && typeof p.catch === 'function') p.catch(() => {})
  }
  const safePause = () => {
    const v = videoRef.value
    if (v && !v.paused) v.pause()
  }

  const onVisibility = () => {
    if (document.hidden) safePause()
    else safePlay()
  }

  onMounted(() => {
    const v = videoRef.value
    if (!v) return

    if (reduce) {
      v.removeAttribute('autoplay')
      v.pause()
      return
    }

    if (typeof IntersectionObserver !== 'undefined') {
      io = new IntersectionObserver((entries) => {
        for (const e of entries) {
          if (e.isIntersecting) safePlay()
          else safePause()
        }
      }, { threshold: 0.1 })
      io.observe(v)
    }
    document.addEventListener('visibilitychange', onVisibility)
  })

  onBeforeUnmount(() => {
    if (io) { io.disconnect(); io = null }
    document.removeEventListener('visibilitychange', onVisibility)
  })
}
