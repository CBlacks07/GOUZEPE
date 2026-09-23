// Photos des bandeaux d'accueil (eFootball et Tekken).
// Ordre de recherche : médias du jeu configurés dans « Apparence » (CMS), puis ceux
// d'eFootball (les photos du club, communes aux deux pôles), puis les fichiers
// déposés dans /assets (Photo1.jpg…, image1.jpg…).
import { mediaUrl } from '@/composables/useAPI'

const HERO_ANIMS = ['slide-float', 'slide-zoom', 'slide-spin', 'slide-drift']

// Découvre /assets/{prefix}1.jpg, {prefix}2.jpg… (ou 01, 02…) jusqu'au premier manquant.
export async function probeAssets(prefix, max = 99) {
  const v = Date.now()
  const results = await Promise.all(
    Array.from({ length: max }, (_, i) => {
      const n = i + 1
      const srcs = [
        `/assets/${prefix}${n}.jpg?v=${v}`,
        `/assets/${prefix}${String(n).padStart(2, '0')}.jpg?v=${v}`,
      ]
      return new Promise((resolve) => {
        let resolved = false
        let pending = srcs.length
        for (const src of srcs) {
          const img = new Image()
          img.onload = () => {
            if (!resolved) { resolved = true; resolve(src) }
          }
          img.onerror = () => {
            pending--
            if (pending === 0 && !resolved) resolve(null)
          }
          img.src = src
        }
      })
    })
  )
  const found = []
  for (const r of results) {
    if (r === null) break
    found.push(r)
  }
  return found
}

export function shuffle(arr) {
  const a = [...arr]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

const cms = (list) => (list || []).filter(Boolean)

// gameKey : 'efootHome' ou 'tekkenHome' (clés des réglages du site).
export async function loadHomeMedia(settings, gameKey, altPrefix = 'GOUZEPE') {
  const own = settings?.[gameKey] || {}
  const club = settings?.efootHome || {}

  const photoSrc = cms(own.slides).length ? cms(own.slides) : cms(club.slides)
  const photos = photoSrc.length ? shuffle(photoSrc.map(mediaUrl)) : shuffle(await probeAssets('Photo'))

  const heroSrc = cms(own.hero).length ? cms(own.hero) : cms(club.hero)
  const heroImgs = heroSrc.length ? heroSrc.map(mediaUrl) : await probeAssets('image')
  const slides = heroImgs.map((src, i) => ({ src, alt: `${altPrefix} ${i + 1}`, anim: HERO_ANIMS[i % HERO_ANIMS.length] }))

  return { photos, slides }
}
