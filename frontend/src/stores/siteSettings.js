import { defineStore } from 'pinia'
import { ref } from 'vue'
import { resolveBaseURL } from '@/composables/useAPI'

export const DEFAULTS = {
  brand: { name: 'GOUZEPE', tagline: 'GAMING CLUB', logo: '/assets/icons/apple-touch-icon.png' },
  accent: { efoot: '#3b82f6', tekken: '#ff5a2c' },
  background: { logo: '/assets/fond1.png', opacity: 0.16 },
  home: {
    eyebrow: 'Communauté compétitive',
    title: 'GOUZEPE GAMING CLUB',
    lead: 'Le club qui réunit les meilleurs joueurs eFootball & Tekken. Journées, tournois, classements et duels — toute la compétition, au même endroit.',
    ctaPrimary: 'Rejoindre le club',
    ctaSecondary: 'Découvrir les jeux',
  },
  efoot: {
    cardTitle: 'Le championnat',
    cardText: 'Journées D1/D2, saisons, classement général, tournois et duels. La gestion complète du championnat du club.',
    heroVideo: '/fonds/bg.mp4',
  },
  tekken: {
    cardTitle: "L'arène versus",
    cardText: 'Ladder, duels classés et tournois à élimination. Le pôle combat du club arrive — prépare-toi.',
    heroVideo: '/fonds/bg-tekk.mp4',
  },
  // Accueil membre eFootball — listes d'URLs (vide = découverte auto des assets)
  efootHome: {
    slides: [], // bande photos défilante (haut de l'accueil)
    hero: [],   // image(s) du hero (visuel rotatif)
  },
  // Accueil membre Tekken — hero personnalisable + médias
  tekkenHome: {
    eyebrow: 'Pôle Combat',
    title: "Bienvenue dans l'arène",
    titleAccent: 'Tekken',
    lead: 'Ladder ELO, duels classés entre membres et tournois à élimination.',
    ctaPrimary: 'Voir le ladder',
    slides: [], // bande photos défilante (haut de l'accueil Tekken)
    hero: [],   // image(s) du hero (visuel rotatif)
  },
}

function isObj(v) { return v && typeof v === 'object' && !Array.isArray(v) }
function deepMerge(base, over) {
  const out = Array.isArray(base) ? [...base] : { ...base }
  for (const k of Object.keys(over || {})) {
    if (isObj(out[k]) && isObj(over[k])) out[k] = deepMerge(out[k], over[k])
    else if (over[k] !== undefined && over[k] !== null && over[k] !== '') out[k] = over[k]
  }
  return out
}
function clone(o) { return JSON.parse(JSON.stringify(o)) }
function hexToRgb(hex) {
  const m = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(String(hex || ''))
  return m ? `${parseInt(m[1], 16)},${parseInt(m[2], 16)},${parseInt(m[3], 16)}` : '59,130,246'
}

export const useSiteSettings = defineStore('siteSettings', () => {
  const settings = ref(clone(DEFAULTS))
  const loaded = ref(false)

  function apply() {
    const s = settings.value
    // Couleurs d'accent (par jeu) — injectées en surcharge des tokens statiques
    const block = (sel, hex) =>
      `${sel}{--accent:${hex};--accent-rgb:${hexToRgb(hex)};--accent-l:color-mix(in srgb, ${hex} 55%, white);--accent-2:color-mix(in srgb, ${hex} 72%, white);}`
    let css = ''
    if (s.accent?.efoot)  css += block(':root', s.accent.efoot)
    if (s.accent?.tekken) css += block(':root[data-game="tekken"]', s.accent.tekken)
    let el = document.getElementById('site-accent')
    if (!el) { el = document.createElement('style'); el.id = 'site-accent'; document.head.appendChild(el) }
    el.textContent = css
    // Fond global (logo en filigrane)
    const root = document.documentElement
    if (s.background?.logo) root.style.setProperty('--app-bg-logo', `url('${s.background.logo}')`)
    if (s.background?.opacity != null) root.style.setProperty('--app-bg-logo-opacity', String(s.background.opacity))
  }

  async function load() {
    try {
      const r = await fetch(resolveBaseURL() + '/public/site-settings', { headers: { Accept: 'application/json' } })
      if (r.ok) { const d = await r.json(); settings.value = deepMerge(clone(DEFAULTS), d.settings || {}) }
    } catch (_) {}
    loaded.value = true
    apply()
  }

  function setLocal(next) {
    settings.value = deepMerge(clone(DEFAULTS), next || {})
    apply()
  }

  return { settings, loaded, load, apply, setLocal }
})
