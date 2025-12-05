/**
 * bracket-svg-renderer.js
 * Générateur de bracket visuel style "Challonge" avec connexions SVG.
 * Version améliorée avec position: absolute et calcul de coordonnées
 */

const BRACKET_CONFIG = {
  cardWidth: 240,
  cardHeight: 90,
  gapX: 60,
  gapY: 20,
  padding: 40
};

/**
 * Fonction principale appelée par les pages HTML
 */
function renderBracketSVG(matches, format, tournamentInfo) {
  if (!matches || matches.length === 0) {
    return '<div class="empty">Aucun match</div>';
  }

  if (format === 'round_robin') {
    return renderRoundRobinSimple(matches);
  }

  // 1. Organiser les données
  const tree = buildBracketTree(matches, format);

  // 2. Calculer les positions (X, Y)
  const layout = calculateCoordinates(tree, format);

  // 3. Générer le HTML (Cartes + SVG)
  return generateDOM(layout, tree, matches, tournamentInfo);
}

// --- LOGIQUE DE POSITIONNEMENT ---

function buildBracketTree(matches, format) {
  const winners = matches.filter(m => m.bracket_type === 'winners');
  const losers = matches.filter(m => m.bracket_type === 'losers');
  const finals = matches.filter(m => m.bracket_type === 'finals');
  const thirdPlace = matches.filter(m => m.bracket_type === 'third_place');

  const groupByRound = (arr) => {
    const rounds = {};
    arr.forEach(m => {
      if (!rounds[m.round]) rounds[m.round] = [];
      rounds[m.round].push(m);
    });
    Object.keys(rounds).forEach(r => {
      rounds[r].sort((a, b) => a.match_number - b.match_number);
    });
    return rounds;
  };

  return {
    winners: groupByRound(winners),
    losers: groupByRound(losers),
    finals: groupByRound(finals),
    thirdPlace: groupByRound(thirdPlace),
    allMatches: matches
  };
}

