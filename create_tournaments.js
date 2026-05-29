const { Pool } = require('pg')
const pool = new Pool({
  host: process.env.PGHOST, port: process.env.PGPORT || 5432,
  user: process.env.PGUSER, password: process.env.PGPASSWORD,
  database: process.env.PGDATABASE, ssl: false
})
const q = (s, p=[]) => pool.query(s, p)
const SEASON_ID = 2

async function run() {

  async function createTournament(name, slug, starts_at, winner_pid, winner_name) {
    const r = await q(`
      INSERT INTO tournaments(slug,name,format,status,starts_at,ended_at,
        winner_player_id,winner_name,created_by,member_tournament,counts_for_title,
        season_id,rr_match_mode,rr_standings_mode,created_at,updated_at)
      VALUES($1,$2,'round_robin','completed',$3,now(),$4,$5,1,true,true,$6,'home_away','goals',now(),now())
      RETURNING id
    `, [slug, name, starts_at, winner_pid, winner_name, SEASON_ID])
    return r.rows[0].id
  }

  async function addP(tid, pid, dname, seed) {
    const r = await q(
      `INSERT INTO tournament_participants(tournament_id,player_id,display_name,seed,created_at)
       VALUES($1,$2,$3,$4,now()) RETURNING id`,
      [tid, pid, dname, seed])
    return r.rows[0].id
  }

  async function addM(tid, rno, sno, p1, p2, s1, s2) {
    const win = s1>s2 ? p1 : s2>s1 ? p2 : null
    await q(`INSERT INTO tournament_matches(tournament_id,round_no,slot_no,
      p1_participant_id,p2_participant_id,score_p1,score_p2,winner_participant_id,
      status,walkover,bracket_side,created_at,updated_at,finished_at)
      VALUES($1,$2,$3,$4,$5,$6,$7,$8,'completed',false,'W',now(),now(),now())`,
      [tid, rno, sno, p1, p2, s1, s2, win])
  }

  // ─── TOURNOI 1 : 11/10/2025 D1 ──────────────────────────────
  console.log('Création tournoi 1...')
  const t1 = await createTournament(
    "Journée 11/10/2025 — D1", "journee-11-10-2025-d1",
    "2025-10-11T20:00:00+00:00", "EmRiCxX_GZ", "Emeric"
  )
  const t1p = {}
  for (const [i,[pid,dn]] of [
    ["EmRiCxX_GZ","Emeric"],["CBlacks_GZ","Caringthon"],["IBR@93_GZ","Ibrahim"],
    ["Akab_GZ","Emmanuel"],["Matrix _GZ","Max"],[null,"Pat"],
    ["KenkNod_GZ","Koboyo"],["Rod_GZ","Folly"],["The_One_GZ","Fabio"],
    ["Rius_oyo_GZ","Marius"],["Walé-GZ","Walé"],["GMT_GZ","Tanguy"]
  ].entries()) { t1p[dn] = await addP(t1, pid, dn, i+1) }
  console.log(`  Tournoi 1 id=${t1}, ${Object.keys(t1p).length} joueurs`)

  // (dom, ext, a1,a2, r1,r2) — aller: dom>ext, retour: ext>dom
  const s1 = [
    ["Walé","Caringthon", 0,5,2,4],["Walé","Emeric", 0,0,1,4],
    ["Walé","Ibrahim",    0,5,2,4],["Walé","Emmanuel",1,6,0,1],
    ["Walé","Fabio",      2,4,0,1],["Walé","Max",     2,4,2,4],
    ["Walé","Koboyo",     2,3,4,2],["Walé","Tanguy",  2,2,4,0],
    ["Walé","Folly",      0,4,1,4],["Walé","Pat",     1,3,2,4],
    ["Ibrahim","Emeric",  1,5,0,7],["Ibrahim","Pat",  4,0,2,3],
    ["Ibrahim","Emmanuel",1,1,4,1],["Ibrahim","Folly",7,0,3,1],
    ["Ibrahim","Fabio",   1,4,2,0],["Ibrahim","Caringthon",1,1,3,1],
    ["Ibrahim","Koboyo",  4,1,3,3],["Ibrahim","Marius",3,1,2,6],
    ["Ibrahim","Tanguy",  4,1,6,0],["Ibrahim","Max",  3,1,2,1],
    ["Caringthon","Emeric",5,1,2,0],["Caringthon","Pat",1,1,1,0],
    ["Caringthon","Tanguy",5,0,1,1],["Caringthon","Fabio",2,2,6,0],
    ["Caringthon","Emmanuel",2,0,3,0],["Caringthon","Max",3,2,2,1],
    ["Caringthon","Marius",3,0,3,3],["Caringthon","Koboyo",0,0,2,3],
    ["Fabio","Emmanuel",  0,0,1,0],["Fabio","Tanguy",2,0,2,1],
    ["Fabio","Folly",     0,2,3,6],["Fabio","Marius",2,2,1,3],
    ["Fabio","Koboyo",    1,3,1,4],["Fabio","Pat",   4,2,3,4],
    ["Fabio","Max",       1,1,0,1],["Emeric","Pat",  4,1,3,1],
    ["Emeric","Folly",    2,1,4,2],["Emeric","Emmanuel",3,2,1,1],
    ["Emeric","Koboyo",   5,2,7,1],["Emeric","Max",  4,1,4,1],
    ["Emeric","Marius",   4,2,5,0],["Max","Pat",     2,0,1,1],
    ["Max","Marius",      2,1,1,2],["Max","Tanguy",  2,0,4,1],
    ["Max","Koboyo",      1,0,2,2],["Koboyo","Tanguy",3,1,6,1],
    ["Koboyo","Pat",      1,1,2,3],["Koboyo","Emmanuel",0,1,0,1],
    ["Koboyo","Marius",   3,0,1,1],["Emmanuel","Pat",1,0,1,2],
    ["Emmanuel","Marius", 2,2,3,2],["Emmanuel","Max",1,1,1,0],
    ["Tanguy","Emeric",   0,5,1,4],["Tanguy","Pat",  2,2,1,4],
    ["Tanguy","Marius",   2,0,1,2],["Marius","Folly",0,2,0,0],
    ["Marius","Pat",      2,0,4,1],["Folly","Pat",   1,3,0,3],
    ["Walé","Marius",     6,5,3,0],["Caringthon","Folly",4,2,3,0],
    ["Folly","Emmanuel",  0,1,1,2],["Emmanuel","Tanguy",3,0,4,3],
    ["Tanguy","Folly",    1,5,1,3],["Max","Folly",   0,2,6,1],
    ["Emeric","Fabio",    2,1,3,0],["Koboyo","Folly",1,1,1,1],
  ]
  let slot=1
  for (const [d,e,a1,a2,r1,r2] of s1) {
    await addM(t1,1,slot,t1p[d],t1p[e],a1,a2); slot++
    await addM(t1,2,slot,t1p[e],t1p[d],r2,r1); slot++
  }
  console.log(`  ${slot-1} matchs insérés`)

  // ─── TOURNOI 2 : 07/02/2026 D1 ──────────────────────────────
  console.log('Création tournoi 2...')
  const t2 = await createTournament(
    "Journée 07/02/2026 — D1", "journee-07-02-2026-d1",
    "2026-02-07T20:00:00+00:00", "EmRiCxX_GZ", "Emeric"
  )
  const t2p = {}
  for (const [i,[pid,dn]] of [
    ["EmRiCxX_GZ","Emeric"],["CBlacks_GZ","Caringthon"],
    ["Yousscash_GZ","ISSOUFOU"],["IBR@93_GZ","Ibrahim"],
    ["Rius_oyo_GZ","Marius"],["KenkNod_GZ","Koboyo"],
    ["Akab_GZ","Emmanuel"],["Walé-GZ","Walé"],
    ["AKA BIG","AKA BIG"],["Ismo","Ismo"]
  ].entries()) { t2p[dn] = await addP(t2, pid, dn, i+1) }
  console.log(`  Tournoi 2 id=${t2}, ${Object.keys(t2p).length} joueurs`)

  const s2 = [
    ["AKA BIG","Emeric",     2,3,3,2],["AKA BIG","Ibrahim",    1,6,2,0],
    ["AKA BIG","Marius",     0,3,2,1],["AKA BIG","ISSOUFOU",  4,2,1,1],
    ["Emmanuel","AKA BIG",   0,1,0,1],["Emmanuel","Ismo",      2,3,1,2],
    ["Emmanuel","Koboyo",    2,1,2,0],["Emmanuel","Walé",      4,1,1,2],
    ["Caringthon","AKA BIG", 2,1,3,4],["Caringthon","Emmanuel",3,1,4,1],
    ["Caringthon","Emeric",  0,2,2,3],["Caringthon","Ibrahim", 6,3,4,1],
    ["Caringthon","Ismo",    4,1,0,6],["Caringthon","Koboyo",  2,1,3,2],
    ["Caringthon","Marius",  4,1,3,2],["Caringthon","Walé",    1,4,3,2],
    ["Caringthon","ISSOUFOU",2,0,2,3],["Emeric","Emmanuel",    4,0,1,0],
    ["Emeric","Ibrahim",     4,0,3,2],["Emeric","Marius",      2,0,4,2],
    ["Emeric","ISSOUFOU",    2,1,2,1],["Ibrahim","Emmanuel",   3,1,4,1],
    ["Ibrahim","Ismo",       1,1,2,2],["Ibrahim","Koboyo",     3,2,3,3],
    ["Ibrahim","Walé",       3,3,5,2],["Ismo","AKA BIG",      1,1,1,2],
    ["Ismo","Emeric",        2,2,4,0],["Ismo","Marius",        3,2,2,2],
    ["Ismo","ISSOUFOU",      0,0,2,2],["Koboyo","AKA BIG",    1,2,1,0],
    ["Koboyo","Emeric",      3,2,2,3],["Koboyo","Ismo",        3,1,2,5],
    ["Koboyo","Marius",      5,0,2,3],["Marius","Emmanuel",    3,1,8,1],
    ["Marius","Ibrahim",     3,4,2,2],["Marius","Walé",        2,1,3,1],
    ["Marius","ISSOUFOU",    1,3,0,0],["Walé","AKA BIG",      0,3,0,3],
    ["Walé","Emeric",        0,5,2,3],["Walé","Ismo",          2,3,2,4],
    ["Walé","Koboyo",        0,1,1,2],["ISSOUFOU","Emmanuel",  1,0,1,0],
    ["ISSOUFOU","Ibrahim",   5,1,2,1],["ISSOUFOU","Koboyo",    4,1,5,1],
    ["ISSOUFOU","Walé",      2,1,4,4],
  ]
  slot=1
  for (const [d,e,a1,a2,r1,r2] of s2) {
    await addM(t2,1,slot,t2p[d],t2p[e],a1,a2); slot++
    await addM(t2,2,slot,t2p[e],t2p[d],r2,r1); slot++
  }
  console.log(`  ${slot-1} matchs insérés`)

  await pool.end()
  console.log('\nTerminé.')
}
run().catch(e => { console.error(e.message); process.exit(1) })
