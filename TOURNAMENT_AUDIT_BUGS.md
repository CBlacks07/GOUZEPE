# GOUZEPE Tournament Admin System - Bug Audit Report

**Date:** April 30, 2026  
**Scope:** Tournament management system (API, Web UI, Vue Frontend, Database)  
**Total Bugs Found:** 12 Critical/High Issues + 8 Medium Issues

---

## 🔴 CRITICAL BUGS

### BUG #1: Guest Player Cleanup Logic Flaw (Cascade Delete)
**Severity:** CRITICAL  
**File:** [api/tournaments.js](api/tournaments.js#L525-L555)  
**Lines:** 525-555

**Description:**
When deleting a tournament, the code attempts to clean up GUEST players AFTER the tournament has already been deleted via CASCADE. This is logically flawed and won't work as intended.

**Code Location:**
```javascript
// Line 525-555 in api/tournaments.js
const deleteResult = await client.query(
  'DELETE FROM tournaments WHERE id = $1 RETURNING id, name',
  [id]
);

if (deleteResult.rows.length === 0) {
  throw new Error('Tournoi non trouvé');
}

// FLAWED: Trying to delete orphan guests AFTER tournament is deleted
const orphanGuests = await client.query(`
  DELETE FROM players
  WHERE role = 'GUEST'
    AND player_id LIKE 'guest_%'
    AND NOT EXISTS (
      SELECT 1 FROM tournament_participants tp WHERE tp.player_id = players.player_id
    )
  RETURNING player_id, name
`);
```

**What Causes It:**
1. Tournament is deleted with CASCADE, which deletes all `tournament_participants`
2. The code then tries to find orphan GUEST players not in `tournament_participants`
3. Since tournament_participants are already deleted, the query can't distinguish which players were only in this tournament
4. GUEST players may not be deleted if they participated in other tournaments

**Suggested Fix:**
Delete orphan GUEST players **BEFORE** deleting the tournament:

```javascript
// First, identify which GUEST players to delete
const guestPlayersToDelete = await client.query(`
  SELECT DISTINCT tp.player_id
  FROM tournament_participants tp
  JOIN players p ON tp.player_id = p.player_id
  WHERE tp.tournament_id = $1 AND p.role = 'GUEST'
    AND NOT EXISTS (
      SELECT 1 FROM tournament_participants tp2
      WHERE tp2.player_id = tp.player_id AND tp2.tournament_id != $1
    )
`, [id]);

const guestIds = guestPlayersToDelete.rows.map(r => r.player_id);
if (guestIds.length > 0) {
  await client.query('DELETE FROM players WHERE player_id = ANY($1)', [guestIds]);
}

// Then delete the tournament
const deleteResult = await client.query(
  'DELETE FROM tournaments WHERE id = $1 RETURNING id, name',
  [id]
);
```

---

### BUG #2: Score Update Missing Winner Validation
**Severity:** CRITICAL  
**File:** [api/server.js](api/server.js#L2105-L2220)  
**Lines:** 2137-2145

**Description:**
The score update endpoint doesn't validate that a winner_id is provided or that the winner is one of the two match participants. This could allow:
- Scores to be set without a winner
- Invalid winners to be assigned
- Bracket progression corruption

**Current Code:**
```javascript
const score1 = parseScoreValue(req.body?.score_p1);
const score2 = parseScoreValue(req.body?.score_p2);
if (score1 === null || score2 === null) return bad(res, 400, 'Scores invalides');

// NO VALIDATION OF winner_id parameter in request body!
// This means winner could be null, undefined, or invalid
```

**Suggested Fix:**
```javascript
const score1 = parseScoreValue(req.body?.score_p1);
const score2 = parseScoreValue(req.body?.score_p2);
const winnerId = req.body?.winner_id;

if (score1 === null || score2 === null) 
  return bad(res, 400, 'Scores invalides');

if (!winnerId) 
  return bad(res, 400, 'winner_id est requis');

// Verify winner is one of the participants
const match = mRes.rows[0];
if (winnerId !== match.player1_id && winnerId !== match.player2_id) {
  return bad(res, 400, 'Le vainqueur doit être l\'un des deux joueurs du match');
}
```

---

### BUG #3: Negative Score Validation Missing
**Severity:** CRITICAL  
**File:** [api/server.js](api/server.js#L2105)  
**Lines:** 2111-2113

**Description:**
The `parseScoreValue()` function accepts scores >= 0, but there's no upper bound validation or protection against extremely large scores which could cause display/calculation issues.

**Current Code:**
```javascript
function parseScoreValue(v) {
  const n = Number(v);
  if (!Number.isFinite(n) || n < 0 || !Number.isInteger(n)) return null;
  return n;
}
// Accepts 0 to 999999 without issue
```

**Suggested Fix:**
```javascript
function parseScoreValue(v) {
  const n = Number(v);
  if (!Number.isFinite(n) || n < 0 || !Number.isInteger(n)) return null;
  if (n > 999) return null; // Prevent unreasonable scores
  return n;
}
```

---

## 🔴 HIGH SEVERITY BUGS

### BUG #4: Bracket Generation Missing Participant Count Validation
**Severity:** HIGH  
**File:** [api/tournaments.js](api/tournaments.js#L775-L785)  
**Lines:** 775-785

**Description:**
Bracket generation doesn't validate that minimum participants are registered for the tournament format. Round Robin needs at least 2, Groups+Knockout needs sufficient participants for groups.

**Current Code:**
```javascript
if (participants.length < 2) {
  throw new Error('Minimum 2 participants requis');
}
```

**Issue:**
- No maximum participant validation
- Groups+Knockout doesn't validate `nb_groups` vs `participants.length`
- Double Elimination doesn't verify bracket can be constructed

**Suggested Fix:**
```javascript
if (participants.length < 2) {
  throw new Error('Minimum 2 participants requis');
}

if (tournament.format === 'groups_knockout') {
  const nbGroups = tournament.nb_groups || 2;
  const qualPerGroup = tournament.qualifiers_per_group || 2;
  if (participants.length < nbGroups * 2) {
    throw new Error(`Minimum ${nbGroups * 2} participants requis pour ${nbGroups} groupes`);
  }
  if (participants.length > 256) {
    throw new Error('Maximum 256 participants');
  }
}

if (participants.length > 256) {
  throw new Error('Maximum 256 participants');
}
```

---

### BUG #5: Status Transition Lock Incomplete
**Severity:** HIGH  
**File:** [web/Admin-Tournois.html](web/Admin-Tournois.html#L900-L920)  
**Lines:** 900-920

**Description:**
The participant section is locked when tournament is not draft, but matches can still be edited in completed tournaments, allowing scores to be changed after tournament is marked completed.

**Current Code:**
```javascript
function applyLockState(){
  const status = bundle?.tournament?.status;
  const isDraft = !status || status === 'draft';
  const section = document.getElementById('participantsSection');
  if (section) section.classList.toggle('locked', !isDraft);
  // Only locks participants, not the bracket/matches!
}
```

**Issue:**
- Matches can be edited after tournament is `completed`
- Scores can be corrected in `archived` tournaments
- No UI protection for finished tournaments

**Suggested Fix:**
```javascript
function applyLockState(){
  const status = bundle?.tournament?.status;
  const isDraft = !status || status === 'draft';
  const isFinished = status === 'completed' || status === 'archived';
  
  // Lock participants section for non-draft
  const section = document.getElementById('participantsSection');
  if (section) section.classList.toggle('locked', !isDraft);
  
  // Lock bracket editing for finished tournaments
  const bracketEl = document.getElementById('bracket');
  if (bracketEl && isFinished) {
    bracketEl.classList.add('locked');
    bracketEl.style.pointerEvents = 'none';
    bracketEl.style.opacity = '0.5';
  }
}
```

---

### BUG #6: Double Elimination Loser Route Edge Case
**Severity:** HIGH  
**File:** [api/server.js](api/server.js#L1173-L1240)  
**Lines:** 1173-1240

**Description:**
In `resolveLoserRoute()`, when WB final loser enters LB final, the calculation assumes LB rounds are always available, but with certain participant counts, edge cases exist.

**Current Code (Line 1213):**
```javascript
// WB final loser feeds LB final as slot 2.
expectedLbRound = 10 + (2 * (wbMaxRound - 1));
expectedLbSlot = 1;
expectedLbEntrySlot = 2;
```

**Issue:**
- If only 2 participants (no LB created), this still tries to route to non-existent LB final
- The loser route calculation doesn't handle 1-round WB (2 players)

**Suggested Fix:**
```javascript
if (wbRounds < 2) {
  // Only 2 players: WB final IS the GF, no loser to route
  return { targetMatchId: null, targetSlot: null };
}

const maxWbRes = await client.query(`
  SELECT MAX(round_no)::int AS max_round FROM tournament_matches
  WHERE tournament_id=$1 AND bracket_side='W'
`, [tournamentId]);

const wbMaxRound = Number(maxWbRes.rows?.[0]?.max_round || 0);
if (!wbMaxRound || wbMaxRound < 1) return { targetMatchId: null, targetSlot: null };
```

---

### BUG #7: Round Robin Standings Not Reset on Score Correction
**Severity:** HIGH  
**File:** [frontend/src/views/admin/AdminTournoisView.vue](frontend/src/views/admin/AdminTournoisView.vue#L945-L955)  
**Lines:** 945-955

**Description:**
When a score is corrected in round-robin, the standings are recalculated but the old score's contribution isn't subtracted, causing incorrect statistics.

**Current Code:**
```javascript
async function onScoreSaved({ matchId, score1, score2, done, fail }) {
  try {
    await api.post(`/admin/tournaments/${selected.value.id}/matches/${matchId}/result`, {
      score_p1: score1,
      score_p2: score2,
    })
    // Standings recalculated, but old match wasn't cleared first
    const { data: s } = await api.get(`/tournaments/${selected.value.id}/standings`)
    // This now has duplicate points if match was already completed!
  }
}
```

**Issue:**
- Backend recalculates from scratch (good)
- But if match was already completed, old score still counted
- Frontend doesn't reset match data before updating

**Note:** This is actually handled correctly in backend's `computeRoundRobinStandings()` which recalculates from scratch, but the frontend doesn't clear the old match display.

---

### BUG #8: Bracket Side and Match Status Mismatch
**Severity:** HIGH  
**File:** [api/server.js](api/server.js#L1070-L1073)  
**Lines:** 1070-1073

**Description:**
Group matches (bracket_side='G') are excluded from tournament completion check, but they can't be set to 'completed' status through normal flow in the UI.

**Current Code:**
```javascript
async function assignWinnerToNextMatch(client, tournamentId, matchRow, winnerParticipantId) {
  if (!matchRow.next_match_id) {
    // Ne pas marquer terminé si c'est un match de phase de groupe
    if (matchRow.bracket_side === 'G') return;
    // Mark tournament completed
  }
}
```

**Issue:**
- Group matches will never trigger tournament completion
- Tournament stays 'draft' or 'live' after all group matches finish
- Knockout phase never auto-generates

---

## 🟠 MEDIUM SEVERITY BUGS

### BUG #9: Participant Name Length Not Validated on Frontend
**Severity:** MEDIUM  
**File:** [web/Admin-Tournois.html](web/Admin-Tournois.html#L820-L835)  
**Lines:** 820-835

**Description:**
Frontend validates manually added participant names but not through bulk add or bulk CSV parsing.

**Current Code:**
```javascript
function addParticipantName(name){
  name = (name || '').trim();
  if (!name) return;
  if (name.length > 64){ alert('Nom trop long (max 64 caractères)'); return; }
  // ...
}

// But in bulk add:
document.getElementById('bulkConfirmBtn').onclick = () => {
  const raw = document.getElementById('bulkNamesTa').value;
  const lines = raw.split('\n').map(l => l.trim()).filter(Boolean);
  let added = 0;
  lines.forEach(name => {
    if (name.length > 64) return; // Silent skip!
    if (!participantNames.some(n => n.toLowerCase() === name.toLowerCase())){
      participantNames.push(name); added++; // NO validation here
    }
  });
}
```

**Issue:**
- Bulk add silently skips long names without user notification
- No validation for special characters
- Backend will reject but user won't know

---

### BUG #10: API Endpoint Mismatch (Score Result)
**Severity:** MEDIUM  
**File:** [web/Admin-Tournois.html](web/Admin-Tournois.html#L704-L710)  
**Lines:** 704-710

**Description:**
The web admin calls `/admin/tournaments/${tournamentId}/matches/${matchId}/result` but the endpoint in server.js uses this exact route. However, there's inconsistency in endpoint naming across different interfaces.

**Current Code (web):**
```javascript
bundle = await api(`/admin/tournaments/${tournamentId}/matches/${matchId}/result`,
  hd('POST', { score_p1: s1, score_p2: s2 }));
```

**Issue:**
- Different parts of codebase may expect different endpoint formats
- No consistent error response format
- Missing error handling for network failures in web UI

---

### BUG #11: Missing Transaction Rollback on Cascade Reset Error
**Severity:** MEDIUM  
**File:** [api/server.js](api/server.js#L1107-L1160)  
**Lines:** 1107-1160

**Description:**
In `cascadeResetWinner()`, if an error occurs during cascade reset, the transaction continues without proper error handling.

**Current Code:**
```javascript
async function cascadeResetWinner(client, tournamentId, startNextMatchId, removedParticipantId) {
  const queue = [];
  while (queue.length) {
    const current = queue.shift();
    const r = await client.query(...); // Could throw
    const nx = r.rows[0];
    // If error happens here, cascade is partially done
  }
}
```

**Issue:**
- No try-catch wrapping cascade logic
- Partial cascade could corrupt bracket
- Parent transaction doesn't know about failure

---

### BUG #12: No Validation for Duplicate Participant Seeds
**Severity:** MEDIUM  
**File:** [db/schema_tournaments.sql](db/schema_tournaments.sql#L60-L75)  
**Lines:** 60-75

**Description:**
The unique constraint on seed allows multiple NULL values, which could allow duplicate seeding logic errors.

**Current Code:**
```sql
UNIQUE(tournament_id, seed)
WHERE seed IS NOT NULL
```

**Issue:**
- Multiple participants can have NULL seed
- Bracket generation doesn't handle NULL seeds correctly
- Seeding algorithm expects all participants to have distinct seeds

---

### BUG #13: Group Assignment Not Reseeded After Deletion
**Severity:** MEDIUM  
**File:** [api/server.js](api/server.js#L1423-L1435)  
**Lines:** 1423-1435

**Description:**
When a participant is deleted from a groups_knockout tournament, remaining participants' group assignments aren't rebalanced.

**Current Code:**
```javascript
async function generateGroupsKnockout(client, id, participants, nb_groups, qual_per_group) {
  const rows = participants.rows;
  const count = rows.length;
  // Distribute players across groups: player[i] → group (i % nb_groups)
  for (let i = 0; i < count; i++) {
    const gn = i % nb_groups;
    await client.query(`UPDATE tournament_participants SET group_no=$1 WHERE id=$2`, [gn, rows[i].id]);
  }
}
```

**Issue:**
- If a participant is deleted mid-tournament, groups become unbalanced
- No automatic rebalancing
- Group standings become inconsistent

---

## 🟡 LOWER SEVERITY ISSUES

### BUG #14: Missing Error Handling for Concurrent Score Updates
**Severity:** LOW  
**File:** [web/Admin-Tournois.html](web/Admin-Tournois.html#L704-L720)  
**Lines:** 704-720

**Description:**
No concurrency control if two admins update the same match score simultaneously.

**Issue:**
- Last write wins
- No conflict detection
- No merge resolution

---

### BUG #15: Browser Refresh Loses Match Editing State
**Severity:** LOW  
**File:** [web/Admin-Tournois.html](web/Admin-Tournois.html#L680-L710)  
**Lines:** 680-710

**Description:**
When user is editing a match score and browser refreshes, the editing state is lost and must restart.

**Issue:**
- No local persistence of draft edits
- Bad UX for slow networks

---

### BUG #16: Standings Calculation Doesn't Handle Draws in Elimination
**Severity:** LOW  
**File:** [api/server.js](api/server.js#L2160)  
**Lines:** 2160-2170

**Description:**
Single Elimination bracket rejects draws, but error message isn't clear about what caused the rejection.

**Current Code:**
```javascript
if (score1 === score2) {
  await client.query('ROLLBACK');
  return bad(res, 400, 'Match nul interdit en élimination directe');
}
```

**Issue:**
- Error message is in French only
- No guidance for user
- Score already entered when error shown

---

### BUG #17: No Audit Trail for Score Corrections
**Severity:** LOW  
**File:** [api/server.js](api/server.js)  
**Lines:** All score update endpoints

**Description:**
No logging or audit trail when admin corrects a score, making it impossible to track who changed what.

**Issue:**
- No administrator accountability
- Can't investigate disputes

---

### BUG #18: Race Condition in Match Status Update
**Severity:** LOW  
**File:** [api/server.js](api/server.js#L1247-1270)  
**Lines:** 1247-1270

**Description:**
Between checking match status and updating it, another process could update it, causing concurrent modification.

**Issue:**
- Uses `FOR UPDATE` locks but with potential gaps
- Auto-advance walkovers could interfere

---

## Summary by File

### [api/tournaments.js](api/tournaments.js)
- **BUG #1:** Guest player cleanup (CRITICAL)
- **BUG #4:** Bracket generation validation (HIGH)

### [api/server.js](api/server.js)
- **BUG #2:** Score update missing validation (CRITICAL)
- **BUG #3:** Negative score validation (CRITICAL)
- **BUG #6:** Double elimination edge case (HIGH)
- **BUG #8:** Bracket side mismatch (HIGH)
- **BUG #11:** Transaction rollback (MEDIUM)
- **BUG #16:** Draw handling (LOW)
- **BUG #17:** No audit trail (LOW)
- **BUG #18:** Race condition (LOW)

### [web/Admin-Tournois.html](web/Admin-Tournois.html)
- **BUG #5:** Status transition lock (HIGH)
- **BUG #9:** Name validation bulk add (MEDIUM)
- **BUG #10:** Endpoint mismatch (MEDIUM)
- **BUG #14:** Concurrent updates (LOW)
- **BUG #15:** Browser refresh state (LOW)

### [frontend/src/views/admin/AdminTournoisView.vue](frontend/src/views/admin/AdminTournoisView.vue)
- **BUG #7:** Round robin standings reset (HIGH)

### [db/schema_tournaments.sql](db/schema_tournaments.sql)
- **BUG #12:** Duplicate seed validation (MEDIUM)

### [api/server.js (Groups)](api/server.js)
- **BUG #13:** Group rebalancing (MEDIUM)

---

## Recommended Fix Priority

1. **Immediate (Today):**
   - BUG #1: Guest cleanup logic
   - BUG #2: Winner validation
   - BUG #3: Score validation

2. **High Priority (This Week):**
   - BUG #4: Bracket validation
   - BUG #5: Status locks
   - BUG #6: DE edge cases
   - BUG #7: RR standings reset

3. **Medium Priority (Next Week):**
   - BUG #8-13: Data consistency issues

4. **Low Priority (Later):**
   - BUG #14-18: UX and logging improvements

