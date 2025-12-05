-- Nettoyage des player_id contenant des caractères invisibles (newlines, tabs, espaces)
-- À exécuter une seule fois pour corriger les données existantes

BEGIN;

-- 1. Afficher les IDs problématiques AVANT nettoyage
SELECT
  player_id,
  name,
  length(player_id) as len,
  encode(player_id::bytea, 'hex') as hex_repr
FROM players
WHERE
  player_id != trim(player_id)
  OR player_id ~ '\s'  -- Contient des espaces/tabs/newlines
ORDER BY player_id;

-- 2. Mettre à jour les player_id en les trimmant et en enlevant les caractères invisibles
UPDATE players
SET player_id = regexp_replace(trim(player_id), '\s+', '', 'g')
WHERE
  player_id != trim(player_id)
  OR player_id ~ '\s';

-- 3. Afficher combien d'enregistrements ont été mis à jour
-- (Cette requête ne retournera rien car les IDs ont déjà été corrigés)
SELECT
  player_id,
  name,
  'CORRIGÉ' as status
FROM players
WHERE
  player_id != trim(player_id)
  OR player_id ~ '\s';

-- 4. Vérifier qu'il n'y a plus de problèmes
SELECT COUNT(*) as remaining_issues
FROM players
WHERE
  player_id != trim(player_id)
  OR player_id ~ '\s';

COMMIT;

-- NOTE: Si des erreurs de contrainte apparaissent (doublons après nettoyage),
-- il faudra fusionner manuellement les joueurs en double.