function calculateCoordinates(tree, format) {
  const positions = new Map();
  const roundX = {};

  // --- WINNER BRACKET ---
  const wRounds = Object.keys(tree.winners).map(Number).sort((a,b)=>a-b);
  const maxWRound = Math.max(...wRounds, 0);

  wRounds.forEach(r => {
    roundX[`w_${r}`] = (r - 1) * (BRACKET_CONFIG.cardWidth + BRACKET_CONFIG.gapX) + BRACKET_CONFIG.padding;
  });

  // Round 1: empiler verticalement
  const firstRoundMatches = tree.winners[1] || [];
  let currentY = BRACKET_CONFIG.padding;

  firstRoundMatches.forEach(m => {
    positions.set(m.id, {
      x: roundX['w_1'],
      y: currentY
    });
    currentY += BRACKET_CONFIG.cardHeight + BRACKET_CONFIG.gapY;
  });

  // Rounds suivants: Y = moyenne des Y des parents
  for (let r = 2; r <= maxWRound; r++) {
    const matchesInRound = tree.winners[r] || [];
    matchesInRound.forEach(m => {
      const prevRound = tree.winners[r-1];
      const p1Index = (m.match_number * 2) - 2;
      const p2Index = (m.match_number * 2) - 1;

      const p1 = prevRound[p1Index];
      const p2 = prevRound[p2Index];

      let y;
      if (p1 && p2 && positions.has(p1.id) && positions.has(p2.id)) {
        y = (positions.get(p1.id).y + positions.get(p2.id).y) / 2;
      } else {
        y = currentY;
        currentY += BRACKET_CONFIG.cardHeight + BRACKET_CONFIG.gapY;
      }

      positions.set(m.id, {
        x: roundX[`w_${r}`],
        y: y
      });
    });
  }

  let maxY = Math.max(...Array.from(positions.values()).map(p => p.y)) + BRACKET_CONFIG.cardHeight;

  // --- LOSER BRACKET ---
  if (format === 'double_elimination' && Object.keys(tree.losers).length > 0) {
    const lRounds = Object.keys(tree.losers).map(Number).sort((a,b)=>a-b);
    const startYLoser = maxY + BRACKET_CONFIG.cardHeight;

    lRounds.forEach(r => {
      roundX[`l_${r}`] = (r - 1) * (BRACKET_CONFIG.cardWidth + BRACKET_CONFIG.gapX) + BRACKET_CONFIG.padding;

      const matches = tree.losers[r];
      let localY = startYLoser;

      matches.forEach(m => {
        positions.set(m.id, {
          x: roundX[`l_${r}`],
          y: localY
        });
        localY += BRACKET_CONFIG.cardHeight + BRACKET_CONFIG.gapY;
      });
    });

    const lMaxY = Math.max(...Array.from(positions.values()).map(p => p.y)) + BRACKET_CONFIG.cardHeight;
    maxY = Math.max(maxY, lMaxY);
  }

  // --- FINALS ---
  if (tree.finals && tree.finals[1] && tree.finals[1].length > 0) {
    const finalsMatch = tree.finals[1][0];
    const finalX = (maxWRound) * (BRACKET_CONFIG.cardWidth + BRACKET_CONFIG.gapX) + BRACKET_CONFIG.padding;

    let finalY = BRACKET_CONFIG.padding;
    const lastWinnerMatch = tree.winners[maxWRound] ? tree.winners[maxWRound][0] : null;
    if (lastWinnerMatch && positions.has(lastWinnerMatch.id)) {
        finalY = positions.get(lastWinnerMatch.id).y;
    }

    positions.set(finalsMatch.id, { x: finalX, y: finalY });
    roundX['f_1'] = finalX;
  }

  // --- THIRD PLACE ---
  if (tree.thirdPlace && tree.thirdPlace[1] && tree.thirdPlace[1].length > 0) {
     const tpMatch = tree.thirdPlace[1][0];
     const finalX = (maxWRound) * (BRACKET_CONFIG.cardWidth + BRACKET_CONFIG.gapX) + BRACKET_CONFIG.padding;

     let finalY = BRACKET_CONFIG.padding;
     if (tree.finals && tree.finals[1] && tree.finals[1].length > 0) {
       finalY = positions.get(tree.finals[1][0].id).y + BRACKET_CONFIG.cardHeight + 40;
     }

     positions.set(tpMatch.id, { x: finalX, y: finalY });
  }

  const allX = Array.from(positions.values()).map(p => p.x);
  const width = Math.max(...allX) + BRACKET_CONFIG.cardWidth + BRACKET_CONFIG.padding;

  return { positions, width, height: maxY + BRACKET_CONFIG.padding };
}

// --- RENDU DOM & SVG ---

function generateDOM(layout, tree, allMatches, tournamentInfo) {
  // Titre en HTML
  let html = '';
  if (tournamentInfo) {
    html += `
      <div style="padding:16px 20px;margin-bottom:20px;background:linear-gradient(90deg, rgba(37,99,235,0.2), rgba(37,99,235,0.05));border-left:4px solid #2563eb;border-radius:8px;">
        <h3 style="margin:0;color:var(--text);font-size:18px;font-weight:700;">
          ${escapeHtml(tournamentInfo.name || 'Tournament')}
        </h3>
      </div>
    `;
  }

  html += `<div style="position:relative; width:${layout.width}px; height:${layout.height}px; min-width:100%;">`;

  // 1. SVG Layer (Lignes)
  html += `<svg style="position:absolute; top:0; left:0; width:100%; height:100%; pointer-events:none; z-index:0">`;

  allMatches.forEach(match => {
    if (match.next_match_winner_id) {
        const start = layout.positions.get(match.id);
        const end = layout.positions.get(match.next_match_winner_id);

        if (start && end) {
            html += drawConnector(start, end, match.next_match_winner_slot === 'player2');
        }
    }
  });

  html += `</svg>`;

  // 2. HTML Layer (Cartes Match)
  allMatches.forEach(match => {
    const pos = layout.positions.get(match.id);
    if (!pos) return;

    const statusClass = match.status;
    const isEditable = (match.player1_id && match.player2_id && match.status !== 'completed');

    html += `
      <div class="bracket-node ${statusClass} ${isEditable ? 'editable' : ''}"
           style="position:absolute; left:${pos.x}px; top:${pos.y}px; width:${BRACKET_CONFIG.cardWidth}px; height:${BRACKET_CONFIG.cardHeight}px;"
           ${isEditable ? `onclick="openScoreModal(${match.id})"` : ''}
           data-id="${match.id}">

        <div class="node-header">
           <span class="match-id">#${match.match_number}</span>
           <span class="round-name">${getShortRoundName(match.bracket_type, match.round)}</span>
        </div>

        <div class="node-player ${match.winner_id === match.player1_id ? 'winner' : ''} ${match.status==='completed' && match.winner_id!==match.player1_id ? 'loser' : ''}">
          <span class="name">${escapeHtml(match.player1_name || '-')}</span>
          <span class="score">${match.player1_score !== null && match.player1_score !== undefined ? match.player1_score : ''}</span>
        </div>

        <div class="node-player ${match.winner_id === match.player2_id ? 'winner' : ''} ${match.status==='completed' && match.winner_id!==match.player2_id ? 'loser' : ''}">
          <span class="name">${escapeHtml(match.player2_name || '-')}</span>
          <span class="score">${match.player2_score !== null && match.player2_score !== undefined ? match.player2_score : ''}</span>
        </div>

      </div>
    `;
  });

  html += `</div>`;
  return html;
}

