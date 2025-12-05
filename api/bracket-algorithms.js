/**
 * Algorithmes de génération de brackets pour tournois
 * Implémentation basée sur les standards Challonge/start.gg
 *
 * Références:
 * - Mirror seeding pour éviter que les meilleurs seeds s'affrontent tôt
 * - Gestion des byes (next_pow2)
 * - Double elimination avec grand final reset
 * - Round-robin avec circle method
 */

/**
 * Calcule la prochaine puissance de 2 >= x
 * @param {number} x - Nombre de participants
 * @returns {number} Prochaine puissance de 2
 */
function nextPow2(x) {
  let p = 1;
  while (p < x) {
    p *= 2;
  }
  return p;
}

/**
 * Génère l'ordre miroir (mirror order) pour le seeding
 * Standard pour éviter que les meilleurs seeds s'affrontent tôt
 *
 * Exemple pour 8 slots: [1, 8, 4, 5, 2, 7, 3, 6]
 * - 1 vs 8 (meilleur vs pire)
 * - 4 vs 5 (milieu)
 * - 2 vs 7
 * - 3 vs 6
 *
 * @param {number} nSlots - Nombre de slots (doit être puissance de 2)
 * @returns {Array<number>} Ordre des seeds (1-indexed)
 */
function generateMirrorOrder(nSlots) {
  if (nSlots === 1) {
    return [1];
  }

  if (nSlots === 2) {
    return [1, 2];
  }

  // Algorithme récursif correct
  const prevRound = generateMirrorOrder(nSlots / 2);
  const result = [];

  for (const seed of prevRound) {
    result.push(seed);
    result.push(nSlots + 1 - seed);
  }

  return result;
}

/**
 * Place les joueurs dans les slots selon le mirror order
 * Gère automatiquement les byes (slots vides)
 *
 * @param {Array} players - Liste des joueurs [{player_id, seed?}, ...]
 * @param {boolean} useSeed - Utiliser le seed des joueurs ou ordre naturel
 * @returns {Array} Slots ordonnés (null = bye)
 */
function placePlayersIntoSlots(players, useSeed = true) {
  const n = players.length;
  const slots = nextPow2(n);

  // Trier les joueurs par seed (ou ordre naturel)
  const sortedPlayers = useSeed
    ? [...players].sort((a, b) => (a.seed || 999) - (b.seed || 999))
    : [...players];

  // Générer l'ordre miroir
  const mirrorOrder = generateMirrorOrder(slots);

  // Créer le mapping seed -> player
  const seedToPlayer = {};
  for (let i = 0; i < slots; i++) {
    const seed = mirrorOrder[i];
    seedToPlayer[seed] = i < n ? sortedPlayers[i] : null;
  }

  // Retourner les slots dans l'ordre séquentiel
  const result = [];
  for (let i = 1; i <= slots; i++) {
    result.push(seedToPlayer[i] || null);
  }

  return result;
}

/**
 * Génère un bracket de Single Elimination avec mirror seeding
 * @param {Array} participants - Liste des participants
 * @param {boolean} useSeed - Utiliser le seed ou ordre naturel
 * @returns {Object} {matches: Array, metadata: Object}
 */
