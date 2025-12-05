/**
 * Bracket Visual Renderer - Style Challonge
 * Affichage horizontal avec connexions visuelles
 */

/**
 * Rend un bracket complet style Challonge avec connexions
 * @param {Array} matches - Liste de tous les matchs
 * @param {string} format - Format du tournoi
 * @param {Object} tournament - Données du tournoi
 * @returns {string} HTML du bracket
 */
function renderChallongeBracket(matches, format, tournament) {
  if (format === 'round_robin') {
    return renderRoundRobinGrid(matches);
  }

  // Organiser les matchs par type et round
  const winnersMatches = matches.filter(m => m.bracket_type === 'winners').sort((a, b) => {
    if (a.round !== b.round) return a.round - b.round;
    return a.match_number - b.match_number;
  });

  const losersMatches = matches.filter(m => m.bracket_type === 'losers').sort((a, b) => {
    if (a.round !== b.round) return a.round - b.round;
    return a.match_number - b.match_number;
  });

  const finalsMatches = matches.filter(m => m.bracket_type === 'finals').sort((a, b) => a.round - b.round);

  const isDoubleElim = losersMatches.length > 0;

  // Organiser par rounds
  const winnersRounds = groupByRound(winnersMatches);
  const losersRounds = groupByRound(losersMatches);

  let html = '<div class="challonge-bracket-container">';

  // Header avec rounds
  html += renderRoundHeaders(winnersRounds, losersRounds, finalsMatches.length > 0);

  // Contenu principal avec SVG connections
  html += '<div class="challonge-bracket-content">';

  // Winners Bracket
  html += '<div class="challonge-winners-section">';
  html += renderBracketSection(winnersRounds, 'winners', matches);
  html += '</div>';

  // Losers Bracket (si double élimination)
  if (isDoubleElim) {
    html += '<div class="challonge-losers-separator"></div>';
    html += '<div class="challonge-losers-section">';
    html += '<div class="challonge-section-label losers">';
    html += '<span class="label-dot"></span>';
    html += '<span class="label-text">Losers Bracket</span>';
    html += '</div>';
    html += renderBracketSection(losersRounds, 'losers', matches);
    html += '</div>';
  }

  // Finals
  if (finalsMatches.length > 0) {
    html += '<div class="challonge-finals-separator"></div>';
    html += '<div class="challonge-finals-section">';
    html += '<div class="challonge-section-label finals">';
    html += '<span class="label-dot"></span>';
    html += '<span class="label-text">Grand Finals</span>';
    html += '</div>';
    html += renderFinalsSection(finalsMatches, matches);
    html += '</div>';
  }

  html += '</div>'; // challonge-bracket-content
  html += '</div>'; // challonge-bracket-container

  return html;
}

/**
 * Groupe les matchs par round
 */
function groupByRound(matches) {
  const rounds = {};
  matches.forEach(m => {
    if (!rounds[m.round]) rounds[m.round] = [];
    rounds[m.round].push(m);
  });
  return rounds;
}

/**
 * Rend les headers de rounds
 */
function renderRoundHeaders(winnersRounds, losersRounds, hasFinals) {
  const winnersRoundCount = Object.keys(winnersRounds).length;
  const losersRoundCount = Object.keys(losersRounds).length;
  const maxRounds = Math.max(winnersRoundCount, losersRoundCount);

  let html = '<div class="challonge-rounds-header">';

  // Headers pour Winners
  for (let i = 1; i <= winnersRoundCount; i++) {
    const roundName = i === winnersRoundCount ? 'Finals' :
                     i === winnersRoundCount - 1 ? 'Semifinals' :
                     i === winnersRoundCount - 2 ? 'Round 3' :
                     `Round ${i}`;
    html += `<div class="round-header">${roundName}</div>`;
  }

  if (hasFinals) {
    html += `<div class="round-header finals">Finals</div>`;
  }

  html += '</div>';

  return html;
}

/**
 * Rend une section de bracket (winners ou losers)
 */
function renderBracketSection(rounds, type, allMatches) {
  const roundKeys = Object.keys(rounds).map(Number).sort((a, b) => a - b);

  let html = '<div class="challonge-bracket-rounds">';

  roundKeys.forEach((roundNum, roundIndex) => {
    const matches = rounds[roundNum];
    const isFirstRound = roundIndex === 0;

    html += `<div class="challonge-round" data-round="${roundNum}" data-bracket="${type}">`;

    // Label du round (pour losers)
    if (type === 'losers') {
      html += `<div class="losers-round-label">Losers Round ${roundNum}</div>`;
    }

    // Matchs
    matches.forEach((match, matchIndex) => {
      html += renderChallongeMatch(match, type, roundNum, matchIndex, allMatches);
    });

    // Connections SVG
    if (roundIndex < roundKeys.length - 1) {
      html += renderConnections(matches, rounds[roundKeys[roundIndex + 1]], type, roundNum);
    }

    html += '</div>';
  });

  html += '</div>';

  return html;
}

/**
 * Rend un match individuel style Challonge
 */
