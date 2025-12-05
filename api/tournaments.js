/**
 * Module de gestion des tournois - VERSION CORRIGÉE
 * Fix principal: saveAndLinkMatches utilise une Map au lieu de indexOf()
 */

// Fonctions de génération simplifiées
function generateSingleEliminationBracket(participants) {
  const n = participants.length;
  let size = 2;
  while (size < n) size *= 2;

  const matches = [];
  const totalRounds = Math.log2(size);

  // Générer tous les matchs
  for (let r = 1; r <= totalRounds; r++) {
    const matchCount = size / Math.pow(2, r);
    for (let m = 1; m <= matchCount; m++) {
      matches.push({
        round: r,
        match_number: m,
        bracket_type: 'winners',
        player1_id: null,
        player2_id: null,
        player1_from: 'seed',
        player2_from: 'seed',
        status: 'pending'
      });
    }
  }

  // Placer les joueurs au Round 1
  const round1Matches = matches.filter(m => m.round === 1);
  round1Matches.forEach((match, i) => {
    const p1 = participants[i * 2] || null;
    const p2 = participants[i * 2 + 1] || null;

    match.player1_id = p1?.player_id || null;
    match.player2_id = p2?.player_id || null;

    // BYE automatique
    if (p1 && !p2) {
      match.winner_id = p1.player_id;
      match.status = 'completed';
    } else if (!p1 && p2) {
      match.winner_id = p2.player_id;
      match.status = 'completed';
    }
  });

  return matches;
}

function generateDoubleEliminationBracket(participants) {
  const matches = generateSingleEliminationBracket(participants);

  const size = Math.pow(2, Math.ceil(Math.log2(participants.length)));
  const wbRounds = Math.log2(size);
  const lbRounds = (wbRounds - 1) * 2;

  let matchesInRound = size / 4;

  for (let r = 1; r <= lbRounds; r++) {
    for (let m = 1; m <= matchesInRound; m++) {
      matches.push({
        round: r,
        match_number: m,
        bracket_type: 'losers',
        player1_id: null,
        player2_id: null,
        player1_from: r === 1 ? 'loser' : (r % 2 === 0 ? 'loser' : 'winner'),
        player2_from: r === 1 ? 'loser' : (r % 2 === 0 ? 'winner' : 'winner'),
        status: 'pending'
      });
    }
    if (r % 2 === 0) matchesInRound /= 2;
  }

  // Grande Finale
  matches.push({
    round: 1,
    match_number: 1,
    bracket_type: 'finals',
    player1_id: null,
    player2_id: null,
    player1_from: 'winner',
    player2_from: 'winner',
    status: 'pending'
  });

  return matches;
}

function generateRoundRobinBracket(participants) {
  const matches = [];
  const n = participants.length;
  const numPlayers = n % 2 === 0 ? n : n + 1;
  const players = participants.map(p => p.player_id);
  if (n % 2 !== 0) players.push(null);

  const rounds = numPlayers - 1;
  const matchesPerRound = numPlayers / 2;

  const shiftedPlayers = [...players];
  const fixedPlayer = shiftedPlayers.shift();

  for (let r = 1; r <= rounds; r++) {
    let matchNum = 1;
    for (let m = 1; m <= matchesPerRound; m++) {
      const p1 = m === 1 ? fixedPlayer : shiftedPlayers[m - 2];
      const p2 = shiftedPlayers[numPlayers - m - 1];

      if (p1 && p2) {
        matches.push({
          round: r,
          match_number: matchNum++,
          bracket_type: 'round_robin',
          player1_id: p1,
          player2_id: p2,
          player1_from: 'seed',
          player2_from: 'seed',
          status: 'pending'
        });
      }
    }
    shiftedPlayers.unshift(shiftedPlayers.pop());
  }

  return matches;
}

/**
 * FONCTION CLÉ CORRIGÉE: Sauvegarde et lie les matchs
 * Utilise une Map au lieu de indexOf() pour éviter les problèmes
 */
