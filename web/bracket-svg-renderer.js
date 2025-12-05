/**
 * SVG Bracket Renderer - Basé sur l'approche React/SVG
 * Adaptation pour notre système existant
 */

function renderBracketSVG(matches, format, tournament) {
  if (format === 'round_robin') {
    return renderRoundRobinSimple(matches);
  }

  // Séparer par type de bracket
  const winnersMatches = matches.filter(m => m.bracket_type === 'winners')
    .sort((a, b) => a.round - b.round || a.match_number - b.match_number);

  const losersMatches = matches.filter(m => m.bracket_type === 'losers')
    .sort((a, b) => a.round - b.round || a.match_number - b.match_number);

  const finalsMatches = matches.filter(m => m.bracket_type === 'finals')
    .sort((a, b) => a.round - b.round);

  // Grouper par rounds
  const wRounds = groupByRound(winnersMatches);
  const lRounds = groupByRound(losersMatches);

  // Constantes de layout (comme dans l'exemple React)
  const BOX_W = 220;
  const BOX_H = 50;
  const GAP_Y = 20;
  const COL_W = 280;
  const LEFT_OFFSET = 40;
  const TOP_OFFSET = 60;

  // Calculer hauteur totale nécessaire
  const maxWinnersInRound = Math.max(...Object.values(wRounds).map(r => r.length));
  const maxLosersInRound = Math.max(...Object.values(lRounds).map(r => r.length), 1);

  const winnersHeight = maxWinnersInRound * (BOX_H + GAP_Y) + 100;
  const losersHeight = maxLosersInRound * (BOX_H + GAP_Y) + 100;
  const svgHeight = winnersHeight + losersHeight + 200;

  const wRoundKeys = Object.keys(wRounds).map(Number).sort((a, b) => a - b);
  const lRoundKeys = Object.keys(lRounds).map(Number).sort((a, b) => a - b);

  const svgWidth = Math.max(
    (wRoundKeys.length * COL_W) + LEFT_OFFSET + 200,
    (lRoundKeys.length * COL_W) + LEFT_OFFSET + 200,
    1400
  );

  // Positionner les matchs et stocker leurs coordonnées
  const positions = new Map();

  // Positionner Winners Bracket
  wRoundKeys.forEach((round, colIdx) => {
    const roundMatches = wRounds[round];
    const x = LEFT_OFFSET + (colIdx * COL_W);

    // Calculer l'espacement vertical qui double à chaque round
    const totalSlots = Math.pow(2, wRoundKeys.length - colIdx);
    const slotHeight = (BOX_H + GAP_Y);
    const spacing = slotHeight * Math.pow(2, colIdx);

    let y = TOP_OFFSET + (totalSlots * slotHeight - roundMatches.length * spacing) / 2;

    roundMatches.forEach((match, idx) => {
      positions.set(match.id, {
        x,
        y,
        w: BOX_W,
        h: BOX_H,
        match,
        side: 'W',
        round,
        index: idx
      });
      y += spacing;
    });
  });

  // Positionner Losers Bracket (en dessous)
  const losersYOffset = winnersHeight + 100;

  lRoundKeys.forEach((round, colIdx) => {
    const roundMatches = lRounds[round];
    const x = LEFT_OFFSET + (colIdx * COL_W);

    // Espacement pour losers (alternance entre rounds)
    const baseSpacing = (BOX_H + GAP_Y);
    const multiplier = Math.pow(2, Math.floor(colIdx / 2));
    const spacing = baseSpacing * multiplier;

    let y = losersYOffset + TOP_OFFSET;

    roundMatches.forEach((match, idx) => {
      positions.set(match.id, {
        x,
        y,
        w: BOX_W,
        h: BOX_H,
        match,
        side: 'L',
        round,
        index: idx
      });
      y += spacing;
    });
  });

  // Positionner Finals (au centre en bas)
  if (finalsMatches.length > 0) {
    const finalsX = svgWidth / 2 - BOX_W / 2;
    let finalsY = svgHeight - 150;

    finalsMatches.forEach(match => {
      positions.set(match.id, {
        x: finalsX,
        y: finalsY,
        w: BOX_W + 40,
        h: BOX_H,
        match,
        side: 'F',
        round: match.round
      });
      finalsY += BOX_H + 30;
    });
  }

  // Générer les connexions SVG
  const connectors = generateConnectors(positions, matches);

  // Construire le HTML avec SVG
  let html = `
    <div class="svg-bracket-container" style="background:#2a2a2a;padding:20px;overflow:auto;">
      <svg width="${svgWidth}" height="${svgHeight}" xmlns="http://www.w3.org/2000/svg">
        <!-- Titre -->
        <text x="20" y="30" fill="#fff" font-size="18" font-weight="700">
          ${escapeHtml(tournament?.name || 'Tournament')} - ${format.toUpperCase()}
        </text>

        <!-- Headers Winners -->
        ${renderRoundHeaders(wRoundKeys, 'winners', LEFT_OFFSET, TOP_OFFSET - 40, COL_W)}

        <!-- Headers Losers -->
        ${lRoundKeys.length > 0 ? `
          <text x="${svgWidth/2}" y="${losersYOffset - 20}" fill="#ef4444" font-size="14" font-weight="700" text-anchor="middle">
            LOSER'S BRACKET
          </text>
          ${renderRoundHeaders(lRoundKeys, 'losers', LEFT_OFFSET, losersYOffset + TOP_OFFSET - 40, COL_W)}
        ` : ''}

        <!-- Connexions -->
        ${connectors.map(c => `
          <path d="${c.path}" stroke="#4a4a4a" stroke-width="2" fill="none"/>
        `).join('')}

        <!-- Matchs -->
        ${Array.from(positions.values()).map(pos => renderMatchBox(pos, matches)).join('')}
      </svg>
    </div>
  `;

  return html;
}