function buildSingleEliminationBracket(participants, useSeed = true) {
  const n = participants.length;
  const bracketSize = nextPow2(n);
  const totalRounds = Math.log2(bracketSize);

  // Placer les joueurs avec mirror seeding
  const slots = placePlayersIntoSlots(participants, useSeed);

  const matches = [];
  let globalMatchId = 0;

  // Round 1
  for (let i = 0; i < slots.length; i += 2) {
    const player1 = slots[i];
    const player2 = slots[i + 1];

    // Déterminer le statut
    let status = 'pending';
    let winnerId = null;

    if (!player1 && !player2) {
      status = 'pending'; // Double bye (ne devrait pas arriver)
    } else if (!player1) {
      status = 'walkover';
      winnerId = player2.player_id;
    } else if (!player2) {
      status = 'walkover';
      winnerId = player1.player_id;
    }

    matches.push({
      id: globalMatchId++,
      round: 1,
      match_number: (i / 2) + 1,
      bracket_type: 'winners',
      player1_id: player1?.player_id || null,
      player2_id: player2?.player_id || null,
      player1_from: 'seed',
      player2_from: 'seed',
      status,
      winner_id: winnerId,
      player1_score: null,
      player2_score: null
    });
  }

  // Rounds suivants (vides au départ)
  for (let r = 2; r <= totalRounds; r++) {
    const matchesInRound = Math.pow(2, totalRounds - r);
    for (let m = 1; m <= matchesInRound; m++) {
      matches.push({
        id: globalMatchId++,
        round: r,
        match_number: m,
        bracket_type: 'winners',
        player1_id: null,
        player2_id: null,
        player1_from: 'winner',
        player2_from: 'winner',
        status: 'pending',
        winner_id: null,
        player1_score: null,
        player2_score: null
      });
    }
  }

  // Lier les matchs
  linkSingleEliminationMatches(matches);

  // Auto-avancer les walkovers
  autoAdvanceByes(matches);

  return {
    matches,
    metadata: {
      format: 'single_elimination',
      bracket_size: bracketSize,
      participant_count: n,
      byes_count: bracketSize - n,
      total_rounds: totalRounds
    }
  };
}

/**
 * Lie les matchs d'un bracket single elimination
 * @param {Array} matches - Liste des matchs
 */
function linkSingleEliminationMatches(matches) {
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
      match.next_match_winner_id = nextMatch.id;
      match.next_match_winner_slot = slotInNextMatch;
    }
  }
}

/**
 * Avance automatiquement les joueurs dans les matchs avec bye
 * @param {Array} matches - Liste des matchs (modifiée en place)
 */
function autoAdvanceByes(matches) {
  let changed = true;
  let iterations = 0;
  const maxIterations = 100; // Sécurité contre boucle infinie

  // Boucler jusqu'à ce qu'il n'y ait plus de changements
  while (changed && iterations < maxIterations) {
    changed = false;
    iterations++;

    for (const match of matches) {
      // Si le match est déjà traité et qu'il n'a pas de gagnant, passer
      if (match._processed && !match.winner_id) {
        continue;
      }

      // Si un seul joueur est présent, c'est un walkover
      if (match.player1_id && !match.player2_id) {
        if (match.status !== 'walkover') {
          match.status = 'walkover';
          match.winner_id = match.player1_id;
          match._processed = true;
          changed = true;
        }

        // Avancer le gagnant si pas encore fait
        if (match.next_match_winner_id && match.winner_id) {
          const nextMatch = matches.find(m => m.id === match.next_match_winner_id);
          if (nextMatch) {
            const slot = match.next_match_winner_slot;
            const slotKey = slot === 'player1' ? 'player1_id' : 'player2_id';

            // Avancer seulement si le slot est vide
            if (!nextMatch[slotKey]) {
              nextMatch[slotKey] = match.winner_id;
              changed = true;
            }
          }
        }
      } else if (!match.player1_id && match.player2_id) {
        if (match.status !== 'walkover') {
          match.status = 'walkover';
          match.winner_id = match.player2_id;
          match._processed = true;
          changed = true;
        }

        // Avancer le gagnant si pas encore fait
        if (match.next_match_winner_id && match.winner_id) {
          const nextMatch = matches.find(m => m.id === match.next_match_winner_id);
          if (nextMatch) {
            const slot = match.next_match_winner_slot;
            const slotKey = slot === 'player1' ? 'player1_id' : 'player2_id';

            // Avancer seulement si le slot est vide
            if (!nextMatch[slotKey]) {
              nextMatch[slotKey] = match.winner_id;
              changed = true;
            }
          }
        }
      } else if (match.player1_id && match.player2_id) {
        // Les deux joueurs sont présents, marquer comme traité
        match._processed = true;
      }
    }
  }

  // Nettoyer les flags temporaires
  matches.forEach(m => delete m._processed);
}

/**
 * Génère un bracket de Double Elimination avec grand final reset
 * @param {Array} participants - Liste des participants
 * @param {boolean} useSeed - Utiliser le seed ou ordre naturel
 * @param {boolean} enableGrandFinalReset - Activer le reset de la grande finale
 * @returns {Object} {matches: Array, metadata: Object}
 */
