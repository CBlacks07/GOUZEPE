// Pronostics eFootball : course au titre, forme récente et probabilité de victoire par affiche.
// Même calcul pour l'accueil membre et la page Journées (un seul endroit à faire évoluer).
import { computed, ref } from 'vue'

export function sc(v) {
  if (v === null || v === undefined || v === '') return null
  const n = Number(v)
  return Number.isNaN(n) ? null : n
}

export function averagePtsPerMatch(row) {
  const j = Number(row?.J || 0)
  if (!j) return 0
  return Number(row?.PTS || 0) / j
}

function addLegToForm(agg, homeId, awayId, homeGoals, awayGoals) {
  if (!homeId || !awayId) return
  if (homeGoals === null || homeGoals === undefined || awayGoals === null || awayGoals === undefined) return
  const ensure = (id) => {
    if (!agg.has(id)) agg.set(id, { id, J: 0, V: 0, N: 0, D: 0, BP: 0, BC: 0 })
    return agg.get(id)
  }
  const home = ensure(homeId)
  const away = ensure(awayId)
  home.J++; away.J++
  home.BP += homeGoals; home.BC += awayGoals
  away.BP += awayGoals; away.BC += homeGoals
  if (homeGoals > awayGoals) { home.V++; away.D++ }
  else if (homeGoals < awayGoals) { away.V++; home.D++ }
  else { home.N++; away.N++ }
}

export function collectDivisionForm(recentDays, divisionKey) {
  const agg = new Map()
  for (const day of recentDays) {
    const matches = day?.payload?.[divisionKey] || []
    for (const m of matches) {
      const a1 = sc(m.a1), a2 = sc(m.a2), r1 = sc(m.r1), r2 = sc(m.r2)
      if (a1 !== null && a2 !== null) addLegToForm(agg, m.p1, m.p2, a1, a2)
      if (r1 !== null && r2 !== null) addLegToForm(agg, m.p2, m.p1, r2, r1)
    }
  }
  return [...agg.values()]
    .map((r) => ({ ...r, PTS: r.V * 3 + r.N, DIFF: r.BP - r.BC }))
    .sort((a, b) => b.PTS - a.PTS || b.DIFF - a.DIFF || b.BP - a.BP || String(a.id).localeCompare(String(b.id)))
}

const PRED_K = 0.34 // sensibilité (force 0-1) -> probabilité

function gapInfo(favProb) {
  if (favProb < 56) return { tier: 'Équilibré', tone: 'close' }
  if (favProb < 65) return { tier: 'Léger avantage', tone: 'mid' }
  if (favProb < 78) return { tier: 'Favori net', tone: 'strong' }
  return { tier: 'Large favori', tone: 'strong' }
}

/**
 * @param payload          ref  { d1: [...], d2: [...] } : les confrontations à pronostiquer
 * @param seasonStandings  ref  classement de la saison (moyenne par joueur)
 * @param recentDays       ref  journées confirmées récentes, la plus récente d'abord : [{ date, payload }]
 * @param knownDaysCount   ref  nombre de journées de la saison (seuil de classement)
 * @param isGuest          fn   (id) => bool : exclut les invités de « en forme »
 */
