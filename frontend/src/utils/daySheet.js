/*
 * Feuille de résultats d'une journée (impression / PDF).
 * Source unique : la page Journées et le module Classement génèrent EXACTEMENT le même document,
 * quel que soit l'endroit d'où l'impression est lancée.
 */

const SVG_TROPHY = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#ca8a04" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6"/><path d="M18 9h1.5a2.5 2.5 0 0 0 0-5H18"/><path d="M4 22h16"/><path d="M10 14.66V17c0 .55-.47.98-.97 1.21C7.85 18.75 7 20.24 7 22"/><path d="M14 14.66V17c0 .55.47.98.97 1.21C16.15 18.75 17 20.24 17 22"/><path d="M18 2H6v7a6 6 0 0 0 12 0V2Z"/></svg>'

const CSS = '@page{size:A4 landscape;margin:12mm;}body{font:12px/1.35 "Segoe UI",Roboto,Arial,sans-serif;color:#111;}h1{font-size:18px;margin:0 0 8px;display:flex;align-items:center;gap:8px}h1 img{height:28px} h2{font-size:14px;margin:10px 0 6px;} .tbl{width:100%;border-collapse:collapse;border:1px solid #444;} .tbl th,.tbl td{border:1px solid #444;padding:4px 6px;text-align:center} .tbl thead th{background:#efefef;} .champ{text-align:center;margin:6px 0 10px;font-weight:900;color:#cc0000;font-size:17px;} .verdict{margin-top:8px;font-weight:800;color:#1d4ed8;text-align:center;font-size:15px;} .notes{margin-top:10px;padding:8px 10px;border:1px solid #444;} .sepRow td{background:#f7f7f7;font-style:italic} .tbl.match{table-layout:fixed;} .tbl.match td.pl{font-weight:600;} .tbl.match td.pl1{text-align:right;padding-right:14px;} .tbl.match td.pl2{text-align:left;padding-left:14px;} .tbl.match td.sc{font-weight:700;white-space:nowrap;} .tbl.match thead th.pl1{text-align:right;padding-right:14px;} .tbl.match thead th.pl2{text-align:left;padding-left:14px;}'

export function escapeHtml(input) {
  return String(input ?? '').replace(/[&<>"']/g, (m) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
  }[m]))
}

function sc(v) {
  if (v === null || v === undefined || v === '') return null
  const n = Number(v)
  return Number.isNaN(n) ? null : n
}

export function fmtDayLong(d) {
  if (!d) return '—'
  try {
    return new Date(d + 'T12:00:00').toLocaleDateString('fr-FR', { weekday: 'long', day: '2-digit', month: 'long', year: 'numeric' })
  } catch (_) { return d }
}

/** Classement d'une journée à partir des confrontations (aller + retour). */
export function computeDayStandings(matches, roleOf) {
  const agg = new Map()
  const ensure = (id) => {
    if (!agg.has(id)) agg.set(id, { id, J: 0, V: 0, N: 0, D: 0, BP: 0, BC: 0 })
    return agg.get(id)
  }
  const play = (home, away, gh, ga) => {
    const A = ensure(home), B = ensure(away)
    A.J++; B.J++; A.BP += gh; A.BC += ga; B.BP += ga; B.BC += gh
    if (gh > ga) { A.V++; B.D++ } else if (gh < ga) { B.V++; A.D++ } else { A.N++; B.N++ }
  }
  for (const m of (matches || [])) {
    if (!m.p1 || !m.p2 || m.p1 === m.p2) continue
    const a1 = sc(m.a1), a2 = sc(m.a2)
    if (a1 !== null && a2 !== null) play(m.p1, m.p2, a1, a2)
    const r1 = sc(m.r1), r2 = sc(m.r2)
    if (r1 !== null && r2 !== null) play(m.p2, m.p1, r2, r1)
  }
  return [...agg.values()]
    .map((r) => ({ ...r, role: roleOf(r.id), PTS: r.V * 3 + r.N, DIFF: r.BP - r.BC }))
    .sort((a, b) => b.PTS - a.PTS || b.DIFF - a.DIFF || b.BP - a.BP || String(a.id).localeCompare(String(b.id)))
}

function splitAndRank(rows) {
  const main = rows.filter((r) => String(r.role || '').toUpperCase() !== 'INVITE')
  const inv = rows.filter((r) => String(r.role || '').toUpperCase() === 'INVITE')
  main.forEach((r, i) => { r.RANK = i + 1 })
  inv.forEach((r) => { r.RANK = '—' })
  return { main, inv }
}

/** Verdict du barrage, déduit de l'affiche et du gagnant (jamais stocké dans la journée). */
export function barrageVerdict(barrage) {
  const parts = String(barrage?.ids || '').split(/[-–]/).map((s) => s.trim())
  const id1 = parts[0] || '', id2 = parts[1] || ''
  if (!id1 || !id2) return '—'
  if (barrage?.winner === id1) return `${id1} se maintient en D1 · ${id2} reste en D2`
  if (barrage?.winner === id2) return `${id2} monte en D1 · ${id1} est relégué en D2`
  return `Affiche : ${id1} – ${id2}`
}

async function logoDataURL(logoPath) {
  const tryFetch = async (path) => {
    if (!path) return null
    try {
      const r = await fetch(path, { cache: 'no-store' })
      if (!r.ok) return null
      const blob = await r.blob()
      return await new Promise((resolve) => {
        const fr = new FileReader()
        fr.onload = () => resolve(fr.result)
        fr.readAsDataURL(blob)
      })
    } catch (_) {
      return null
    }
  }
  return (await tryFetch(logoPath))
    || (await tryFetch('/assets/logo.png'))
    || (await tryFetch('/assets/icons/apple-touch-icon.png'))
    || (await tryFetch('assets/logo.png'))
    || (await tryFetch('assets/icons/apple-touch-icon.png'))
}