function buildDoubleEliminationBracket(participants, useSeed = true, enableGrandFinalReset = true) {
  const n = participants.length;
  const bracketSize = nextPow2(n);
  const winnersRounds = Math.log2(bracketSize);

  // Placer les joueurs avec mirror seeding
  const slots = placePlayersIntoSlots(participants, useSeed);

  const matches = [];
  let globalMatchId = 0;

  // ===== WINNER'S BRACKET =====
  // Round 1
  for (let i = 0; i < slots.length; i += 2) {
    const player1 = slots[i];
    const player2 = slots[i + 1];

    let status = 'pending';
    let winnerId = null;

    if (!player1 && player2) {
      status = 'walkover';
      winnerId = player2.player_id;
    } else if (player1 && !player2) {
      status = 'walkover';
      winnerId = player1.player_id;
    }

    matches.push({
      id: globalMatchId++,
      round: 1,
      match_number: (i / 2) + 1,
      bracket_type: 'winners',
      player1_id: player1?.player_id || null,
      player2_id: player2?.player_id || null,
      player1_from: 'seed',
      player2_from: 'seed',
      status,
      winner_id: winnerId,
      player1_score: null,
      player2_score: null
    });
  }

  // Rounds suivants du Winner's Bracket
  for (let r = 2; r <= winnersRounds; r++) {
    const matchesInRound = Math.pow(2, winnersRounds - r);
    for (let m = 1; m <= matchesInRound; m++) {
      matches.push({
        id: globalMatchId++,
        round: r,
        match_number: m,
        bracket_type: 'winners',
        player1_id: null,
        player2_id: null,
        player1_from: 'winner',
        player2_from: 'winner',
        status: 'pending',
        winner_id: null,
        player1_score: null,
        player2_score: null
      });
    }
  }

  // ===== LOSER'S BRACKET =====
  const losersRounds = (winnersRounds - 1) * 2;

  for (let r = 1; r <= losersRounds; r++) {
    // Nombre de matchs dans ce round
    const matchesInRound = r === 1
      ? bracketSize / 4
      : Math.pow(2, Math.floor((losersRounds - r) / 2));

    for (let m = 1; m <= matchesInRound; m++) {
      // Déterminer d'où viennent les joueurs
      let player1From, player2From;

      if (r === 1) {
        player1From = 'loser';
        player2From = 'loser';
      } else if (r % 2 === 0) {
        // Rounds pairs: gagnant LB + perdant WB
        player1From = 'winner';
        player2From = 'loser';
      } else {
        // Rounds impairs: deux gagnants LB
        player1From = 'winner';
        player2From = 'winner';
      }

      matches.push({
        id: globalMatchId++,
        round: r,
        match_number: m,
        bracket_type: 'losers',
        player1_id: null,
        player2_id: null,
        player1_from: player1From,
        player2_from: player2From,
        status: 'pending',
        winner_id: null,
        player1_score: null,
        player2_score: null
      });
    }
  }

  // ===== GRAND FINALS =====
  matches.push({
    id: globalMatchId++,
    round: 1,
    match_number: 1,
    bracket_type: 'finals',
    player1_id: null,
    player2_id: null,
    player1_from: 'winner', // Champion du Winner's Bracket
    player2_from: 'winner', // Champion du Loser's Bracket
    status: 'pending',
    winner_id: null,
    player1_score: null,
    player2_score: null
  });

  // Grand Final Reset (si activé)
  if (enableGrandFinalReset) {
    matches.push({
      id: globalMatchId++,
      round: 2,
      match_number: 1,
      bracket_type: 'finals',
      player1_id: null,
      player2_id: null,
      player1_from: 'conditional', // Si player2 gagne le match 1
      player2_from: 'conditional',
      status: 'conditional',
      winner_id: null,
      player1_score: null,
      player2_score: null,
      is_reset: true
    });
  }

  // Lier tous les matchs
  linkDoubleEliminationMatches(matches);

  // Auto-avancer les byes
  autoAdvanceByes(matches);

  return {
    matches,
    metadata: {
      format: 'double_elimination',
      bracket_size: bracketSize,
      participant_count: n,
      byes_count: bracketSize - n,
      winners_rounds: winnersRounds,
      losers_rounds: losersRounds,
      grand_final_reset: enableGrandFinalReset
    }
  };
}

