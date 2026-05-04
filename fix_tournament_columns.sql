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

-- Afficher les colonnes pour vérification
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'tournament_matches'
ORDER BY ordinal_position;
