# Algorithmes de Tournois - Documentation Technique

## 📋 Vue d'ensemble

Implémentation complète des algorithmes de génération de brackets conformes aux standards **Challonge** et **start.gg**.

### Formats supportés

1. **Single Elimination** - Élimination directe
2. **Double Elimination** - Double élimination avec grand final reset
3. **Round Robin** - Tous contre tous avec circle method

---

## 🎯 Fonctionnalités Clés

### ✅ Implémenté

- [x] **Mirror Seeding** - Ordre standard pour éviter que les meilleurs seeds s'affrontent tôt
- [x] **Gestion automatique des byes** - Walkovers et progression automatique
- [x] **Double elimination correct** - Formule WB→LB corrigée (WB R1→LB R1, WB R2→LB R2, WB R3→LB R4)
- [x] **Grand Final Reset** - Si le champion du loser bracket gagne, match décisif
- [x] **Circle Method** - Génération optimisée des rounds pour round-robin
- [x] **Revert Match** - Annulation de résultats avec nettoyage en cascade
- [x] **Auto-advancement** - Propagation automatique des walkovers

---

## 📐 Algorithmes

### 1. Mirror Seeding

**Problème**: Comment placer les seeds pour éviter que les meilleurs s'affrontent tôt?

**Solution**: Algorithme récursif générant l'ordre miroir

```javascript
Pour 8 slots: [1, 8, 4, 5, 2, 7, 3, 6]

Matchups Round 1:
  M1: 1 vs 8 (meilleur vs pire)
  M2: 4 vs 5 (milieu)
  M3: 2 vs 7
  M4: 3 vs 6

Si 1 et 2 gagnent, ils ne se rencontrent qu'en finale
```

**Code**:

```javascript
function generateMirrorOrder(nSlots) {
  if (nSlots === 1) return [1];
  if (nSlots === 2) return [1, 2];

  const prevRound = generateMirrorOrder(nSlots / 2);
  const result = [];

  for (const seed of prevRound) {
    result.push(seed);
    result.push(nSlots + 1 - seed);
  }

  return result;
}
```

### 2. Gestion des Byes

**Problème**: Que faire si le nombre de joueurs n'est pas une puissance de 2?

**Solution**:
1. Arrondir au `next_pow2(n)` pour obtenir le nombre de slots
2. Placer les joueurs selon le mirror order
3. Les slots vides deviennent des **byes**
4. Auto-advancement: si un joueur n'a pas d'adversaire → walkover automatique

**Exemple**:
```
5 joueurs → 8 slots → 3 byes

Slots: [P1, P5, BYE, P3, P4, BYE, BYE, P2]

Round 1:
  M1: P1 vs P5 (normal)
  M2: BYE vs P3 → P3 gagne par walkover
  M3: P4 vs BYE → P4 gagne par walkover
  M4: BYE vs P2 → P2 gagne par walkover

Round 2:
  M1: BYE vs P3 → P3 gagne par walkover (propagation)
  M2: P4 vs P2 (normal)
```

### 3. Double Elimination - Formule Correcte

**Problème critique**: Où vont les perdants du Winner's Bracket dans le Loser's Bracket?

**FORMULE CORRECTE** (celle implémentée):
```
WB Round X → LB Round Y

Où Y = {
  1           si X = 1
  2×(X-1)     si X > 1
}

Exemples:
  WB R1 → LB R1  ✓
  WB R2 → LB R2  ✓ (NOT R3!)
  WB R3 → LB R4  ✓
```

**Pourquoi cette formule?**

Le loser bracket a deux types de rounds:
- **Rounds impairs**: Gagnants LB vs Gagnants LB
- **Rounds pairs**: Gagnants LB vs Perdants WB

### 4. Grand Final Reset

**Principe**: Dans une double élimination, chaque joueur a droit à **une défaite**.

- Champion du WB: 0 défaite
- Champion du LB: 1 défaite

**Si le champion du LB gagne la finale**:
→ Les deux ont 1 défaite
→ **RESET**: Match décisif (Finale R2)

**Implémentation**:
```javascript
// Créer 2 matchs de finale
matches.push({
  round: 1,
  bracket_type: 'finals',
  // ...
});

matches.push({
  round: 2,
  bracket_type: 'finals',
  status: 'conditional',  // Activé seulement si player2 gagne R1
  is_reset: true
});
```

### 5. Round-Robin - Circle Method

**Problème**: Comment organiser les matchs pour que:
- Chaque joueur affronte tous les autres exactement une fois
- Pas de conflits (un joueur ne peut pas jouer 2 matchs simultanés)

**Solution**: **Circle Method**