export function usePronostics({ payload, seasonStandings, recentDays, knownDaysCount, isGuest = () => false }) {
  const moyenneById = computed(() => {
    const m = new Map()
    for (const r of seasonStandings.value) m.set(String(r.id), Number(r.moyenne) || 0)
    return m
  })
  const titleThreshold = computed(() => (knownDaysCount.value ? Math.ceil(knownDaysCount.value * 0.25) : 0))

  const titleRace = computed(() => {
    const classed = seasonStandings.value
      .filter((r) => Number(r.participations || 0) >= titleThreshold.value)
      .slice()
      .sort((a, b) => Number(b.moyenne || 0) - Number(a.moyenne || 0) || Number(b.total || 0) - Number(a.total || 0))
    const leader = classed[0]
    return classed.slice(0, 3).map((r, i) => ({
      rank: i + 1,
      id: r.id,
      name: r.name || r.id,
      moyenne: Number(r.moyenne || 0),
      gap: leader ? +(Number(leader.moyenne || 0) - Number(r.moyenne || 0)).toFixed(2) : 0,
    }))
  })

  const titleConfidence = computed(() => {
    const r = titleRace.value
    if (r.length < 2) return r.length === 1 ? { label: 'Seul classé', tone: 'open' } : null
    const lead = r[1].gap
    if (lead >= 1.2) return { label: 'Quasi assuré', tone: 'strong' }
    if (lead >= 0.5) return { label: 'Favori', tone: 'mid' }
    return { label: 'Course ouverte', tone: 'open' }
  })

  // Forme récente : points/match moyens sur les 4 dernières journées (échelle 0-3)
  const formRatingById = computed(() => {
    const map = new Map()
    const days = recentDays.value.slice(0, 4)
    if (!days.length) return map
    for (const r of [...collectDivisionForm(days, 'd1'), ...collectDivisionForm(days, 'd2')]) {
      map.set(String(r.id), averagePtsPerMatch(r))
    }
    return map
  })

  // Plages min/max pour normaliser saison et forme sur une échelle 0-1
  const ratingRanges = computed(() => {
    const range = (arr) => {
      const vals = arr.filter((v) => Number.isFinite(v))
      if (!vals.length) return null
      const mn = Math.min(...vals)
      const mx = Math.max(...vals)
      return { mn, span: Math.max(1e-6, mx - mn) }
    }
    return {
      season: range(seasonStandings.value.map((r) => Number(r.moyenne) || 0).filter((v) => v > 0)),
      form: range([...formRatingById.value.values()]),
    }
  })

  // Force d'un joueur : 60 % moyenne saison normalisée + 40 % forme récente normalisée
  function strengthOf(id) {
    const sR = ratingRanges.value.season
    const fR = ratingRanges.value.form
    const sVal = moyenneById.value.get(String(id))
    const fVal = formRatingById.value.get(String(id))
    const hasS = sVal != null && sVal > 0 && sR
    const hasF = fVal != null && fR
    if (!hasS && !hasF) return null
    const sNorm = hasS ? (sVal - sR.mn) / sR.span : null
    const fNorm = hasF ? (fVal - fR.mn) / fR.span : null
    if (sNorm != null && fNorm != null) return 0.6 * sNorm + 0.4 * fNorm
    return sNorm != null ? sNorm : fNorm
  }

  const matchPredictions = computed(() => {
    const p = payload.value
    if (!p) return []
    const out = []
    for (const div of ['d1', 'd2']) {
      for (const m of (p[div] || [])) {
        if (!m?.p1 || !m?.p2) continue
        const s1 = strengthOf(m.p1)
        const s2 = strengthOf(m.p2)
        const unknown = s1 == null && s2 == null
        let prob1
        if (unknown) {
          prob1 = 0.5
        } else {
          const a = s1 != null ? s1 : Math.max(0, (s2 ?? 0.5) - 0.25)
          const b = s2 != null ? s2 : Math.max(0, (s1 ?? 0.5) - 0.25)
          prob1 = 1 / (1 + Math.exp(-(a - b) / PRED_K))
        }
        const favIsP1 = prob1 >= 0.5
        const favProb = Math.round((favIsP1 ? prob1 : 1 - prob1) * 100)
        const gap = gapInfo(favProb)
        out.push({
          key: `${div}-${m.p1}-${m.p2}`,
          div: div.toUpperCase(),
          p1: String(m.p1),
          p2: String(m.p2),
          prob1: Math.round(prob1 * 100),
          favorite: favIsP1 ? String(m.p1) : String(m.p2),
          favProb,
          close: favProb < 56,
          unknown,
          gapTier: gap.tier,
          gapTone: gap.tone,
          _interest: unknown ? 999 : favProb, // plus c'est serré, plus c'est intéressant
        })
      }
    }
    // Affiches serrées en tête, incertaines en fin
    return out.sort((a, b) => a._interest - b._interest)
  })

  const formPlayer = computed(() => {
    const days = recentDays.value.slice(0, 2)
    if (!days.length) return null
    const rows = [...collectDivisionForm(days, 'd1'), ...collectDivisionForm(days, 'd2')].filter((r) => !isGuest(r.id))
    if (!rows.length) return null
    rows.sort((a, b) => averagePtsPerMatch(b) - averagePtsPerMatch(a) || Number(b.PTS || 0) - Number(a.PTS || 0))
    const t = rows[0]
    return { id: t.id, name: String(t.id), pts: Number(t.PTS || 0), bp: Number(t.BP || 0) }
  })

  return { titleRace, titleConfidence, matchPredictions, formPlayer }
}

// Chargement autonome des données de pronostic (pour les pages qui ne les ont pas déjà).
// api : instance axios de useAPI(). Renvoie les refs à passer à usePronostics.
export function usePronosticsData(api) {
  const seasonStandings = ref([])
  const recentDays = ref([])
  const knownDaysCount = ref(0)
  const roleById = ref(new Map())
  let loaded = false

  async function load(seasonId) {
    if (loaded) return
    loaded = true
    try {
      const [st, pl] = await Promise.all([api.get('/standings'), api.get('/players')])
      seasonStandings.value = Array.isArray(st.data.standings) ? st.data.standings : []
      roleById.value = new Map((pl.data.players || []).map((p) => [String(p.player_id), String(p.role || 'MEMBRE').toUpperCase()]))
      if (seasonId) {
        const { data } = await api.get(`/seasons/${seasonId}/matchdays`)
        const days = (data.days || []).slice().sort()
        knownDaysCount.value = days.length
        const out = []
        for (let i = days.length - 1; i >= 0 && out.length < 4; i--) {
          try {
            const { data: payload } = await api.get(`/matchdays/${days[i]}`)
            out.push({ date: days[i], payload })
          } catch (_) { /* journée illisible : on passe à la précédente */ }
        }
        recentDays.value = out
      }
    } catch (_) { /* pronostics indisponibles : le panneau reste simplement masqué */ }
  }

  const isGuest = (id) => String(id).startsWith('G_') || roleById.value.get(String(id)) === 'INVITE'
  return { seasonStandings, recentDays, knownDaysCount, isGuest, load }
}
