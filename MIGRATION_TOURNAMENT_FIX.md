# Migration - Fix Tournois Double Elimination

## ⚠️ ÉTAPE OBLIGATOIRE : Mise à jour de la base de données

**Vous DEVEZ exécuter ce SQL AVANT de redémarrer le serveur**, sinon les tournois ne fonctionneront pas !

### Comment exécuter le SQL :

#### Option 1 : Via psql (Terminal)
```bash
psql -U postgres -d gouzepe_efootball -f fix_tournament_columns.sql
```

#### Option 2 : Via pgAdmin
1. Ouvrir pgAdmin
2. Connectez-vous à votre base `gouzepe_efootball`
3. Cliquer sur "Tools" > "Query Tool"
4. Copier-coller le contenu du fichier `fix_tournament_columns.sql`
5. Appuyer sur F5 ou cliquer sur le bouton ▶ "Execute"

#### Option 3 : Via votre interface de gestion de BDD
Copier-coller ce code dans votre interface SQL :

```sql
-- Ajoute les colonnes pour savoir où envoyer les joueurs après le match
ALTER TABLE tournament_matches
ADD COLUMN IF NOT EXISTS next_match_winner_id INTEGER,
ADD COLUMN IF NOT EXISTS next_match_winner_slot TEXT,
ADD COLUMN IF NOT EXISTS next_match_loser_id INTEGER,
ADD COLUMN IF NOT EXISTS next_match_loser_slot TEXT;

-- Ajoute les colonnes pour savoir d'où viennent les joueurs (visuel bracket)
ALTER TABLE tournament_matches
ADD COLUMN IF NOT EXISTS player1_from TEXT,
ADD COLUMN IF NOT EXISTS player2_from TEXT;
```

### Vérification :

Après avoir exécuté le SQL, vérifiez que les colonnes existent :

```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'tournament_matches'
ORDER BY ordinal_position;
```

Vous devriez voir les colonnes :
- `next_match_winner_id` (integer)
- `next_match_winner_slot` (text)
- `next_match_loser_id` (integer)
- `next_match_loser_slot` (text)
- `player1_from` (text)
- `player2_from` (text)

---

## 🎯 Corrections appliquées

### 1. **Problème principal résolu : indexOf() → Map**

**Avant** :
```javascript
match.next_match_loser_id = matches.indexOf(loserMatch); // ❌ FRAGILE
```

**Après** :
```javascript
const key = `${match.bracket_type}_${match.round}_${match.match_number}`;
savedMatchesMap.set(key, dbId); // ✅ ROBUSTE
nextLoseId = savedMatchesMap.get(`losers_${lbRound}_${lbMatch}`);
```

### 2. **Ajout manuel corrigé**
- Génération d'ID unique : `guest_${timestamp}_${random}`
- Seed automatique (dernier + 1)
- Pas de contrainte email

### 3. **Logs détaillés ajoutés**
```
🎯 Génération du bracket pour le tournoi 5...
👥 8 participants
📊 Double Elimination: 19 matchs
🔗 Sauvegarde et liaison de 19 matchs...
✅ 19 matchs sauvegardés
  WB R1 M1 → WB R2 M1 [player1]
  WB R1 M1 LOSER → LB R1 M1 [player1]
✅ 18 liens créés
✅ Bracket généré avec succès
```

---

## 🧪 Test après migration

1. **Redémarrer le serveur backend** pour charger le nouveau code

2. **Créer un nouveau tournoi** :
   - Format : Double Elimination
   - 4 à 8 participants

3. **Générer le bracket** :
   - Vérifier les logs serveur
   - Vous devriez voir `WB R1 M1 LOSER → LB R1 M1 [player1]`

4. **Entrer un score dans le Winner's Bracket** :
   - Le gagnant doit progresser automatiquement
   - **Le perdant doit descendre au Loser's Bracket** ✅
   - Vérifier les logs : `✅ Perdant → Match X [player1_id]`

5. **Ajouter un participant manuellement** :
   - Utiliser le champ "Ajout manuel"
   - Devrait fonctionner même si le tournoi est en cours

---

## 📁 Fichiers modifiés

- `api/tournaments.js` - Logique corrigée (backup dans `tournaments.js.backup`)
- `fix_tournament_columns.sql` - Migration SQL

## ⚠️ En cas de problème

Si après la migration les tournois existants ne fonctionnent toujours pas :

```sql
-- Supprimer tous les matchs et régénérer
DELETE FROM tournament_matches WHERE tournament_id = [ID_DU_TOURNOI];
```

Puis régénérer le bracket depuis l'interface admin.

---

**Questions ?** Vérifiez les logs du serveur backend - ils sont maintenant très détaillés !
