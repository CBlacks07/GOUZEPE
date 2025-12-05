/**
 * Module de gestion des tournois
 * Compatible avec Challonge et start.gg
 *
 * Fonctionnalités :
 * - Création et gestion de tournois
 * - Génération automatique de brackets (single/double elimination, round robin)
 * - Gestion des participants
 * - Enregistrement des résultats
 * - Progression automatique dans les brackets
 */

/**
 * Génère un bracket de single elimination
 * @param {Array} participants - Liste des participants avec leur seed
 * @returns {Array} Matchs du bracket
 */
function generateSingleEliminationBracket(participants) {
  const n = participants.length;

  // Arrondir au prochain power of 2
  const bracketSize = Math.pow(2, Math.ceil(Math.log2(n)));

  // Trier par seed
  const seededPlayers = [...participants].sort((a, b) => (a.seed || 999) - (b.seed || 999));

  // Standard bracket seeding (1 vs last, 2 vs second-to-last, etc.)
  const matches = [];
  let matchNumber = 1;
  const round = 1;

  for (let i = 0; i < bracketSize / 2; i++) {
    const player1 = seededPlayers[i] || null;
    const player2 = seededPlayers[n - 1 - i] || null;

    matches.push({
      round,
      match_number: matchNumber++,
      bracket_type: 'winners',
      player1_id: player1?.player_id || null,
      player2_id: player2?.player_id || null,
      player1_from: 'seed',
      player2_from: 'seed',
      status: (player1 && player2) ? 'pending' : (player1 || player2) ? 'walkover' : 'pending',
      winner_id: (!player2 && player1) ? player1.player_id : (!player1 && player2) ? player2.player_id : null
    });
  }

  // Générer les rounds suivants (vides pour l'instant)
  const totalRounds = Math.ceil(Math.log2(bracketSize));
  for (let r = 2; r <= totalRounds; r++) {
    const matchesInRound = Math.pow(2, totalRounds - r);
    for (let m = 1; m <= matchesInRound; m++) {
      matches.push({
        round: r,
        match_number: m,
        bracket_type: 'winners',
        player1_id: null,
        player2_id: null,
        player1_from: 'winner',
        player2_from: 'winner',
        status: 'pending'
      });
    }
  }

  // Lier les matchs entre eux
  linkMatches(matches, 'single');

  return matches;
}

/**
 * Génère un bracket de double elimination
 * @param {Array} participants - Liste des participants
 * @returns {Array} Matchs du bracket (winners + losers + finals)
 */
function generateDoubleEliminationBracket(participants) {
  const n = participants.length;
  const bracketSize = Math.pow(2, Math.ceil(Math.log2(n)));
  const seededPlayers = [...participants].sort((a, b) => (a.seed || 999) - (b.seed || 999));

  const matches = [];

  // Winner's Bracket (identique à single elimination)
  const winnersRounds = Math.ceil(Math.log2(bracketSize));
  let matchNumber = 1;

  // Round 1 du Winner's Bracket
  for (let i = 0; i < bracketSize / 2; i++) {
    const player1 = seededPlayers[i] || null;
    const player2 = seededPlayers[n - 1 - i] || null;

    matches.push({
      round: 1,
      match_number: matchNumber++,
      bracket_type: 'winners',
      player1_id: player1?.player_id || null,
      player2_id: player2?.player_id || null,
      player1_from: 'seed',
      player2_from: 'seed',
      status: (player1 && player2) ? 'pending' : (player1 || player2) ? 'walkover' : 'pending',
      winner_id: (!player2 && player1) ? player1.player_id : (!player1 && player2) ? player2.player_id : null
    });
  }

  // Rounds suivants du Winner's Bracket
  for (let r = 2; r <= winnersRounds; r++) {
    const matchesInRound = Math.pow(2, winnersRounds - r);
    for (let m = 1; m <= matchesInRound; m++) {
      matches.push({
        round: r,
        match_number: m,
        bracket_type: 'winners',
        player1_id: null,
        player2_id: null,
        player1_from: 'winner',
        player2_from: 'winner',
        status: 'pending'
      });
    }
  }

  // Loser's Bracket
  const losersRounds = (winnersRounds - 1) * 2;
  for (let r = 1; r <= losersRounds; r++) {
    // Le nombre de matchs dans le loser's bracket est plus complexe
    const matchesInRound = r === 1 ? bracketSize / 4 : Math.pow(2, Math.floor((losersRounds - r) / 2));

    for (let m = 1; m <= matchesInRound; m++) {
      // Déterminer d'où viennent les joueurs
      let player1From, player2From;

      if (r === 1) {
        // Round 1 du LB: les deux joueurs sont des perdants du WB R1
        player1From = 'loser';
        player2From = 'loser';
      } else if (r % 2 === 0) {
        // Rounds PAIRS: gagnant du LB précédent vs perdant du WB
        player1From = 'winner';
        player2From = 'loser';
      } else {
        // Rounds IMPAIRS (après R1): gagnant du LB précédent vs gagnant du LB précédent
        player1From = 'winner';
        player2From = 'winner';
      }

      matches.push({
        round: r,
        match_number: m,
        bracket_type: 'losers',
        player1_id: null,
        player2_id: null,
        player1_from: player1From,
        player2_from: player2From,
        status: 'pending'
      });
    }
  }

  // Grand Finals
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

  linkMatches(matches, 'double');

  return matches;
}

