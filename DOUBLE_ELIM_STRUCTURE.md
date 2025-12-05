# Structure Double Élimination - 8 Joueurs (CORRECTE)

## Winner's Bracket (3 rounds)

```
ROUND 1 (4 matchs):
  WM1: J1 vs J8
  WM2: J4 vs J5
  WM3: J2 vs J7
  WM4: J3 vs J6

ROUND 2 (2 matchs):
  WM5: G(WM1) vs G(WM2)
  WM6: G(WM3) vs G(WM4)

ROUND 3 (1 match - Finals WB):
  WM7: G(WM5) vs G(WM6)
```

## Loser's Bracket (4 rounds, PAS 5!)

```
ROUND 1 (2 matchs): PERDANTS de WB R1
  LM1: P(WM1) vs P(WM2)
  LM2: P(WM3) vs P(WM4)

ROUND 2 (2 matchs): GAGNANTS LB R1 vs PERDANTS WB R2
  LM3: G(LM1) [p1] vs P(WM5) [p2]
  LM4: G(LM2) [p1] vs P(WM6) [p2]

ROUND 3 (1 match): GAGNANTS LB R2
  LM5: G(LM3) vs G(LM4)

ROUND 4 (1 match): GAGNANT LB R3 vs PERDANT WB R3
  LM6: G(LM5) [p1] vs P(WM7) [p2]
```

## Grand Finals

```
GF: G(WM7) [p1] vs G(LM6) [p2]
```

## FORMULE CORRECTE

Pour bracket size 2^n (n = nombre de rounds WB):

**Loser's Bracket a:** (n - 1) * 2 rounds

Pour 8 joueurs: n=3, donc LB = (3-1)*2 = **4 rounds** ✓

## Pattern de progression (LA CLÉ!)

**De WB vers LB:**
- WB R1 perdants → LB R1
- WB R2 perdants → LB R2 (pas R3!)
- WB R3 perdants → LB R4 (pas R5!)
- Formule: `WB Round X perdants → LB Round 2*(X-1) + (X > 1 ? 0 : 1)`
  - X=1: 2*0 + 1 = 1 ✓
  - X=2: 2*1 + 0 = 2 ✓
  - X=3: 2*2 + 0 = 4 ✓

**Dans LB:**
- Rounds IMPAIRS (1, 3, ...): Les perdants du WB s'affrontent OU gagnants LB s'affrontent
- Rounds PAIRS (2, 4, ...): Gagnants LB précédent vs Perdants WB

## Structure des matchs

- **LB R1:** player1=loser, player2=loser (2 perdants WB s'affrontent)
- **LB R2:** player1=winner (LB R1), player2=loser (WB R2)
- **LB R3:** player1=winner (LB R2), player2=winner (LB R2)
- **LB R4:** player1=winner (LB R3), player2=loser (WB R3)