function renderChallongeMatch(match, bracketType, roundNum, matchIndex, allMatches) {
  const isEmpty = !match.player1_id && !match.player2_id;
  const isWalkover = match.status === 'walkover';
  const isCompleted = match.status === 'completed';
  const isClickable = match.player1_id && match.player2_id && match.status !== 'completed';

  // Déterminer les labels "Loser of X" ou "Winner of X"
  const p1Label = getPlayerLabel(match, 'player1', allMatches, bracketType, roundNum);
  const p2Label = getPlayerLabel(match, 'player2', allMatches, bracketType, roundNum);

  const p1Name = match.player1_name || p1Label || '';
  const p2Name = match.player2_name || p2Label || '';

  const p1Winner = match.winner_id === match.player1_id;
  const p2Winner = match.winner_id === match.player2_id;

  let html = `
    <div class="challonge-match"
         data-match-id="${match.id}"
         ${isClickable ? `onclick="openScoreModal(${match.id})"` : ''}
         ${isClickable ? 'style="cursor:pointer"' : ''}>
      <div class="match-number">${match.id}</div>
      <div class="match-players">
        <div class="match-player ${p1Winner ? 'winner' : ''} ${isCompleted && !p1Winner ? 'loser' : ''}">
          <span class="player-seed">${match.player1_seed || ''}</span>
          <span class="player-name ${!match.player1_id ? 'placeholder' : ''}">${escapeHtml(p1Name) || 'TBD'}</span>
          ${match.player1_score !== null && match.player1_score !== undefined ?
            `<span class="player-score">${match.player1_score}</span>` : ''}
        </div>
        <div class="match-player ${p2Winner ? 'winner' : ''} ${isCompleted && !p2Winner ? 'loser' : ''}">
          <span class="player-seed">${match.player2_seed || ''}</span>
          <span class="player-name ${!match.player2_id ? 'placeholder' : ''}">${escapeHtml(p2Name) || 'TBD'}</span>
          ${match.player2_score !== null && match.player2_score !== undefined ?
            `<span class="player-score">${match.player2_score}</span>` : ''}
        </div>
      </div>
    </div>
  `;

  return html;
}

/**
 * Obtient le label d'un joueur (ex: "Loser of 15")
 */
function getPlayerLabel(match, playerSlot, allMatches, bracketType, roundNum) {
  // Pour le premier round du winners, pas de label
  if (bracketType === 'winners' && roundNum === 1) {
    return null;
  }

  // Pour les losers, afficher "Loser of X" pour les joueurs venant du winners
  if (bracketType === 'losers') {
    const from = playerSlot === 'player1' ? match.player1_from : match.player2_from;

    if (from === 'loser') {
      // Trouver quel match du winners a envoyé ce joueur
      const sourceMatch = findSourceMatch(match, playerSlot, allMatches);
      if (sourceMatch) {
        return `Loser of ${sourceMatch.id}`;
      }
    }
  }

  return null;
}

/**
 * Trouve le match source d'un joueur
 */
function findSourceMatch(targetMatch, playerSlot, allMatches) {
  // Chercher dans tous les matchs celui qui envoie un perdant vers ce match
  for (const match of allMatches) {
    if (match.next_match_loser_id === targetMatch.id) {
      const loserSlot = match.next_match_loser_slot;
      if ((loserSlot === 'player1' && playerSlot === 'player1') ||
          (loserSlot === 'player2' && playerSlot === 'player2')) {
        return match;
      }
    }
  }
  return null;
}

/**
 * Rend les connexions SVG entre matchs
 */
function renderConnections(currentRoundMatches, nextRoundMatches, type, roundNum) {
  if (!nextRoundMatches || nextRoundMatches.length === 0) {
    return '';
  }

  // Pour l'instant, on skip les connexions SVG complexes
  // On utilisera du CSS pur pour les lignes simples
  return '<div class="match-connector"></div>';
}

/**
 * Rend la section finals
 */
function renderFinalsSection(finalsMatches, allMatches) {
  let html = '<div class="challonge-finals-matches">';

  finalsMatches.forEach(match => {
    // Labels spéciaux pour les finals
    const p1Label = match.player1_from === 'winner' ? 'Winner of Losers Bracket' : '';
    const p2Label = match.player2_from === 'winner' && match.round === 1 ? 'Winner of Winners Bracket' : '';

    html += renderChallongeMatch(match, 'finals', match.round, 0, allMatches);

    if (match.round === 2) {
      html += '<div class="reset-note">(if necessary)</div>';
    }
  });

  html += '</div>';

  return html;
}

/**
 * Rend round robin en grille
 */
function renderRoundRobinGrid(matches) {
  const byRound = groupByRound(matches);

  let html = '<div class="round-robin-container">';

  Object.keys(byRound).sort((a, b) => a - b).forEach(round => {
    html += `
      <div class="rr-round">
        <div class="rr-round-title">Round ${round}</div>
        <div class="rr-matches">
    `;

    byRound[round].forEach(match => {
      const isClickable = match.player1_id && match.player2_id && match.status !== 'completed';
      html += `
        <div class="rr-match ${match.status}"
             ${isClickable ? `onclick="openScoreModal(${match.id})"` : ''}
             ${isClickable ? 'style="cursor:pointer"' : ''}>
          <div class="rr-player ${match.winner_id === match.player1_id ? 'winner' : ''}">
            <span class="player-name">${escapeHtml(match.player1_name) || 'TBD'}</span>
            ${match.player1_score !== null ? `<span class="score">${match.player1_score}</span>` : ''}
          </div>
          <div class="rr-vs">vs</div>
          <div class="rr-player ${match.winner_id === match.player2_id ? 'winner' : ''}">
            <span class="player-name">${escapeHtml(match.player2_name) || 'TBD'}</span>
            ${match.player2_score !== null ? `<span class="score">${match.player2_score}</span>` : ''}
          </div>
        </div>
      `;
    });

    html += '</div></div>';
  });

  html += '</div>';

  return html;
}