function renderMatches(matches) {
  let h = '<table class="tbl match"><colgroup><col style="width:32%"><col style="width:18%"><col style="width:18%"><col style="width:32%"></colgroup><thead><tr><th class="pl1">Joueur 1</th><th>Aller</th><th>Retour</th><th class="pl2">Joueur 2</th></tr></thead><tbody>'
  for (const m of (matches || [])) {
    const a = (m.a1 != null || m.a2 != null) ? `${m.a1 ?? ''} - ${m.a2 ?? ''}` : ''
    const r = (m.r1 != null || m.r2 != null) ? `${m.r1 ?? ''} - ${m.r2 ?? ''}` : ''
    h += `<tr><td class="pl pl1">${escapeHtml(m.p1 || '')}</td><td class="sc">${escapeHtml(a)}</td><td class="sc">${escapeHtml(r)}</td><td class="pl pl2">${escapeHtml(m.p2 || '')}</td></tr>`
  }
  return h + '</tbody></table>'
}

function renderStand(title, { main, inv }, nameOf) {
  let h = `<h2>${escapeHtml(title)}</h2><table class="tbl"><thead><tr><th>Rang</th><th>Nom</th><th>ID</th><th>J</th><th>V</th><th>N</th><th>D</th><th>BM</th><th>BC</th><th>Diff</th><th>PTS</th></tr></thead><tbody>`
  const row = (r) => `<tr><td>${r.RANK}</td><td>${escapeHtml(nameOf(r.id))}</td><td>${escapeHtml(r.id)}</td><td>${r.J}</td><td>${r.V}</td><td>${r.N}</td><td>${r.D}</td><td>${r.BP}</td><td>${r.BC}</td><td>${r.DIFF > 0 ? '+' : ''}${r.DIFF}</td><td>${r.PTS}</td></tr>`
  for (const r of main) h += row(r)
  if (inv.length) {
    h += '<tr class="sepRow"><td colspan="11">Invités (non classés)</td></tr>'
    for (const r of inv) h += row(r)
  }
  return h + '</tbody></table>'
}

/**
 * Construit le document HTML de la feuille de journée.
 * @param {object} o
 *  - day        'YYYY-MM-DD'
 *  - d1, d2     confrontations (p1, p2, a1, a2, r1, r2)
 *  - champions  { d1: { id, team }, d2: { id, team } }
 *  - barrage    { ids, winner, notes }
 *  - roleOf     (id) => 'MEMBRE' | 'INVITE'
 *  - nameOf     (id) => nom affiché
 *  - logo       data URL du logo (optionnel)
 */
export function buildDaySheetHtml({ day, d1, d2, champions, barrage, roleOf, nameOf, logo }) {
  const st1 = splitAndRank(computeDayStandings(d1, roleOf))
  const st2 = splitAndRank(computeDayStandings(d2, roleOf))
  const c1 = champions?.d1 || {}, c2 = champions?.d2 || {}
  const team1 = (c1.team || '').toUpperCase() || '—'
  const team2 = (c2.team || '').toUpperCase() || '—'
  const b = barrage || {}

  let html = `<!doctype html><html lang="fr"><head><meta charset="utf-8"/><title>Résultats — ${escapeHtml(day)}</title><style>${CSS}</style></head><body onload="window.print()">`
  html += `<h1>${logo ? `<img src="${logo}" alt="logo">` : ''}GOUZEPE GAMING CLUB — Journée du ${escapeHtml(fmtDayLong(day))}</h1>`
  html += '<h2>SCORES D1</h2>' + renderMatches(d1)
  html += `<div class="champ">${SVG_TROPHY} ${escapeHtml(c1.id || '—')} — CHAMPION avec ${escapeHtml(team1)}</div>`
  html += renderStand('CLASSEMENT D1', st1, nameOf)
  html += '<h2>SCORES D2</h2>' + renderMatches(d2)
  html += `<div class="champ">${SVG_TROPHY} ${escapeHtml(c2.id || '—')} — CHAMPION avec ${escapeHtml(team2)}</div>`
  html += renderStand('CLASSEMENT D2', st2, nameOf)
  html += '<h2>BARRAGES</h2><table class="tbl"><thead><tr><th>Affiche</th><th>Gagnant</th></tr></thead><tbody>'
  html += `<tr><td>${escapeHtml(b.ids || '—')}</td><td style="font-weight:700;color:#16a34a">${escapeHtml(b.winner || '—')}</td></tr></tbody></table>`
  html += `<div class="verdict">*** ${escapeHtml(barrageVerdict(b))}</div>`
  const notes = String(b.notes || '').trim()
  if (notes) {
    html += `<div class="notes"><b>Notes :</b><br>${escapeHtml(notes).replace(/\r?\n/g, '<br>')}</div>`
  }
  return html + '</body></html>'
}

/** Ouvre la feuille dans un nouvel onglet (impression automatique). Retourne false si le popup est bloqué. */
export async function openDaySheet({ logoPath, ...sheet }) {
  const logo = await logoDataURL(logoPath)
  const html = buildDaySheetHtml({ ...sheet, logo })
  const url = URL.createObjectURL(new Blob([html], { type: 'text/html' }))
  const w = window.open(url, '_blank')
  if (!w) return false
  w.addEventListener('unload', () => URL.revokeObjectURL(url), { once: true })
  return true
}