async function saveAndLinkMatches(client, tournamentId, matches, format) {
  console.log(`🔗 Sauvegarde et liaison de ${matches.length} matchs...`);

  // 1. Sauvegarder tous les matchs et créer la Map
  const savedMatchesMap = new Map();

  for (const match of matches) {
    const res = await client.query(`
      INSERT INTO tournament_matches
      (tournament_id, round, match_number, bracket_type, player1_id, player2_id,
       player1_from, player2_from, status, winner_id)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING id`,
      [tournamentId, match.round, match.match_number, match.bracket_type,
       match.player1_id, match.player2_id, match.player1_from, match.player2_from,
       match.status, match.winner_id || null]
    );

    const key = `${match.bracket_type}_${match.round}_${match.match_number}`;
    savedMatchesMap.set(key, res.rows[0].id);
  }

  console.log(`✅ ${savedMatchesMap.size} matchs sauvegardés`);

  // 2. Calculer et appliquer les liens
  const getID = (type, r, m) => savedMatchesMap.get(`${type}_${r}_${m}`);
  let linksCreated = 0;

  for (const match of matches) {
    const currentId = getID(match.bracket_type, match.round, match.match_number);
    let nextWinId = null, nextWinSlot = null;
    let nextLoseId = null, nextLoseSlot = null;

    // WINNERS BRACKET
    if (match.bracket_type === 'winners') {
      // Gagnant -> Round suivant
      const nextR = match.round + 1;
      const nextM = Math.ceil(match.match_number / 2);
      const slot = match.match_number % 2 === 1 ? 'player1' : 'player2';

      if (getID('winners', nextR, nextM)) {
        nextWinId = getID('winners', nextR, nextM);
        nextWinSlot = slot;
        console.log(`  WB R${match.round} M${match.match_number} → WB R${nextR} M${nextM} [${slot}]`);
      } else if (format === 'double_elimination' && getID('finals', 1, 1)) {
        nextWinId = getID('finals', 1, 1);
        nextWinSlot = 'player1';
        console.log(`  WB R${match.round} M${match.match_number} → FINALS [player1]`);
      }

      // Perdant -> Loser Bracket
      if (format === 'double_elimination') {
        let lbRound, lbMatch, lbSlot;

        if (match.round === 1) {
          lbRound = 1;
          lbMatch = Math.ceil(match.match_number / 2);
          lbSlot = match.match_number % 2 === 1 ? 'player1' : 'player2';
        } else {
          lbRound = (match.round - 1) * 2;
          lbMatch = match.match_number;
          lbSlot = 'player2';
        }

        if (getID('losers', lbRound, lbMatch)) {
          nextLoseId = getID('losers', lbRound, lbMatch);
          nextLoseSlot = lbSlot;
          console.log(`  WB R${match.round} M${match.match_number} LOSER → LB R${lbRound} M${lbMatch} [${lbSlot}]`);
        }
      }
    }

    // LOSERS BRACKET
    else if (match.bracket_type === 'losers') {
      const nextR = match.round + 1;
      let nextM, slot;

      if (match.round % 2 === 1) {
        nextM = match.match_number;
        slot = 'player2';
      } else {
        nextM = Math.ceil(match.match_number / 2);
        slot = match.match_number % 2 === 1 ? 'player1' : 'player2';
      }

      if (getID('losers', nextR, nextM)) {
        nextWinId = getID('losers', nextR, nextM);
        nextWinSlot = slot;
        console.log(`  LB R${match.round} M${match.match_number} → LB R${nextR} M${nextM} [${slot}]`);
      } else if (getID('finals', 1, 1)) {
        nextWinId = getID('finals', 1, 1);
        nextWinSlot = 'player2';
        console.log(`  LB R${match.round} M${match.match_number} → FINALS [player2]`);
      }
    }

    // Appliquer les liens
    if (nextWinId || nextLoseId) {
      await client.query(`
        UPDATE tournament_matches
        SET next_match_winner_id=$1, next_match_winner_slot=$2,
            next_match_loser_id=$3, next_match_loser_slot=$4
        WHERE id=$5`,
        [nextWinId, nextWinSlot, nextLoseId, nextLoseSlot, currentId]
      );
      linksCreated++;
    }
  }

  console.log(`✅ ${linksCreated} liens créés`);
}

