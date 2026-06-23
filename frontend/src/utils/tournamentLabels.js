// Pour les tournois "membre", on affiche l'identifiant du joueur (player_id)
// à la place de son nom d'affichage, dans les brackets et les classements.

export function applyIdLabels(matches, useIds) {
  if (!useIds) return matches || []
  return (matches || []).map((m) => ({
    ...m,
    p1_name: m.p1_player_id || m.p1_name,
    p2_name: m.p2_player_id || m.p2_name,
    winner_name: m.winner_player_id || m.winner_name,
  }))
}

export function applyIdStandings(rows, useIds) {
  if (!useIds) return rows || []
  return (rows || []).map((s) => (s && s.player_id ? { ...s, name: s.player_id } : s))
}

// Construit un index display_name -> player_id à partir des participants du bundle.
export function buildIdIndex(participants) {
  const idx = new Map()
  for (const p of participants || []) {
    if (!p) continue
    const name = String(p.display_name || p.name || '').trim()
    const pid = p.player_id ? String(p.player_id) : ''
    if (name && pid) idx.set(name, pid)
  }
  return idx
}

// Renvoie le player_id d'un participant (objet) pour usage en libellé.
export function participantIdLabel(p, useIds) {
  if (!p) return ''
  if (useIds && p.player_id) return String(p.player_id)
  return String(p.display_name || p.name || p.player_id || '').trim()
}