/**
 * Lie les matchs d'un bracket double elimination
 * @param {Array} matches - Liste des matchs
 */
function linkDoubleEliminationMatches(matches) {
  const winnerMatches = matches.filter(m => m.bracket_type === 'winners');
  const loserMatches = matches.filter(m => m.bracket_type === 'losers');
  const finalsMatches = matches.filter(m => m.bracket_type === 'finals');
  const grandFinal = finalsMatches.find(m => m.round === 1);
  const grandFinalReset = finalsMatches.find(m => m.round === 2);

  // 1. Lier le Winner's Bracket
  for (const match of winnerMatches) {
    const nextRound = match.round + 1;
    const nextMatchNumber = Math.ceil(match.match_number / 2);
    const slotInNextMatch = match.match_number % 2 === 1 ? 'player1' : 'player2';

    const nextMatch = winnerMatches.find(
      m => m.round === nextRound && m.match_number === nextMatchNumber
    );

    if (nextMatch) {
      match.next_match_winner_id = nextMatch.id;
      match.next_match_winner_slot = slotInNextMatch;
    } else if (grandFinal) {
      // Dernier match du WB va à la grande finale
      match.next_match_winner_id = grandFinal.id;
      match.next_match_winner_slot = 'player1';
    }
  }

  // 2. Lier les perdants du WB vers le LB
  for (const match of winnerMatches) {
    // Formule: WB R1 → LB R1, WB R2 → LB R2, WB R3 → LB R4, etc.
    const loserRound = match.round === 1 ? 1 : (match.round - 1) * 2;

    if (match.round === 1) {
      // R1: 2 perdants WB → 1 match LB
      const loserMatchNumber = Math.ceil(match.match_number / 2);
      const loserSlot = match.match_number % 2 === 1 ? 'player1' : 'player2';

      const loserMatch = loserMatches.find(
        m => m.round === loserRound && m.match_number === loserMatchNumber
      );

      if (loserMatch) {
        match.next_match_loser_id = loserMatch.id;
        match.next_match_loser_slot = loserSlot;
      }
    } else {
      // R2+: 1 perdant WB → 1 match LB (en player2)
      const loserMatch = loserMatches.find(
        m => m.round === loserRound && m.match_number === match.match_number
      );

      if (loserMatch) {
        match.next_match_loser_id = loserMatch.id;
        match.next_match_loser_slot = 'player2';
      }
    }
  }

  // 3. Lier le Loser's Bracket entre ses matchs
  for (const match of loserMatches) {
    const nextRound = match.round + 1;
    let nextMatchNumber, slotInNextMatch;

    if (match.round % 2 === 1) {
      // Round impair → round pair (même numéro)
      nextMatchNumber = match.match_number;
      slotInNextMatch = 'player1';
    } else {
      // Round pair → round impair (division)
      nextMatchNumber = Math.ceil(match.match_number / 2);
      slotInNextMatch = match.match_number % 2 === 1 ? 'player1' : 'player2';
    }

    const nextMatch = loserMatches.find(
      m => m.round === nextRound && m.match_number === nextMatchNumber
    );

    if (nextMatch) {
      match.next_match_winner_id = nextMatch.id;
      match.next_match_winner_slot = slotInNextMatch;
    } else if (grandFinal) {
      // Dernier match du LB va à la grande finale
      match.next_match_winner_id = grandFinal.id;
      match.next_match_winner_slot = 'player2';
    }
  }

  // 4. Lier le grand final reset
  if (grandFinal && grandFinalReset) {
    grandFinal.next_match_conditional_id = grandFinalReset.id;
    // Si player2 (champion LB) gagne → reset
    grandFinal.conditional_on_player2_win = true;
  }
}

/**
 * Génère un bracket Round-Robin avec circle method
 * Optimisé pour minimiser les conflits d'horaires
 *
 * @param {Array} participants - Liste des participants
 * @returns {Object} {matches: Array, rounds: Array, metadata: Object}
 */