/**
 * Configure les routes API pour les tournois
 */
function setupTournamentRoutes(app, pool, auth, io) {

  // GET /tournaments - Liste
  app.get('/tournaments', auth, async (req, res) => {
    try {
      const { status, format, limit = 50, offset = 0 } = req.query;

      let query = `
        SELECT
          t.*,
          u.email as creator_email,
          p1.name as winner_name,
          p2.name as runner_up_name,
          p3.name as third_place_name,
          (SELECT COUNT(*) FROM tournament_participants WHERE tournament_id = t.id) as participant_count
        FROM tournaments t
        LEFT JOIN users u ON t.created_by = u.id
        LEFT JOIN players p1 ON t.winner_id = p1.player_id
        LEFT JOIN players p2 ON t.runner_up_id = p2.player_id
        LEFT JOIN players p3 ON t.third_place_id = p3.player_id
        WHERE 1=1
      `;

      const params = [];
      if (status) {
        params.push(status);
        query += ` AND t.status = $${params.length}`;
      }
      if (format) {
        params.push(format);
        query += ` AND t.format = $${params.length}`;
      }

      params.push(limit, offset);
      query += ` ORDER BY t.created_at DESC LIMIT $${params.length - 1} OFFSET $${params.length}`;

      const result = await pool.query(query, params);
      res.json({ tournaments: result.rows });
    } catch (error) {
      console.error('Error loading tournaments:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  });

  // GET /tournaments/:id - Détails
  app.get('/tournaments/:id', auth, async (req, res) => {
    try {
      const { id } = req.params;

      const tResult = await pool.query(`
        SELECT t.*, u.email as creator_email
        FROM tournaments t
        LEFT JOIN users u ON t.created_by = u.id
        WHERE t.id = $1
      `, [id]);

      if (tResult.rows.length === 0) {
        return res.status(404).json({ error: 'Tournoi non trouvé' });
      }

      const pResult = await pool.query(`
        SELECT tp.*, p.name as player_name, p.profile_pic_url
        FROM tournament_participants tp
        JOIN players p ON tp.player_id = p.player_id
        WHERE tp.tournament_id = $1
        ORDER BY tp.seed NULLS LAST
      `, [id]);

      const mResult = await pool.query(`
        SELECT
          tm.*,
          p1.name as player1_name,
          p2.name as player2_name
        FROM tournament_matches tm
        LEFT JOIN players p1 ON tm.player1_id = p1.player_id
        LEFT JOIN players p2 ON tm.player2_id = p2.player_id
        WHERE tm.tournament_id = $1
        ORDER BY
          CASE tm.bracket_type
            WHEN 'winners' THEN 1
            WHEN 'losers' THEN 2
            WHEN 'finals' THEN 3
            WHEN 'third_place' THEN 4
            ELSE 5
          END,
          tm.round,
          tm.match_number
      `, [id]);

      res.json({
        tournament: tResult.rows[0],
        participants: pResult.rows,
        matches: mResult.rows
      });
    } catch (error) {
      console.error('Error loading tournament:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  });

  // POST /tournaments - Créer
  app.post('/tournaments', auth, async (req, res) => {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Accès refusé' });
    }

    try {
      const { name, description, format, status, max_participants, third_place_match } = req.body;

      const result = await pool.query(`
        INSERT INTO tournaments
        (name, description, format, status, max_participants, third_place_match, created_by)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING *
      `, [name, description, format, status || 'draft', max_participants, third_place_match || false, req.user.user_id]);

      res.status(201).json({ tournament: result.rows[0] });
    } catch (error) {
      console.error('Error creating tournament:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  });

  // PUT /tournaments/:id - Modifier
  app.put('/tournaments/:id', auth, async (req, res) => {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Accès refusé' });
    }

    try {
      const { id } = req.params;
      const { name, description, format, status, max_participants, third_place_match } = req.body;

      const result = await pool.query(`
        UPDATE tournaments
        SET name = $1, description = $2, format = $3, status = $4,
            max_participants = $5, third_place_match = $6
        WHERE id = $7
        RETURNING *
      `, [name, description, format, status, max_participants, third_place_match, id]);

      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'Tournoi non trouvé' });
      }

      res.json({ tournament: result.rows[0] });
    } catch (error) {
      console.error('Error updating tournament:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  });

  // POST /tournaments/:id/participants/manual - Ajout manuel CORRIGÉ
  app.post('/tournaments/:id/participants/manual', auth, async (req, res) => {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Admin only' });
    }

    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      const { id } = req.params;
      const { player_name } = req.body;

      if (!player_name || !player_name.trim()) {
        throw new Error("Nom requis");
      }

      // Créer le joueur GUEST avec ID unique
      const guestId = `guest_${Date.now()}_${Math.floor(Math.random()*1000)}`;

      await client.query(
        `INSERT INTO players (player_id, name, role) VALUES ($1, $2, 'GUEST')`,
        [guestId, player_name.trim()]
      );

      // Seed automatique (dernier)
      const seedRes = await client.query(
        'SELECT COALESCE(MAX(seed), 0) as s FROM tournament_participants WHERE tournament_id=$1',
        [id]
      );
      const nextSeed = seedRes.rows[0].s + 1;

      await client.query(
        `INSERT INTO tournament_participants (tournament_id, player_id, seed) VALUES ($1, $2, $3)`,
        [id, guestId, nextSeed]
      );

      await client.query('COMMIT');

      io.to(`tournament:${id}`).emit('participant:added', { player_id: guestId });

      res.json({
        player_id: guestId,
        name: player_name.trim()
      });
    } catch (e) {
      await client.query('ROLLBACK');
      console.error('Erreur ajout manuel:', e);
      res.status(500).json({ error: e.message });
    } finally {
      client.release();
    }
  });

  // POST /tournaments/:id/generate-bracket - CORRIGÉ
  app.post('/tournaments/:id/generate-bracket', auth, async (req, res) => {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Accès refusé' });
    }

    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      const { id } = req.params;

      console.log(`🎯 Génération du bracket pour le tournoi ${id}...`);

      // Récupérer le tournoi
      const tRes = await client.query('SELECT * FROM tournaments WHERE id = $1', [id]);
      const tournament = tRes.rows[0];

      if (!tournament) {
        throw new Error('Tournoi non trouvé');
      }

      // Récupérer les participants
      const pRes = await client.query(
        'SELECT * FROM tournament_participants WHERE tournament_id = $1 ORDER BY seed',
        [id]
      );
      const participants = pRes.rows;

      if (participants.length < 2) {
        throw new Error('Minimum 2 participants requis');
      }

      console.log(`👥 ${participants.length} participants`);

      // Nettoyer les anciens matchs
      await client.query('DELETE FROM tournament_matches WHERE tournament_id = $1', [id]);

      // Générer la structure
      let matches = [];
      if (tournament.format === 'single_elimination') {
        matches = generateSingleEliminationBracket(participants);
        console.log(`📊 Single Elimination: ${matches.length} matchs`);
      } else if (tournament.format === 'double_elimination') {
        matches = generateDoubleEliminationBracket(participants);
        console.log(`📊 Double Elimination: ${matches.length} matchs`);
      } else if (tournament.format === 'round_robin') {
        matches = generateRoundRobinBracket(participants);
        console.log(`📊 Round Robin: ${matches.length} matchs`);
      }

      // SAUVEGARDER ET LIER (fonction corrigée)
      await saveAndLinkMatches(client, id, matches, tournament.format);

      // Mettre à jour le statut
      await client.query(
        "UPDATE tournaments SET status = 'in_progress', total_matches = $1 WHERE id = $2",
        [matches.length, id]
      );

      await client.query('COMMIT');

      io.to(`tournament:${id}`).emit('bracket:generated');

      console.log(`✅ Bracket généré avec succès`);
      res.json({ ok: true, matches_count: matches.length });

    } catch (error) {
      await client.query('ROLLBACK');
      console.error('❌ Erreur bracket:', error);
      res.status(500).json({ error: error.message });
    } finally {
      client.release();
    }
  });

  // PUT /tournaments/:tid/matches/:mid - Mise à jour match CORRIGÉE
  app.put('/tournaments/:tournamentId/matches/:matchId', auth, async (req, res) => {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Admin only' });
    }

    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      const { tournamentId, matchId } = req.params;
      const { player1_score, player2_score, winner_id } = req.body;

      console.log(`⚽ Mise à jour match ${matchId}...`);

      // Récupérer le match
      const mRes = await client.query(
        'SELECT * FROM tournament_matches WHERE id = $1 AND tournament_id = $2',
        [matchId, tournamentId]
      );

      if (mRes.rows.length === 0) {
        throw new Error('Match non trouvé');
      }

      const match = mRes.rows[0];
      const loserId = (match.player1_id === winner_id) ? match.player2_id : match.player1_id;

      // 1. Mettre à jour le score
      await client.query(`
        UPDATE tournament_matches
        SET player1_score=$1, player2_score=$2, winner_id=$3,
            status='completed', completed_at=NOW()
        WHERE id=$4`,
        [player1_score, player2_score, winner_id, matchId]
      );

      console.log(`  Winner: ${winner_id}, Loser: ${loserId}`);

      // 2. AVANCER LE GAGNANT
      if (match.next_match_winner_id) {
        const field = match.next_match_winner_slot === 'player1' ? 'player1_id' : 'player2_id';
        await client.query(
          `UPDATE tournament_matches SET ${field}=$1 WHERE id=$2`,
          [winner_id, match.next_match_winner_id]
        );
        console.log(`  ✅ Gagnant → Match ${match.next_match_winner_id} [${field}]`);
      }

      // 3. FAIRE TOMBER LE PERDANT (DOUBLE ELIM)
      if (match.next_match_loser_id && match.bracket_type !== 'round_robin') {
        const field = match.next_match_loser_slot === 'player1' ? 'player1_id' : 'player2_id';
        await client.query(
          `UPDATE tournament_matches SET ${field}=$1 WHERE id=$2`,
          [loserId, match.next_match_loser_id]
        );
        console.log(`  ✅ Perdant → Match ${match.next_match_loser_id} [${field}]`);
      }

      // 4. Update stats
      await client.query(`
        UPDATE tournament_participants
        SET wins = wins + 1,
            points_for = points_for + $1,
            points_against = points_against + $2
        WHERE tournament_id = $3 AND player_id = $4
      `, [
        winner_id === match.player1_id ? player1_score : player2_score,
        winner_id === match.player1_id ? player2_score : player1_score,
        tournamentId,
        winner_id
      ]);

      await client.query(`
        UPDATE tournament_participants
        SET losses = losses + 1,
            points_for = points_for + $1,
            points_against = points_against + $2
        WHERE tournament_id = $3 AND player_id = $4
      `, [
        loserId === match.player1_id ? player1_score : player2_score,
        loserId === match.player1_id ? player2_score : player1_score,
        tournamentId,
        loserId
      ]);

      // 5. Incrémenter completed_matches
      await client.query(
        'UPDATE tournaments SET completed_matches = completed_matches + 1 WHERE id = $1',
        [tournamentId]
      );

      await client.query('COMMIT');

      io.to(`tournament:${tournamentId}`).emit('match:updated', { matchId });

      console.log(`✅ Match ${matchId} mis à jour`);
      res.json({ ok: true });

    } catch (e) {
      await client.query('ROLLBACK');
      console.error('❌ Erreur update match:', e);
      res.status(500).json({ error: e.message });
    } finally {
      client.release();
    }
  });
}

module.exports = { setupTournamentRoutes };