function drawConnector(start, end, isPlayer2Slot) {
  const x1 = start.x + BRACKET_CONFIG.cardWidth;
  const y1 = start.y + (BRACKET_CONFIG.cardHeight / 2);

  const x2 = end.x;
  const y2 = end.y + (BRACKET_CONFIG.cardHeight / 2);

  const midX = x1 + (BRACKET_CONFIG.gapX / 2);

  return `<path d="M ${x1} ${y1} H ${midX} V ${y2} H ${x2}"
            fill="none" stroke="var(--border)" stroke-width="2" stroke-linecap="round" />`;
}

// --- UTILITAIRES ---

function renderRoundRobinSimple(matches) {
  const byRound = {};
  matches.forEach(m => {
    if (!byRound[m.round]) byRound[m.round] = [];
    byRound[m.round].push(m);
  });

  let html = '<div class="round-robin-container" style="padding:20px;background:var(--bg);">';

  Object.keys(byRound).sort((a, b) => a - b).forEach(round => {
    html += `<div class="rr-round" style="margin-bottom:30px;">`;
    html += `<h3 style="color:#2563eb;margin-bottom:16px;">Round ${round}</h3>`;
    html += '<div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:12px;">';

    byRound[round].forEach(match => {
      const isEditable = match.player1_id && match.player2_id && match.status !== 'completed';
      html += `
        <div class="rr-match ${isEditable ? 'clickable' : ''}"
             ${isEditable ? `onclick="openScoreModal(${match.id})"` : ''}
             style="background:#3a3a3a;border:1px solid #4a4a4a;border-radius:6px;padding:16px;display:flex;align-items:center;gap:16px;${isEditable ? 'cursor:pointer;' : ''}">
          <div style="flex:1;display:flex;justify-content:space-between;padding:8px 12px;background:#2a2a2a;border-radius:4px;${match.winner_id === match.player1_id ? 'border:1px solid #22c55e;' : ''}">
            <span style="color:#fff;font-size:13px;">${escapeHtml(match.player1_name || 'TBD')}</span>
            ${match.player1_score !== null ? `<b style="color:#fff;font-size:14px;">${match.player1_score}</b>` : ''}
          </div>
          <span style="color:#666;font-size:11px;font-weight:700;">vs</span>
          <div style="flex:1;display:flex;justify-content:space-between;padding:8px 12px;background:#2a2a2a;border-radius:4px;${match.winner_id === match.player2_id ? 'border:1px solid #22c55e;' : ''}">
            <span style="color:#fff;font-size:13px;">${escapeHtml(match.player2_name || 'TBD')}</span>
            ${match.player2_score !== null ? `<b style="color:#fff;font-size:14px;">${match.player2_score}</b>` : ''}
          </div>
        </div>
      `;
    });

    html += '</div></div>';
  });

  html += '</div>';
  return html;
}

function getShortRoundName(type, round) {
  if (type === 'finals') return 'Finale';
  if (type === 'third_place') return '3ème';
  if (type === 'losers') return `L${round}`;
  return `R${round}`;
}

function escapeHtml(text) {
  if (!text) return '';
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}
