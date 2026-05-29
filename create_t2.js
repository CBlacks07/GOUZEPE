const { Pool } = require('pg')
const pool = new Pool({ host:process.env.PGHOST,port:process.env.PGPORT||5432,user:process.env.PGUSER,password:process.env.PGPASSWORD,database:process.env.PGDATABASE,ssl:false })
const q = (s,p=[])=>pool.query(s,p)
const SEASON_ID=2

async function run(){
  async function createT(name,slug,starts,winner_pid,winner_name){
    const r=await q(`INSERT INTO tournaments(slug,name,format,status,starts_at,ended_at,winner_player_id,winner_name,created_by,member_tournament,counts_for_title,season_id,rr_match_mode,rr_standings_mode,created_at,updated_at)VALUES($1,$2,'round_robin','completed',$3,now(),$4,$5,1,true,true,$6,'home_away','goals',now(),now())RETURNING id`,[slug,name,starts,winner_pid,winner_name,SEASON_ID])
    return r.rows[0].id
  }
  async function addP(tid,pid,dn,seed){
    const r=await q(`INSERT INTO tournament_participants(tournament_id,player_id,display_name,seed,created_at)VALUES($1,$2,$3,$4,now())RETURNING id`,[tid,pid,dn,seed])
    return r.rows[0].id
  }
  async function addM(tid,rno,sno,p1,p2,s1,s2){
    // s1/s2 = null → match non joué (ready)
    const done = s1!==null && s2!==null
    const win = done?(s1>s2?p1:s2>s1?p2:null):null
    const status = done?'completed':'ready'
    await q(`INSERT INTO tournament_matches(tournament_id,round_no,slot_no,p1_participant_id,p2_participant_id,score_p1,score_p2,winner_participant_id,status,walkover,bracket_side,created_at,updated_at,finished_at)VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9,false,'W',now(),now(),$10)`,[tid,rno,sno,p1,p2,s1,s2,win,status,done?new Date():null])
  }

  // ───── TOURNOI 1 : 27/12/2025 D1 ─────────────────────────────
  console.log('Création tournoi 27/12/2025...')
  const t1=await createT("Journée 27/12/2025 — D1","journee-27-12-2025-d1","2025-12-27T20:00:00+00:00","CBlacks_GZ","Caringthon")
  const p1={}
  for(const[i,[pid,dn]]of[["CBlacks_GZ","Caringthon"],["IBR@93_GZ","Ibrahim"],["Akab_GZ","Emmanuel"],["EmRiCxX_GZ","Emeric"],["Yousscash_GZ","ISSOUFOU"],["Walé-GZ","Walé"],["Rod_GZ","Folly"],["Ismo","Ismo"]].entries())
    p1[dn]=await addP(t1,pid,dn,i+1)
  console.log(`  id=${t1}, ${Object.keys(p1).length} joueurs`)

  // null = non joué
  const N=null
  const sc1=[
    ["ISSOUFOU","Walé",      1,0, 1,0],
    ["Ismo","Ibrahim",       0,1, 0,1],
    ["Emeric","Emmanuel",    1,1, 1,1],
    ["Caringthon","Walé",    1,0, 1,0],
    ["Folly","Ibrahim",      0,1, 0,1],
    ["Caringthon","Ibrahim", 1,0, 1,0],
    ["Walé","Emmanuel",      0,1, 0,0],
    ["Folly","Emeric",       0,1, 0,1],
    ["ISSOUFOU","Ismo",      1,1, 1,1],
    ["Caringthon","Emmanuel",1,0, 1,0],
    ["Ibrahim","Emeric",     N,N, N,N],
    ["Walé","Ismo",          N,N, N,N],
    ["Folly","ISSOUFOU",     N,N, N,N],
    ["Caringthon","Emeric",  N,N, N,N],
    ["Emmanuel","Ismo",      N,N, N,N],
    ["Ibrahim","ISSOUFOU",   N,N, N,N],
    ["Walé","Folly",         N,N, N,N],
    ["Caringthon","Ismo",    N,N, N,N],
    ["Emeric","ISSOUFOU",    N,N, N,N],
    ["Emmanuel","Folly",     1,0, 1,0],
    ["Ibrahim","Walé",       N,N, N,N],
    ["Caringthon","ISSOUFOU",N,N, N,N],
    ["Ismo","Folly",         N,N, N,N],
    ["Emeric","Walé",        N,N, N,N],
    ["Emmanuel","Ibrahim",   N,N, N,N],
  ]
  let slot=1
  for(const[d,e,a1,a2,r1,r2]of sc1){
    const s1a=a1===N?null:a1, s2a=a2===N?null:a2
    const s1r=r1===N?null:r2, s2r=r2===N?null:r1
    await addM(t1,1,slot,p1[d],p1[e],s1a,s2a);slot++
    await addM(t1,2,slot,p1[e],p1[d],s1r,s2r);slot++
  }
  console.log(`  ${slot-1} matchs insérés`)

  // ───── TOURNOI 2 : 17/01/2026 D1 ─────────────────────────────
  console.log('Création tournoi 17/01/2026...')
  const t2=await createT("Journée 17/01/2026 — D1","journee-17-01-2026-d1","2026-01-17T20:00:00+00:00","Yousscash_GZ","ISSOUFOU")
  const p2={}
  for(const[i,[pid,dn]]of[["Yousscash_GZ","ISSOUFOU"],["IBR@93_GZ","Ibrahim"],["CBlacks_GZ","Caringthon"],["EmRiCxX_GZ","Emeric"],["Akab_GZ","Emmanuel"],["Rod_GZ","Folly"],["Walé-GZ","Walé"],["KenkNod_GZ","Koboyo"],["Matrix _GZ","Max"],["The_One_GZ","Fabio"],["Ismo","Ismo"]].entries())
    p2[dn]=await addP(t2,pid,dn,i+1)
  console.log(`  id=${t2}, ${Object.keys(p2).length} joueurs`)

  const sc2=[
    // dom, ext, a1,a2, r1,r2  (null=non joué)
    ["Emmanuel","Emeric",    0,0, 0,1],
    ["Emmanuel","Ibrahim",   N,N, N,N],
    ["Emmanuel","Ismo",      N,N, N,N],
    ["Emmanuel","ISSOUFOU",  N,N, N,N],
    ["Caringthon","Emmanuel",1,0, 0,0],
    ["Caringthon","Emeric",  N,N, N,N],
    ["Caringthon","Ibrahim", 1,0, 0,1],
    ["Caringthon","Ismo",    1,0, 0,0],
    ["Caringthon","Koboyo",  N,N, N,N],
    ["Caringthon","Max",     1,0, 0,0],
    ["Caringthon","Folly",   N,N, N,N],
    ["Caringthon","Fabio",   N,N, N,N],
    ["Caringthon","Walé",    N,N, N,N],
    ["Caringthon","ISSOUFOU",1,1, 0,0],
    ["Emeric","Ibrahim",     0,0, 0,1],
    ["Emeric","Ismo",        N,N, N,N],
    ["Emeric","Max",         N,N, N,N],
    ["Emeric","ISSOUFOU",    N,N, N,N],
    ["Ibrahim","Ismo",       1,0, 0,0],
    ["Ibrahim","Koboyo",     1,0, 0,0],
    ["Ibrahim","Max",        N,N, N,N],
    ["Ibrahim","Walé",       N,N, N,N],
    ["Ibrahim","ISSOUFOU",   1,0, 0,1],
    ["Ismo","Koboyo",        1,0, 0,0],
    ["Ismo","Max",           1,0, 0,0],
    ["Ismo","Folly",         1,0, 0,0],
    ["Ismo","Walé",          N,N, N,N],
    ["Ismo","ISSOUFOU",      0,0, 0,1],
    ["Koboyo","Emmanuel",    N,N, N,N],
    ["Koboyo","Emeric",      N,N, N,N],
    ["Koboyo","Folly",       N,N, N,N],
    ["Koboyo","Fabio",       N,N, N,N],
    ["Koboyo","Walé",        N,N, N,N],
    ["Max","Emmanuel",       N,N, N,N],
    ["Max","Koboyo",         0,0, 0,0],
    ["Max","Folly",          N,N, N,N],
    ["Max","Fabio",          N,N, N,N],
    ["Max","Walé",           N,N, N,N],
    ["Folly","Emmanuel",     0,1, 0,0],
    ["Folly","Emeric",       1,1, 0,0],
    ["Folly","Ibrahim",      N,N, N,N],
    ["Folly","Fabio",        N,N, N,N],
    ["Fabio","Emmanuel",     0,1, 0,0],
    ["Fabio","Emeric",       0,0, 0,1],
    ["Fabio","Ibrahim",      N,N, N,N],
    ["Fabio","Ismo",         N,N, N,N],
    ["Walé","Emmanuel",      0,1, 0,0],
    ["Walé","Emeric",        0,1, 0,0],
    ["Walé","Folly",         0,1, 0,0],
    ["Walé","Fabio",         1,0, 0,0],
    ["ISSOUFOU","Koboyo",    1,0, 0,0],
    ["ISSOUFOU","Max",       1,0, 0,0],
    ["ISSOUFOU","Folly",     N,N, N,N],
    ["ISSOUFOU","Fabio",     N,N, N,N],
    ["ISSOUFOU","Walé",      1,0, 0,0],
  ]
  slot=1
  for(const[d,e,a1,a2,r1,r2]of sc2){
    const s1a=a1===N?null:a1, s2a=a2===N?null:a2
    const s1r=r1===N?null:r2, s2r=r2===N?null:r1
    await addM(t2,1,slot,p2[d],p2[e],s1a,s2a);slot++
    await addM(t2,2,slot,p2[e],p2[d],s1r,s2r);slot++
  }
  console.log(`  ${slot-1} matchs insérés`)

  await pool.end()
  console.log('\nTerminé.')
}
run().catch(e=>{console.error(e.message);process.exit(1)})