/**
 * Génère un bracket de round robin
 * @param {Array} participants - Liste des participants
 * @returns {Array} Matchs du bracket
 */
function generateRoundRobinBracket(participants) {
  const n = participants.length;
  const matches = [];
  let matchNumber = 1;

  // Générer tous les matchs possibles
  for (let i = 0; i < n; i++) {
    for (let j = i + 1; j < n; j++) {
      matches.push({
        round: 1,
        match_number: matchNumber++,
        bracket_type: 'round_robin',
        player1_id: participants[i].player_id,
        player2_id: participants[j].player_id,
        player1_from: 'seed',
        player2_from: 'seed',
        status: 'pending'
      });
    }
  }

  return matches;
}

/**
 * Lie les matchs entre eux pour la progression automatique
 * @param {Array} matches - Matchs à lier
 * @param {string} type - Type de bracket ('single' ou 'double')
 */
function linkMatches(matches, type) {
  if (type === 'single') {
    const winnerMatches = matches.filter(m => m.bracket_type === 'winners');

    for (let i = 0; i < winnerMatches.length; i++) {
      const match = winnerMatches[i];
      const nextRound = match.round + 1;
      const nextMatchNumber = Math.ceil(match.match_number / 2);
      const slotInNextMatch = match.match_number % 2 === 1 ? 'player1' : 'player2';

      const nextMatch = winnerMatches.find(
        m => m.round === nextRound && m.match_number === nextMatchNumber
      );

      if (nextMatch) {
        match.next_match_winner_id = winnerMatches.indexOf(nextMatch);
        match.next_match_winner_slot = slotInNextMatch;
      }
    }
  } else if (type === 'double') {
    const winnerMatches = matches.filter(m => m.bracket_type === 'winners');
    const loserMatches = matches.filter(m => m.bracket_type === 'losers');
    const finalsMatch = matches.find(m => m.bracket_type === 'finals');

    // 1. Lier le Winner's Bracket (les gagnants progressent)
    for (let i = 0; i < winnerMatches.length; i++) {
      const match = winnerMatches[i];
      const nextRound = match.round + 1;
      const nextMatchNumber = Math.ceil(match.match_number / 2);
      const slotInNextMatch = match.match_number % 2 === 1 ? 'player1' : 'player2';

      // Prochain match pour le gagnant dans le winner's bracket
      const nextMatch = winnerMatches.find(
        m => m.round === nextRound && m.match_number === nextMatchNumber
      );

      if (nextMatch) {
        match.next_match_winner_id = winnerMatches.indexOf(nextMatch);
        match.next_match_winner_slot = slotInNextMatch;
      } else if (finalsMatch) {
        // Le dernier match du winner's bracket va aux finales
        match.next_match_winner_id = matches.indexOf(finalsMatch);
        match.next_match_winner_slot = 'player1'; // Champion du winner's bracket en player1
      }
    }

    // 2. Lier le Loser's Bracket (structure complexe)
    // Les perdants du winner's bracket tombent dans le loser's bracket
    // Pattern CORRECT: WB R1 → LB R1, WB R2 → LB R2, WB R3 → LB R4
    for (let i = 0; i < winnerMatches.length; i++) {
      const match = winnerMatches[i];

      // FORMULE CORRECTE pour calculer dans quel round du loser's bracket le perdant va tomber
      // WB R1 → LB R1, WB R2 → LB R2, WB R3 → LB R4, etc.
      // Formule: round 1 → 1, sinon → 2*(round-1)
      const loserRound = match.round === 1 ? 1 : (match.round - 1) * 2;

      if (match.round === 1) {
        // WB R1: Les perdants vont au LB R1 - 2 perdants par match du LB
        // WB M1 et M2 → LB M1, WB M3 et M4 → LB M2, etc.
        const loserMatchNumber = Math.ceil(match.match_number / 2);
        const loserSlot = match.match_number % 2 === 1 ? 'player1' : 'player2';

        const loserMatch = loserMatches.find(
          m => m.round === loserRound && m.match_number === loserMatchNumber
        );

        if (loserMatch) {
          const loserIndex = matches.indexOf(loserMatch);
          console.log(`WB R${match.round} M${match.match_number} → LB R${loserRound} M${loserMatchNumber} (index: ${loserIndex})`);
          match.next_match_loser_id = loserIndex;
          match.next_match_loser_slot = loserSlot;
        } else {
          console.log(`⚠️ WB R${match.round} M${match.match_number} → Pas de loser match trouvé pour LB R${loserRound} M${loserMatchNumber}`);
        }
      } else {
        // WB R2+ : Les perdants vont aux rounds PAIRS du LB en player2
        // WB R2 M1 → LB R2 M1 [p2], WB R2 M2 → LB R2 M2 [p2]
        const loserMatchNumber = match.match_number;

        const loserMatch = loserMatches.find(
          m => m.round === loserRound && m.match_number === loserMatchNumber
        );

        if (loserMatch) {
          const loserIndex = matches.indexOf(loserMatch);
          console.log(`WB R${match.round} M${match.match_number} → LB R${loserRound} M${loserMatchNumber} [p2] (index: ${loserIndex})`);
          match.next_match_loser_id = loserIndex;
          match.next_match_loser_slot = 'player2'; // Les perdants du WB entrent toujours en player2 des rounds pairs
        } else {
          console.log(`⚠️ WB R${match.round} M${match.match_number} → Pas de loser match trouvé pour LB R${loserRound} M${loserMatchNumber}`);
        }
      }
    }

    // 3. Lier les matchs du Loser's Bracket entre eux
    for (let i = 0; i < loserMatches.length; i++) {
      const match = loserMatches[i];
      const nextRound = match.round + 1;

      // Dans le loser's bracket:
      // - Rounds impairs → rounds pairs: même nombre de match
      // - Rounds pairs → rounds impairs: division par 2
      let nextMatchNumber;
      let slotInNextMatch;

      if (match.round % 2 === 1) {
        // Round impair → round pair (même match number)
        nextMatchNumber = match.match_number;
        slotInNextMatch = 'player1'; // Les gagnants des rounds impairs vont en player1
      } else {
        // Round pair → round impair (division)
        nextMatchNumber = Math.ceil(match.match_number / 2);
        slotInNextMatch = match.match_number % 2 === 1 ? 'player1' : 'player2';
      }

      const nextMatch = loserMatches.find(
        m => m.round === nextRound && m.match_number === nextMatchNumber
      );

      if (nextMatch) {
        match.next_match_winner_id = matches.indexOf(nextMatch);
        match.next_match_winner_slot = slotInNextMatch;
      } else if (finalsMatch) {
        // Le dernier match du loser's bracket va aux finales
        match.next_match_winner_id = matches.indexOf(finalsMatch);
        match.next_match_winner_slot = 'player2'; // Champion du loser's bracket en player2
      }
    }
  }
}