```
Exemple 6 joueurs (P1-P6):

Round 1:
  P1 vs P6
  P2 vs P5
  P3 vs P4

Round 2: (rotation, P1 fixe)
  P1 vs P5
  P6 vs P4
  P2 vs P3

Round 3:
  P1 vs P4
  P5 vs P3
  P6 vs P2

etc.
```

**Algorithme**:
```javascript
const positions = [0, 1, 2, 3, 4, 5];

Pour chaque round:
  - Créer des paires: positions[0] vs positions[n-1], positions[1] vs positions[n-2], etc.
  - Rotation: fixer positions[0], faire tourner les autres vers la droite
```

**Avantages**:
- ✓ Chaque joueur joue exactement `n-1` matchs
- ✓ Chaque round a `n/2` matchs simultanés
- ✓ Pas de doublons, pas de conflits
- ✓ Gère automatiquement les nombres impairs (bye)

---

## 🔧 API Usage

### Single Elimination

```javascript
const { buildSingleEliminationBracket } = require('./bracket-algorithms');

const players = [
  { player_id: 'P1', seed: 1 },
  { player_id: 'P2', seed: 2 },
  { player_id: 'P3', seed: 3 },
  { player_id: 'P4', seed: 4 },
  { player_id: 'P5', seed: 5 }
];

const { matches, metadata } = buildSingleEliminationBracket(players, true);

// metadata:
// {
//   format: 'single_elimination',
//   bracket_size: 8,
//   participant_count: 5,
//   byes_count: 3,
//   total_rounds: 3
// }
```

### Double Elimination

```javascript
const { buildDoubleEliminationBracket } = require('./bracket-algorithms');

const { matches, metadata } = buildDoubleEliminationBracket(
  players,
  true,        // useSeed
  true         // enableGrandFinalReset
);

// Trois types de matchs:
// - bracket_type: 'winners'
// - bracket_type: 'losers'
// - bracket_type: 'finals'
```

### Round Robin

```javascript
const { buildRoundRobinBracket } = require('./bracket-algorithms');

const { matches, rounds, metadata } = buildRoundRobinBracket(players);

// rounds: tableaux de matchs par round (utile pour scheduling)
// Gère automatiquement les nombres impairs avec bye
```

### Revert Match

```javascript
const { revertMatch } = require('./bracket-algorithms');

// Annuler un match et nettoyer les matchs suivants
const affectedMatches = revertMatch(allMatches, matchId);

// affectedMatches contient:
// - Le match revert
// - Les matchs suivants où les joueurs ont été retirés
```

---

## 🧪 Tests

Exécuter la suite de tests:

```bash
node api/test-brackets.js
```

**Tests inclus**:
- ✓ Mirror seeding pour 8 et 16 slots
- ✓ Placement avec byes (5 joueurs)
- ✓ Single elimination (auto-advancement)
- ✓ Double elimination (liens WB/LB corrects)
- ✓ Round-robin avec et sans bye
- ✓ Revert match
- ✓ Validation formule loser bracket

---

## 📊 Exemples Détaillés

### Cas 1: Single Elim - 5 joueurs

```
Bracket size: 8 (next_pow2(5))
Byes: 3

Mirror order: [1, 8, 4, 5, 2, 7, 3, 6]
Players: [P1(1), P5(5), BYE, P3(3), P4(4), BYE, BYE, P2(2)]

Round 1:
  M1: P1 vs P5       (pending)
  M2: BYE vs P3      (walkover → P3)
  M3: P4 vs BYE      (walkover → P4)
  M4: BYE vs P2      (walkover → P2)

Round 2:
  M1: BYE vs P3      (walkover → P3, auto-propagé)
  M2: P4 vs P2       (pending)

Round 3 (Finals):
  M1: P3 vs ?        (walkover si P3, sinon pending)
```

### Cas 2: Double Elim - 8 joueurs

```
Winner's Bracket: 7 matchs (3 rounds)
Loser's Bracket: 6 matchs (4 rounds)
Finals: 2 matchs (avec reset conditionnel)

Round 1 WB:
  M1: P1 vs P8 → Loser → LB R1 M1 slot 1
  M2: P4 vs P5 → Loser → LB R1 M1 slot 2
  M3: P2 vs P7 → Loser → LB R1 M2 slot 1
  M4: P3 vs P6 → Loser → LB R1 M2 slot 2

Round 2 WB:
  M1: Winner(M1) vs Winner(M2) → Loser → LB R2 M1 slot 2
  M2: Winner(M3) vs Winner(M4) → Loser → LB R2 M2 slot 2

LB R1 (odd round): Losers WB vs Losers WB
LB R2 (even round): Winners LB vs Losers WB
LB R3 (odd round): Winners LB vs Winners LB
LB R4 (even round): Winners LB vs Loser WB R3

Finals:
  R1: Champion WB vs Champion LB
  R2: (conditional) Si Champion LB gagne R1
```