function groupByRound(matches) {
  const rounds = {};
  matches.forEach(m => {
    if (!rounds[m.round]) rounds[m.round] = [];
    rounds[m.round].push(m);
  });
  return rounds;
}

function renderRoundHeaders(roundKeys, type, offsetX, offsetY, colW) {
  const roundNames = {
    winners: ['Round 1', 'Round 2', 'Round 3', 'Semifinals', 'Finals'],
    losers: (r) => `Losers Round ${r}`
  };

  return roundKeys.map((round, idx) => {
    const x = offsetX + (idx * colW) + 110; // Center in column
    const name = type === 'winners'
      ? (roundNames.winners[idx] || `Round ${round}`)
      : roundNames.losers(round);

    return `
      <rect x="${offsetX + idx * colW}" y="${offsetY}" width="220" height="32" fill="#374151" rx="4"/>
      <text x="${x}" y="${offsetY + 20}" fill="#9ca3af" font-size="12" font-weight="700" text-anchor="middle">
        ${name.toUpperCase()}
      </text>
    `;
  }).join('');
}

function renderMatchBox(pos, allMatches) {
  const { x, y, w, h, match } = pos;

  // Obtenir les noms des joueurs
  const p1Name = match.player1_name || getPlaceholder(match, 'player1', allMatches);
  const p2Name = match.player2_name || getPlaceholder(match, 'player2', allMatches);

  const p1Winner = match.winner_id && match.winner_id === match.player1_id;
  const p2Winner = match.winner_id && match.winner_id === match.player2_id;

  const isClickable = match.player1_id && match.player2_id && match.status !== 'completed';

  return `
    <g class="match-group ${isClickable ? 'clickable' : ''}"
       data-match-id="${match.id}"
       ${isClickable ? `onclick="openScoreModal(${match.id})"` : ''}
       style="${isClickable ? 'cursor:pointer' : ''}">

      <!-- Box background -->
      <rect x="${x}" y="${y}" width="${w}" height="${h}" fill="#3a3a3a" stroke="#4f4f4f" stroke-width="1" rx="3"/>

      <!-- Match number -->
      <text x="${x + w - 5}" y="${y + 12}" fill="#666" font-size="9" font-weight="600" text-anchor="end">
        ${match.id}
      </text>

      <!-- Player 1 -->
      <rect x="${x}" y="${y}" width="${w}" height="${h/2}" fill="${p1Winner ? 'rgba(34,197,94,0.1)' : 'transparent'}" rx="3"/>
      ${p1Winner ? `<rect x="${x}" y="${y}" width="3" height="${h/2}" fill="#22c55e"/>` : ''}
      <text x="${x + 10}" y="${y + 16}" fill="#fff" font-size="13">
        ${escapeHtml(p1Name || 'TBD')}
      </text>
      ${match.player1_score !== null && match.player1_score !== undefined ? `
        <text x="${x + w - 10}" y="${y + 16}" fill="#fff" font-size="13" font-weight="700" text-anchor="end">
          ${match.player1_score}
        </text>
      ` : ''}

      <!-- Separator -->
      <line x1="${x}" y1="${y + h/2}" x2="${x + w}" y2="${y + h/2}" stroke="#4f4f4f" stroke-width="1"/>

      <!-- Player 2 -->
      <rect x="${x}" y="${y + h/2}" width="${w}" height="${h/2}" fill="${p2Winner ? 'rgba(34,197,94,0.1)' : 'transparent'}" rx="3"/>
      ${p2Winner ? `<rect x="${x}" y="${y + h/2}" width="3" height="${h/2}" fill="#22c55e"/>` : ''}
      <text x="${x + 10}" y="${y + h/2 + 16}" fill="#fff" font-size="13">
        ${escapeHtml(p2Name || 'TBD')}
      </text>
      ${match.player2_score !== null && match.player2_score !== undefined ? `
        <text x="${x + w - 10}" y="${y + h/2 + 16}" fill="#fff" font-size="13" font-weight="700" text-anchor="end">
          ${match.player2_score}
        </text>
      ` : ''}

      ${isClickable ? `
        <rect x="${x}" y="${y}" width="${w}" height="${h}" fill="transparent" stroke="transparent" stroke-width="2" rx="3">
          <animate attributeName="stroke" begin="mouseover" end="mouseout" from="transparent" to="#2563eb" dur="0.2s" fill="freeze"/>
        </rect>
      ` : ''}
    </g>
  `;
}

