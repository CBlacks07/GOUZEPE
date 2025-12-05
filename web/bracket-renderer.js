/**
 * Challonge Bracket Renderer - Reproduction EXACTE de l'image
 */

function renderChallongeBracket(matches, format, tournament) {
  if (format === 'round_robin') {
    return renderSimpleRoundRobin(matches);
  }

  // Séparer les matchs par type
  const winnersMatches = matches.filter(m => m.bracket_type === 'winners');
  const losersMatches = matches.filter(m => m.bracket_type === 'losers');
  const finalsMatches = matches.filter(m => m.bracket_type === 'finals');

  const isDoubleElim = losersMatches.length > 0;

  // Organiser par rounds
  const wbRounds = groupMatchesByRound(winnersMatches);
  const lbRounds = groupMatchesByRound(losersMatches);

  let html = '<div class="challonge-wrapper">';

  // Render Winners Bracket
  html += renderWinnersBracket(wbRounds, matches);

  // Render Losers Bracket
  if (isDoubleElim) {
    html += renderLosersBracket(lbRounds, matches);
  }

  // Render Finals
  if (finalsMatches.length > 0) {
    html += renderFinals(finalsMatches, matches);
  }

  html += '</div>';

  return html;
}

function groupMatchesByRound(matches) {
  const rounds = {};
  matches.forEach(m => {
    if (!rounds[m.round]) rounds[m.round] = [];
    rounds[m.round].push(m);
  });
  return rounds;
}

function renderWinnersBracket(rounds, allMatches) {
  const roundKeys = Object.keys(rounds).map(Number).sort((a, b) => a - b);
  const roundNames = ['Round 1', 'Round 2', 'Round 3', 'Semifinals', 'Finals'];

  let html = '<div class="bracket-section winners-bracket">';
  html += '<div class="bracket-rounds">';

  roundKeys.forEach((roundNum, idx) => {
    const matches = rounds[roundNum];
    const roundName = roundNames[idx] || `Round ${roundNum}`;

    html += `<div class="bracket-column" data-round="${roundNum}">`;
    html += `<div class="round-header">${roundName}</div>`;
    html += '<div class="matches-container">';

    matches.forEach((match, matchIdx) => {
      html += renderMatch(match, 'winners', allMatches);
    });

    html += '</div>'; // matches-container

    // SVG pour connexions
    if (idx < roundKeys.length - 1) {
      html += renderConnectorsSVG(matches, rounds[roundKeys[idx + 1]], 'winners');
    }

    html += '</div>'; // bracket-column
  });

  html += '</div>'; // bracket-rounds
  html += '</div>'; // bracket-section

  return html;
}

function renderLosersBracket(rounds, allMatches) {
  const roundKeys = Object.keys(rounds).map(Number).sort((a, b) => a - b);

  let html = '<div class="bracket-section losers-bracket">';
  html += '<div class="losers-header">Losers Bracket</div>';
  html += '<div class="bracket-rounds">';

  roundKeys.forEach((roundNum, idx) => {
    const matches = rounds[roundNum];

    html += `<div class="bracket-column" data-round="${roundNum}">`;
    html += `<div class="round-header">Losers Round ${roundNum}</div>`;
    html += '<div class="matches-container">';

    matches.forEach((match, matchIdx) => {
      html += renderMatch(match, 'losers', allMatches);
    });

    html += '</div>'; // matches-container

    // SVG pour connexions
    if (idx < roundKeys.length - 1) {
      html += renderConnectorsSVG(matches, rounds[roundKeys[idx + 1]], 'losers');
    }

    html += '</div>'; // bracket-column
  });

  html += '</div>'; // bracket-rounds
  html += '</div>'; // bracket-section

  return html;
}

function renderFinals(finalsMatches, allMatches) {
  let html = '<div class="bracket-section finals-bracket">';
  html += '<div class="finals-header">Finals</div>';
  html += '<div class="finals-matches">';

  finalsMatches.forEach(match => {
    html += renderMatch(match, 'finals', allMatches);
    if (match.round === 2) {
      html += '<div class="reset-note">Loser of 30 (if necessary)</div>';
    }
  });

  html += '</div>';
  html += '</div>';

  return html;
}