---

## 🔗 Intégration avec Challonge/start.gg

Pour synchroniser avec les APIs externes:

1. **Mapping des IDs**:
   ```javascript
   participant.external_id = challonge_participant_id;
   match.external_id = challonge_match_id;
   ```

2. **Reporting scores**:
   ```javascript
   // Local
   await reportScore(matchId, scoreA, scoreB);

   // Sync to Challonge
   await axios.put(`https://api.challonge.com/v1/tournaments/${tournamentId}/matches/${match.external_id}`, {
     match: {
       scores_csv: `${scoreA}-${scoreB}`,
       winner_id: winnerId
     }
   });
   ```

3. **Polling pour changements**:
   ```javascript
   setInterval(async () => {
     const remoteMatches = await fetchChallongeMatches(tournamentId);
     // Comparer avec local et sync
   }, 30000); // Toutes les 30s
   ```

---

## ⚠️ Edge Cases Gérés

- [x] Nombre de joueurs = 1 (direct winner)
- [x] Nombre de joueurs = 2 (1 match)
- [x] Nombres impairs (byes automatiques)
- [x] Nombres premiers (ex: 7 → 8 slots, 1 bye)
- [x] Puissances de 2 parfaites (pas de byes)
- [x] Walkovers en cascade (multiple byes consécutifs)
- [x] Revert de match avec cleanup
- [x] Double bye (deux byes dans un match)

---

## 🚀 Prochaines Étapes

### Phase 1: Intégration (À faire)
- [ ] Intégrer les algorithmes dans `api/tournaments.js`
- [ ] Migrer generateBracket() vers les nouvelles fonctions
- [ ] Ajouter le support grand final reset dans l'API
- [ ] Mettre à jour le frontend pour afficher le reset

### Phase 2: Fonctionnalités Avancées
- [ ] Swiss System (pairings par points)
- [ ] Group Stage → Bracket (ex: 4 groupes de 4 → top 2 en playoffs)
- [ ] Best-of-N validation (nécessite scoreA > scoreB d'au moins (N+1)/2)
- [ ] Tiebreakers (head-to-head, goal diff, etc.)
- [ ] Scheduling automatique (avec contraintes horaires)

### Phase 3: Optimisations
- [ ] Cache des brackets générés
- [ ] Webhooks pour sync temps réel avec Challonge/start.gg
- [ ] Audit log complet (qui a modifié quoi, quand)
- [ ] Rollback intelligent (annuler plusieurs matchs)

---

## 📚 Références

- [Challonge API Documentation](https://api.challonge.com/v1)
- [start.gg Developer Portal](https://developer.start.gg/)
- [Double Elimination Structure](https://en.wikipedia.org/wiki/Double-elimination_tournament)
- [Round-Robin Circle Method](https://en.wikipedia.org/wiki/Round-robin_tournament#Scheduling_algorithm)
- [Tournament Seeding Best Practices](https://stackoverflow.com/questions/tagged/tournament-bracket)

---

## 📝 Notes Techniques

### Complexité

- **Génération bracket**: O(n) où n = participant count
- **Auto-advancement**: O(n × log n) dans le pire cas
- **Mirror order**: O(log n) récursif
- **Round-robin**: O(n²) pour n matchs

### Stockage

```sql
-- Structure recommandée
CREATE TABLE tournament_matches (
  id SERIAL PRIMARY KEY,
  tournament_id INT,
  round INT,
  match_number INT,
  bracket_type VARCHAR(20), -- 'winners', 'losers', 'finals', 'round_robin'
  player1_id VARCHAR(50),
  player2_id VARCHAR(50),
  player1_score INT,
  player2_score INT,
  winner_id VARCHAR(50),
  status VARCHAR(20), -- 'pending', 'in_progress', 'completed', 'walkover'
  next_match_winner_id INT, -- Lien vers le prochain match
  next_match_winner_slot VARCHAR(10), -- 'player1' ou 'player2'
  next_match_loser_id INT, -- Pour double elim
  next_match_loser_slot VARCHAR(10),
  is_reset BOOLEAN DEFAULT FALSE, -- Pour grand final reset
  completed_at TIMESTAMP
);
```

---

**Auteur**: Système de tournois Gouzepe eFOOT
**Date**: 2025-12-05
**Version**: 1.0.0
**License**: Propriétaire