function getPlaceholder(match, playerSlot, allMatches) {
  const from = playerSlot === 'player1' ? match.player1_from : match.player2_from;

  if (from === 'loser') {
    for (const source of allMatches) {
      if (source.next_match_loser_id === match.id) {
        const slot = source.next_match_loser_slot;
        if ((slot === 'player1' && playerSlot === 'player1') ||
            (slot === 'player2' && playerSlot === 'player2')) {
          return `Loser of ${source.id}`;
        }
      }
    }
  }

  if (from === 'winner' && match.bracket_type === 'finals') {
    if (playerSlot === 'player1') return "Winner of Loser's Bracket";
    if (playerSlot === 'player2') return "Winner of Winner's Bracket";
  }

  return '';
}

function generateConnectors(positions, allMatches) {
  const connectors = [];

  positions.forEach((fromPos, matchId) => {
    const match = fromPos.match;

    // Trouver le prochain match pour le gagnant
    if (match.next_match_winner_id) {
      const toPos = positions.get(match.next_match_winner_id);
      if (toPos) {
        const slot = match.next_match_winner_slot;

        // Point de départ: milieu droit du match actuel
        const x1 = fromPos.x + fromPos.w;
        const y1 = fromPos.y + fromPos.h / 2;

        // Point d'arrivée: gauche du prochain match, haut ou bas selon le slot
        const x2 = toPos.x;
        const y2 = slot === 'player1'
          ? toPos.y + toPos.h / 4
          : toPos.y + (3 * toPos.h / 4);

        // Courbe bézier cubique
        const cx1 = x1 + (x2 - x1) * 0.5;
        const cx2 = x2 - (x2 - x1) * 0.5;

        connectors.push({
          path: `M ${x1} ${y1} C ${cx1} ${y1} ${cx2} ${y2} ${x2} ${y2}`
        });
      }
    }

    // Connexions pour les perdants (double elim)
    if (match.next_match_loser_id && match.bracket_type !== 'round_robin') {
      const toPos = positions.get(match.next_match_loser_id);
      if (toPos) {
        const slot = match.next_match_loser_slot;

        const x1 = fromPos.x + fromPos.w;
        const y1 = fromPos.y + fromPos.h / 2;

        const x2 = toPos.x;
        const y2 = slot === 'player1'
          ? toPos.y + toPos.h / 4
          : toPos.y + (3 * toPos.h / 4);

        const cx1 = x1 + (x2 - x1) * 0.3;
        const cx2 = x2 - (x2 - x1) * 0.3;

        connectors.push({
          path: `M ${x1} ${y1} C ${cx1} ${y1} ${cx2} ${y2} ${x2} ${y2}`,
          isLoser: true
        });
      }
    }
  });

  return connectors;
}

function renderRoundRobinSimple(matches) {
  const byRound = groupByRound(matches);

  let html = '<div class="round-robin-container" style="padding:20px;background:#2a2a2a;">';

  Object.keys(byRound).sort((a, b) => a - b).forEach(round => {
    html += `<div class="rr-round" style="margin-bottom:30px;">`;
    html += `<h3 style="color:#2563eb;margin-bottom:16px;">Round ${round}</h3>`;
    html += '<div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:12px;">';

    byRound[round].forEach(match => {
      const isClickable = match.player1_id && match.player2_id && match.status !== 'completed';
      html += `
        <div class="rr-match ${isClickable ? 'clickable' : ''}"
             ${isClickable ? `onclick="openScoreModal(${match.id})"` : ''}
             style="background:#3a3a3a;border:1px solid #4a4a4a;border-radius:6px;padding:16px;display:flex;align-items:center;gap:16px;${isClickable ? 'cursor:pointer;' : ''}">
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
