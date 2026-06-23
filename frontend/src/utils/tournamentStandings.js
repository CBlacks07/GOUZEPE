// Classement final d'un tournoi, calcule selon le format.
//
// - single_elimination : classement par progression (tour d'elimination).
//   Le champion est 1er, le finaliste 2e, les demi-finalistes ensuite, etc.
//   Ce n'est PAS le nombre de victoires qui prime mais le stade atteint.
// - double_elimination : champion (vainqueur grande finale), finaliste
//   (perdant grande finale), puis par tour d'elimination dans le loser bracket.
// - groups_knockout : d'abord la phase finale (comme une elimination directe),
//   puis les joueurs sortis en poule, classes a leur performance de poule.
// - round_robin : classement aux points (gere ailleurs, via les standings).

const DONE = new Set(['completed', 'done'])

function isDone(m) {
  return DONE.has(String(m.status || '').toLowerCase())
    && m.p1_participant_id != null && m.p2_participant_id != null
    && m.score_p1 != null && m.score_p2 != null
}

function bracketSideOf(m, format) {
  const s = String(m.bracket_side || '').trim().toUpperCase()
  if (s) return s === 'WB' ? 'W' : s === 'LB' ? 'L' : s
  const r = Number(m.round_no || 0)
  if (format === 'double_elimination') return r >= 20 ? 'GF' : r >= 10 ? 'L' : 'W'
  return 'W'
}

function isGroupMatch(m) {
  const s = String(m.bracket_side || '').trim().toUpperCase()
  return s === 'G' || s === 'GROUP' || m.group_no != null
}

export function computeFinalStandings(format, rawMatches, participants) {
  const stats = new Map()
  for (const p of participants || []) {
    const id = p.participant_id ?? p.id
    if (id == null) continue
    stats.set(id, {
      participant_id: id,
      player_id: p.player_id ? String(p.player_id) : '',
      name: String(p.display_name || p.name || '').trim(),
      wins: 0, losses: 0, draws: 0, played: 0, gf: 0, ga: 0,
      elim: -1,            // score de "longevite" : plus c'est haut, plus il a avance
      isChampion: false,
      isRunnerUp: false,
      koReached: false,    // a atteint la phase finale (groups_knockout)
    })
  }

  const ms = rawMatches || []

  for (const m of ms) {
    if (!isDone(m)) continue
    const a = stats.get(m.p1_participant_id)
    const b = stats.get(m.p2_participant_id)
    if (!a || !b) continue
    const s1 = Number(m.score_p1)
    const s2 = Number(m.score_p2)
    a.played++; b.played++
    a.gf += s1; a.ga += s2
    b.gf += s2; b.ga += s1

    let winner = null
    let loser = null
    if (s1 > s2) { winner = a; loser = b; a.wins++; b.losses++ }
    else if (s2 > s1) { winner = b; loser = a; b.wins++; a.losses++ }
    else { a.draws++; b.draws++ }

    const grp = isGroupMatch(m)
    if (format === 'groups_knockout' && !grp) { a.koReached = true; b.koReached = true }

    if (winner && loser) {
      const side = bracketSideOf(m, format)
      const r = Number(m.round_no || 0)
      if (format === 'single_elimination') {
        loser.elim = Math.max(loser.elim, r)
      } else if (format === 'double_elimination') {
        if (side === 'GF') { winner.isChampion = true; loser.isRunnerUp = true }
        else if (side === 'L') loser.elim = Math.max(loser.elim, r)
      } else if (format === 'groups_knockout') {
        if (!grp) loser.elim = Math.max(loser.elim, 1000 + r)
      }
    }
  }

  // Champion pour SE / groups_knockout = vainqueur du dernier match (hors poule).
  if (format === 'single_elimination' || format === 'groups_knockout') {
    const pool = ms.filter((m) => isDone(m) && !(format === 'groups_knockout' && isGroupMatch(m)))
    if (pool.length) {
      const fin = pool.slice().sort((x, y) => Number(y.round_no || 0) - Number(x.round_no || 0))[0]
      const s1 = Number(fin.score_p1)
      const s2 = Number(fin.score_p2)
      const champId = s1 >= s2 ? fin.p1_participant_id : fin.p2_participant_id
      const champ = stats.get(champId)
      if (champ) champ.isChampion = true
    }
  }

  const rows = [...stats.values()]

  const scoreOf = (r) =>
    r.isChampion ? Number.POSITIVE_INFINITY
      : r.isRunnerUp ? Number.MAX_SAFE_INTEGER
        : r.elim

  rows.sort((a, b) => {
    const ea = scoreOf(a)
    const eb = scoreOf(b)
    if (eb !== ea) return eb - ea
    // Egalite de stade : on departage a la performance.
    if (b.wins !== a.wins) return b.wins - a.wins
    const da = a.gf - a.ga
    const db = b.gf - b.ga
    if (db !== da) return db - da
    if (b.gf !== a.gf) return b.gf - a.gf
    return String(a.player_id || a.name).localeCompare(String(b.player_id || b.name), 'fr')
  })

  const maxElim = rows.reduce((mx, r) => (!r.isChampion && r.elim > mx ? r.elim : mx), -Infinity)
  rows.forEach((r, i) => {
    r.rank = i + 1
    r.stage = stageLabel(format, r, maxElim)
  })
  return rows
}

function stageLabel(format, r, maxElim) {
  if (r.isChampion) return 'Champion'
  if (r.isRunnerUp) return 'Finaliste'

  if (format === 'single_elimination' || format === 'groups_knockout') {
    if (r.elim < 0) {
      return format === 'groups_knockout' ? 'Phase de groupes' : ''
    }
    const depth = maxElim - r.elim // 0 = finaliste, 1 = demie, 2 = quart...
    if (depth <= 0) return 'Finaliste'
    if (depth === 1) return 'Demi-finaliste'
    if (depth === 2) return 'Quart de finaliste'
    if (depth === 3) return '8e de finale'
    if (depth === 4) return '16e de finale'
    return `${r.rank}e place`
  }

  if (format === 'double_elimination') {
    if (r.rank === 3) return 'Demi-finaliste'
    return `${r.rank}e place`
  }

  return `${r.rank}e place`
}