function buildRoundRobinBracket(participants) {
  const n = participants.length;

  // Si n est impair, ajouter un bye
  const players = [...participants];
  const hasBye = n % 2 === 1;
  if (hasBye) {
    players.push({ player_id: null, name: 'BYE', is_bye: true });
  }

  const totalPlayers = players.length;
  const roundsCount = totalPlayers - 1;
  const matchesPerRound = totalPlayers / 2;

  const matches = [];
  const rounds = [];
  let globalMatchId = 0;

  // Circle method (algorithme standard)
  // On fixe le joueur 0, les autres tournent
  const positions = Array.from({ length: totalPlayers }, (_, i) => i);

  for (let round = 0; round < roundsCount; round++) {
    const roundMatches = [];

    // Créer les paires pour ce round
    for (let match = 0; match < matchesPerRound; match++) {
      const idx1 = match;
      const idx2 = totalPlayers - 1 - match;

      const player1 = players[positions[idx1]];
      const player2 = players[positions[idx2]];

      // Ne pas créer de match si un joueur est un bye
      if (player1?.is_bye || player2?.is_bye) {
        continue;
      }

      const matchObj = {
        id: globalMatchId++,
        round: round + 1,
        match_number: roundMatches.length + 1,
        bracket_type: 'round_robin',
        player1_id: player1?.player_id,
        player2_id: player2?.player_id,
        player1_from: 'seed',
        player2_from: 'seed',
        status: 'pending',
        winner_id: null,
        player1_score: null,
        player2_score: null
      };

      matches.push(matchObj);
      roundMatches.push(matchObj);
    }

    if (roundMatches.length > 0) {
      rounds.push({
        round: round + 1,
        matches: roundMatches
      });
    }

    // Rotation: fixer position 0, faire tourner les autres
    if (round < roundsCount - 1) {
      const last = positions.pop();
      positions.splice(1, 0, last);
    }
  }

  return {
    matches,
    rounds,
    metadata: {
      format: 'round_robin',
      participant_count: n,
      rounds_count: roundsCount,
      matches_per_round: matchesPerRound,
      total_matches: matches.length,
      has_bye: hasBye
    }
  };
}

/**
 * Revert un match (annule le résultat)
 * @param {Array} matches - Liste de tous les matchs
 * @param {number} matchId - ID du match à revert
 * @returns {Array} Liste des matchs affectés (pour mise à jour DB)
 */
function revertMatch(matches, matchId) {
  const match = matches.find(m => m.id === matchId);

  if (!match) {
    throw new Error('Match non trouvé');
  }

  if (match.status !== 'completed') {
    throw new Error('Le match n\'est pas complété');
  }

  const affectedMatches = [match];

  // Réinitialiser le match
  match.status = 'pending';
  match.winner_id = null;
  match.player1_score = null;
  match.player2_score = null;

  // Retirer les joueurs des matchs suivants
  if (match.next_match_winner_id) {
    const nextMatch = matches.find(m => m.id === match.next_match_winner_id);
    if (nextMatch) {
      const slot = match.next_match_winner_slot === 'player1' ? 'player1_id' : 'player2_id';
      nextMatch[slot] = null;
      affectedMatches.push(nextMatch);
    }
  }

  if (match.next_match_loser_id) {
    const nextMatch = matches.find(m => m.id === match.next_match_loser_id);
    if (nextMatch) {
      const slot = match.next_match_loser_slot === 'player1' ? 'player1_id' : 'player2_id';
      nextMatch[slot] = null;
      affectedMatches.push(nextMatch);
    }
  }

  return affectedMatches;
}

module.exports = {
  // Utilitaires
  nextPow2,
  generateMirrorOrder,
  placePlayersIntoSlots,

  // Génération de brackets
  buildSingleEliminationBracket,
  buildDoubleEliminationBracket,
  buildRoundRobinBracket,

  // Helpers
  autoAdvanceByes,
  revertMatch,

  // Linking (exporté pour tests)
  linkSingleEliminationMatches,
  linkDoubleEliminationMatches
};