/**
 * Configure les routes API pour les tournois
 * @param {Express.Application} app - Application Express
 * @param {Pool} pool - Pool de connexions PostgreSQL
 * @param {Function} auth - Middleware d'authentification
 * @param {SocketIO.Server} io - Serveur Socket.IO
 */
function setupTournamentRoutes(app, pool, auth, io) {

  // ===== ROUTES PUBLIQUES =====

  /**
   * GET /tournaments
   * Liste tous les tournois (avec filtres optionnels)
   */
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
      let paramCount = 1;

      if (status) {
        query += ` AND t.status = $${paramCount++}`;
        params.push(status);
      }

      if (format) {
        query += ` AND t.format = $${paramCount++}`;
        params.push(format);
      }

      query += ` ORDER BY t.created_at DESC LIMIT $${paramCount++} OFFSET $${paramCount++}`;
      params.push(limit, offset);

      const result = await pool.query(query, params);

      res.json({
        tournaments: result.rows,
        total: result.rowCount
      });
    } catch (error) {
      console.error('Erreur lors de la récupération des tournois:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  });

  /**
   * GET /tournaments/:id
   * Détails d'un tournoi spécifique
   */
  app.get('/tournaments/:id', auth, async (req, res) => {
    try {
      const { id } = req.params;

      // Récupérer le tournoi
      const tournamentResult = await pool.query(`
        SELECT
          t.*,
          u.email as creator_email,
          p1.name as winner_name,
          p2.name as runner_up_name,
          p3.name as third_place_name
        FROM tournaments t
        LEFT JOIN users u ON t.created_by = u.id
        LEFT JOIN players p1 ON t.winner_id = p1.player_id
        LEFT JOIN players p2 ON t.runner_up_id = p2.player_id
        LEFT JOIN players p3 ON t.third_place_id = p3.player_id
        WHERE t.id = $1
      `, [id]);

      if (tournamentResult.rows.length === 0) {
        return res.status(404).json({ error: 'Tournoi non trouvé' });
      }

      const tournament = tournamentResult.rows[0];

      // Récupérer les participants
      const participantsResult = await pool.query(`
        SELECT
          tp.*,
          p.name as player_name,
          p.profile_pic_url
        FROM tournament_participants tp
        JOIN players p ON tp.player_id = p.player_id
        WHERE tp.tournament_id = $1
        ORDER BY tp.seed NULLS LAST, tp.registered_at
      `, [id]);

      // Récupérer les matchs
      const matchesResult = await pool.query(`
        SELECT
          tm.*,
          p1.name as player1_name,
          p2.name as player2_name,
          pw.name as winner_name
        FROM tournament_matches tm
        LEFT JOIN players p1 ON tm.player1_id = p1.player_id
        LEFT JOIN players p2 ON tm.player2_id = p2.player_id
        LEFT JOIN players pw ON tm.winner_id = pw.player_id
        WHERE tm.tournament_id = $1
        ORDER BY tm.bracket_type, tm.round, tm.match_number
      `, [id]);

      res.json({
        tournament,
        participants: participantsResult.rows,
        matches: matchesResult.rows
      });
    } catch (error) {
      console.error('Erreur lors de la récupération du tournoi:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  });

  // ===== ROUTES ADMIN =====

  /**
   * POST /tournaments
   * Créer un nouveau tournoi (admin uniquement)
   */
  app.post('/tournaments', auth, async (req, res) => {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Accès refusé' });
    }

    try {
      const {
        name,
        description,
        format,
        max_participants,
        third_place_match,
        registration_start,
        registration_end,
        start_date
      } = req.body;

      if (!name || !format) {
        return res.status(400).json({ error: 'Nom et format requis' });
      }

      if (!['single_elimination', 'double_elimination', 'round_robin'].includes(format)) {
        return res.status(400).json({ error: 'Format invalide' });
      }

      const result = await pool.query(`
        INSERT INTO tournaments (
          name, description, format, status,
          max_participants, third_place_match,
          registration_start, registration_end, start_date,
          created_by
        ) VALUES ($1, $2, $3, 'draft', $4, $5, $6, $7, $8, $9)
        RETURNING *
      `, [
        name,
        description || null,
        format,
        max_participants || null,
        third_place_match || false,
        registration_start || null,
        registration_end || null,
        start_date || null,
        req.user.uid
      ]);

      const tournament = result.rows[0];

      // Émettre un événement Socket.IO
      io.emit('tournament:created', { tournament });

      res.status(201).json({ tournament });
    } catch (error) {
      console.error('Erreur lors de la création du tournoi:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  });

  /**
   * PUT /tournaments/:id
   * Mettre à jour un tournoi (admin uniquement)
   */
  app.put('/tournaments/:id', auth, async (req, res) => {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Accès refusé' });
    }

    try {
      const { id } = req.params;
      const {
        name,
        description,
        status,
        max_participants,
        third_place_match,
        registration_start,
        registration_end,
        start_date
      } = req.body;

      // Vérifier que le tournoi existe
      const checkResult = await pool.query('SELECT * FROM tournaments WHERE id = $1', [id]);
      if (checkResult.rows.length === 0) {
        return res.status(404).json({ error: 'Tournoi non trouvé' });
      }

      const result = await pool.query(`
        UPDATE tournaments SET
          name = COALESCE($1, name),
          description = COALESCE($2, description),
          status = COALESCE($3, status),
          max_participants = COALESCE($4, max_participants),
          third_place_match = COALESCE($5, third_place_match),
          registration_start = COALESCE($6, registration_start),
          registration_end = COALESCE($7, registration_end),
          start_date = COALESCE($8, start_date)
        WHERE id = $9
        RETURNING *
      `, [
        name,
        description,
        status,
        max_participants,
        third_place_match,
        registration_start,
        registration_end,
        start_date,
        id
      ]);

      const tournament = result.rows[0];

      // Émettre un événement Socket.IO
      io.to(`tournament:${id}`).emit('tournament:updated', { tournament });

      res.json({ tournament });
    } catch (error) {
      console.error('Erreur lors de la mise à jour du tournoi:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  });

  /**
   * DELETE /tournaments/:id
   * Supprimer un tournoi (admin uniquement)
   */
  app.delete('/tournaments/:id', auth, async (req, res) => {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Accès refusé' });
    }

    try {
      const { id } = req.params;

      const result = await pool.query('DELETE FROM tournaments WHERE id = $1 RETURNING *', [id]);

      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'Tournoi non trouvé' });
      }

      // Émettre un événement Socket.IO
      io.emit('tournament:deleted', { tournamentId: id });

      res.json({ message: 'Tournoi supprimé avec succès' });
    } catch (error) {
      console.error('Erreur lors de la suppression du tournoi:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  });

  /**
   * POST /tournaments/:id/participants/manual
   * Ajouter un participant manuel (guest) au tournoi
   * IMPORTANT: Cette route doit être AVANT la route générale /participants
   */
  app.post('/tournaments/:id/participants/manual', auth, async (req, res) => {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Accès refusé' });
    }

    const client = await pool.connect();

    try {
      await client.query('BEGIN');

      const { id } = req.params;
      const { player_name } = req.body;

      if (!player_name || !player_name.trim()) {
        await client.query('ROLLBACK');
        return res.status(400).json({ error: 'Nom du joueur requis' });
      }

      // Vérifier que le tournoi existe et accepte les inscriptions
      const tournamentResult = await client.query(
        'SELECT * FROM tournaments WHERE id = $1',
        [id]
      );

      if (tournamentResult.rows.length === 0) {
        await client.query('ROLLBACK');
        return res.status(404).json({ error: 'Tournoi non trouvé' });
      }

      const tournament = tournamentResult.rows[0];

      if (tournament.status === 'completed' || tournament.status === 'cancelled') {
        await client.query('ROLLBACK');
        return res.status(400).json({ error: 'Le tournoi est terminé ou annulé' });
      }

      // Note: On permet l'ajout de participants manuels même si le tournoi est en cours
      // car l'admin peut vouloir ajouter un remplaçant ou corriger une erreur

      // Vérifier le nombre max de participants
      if (tournament.max_participants) {
        const countResult = await client.query(
          'SELECT COUNT(*) FROM tournament_participants WHERE tournament_id = $1',
          [id]
        );

        if (parseInt(countResult.rows[0].count) >= tournament.max_participants) {
          await client.query('ROLLBACK');
          return res.status(400).json({ error: 'Tournoi complet' });
        }
      }

      // Générer un player_id unique pour le joueur guest
      const timestamp = Date.now();
      const randomSuffix = Math.random().toString(36).substring(2, 6).toUpperCase();
      const playerId = `GUEST_${timestamp}_${randomSuffix}`;

      // Créer le joueur guest dans la table players
      await client.query(`
        INSERT INTO players (player_id, name, role)
        VALUES ($1, $2, 'GUEST')
      `, [playerId, player_name.trim()]);

      // Ajouter le participant au tournoi
      const participantResult = await client.query(`
        INSERT INTO tournament_participants (tournament_id, player_id)
        VALUES ($1, $2)
        RETURNING *
      `, [id, playerId]);

      await client.query('COMMIT');

      const participant = participantResult.rows[0];

      // Émettre un événement Socket.IO
      io.to(`tournament:${id}`).emit('tournament:participant_added', {
        participant: {
          ...participant,
          player_name: player_name.trim()
        }
      });

      res.status(201).json({
        player_id: playerId,
        name: player_name.trim(),
        participant
      });
    } catch (error) {
      await client.query('ROLLBACK');
      console.error('Erreur lors de l\'ajout du participant manuel:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    } finally {
      client.release();
    }
  });

  /**
   * POST /tournaments/:id/participants
   * Ajouter un participant à un tournoi
   */
  app.post('/tournaments/:id/participants', auth, async (req, res) => {
    try {
      const { id } = req.params;
      const { player_id, seed } = req.body;

      if (!player_id) {
        return res.status(400).json({ error: 'player_id requis' });
      }

      // Vérifier que le tournoi existe et accepte les inscriptions
      const tournamentResult = await pool.query(
        'SELECT * FROM tournaments WHERE id = $1',
        [id]
      );

      if (tournamentResult.rows.length === 0) {
        return res.status(404).json({ error: 'Tournoi non trouvé' });
      }

      const tournament = tournamentResult.rows[0];

      if (tournament.status === 'completed' || tournament.status === 'cancelled') {
        return res.status(400).json({ error: 'Le tournoi est terminé' });
      }

      if (tournament.status === 'in_progress') {
        return res.status(400).json({ error: 'Le tournoi a déjà commencé' });
      }

      // Vérifier le nombre max de participants
      if (tournament.max_participants) {
        const countResult = await pool.query(
          'SELECT COUNT(*) FROM tournament_participants WHERE tournament_id = $1',
          [id]
        );

        if (parseInt(countResult.rows[0].count) >= tournament.max_participants) {
          return res.status(400).json({ error: 'Tournoi complet' });
        }
      }

      // Ajouter le participant
      const result = await pool.query(`
        INSERT INTO tournament_participants (tournament_id, player_id, seed)
        VALUES ($1, $2, $3)
        ON CONFLICT (tournament_id, player_id) DO UPDATE
        SET seed = EXCLUDED.seed
        RETURNING *
      `, [id, player_id, seed || null]);

      const participant = result.rows[0];

      // Émettre un événement Socket.IO
      io.to(`tournament:${id}`).emit('tournament:participant_added', { participant });

      res.status(201).json({ participant });
    } catch (error) {
      console.error('Erreur lors de l\'ajout du participant:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  });

  /**
   * DELETE /tournaments/:id/participants/:playerId
   * Retirer un participant d'un tournoi
   */
  app.delete('/tournaments/:id/participants/:playerId', auth, async (req, res) => {
    try {
      const { id, playerId } = req.params;

      // Vérifier que le tournoi n'a pas encore commencé
      const tournamentResult = await pool.query(
        'SELECT status FROM tournaments WHERE id = $1',
        [id]
      );

      if (tournamentResult.rows.length === 0) {
        return res.status(404).json({ error: 'Tournoi non trouvé' });
      }

      if (tournamentResult.rows[0].status === 'in_progress' || tournamentResult.rows[0].status === 'completed') {
        return res.status(400).json({ error: 'Impossible de retirer un participant d\'un tournoi en cours ou terminé' });
      }

      const result = await pool.query(
        'DELETE FROM tournament_participants WHERE tournament_id = $1 AND player_id = $2 RETURNING *',
        [id, playerId]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'Participant non trouvé' });
      }

      // Émettre un événement Socket.IO
      io.to(`tournament:${id}`).emit('tournament:participant_removed', { playerId });

      res.json({ message: 'Participant retiré avec succès' });
    } catch (error) {
      console.error('Erreur lors du retrait du participant:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  });

  /**
   * POST /tournaments/:id/generate-bracket
   * Générer le bracket du tournoi (admin uniquement)
   */
  app.post('/tournaments/:id/generate-bracket', auth, async (req, res) => {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Accès refusé' });
    }

    const client = await pool.connect();

    try {
      await client.query('BEGIN');

      const { id } = req.params;

      // Récupérer le tournoi
      const tournamentResult = await client.query(
        'SELECT * FROM tournaments WHERE id = $1',
        [id]
      );

      if (tournamentResult.rows.length === 0) {
        await client.query('ROLLBACK');
        return res.status(404).json({ error: 'Tournoi non trouvé' });
      }

      const tournament = tournamentResult.rows[0];

      if (tournament.status !== 'draft' && tournament.status !== 'registration') {
        await client.query('ROLLBACK');
        return res.status(400).json({ error: 'Le bracket a déjà été généré' });
      }

      // Récupérer les participants
      const participantsResult = await client.query(
        'SELECT * FROM tournament_participants WHERE tournament_id = $1 ORDER BY seed NULLS LAST',
        [id]
      );

      const participants = participantsResult.rows;

      if (participants.length < 2) {
        await client.query('ROLLBACK');
        return res.status(400).json({ error: 'Au moins 2 participants requis' });
      }

      // Assigner des seeds si nécessaire
      for (let i = 0; i < participants.length; i++) {
        if (!participants[i].seed) {
          await client.query(
            'UPDATE tournament_participants SET seed = $1 WHERE id = $2',
            [i + 1, participants[i].id]
          );
          participants[i].seed = i + 1;
        }
      }

      // Supprimer les anciens matchs s'il y en a
      await client.query('DELETE FROM tournament_matches WHERE tournament_id = $1', [id]);

      // Générer le bracket selon le format
      let matches = [];
      switch (tournament.format) {
        case 'single_elimination':
          matches = generateSingleEliminationBracket(participants);
          break;
        case 'double_elimination':
          matches = generateDoubleEliminationBracket(participants);
          break;
        case 'round_robin':
          matches = generateRoundRobinBracket(participants);
          break;
        default:
          await client.query('ROLLBACK');
          return res.status(400).json({ error: 'Format de tournoi non supporté' });
      }

      // Ajouter un match pour la 3ème place si demandé
      if (tournament.third_place_match && tournament.format !== 'round_robin') {
        const finalRound = Math.max(...matches.filter(m => m.bracket_type === 'winners').map(m => m.round));
        const semiFinalMatches = matches.filter(m => m.bracket_type === 'winners' && m.round === finalRound - 1);

        if (semiFinalMatches.length === 2) {
          matches.push({
            round: 1,
            match_number: 1,
            bracket_type: 'third_place',
            player1_id: null,
            player2_id: null,
            player1_from: 'loser',
            player2_from: 'loser',
            status: 'pending',
            prerequisite_match1_id: null, // À lier avec les IDs réels
            prerequisite_match2_id: null
          });
        }
      }

      // Insérer les matchs dans la base de données
      const insertedMatches = [];
      for (const match of matches) {
        const result = await client.query(`
          INSERT INTO tournament_matches (
            tournament_id, round, match_number, bracket_type,
            player1_id, player2_id, player1_from, player2_from,
            status, winner_id
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
          RETURNING *
        `, [
          id,
          match.round,
          match.match_number,
          match.bracket_type,
          match.player1_id,
          match.player2_id,
          match.player1_from,
          match.player2_from,
          match.status,
          match.winner_id || null
        ]);

        insertedMatches.push(result.rows[0]);
      }

      // Mettre à jour les liens de progression entre matchs
      console.log('📊 Mise à jour des liens de progression...');
      for (let i = 0; i < insertedMatches.length; i++) {
        const match = insertedMatches[i];
        const originalMatch = matches[i];

        // Utiliser les liens calculés par linkMatches
        let nextMatchWinnerId = null;
        let nextMatchWinnerSlot = null;
        let nextMatchLoserId = null;
        let nextMatchLoserSlot = null;

        if (originalMatch.next_match_winner_id !== undefined) {
          const nextMatchIndex = originalMatch.next_match_winner_id;
          nextMatchWinnerId = insertedMatches[nextMatchIndex]?.id || null;
          nextMatchWinnerSlot = originalMatch.next_match_winner_slot;
        }

        if (originalMatch.next_match_loser_id !== undefined) {
          const nextMatchIndex = originalMatch.next_match_loser_id;
          nextMatchLoserId = insertedMatches[nextMatchIndex]?.id || null;
          nextMatchLoserSlot = originalMatch.next_match_loser_slot;
        }

        // Mettre à jour la BDD avec les liens
        if (nextMatchWinnerId || nextMatchLoserId) {
          await client.query(`
            UPDATE tournament_matches
            SET next_match_winner_id = $1,
                next_match_winner_slot = $2,
                next_match_loser_id = $3,
                next_match_loser_slot = $4
            WHERE id = $5
          `, [nextMatchWinnerId, nextMatchWinnerSlot, nextMatchLoserId, nextMatchLoserSlot, match.id]);
        }
      }

      // Mettre à jour le compteur de matchs du tournoi
      await client.query(
        'UPDATE tournaments SET total_matches = $1, status = $2 WHERE id = $3',
        [insertedMatches.length, 'in_progress', id]
      );

      await client.query('COMMIT');

      // Émettre un événement Socket.IO
      io.to(`tournament:${id}`).emit('tournament:bracket_generated', {
        tournamentId: id,
        matches: insertedMatches
      });

      res.json({
        message: 'Bracket généré avec succès',
        matches: insertedMatches
      });
    } catch (error) {
      await client.query('ROLLBACK');
      console.error('Erreur lors de la génération du bracket:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    } finally {
      client.release();
    }
  });

  /**
   * PUT /tournaments/:tournamentId/matches/:matchId
   * Mettre à jour le résultat d'un match (admin uniquement)
   */
  app.put('/tournaments/:tournamentId/matches/:matchId', auth, async (req, res) => {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Accès refusé' });
    }

    const client = await pool.connect();

    try {
      await client.query('BEGIN');

      const { tournamentId, matchId } = req.params;
      const { player1_score, player2_score, winner_id } = req.body;

      // Récupérer le match
      const matchResult = await client.query(
        'SELECT * FROM tournament_matches WHERE id = $1 AND tournament_id = $2',
        [matchId, tournamentId]
      );

      if (matchResult.rows.length === 0) {
        await client.query('ROLLBACK');
        return res.status(404).json({ error: 'Match non trouvé' });
      }

      const match = matchResult.rows[0];

      // Vérifier que les deux joueurs sont présents
      if (!match.player1_id || !match.player2_id) {
        await client.query('ROLLBACK');
        return res.status(400).json({ error: 'Match incomplet' });
      }

      // Mettre à jour le match
      await client.query(`
        UPDATE tournament_matches
        SET player1_score = $1,
            player2_score = $2,
            winner_id = $3,
            status = 'completed',
            completed_at = NOW()
        WHERE id = $4
      `, [player1_score, player2_score, winner_id, matchId]);

      // Mettre à jour les statistiques des participants
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

      const loserId = winner_id === match.player1_id ? match.player2_id : match.player1_id;
      const loserScore = winner_id === match.player1_id ? player2_score : player1_score;
      const winnerScore = winner_id === match.player1_id ? player1_score : player2_score;

      await client.query(`
        UPDATE tournament_participants
        SET losses = losses + 1,
            points_for = points_for + $1,
            points_against = points_against + $2
        WHERE tournament_id = $3 AND player_id = $4
      `, [loserScore, winnerScore, tournamentId, loserId]);

      // Faire progresser les joueurs dans le bracket
      console.log(`📊 Match ${matchId} terminé (${match.bracket_type} R${match.round}):`, {
        winner_id,
        loser_id: loserId,
        next_match_winner_id: match.next_match_winner_id,
        next_match_loser_id: match.next_match_loser_id,
        next_match_loser_slot: match.next_match_loser_slot
      });

      if (match.next_match_winner_id) {
        const slot = match.next_match_winner_slot === 'player1' ? 'player1_id' : 'player2_id';
        console.log(`  ✅ Gagnant ${winner_id} → Match ${match.next_match_winner_id} [${slot}]`);
        await client.query(`
          UPDATE tournament_matches
          SET ${slot} = $1
          WHERE id = $2
        `, [winner_id, match.next_match_winner_id]);
      }

      if (match.next_match_loser_id && match.bracket_type !== 'round_robin') {
        const slot = match.next_match_loser_slot === 'player1' ? 'player1_id' : 'player2_id';
        console.log(`  ✅ Perdant ${loserId} → Match ${match.next_match_loser_id} [${slot}]`);
        await client.query(`
          UPDATE tournament_matches
          SET ${slot} = $1
          WHERE id = $2
        `, [loserId, match.next_match_loser_id]);
      } else if (!match.next_match_loser_id && match.bracket_type === 'winners') {
        console.log(`  ⚠️ PROBLÈME: Match winner's bracket sans next_match_loser_id !`);
      }

      // Mettre à jour le compteur de matchs complétés
      await client.query(`
        UPDATE tournaments
        SET completed_matches = completed_matches + 1
        WHERE id = $1
      `, [tournamentId]);

      // Vérifier si le tournoi est terminé
      const statsResult = await client.query(`
        SELECT total_matches, completed_matches
        FROM tournaments
        WHERE id = $1
      `, [tournamentId]);

      const stats = statsResult.rows[0];

      if (stats.completed_matches >= stats.total_matches) {
        // Déterminer le vainqueur, runner-up, et 3ème place
        const finalsMatch = await client.query(`
          SELECT * FROM tournament_matches
          WHERE tournament_id = $1 AND bracket_type = 'finals'
          ORDER BY round DESC, match_number DESC
          LIMIT 1
        `, [tournamentId]);

        if (finalsMatch.rows.length > 0 && finalsMatch.rows[0].winner_id) {
          const winnerId = finalsMatch.rows[0].winner_id;
          const runnerUpId = finalsMatch.rows[0].winner_id === finalsMatch.rows[0].player1_id
            ? finalsMatch.rows[0].player2_id
            : finalsMatch.rows[0].player1_id;

          // Troisième place
          const thirdPlaceMatch = await client.query(`
            SELECT * FROM tournament_matches
            WHERE tournament_id = $1 AND bracket_type = 'third_place'
            LIMIT 1
          `, [tournamentId]);

          const thirdPlaceId = thirdPlaceMatch.rows.length > 0 && thirdPlaceMatch.rows[0].winner_id
            ? thirdPlaceMatch.rows[0].winner_id
            : null;

          await client.query(`
            UPDATE tournaments
            SET status = 'completed',
                winner_id = $1,
                runner_up_id = $2,
                third_place_id = $3,
                end_date = NOW()
            WHERE id = $4
          `, [winnerId, runnerUpId, thirdPlaceId, tournamentId]);

          // Mettre à jour les placements finaux
          await client.query(`
            UPDATE tournament_participants
            SET final_placement = 1
            WHERE tournament_id = $1 AND player_id = $2
          `, [tournamentId, winnerId]);

          await client.query(`
            UPDATE tournament_participants
            SET final_placement = 2
            WHERE tournament_id = $1 AND player_id = $2
          `, [tournamentId, runnerUpId]);

          if (thirdPlaceId) {
            await client.query(`
              UPDATE tournament_participants
              SET final_placement = 3
              WHERE tournament_id = $1 AND player_id = $2
            `, [tournamentId, thirdPlaceId]);
          }
        }
      }

      await client.query('COMMIT');

      // Émettre un événement Socket.IO
      io.to(`tournament:${tournamentId}`).emit('tournament:match_updated', {
        matchId,
        tournamentId,
        winner_id,
        player1_score,
        player2_score
      });

      res.json({ message: 'Match mis à jour avec succès' });
    } catch (error) {
      await client.query('ROLLBACK');
      console.error('Erreur lors de la mise à jour du match:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    } finally {
      client.release();
    }
  });

  /**
   * GET /tournaments/:id/standings
   * Classement du tournoi
   */
  app.get('/tournaments/:id/standings', auth, async (req, res) => {
    try {
      const { id } = req.params;

      const result = await pool.query(`
        SELECT
          tp.*,
          p.name as player_name,
          p.profile_pic_url,
          (tp.points_for - tp.points_against) as point_differential
        FROM tournament_participants tp
        JOIN players p ON tp.player_id = p.player_id
        WHERE tp.tournament_id = $1
        ORDER BY
          CASE WHEN tp.final_placement IS NOT NULL THEN tp.final_placement ELSE 999 END,
          tp.wins DESC,
          (tp.points_for - tp.points_against) DESC,
          tp.points_for DESC,
          p.name
      `, [id]);

      res.json({ standings: result.rows });
    } catch (error) {
      console.error('Erreur lors de la récupération du classement:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  });

}

module.exports = {
  setupTournamentRoutes,
  generateSingleEliminationBracket,
  generateDoubleEliminationBracket,
  generateRoundRobinBracket
};
