// Préparation des matchs d'un tournoi pour les composants Bracket* (lecture seule).
import { applyIdLabels } from '@/utils/tournamentLabels'

function normalizeSide(raw, format, roundNo) {
  const side = String(raw || '').trim().toUpperCase()
  if (['W', 'L', 'GF', 'G'].includes(side)) return side
  if (format === 'double_elimination') return roundNo >= 20 ? 'GF' : roundNo >= 10 ? 'L' : 'W'
  return 'W'
}

// Dans les confrontations et brackets, les joueurs du club apparaissent par leur identifiant.
export function normalizeBracketMatches(rawMatches, format) {
  return applyIdLabels(rawMatches || [], true).map((m) => {
    const roundNo = Number(m.round_no || 0)
    return {
      ...m,
      round_no: roundNo,
      slot_no: Number(m.slot_no || 0),
      p1_id: m.p1_participant_id ?? null,
      p2_id: m.p2_participant_id ?? null,
      score1: m.score_p1 ?? null,
      score2: m.score_p2 ?? null,
      bracket_side: normalizeSide(m.bracket_side, format, roundNo),
    }
  })
}

export const isGroupMatch = (m) => m.bracket_side === 'G' || (m.group_no !== null && m.group_no !== undefined)

export function groupBuckets(matches) {
  const map = new Map()
  for (const m of matches.filter(isGroupMatch)) {
    const k = Number(m.group_no) || 0
    if (!map.has(k)) map.set(k, [])
    map.get(k).push(m)
  }
  return [...map.entries()].sort((a, b) => a[0] - b[0]).map(([group_no, list]) => ({ group_no, matches: list }))
}

export const FORMAT_LABELS = {
  single_elimination: 'Élimination simple',
  double_elimination: 'Double élimination',
  round_robin: 'Toutes rondes',
  groups_knockout: 'Groupes + Finales',
}