function renderMatch(match, bracketType, allMatches) {
  const p1Name = match.player1_name || getPlaceholderLabel(match, 'player1', allMatches);
  const p2Name = match.player2_name || getPlaceholderLabel(match, 'player2', allMatches);

  const p1Winner = match.winner_id && match.winner_id === match.player1_id;
  const p2Winner = match.winner_id && match.winner_id === match.player2_id;

  const isClickable = match.player1_id && match.player2_id && match.status !== 'completed';

  let html = `
    <div class="match-box ${isClickable ? 'clickable' : ''}"
         data-match-id="${match.id}"
         ${isClickable ? `onclick="openScoreModal(${match.id})"` : ''}>
      <div class="match-number">${match.id}</div>
      <div class="match-players">
        <div class="player ${p1Winner ? 'winner' : ''}">
          <span class="seed">${match.player1_seed || ''}</span>
          <span class="name">${escapeHtml(p1Name) || 'TBD'}</span>
          ${match.player1_score !== null && match.player1_score !== undefined ?
            `<span class="score">${match.player1_score}</span>` : ''}
        </div>
        <div class="player ${p2Winner ? 'winner' : ''}">
          <span class="seed">${match.player2_seed || ''}</span>
          <span class="name">${escapeHtml(p2Name) || 'TBD'}</span>
          ${match.player2_score !== null && match.player2_score !== undefined ?
            `<span class="score">${match.player2_score}</span>` : ''}
        </div>
      </div>
    </div>
  `;

  return html;
}

function getPlaceholderLabel(match, playerSlot, allMatches) {
  const from = playerSlot === 'player1' ? match.player1_from : match.player2_from;

  if (from === 'loser') {
    // Trouver le match source
    for (const sourceMatch of allMatches) {
      if (sourceMatch.next_match_loser_id === match.id) {
        const loserSlot = sourceMatch.next_match_loser_slot;
        if ((loserSlot === 'player1' && playerSlot === 'player1') ||
            (loserSlot === 'player2' && playerSlot === 'player2')) {
          return `Loser of ${sourceMatch.id}`;
        }
      }
    }
  }

  if (from === 'winner') {
    // Finals spéciaux
    if (match.bracket_type === 'finals') {
      if (playerSlot === 'player1') return 'Winner of Loser\'s Bracket';
      if (playerSlot === 'player2') return 'Winner of Winner\'s Bracket';
    }
  }

  return '';
}

function renderConnectorsSVG(fromMatches, toMatches, bracketType) {
  if (!toMatches || toMatches.length === 0) return '';

  // Simple connector line for now
  return `<svg class="connector-svg" width="40" height="100%">
    <line x1="0" y1="50%" x2="40" y2="50%" stroke="#4a4a4a" stroke-width="2"/>
  </svg>`;
}

function renderSimpleRoundRobin(matches) {
  const byRound = groupMatchesByRound(matches);

  let html = '<div class="round-robin-grid">';

  Object.keys(byRound).sort((a, b) => a - b).forEach(round => {
    html += `<div class="rr-round">`;
    html += `<h3>Round ${round}</h3>`;
    html += '<div class="rr-matches">';

    byRound[round].forEach(match => {
      const isClickable = match.player1_id && match.player2_id && match.status !== 'completed';
      html += `
        <div class="rr-match ${isClickable ? 'clickable' : ''}"
             ${isClickable ? `onclick="openScoreModal(${match.id})"` : ''}>
          <div class="rr-player ${match.winner_id === match.player1_id ? 'winner' : ''}">
            <span>${escapeHtml(match.player1_name) || 'TBD'}</span>
            ${match.player1_score !== null ? `<b>${match.player1_score}</b>` : ''}
          </div>
          <div class="rr-vs">vs</div>
          <div class="rr-player ${match.winner_id === match.player2_id ? 'winner' : ''}">
            <span>${escapeHtml(match.player2_name) || 'TBD'}</span>
            ${match.player2_score !== null ? `<b>${match.player2_score}</b>` : ''}
          </div>
        </div>
      `;
    });

    html += '</div></div>';
  });

  html += '</div>';

  return html;
}
