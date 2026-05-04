-- ========================================================
-- Schéma de base de données pour la gestion des tournois
-- Compatible avec Challonge et start.gg
-- ========================================================

-- Table principale des tournois
CREATE TABLE IF NOT EXISTS tournaments (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  format TEXT NOT NULL CHECK (format IN ('single_elimination', 'double_elimination', 'round_robin')),
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'registration', 'in_progress', 'completed', 'cancelled')),

  -- Dates
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  registration_start TIMESTAMPTZ,
  registration_end TIMESTAMPTZ,
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,

  -- Configuration
  max_participants INTEGER,
  third_place_match BOOLEAN DEFAULT false, -- Pour single/double elimination

  -- Métadonnées
  created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
  winner_id TEXT REFERENCES players(player_id) ON DELETE SET NULL,
  runner_up_id TEXT REFERENCES players(player_id) ON DELETE SET NULL,
  third_place_id TEXT REFERENCES players(player_id) ON DELETE SET NULL,

  -- Statistiques
  total_matches INTEGER DEFAULT 0,
  completed_matches INTEGER DEFAULT 0
);

-- Table des participants aux tournois
CREATE TABLE IF NOT EXISTS tournament_participants (
  id SERIAL PRIMARY KEY,
  tournament_id INTEGER NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
  player_id TEXT NOT NULL REFERENCES players(player_id) ON DELETE CASCADE,

  -- Statut
  registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  seed INTEGER, -- Position de seed (1 = meilleur, utilisé pour le bracket)
  status TEXT NOT NULL DEFAULT 'registered' CHECK (status IN ('registered', 'checked_in', 'disqualified', 'withdrawn')),

  -- Statistiques du tournoi
  wins INTEGER DEFAULT 0,
  losses INTEGER DEFAULT 0,
  points_for INTEGER DEFAULT 0,
  points_against INTEGER DEFAULT 0,

  -- Position finale
  final_placement INTEGER, -- Position finale (1 = winner, 2 = runner-up, etc.)

  -- Contrainte d'unicité : un joueur ne peut être inscrit qu'une fois par tournoi
  UNIQUE(tournament_id, player_id)
);

-- Table des matchs de tournoi
CREATE TABLE IF NOT EXISTS tournament_matches (
  id SERIAL PRIMARY KEY,
  tournament_id INTEGER NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,

  -- Identification du match dans le bracket
  round INTEGER NOT NULL, -- Numéro du tour (1, 2, 3, etc.)
  match_number INTEGER NOT NULL, -- Numéro du match dans le tour
  bracket_type TEXT DEFAULT 'winners' CHECK (bracket_type IN ('winners', 'losers', 'finals', 'third_place', 'round_robin')),

  -- Participants
  player1_id TEXT REFERENCES players(player_id) ON DELETE SET NULL,
  player2_id TEXT REFERENCES players(player_id) ON DELETE SET NULL,

  -- IDs des matchs précédents (pour la progression automatique)
  -- NULL si le match est en première ronde
  prerequisite_match1_id INTEGER REFERENCES tournament_matches(id) ON DELETE SET NULL,
  prerequisite_match2_id INTEGER REFERENCES tournament_matches(id) ON DELETE SET NULL,

  -- Indique si le joueur vient du winner ou loser du match prerequisite
  -- Valeurs: 'winner', 'loser'
  player1_from TEXT CHECK (player1_from IN ('winner', 'loser', 'seed')),
  player2_from TEXT CHECK (player2_from IN ('winner', 'loser', 'seed')),

  -- Résultats
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'walkover')),
  player1_score INTEGER,
  player2_score INTEGER,
  winner_id TEXT REFERENCES players(player_id) ON DELETE SET NULL,

  -- Match suivant (où va le winner/loser)
  next_match_winner_id INTEGER REFERENCES tournament_matches(id) ON DELETE SET NULL,
  next_match_loser_id INTEGER REFERENCES tournament_matches(id) ON DELETE SET NULL, -- Utilisé en double elimination
  next_match_winner_slot TEXT CHECK (next_match_winner_slot IN ('player1', 'player2')),
  next_match_loser_slot TEXT CHECK (next_match_loser_slot IN ('player1', 'player2')),

  -- Métadonnées
  scheduled_at TIMESTAMPTZ,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,

  -- Position d'affichage dans le bracket (pour UI)
  display_order INTEGER,

  -- Contrainte d'unicité : un seul match par position dans le bracket
  UNIQUE(tournament_id, round, match_number, bracket_type)
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_tournaments_status ON tournaments(status);
CREATE INDEX IF NOT EXISTS idx_tournaments_created_at ON tournaments(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tournament_participants_tournament ON tournament_participants(tournament_id);
CREATE INDEX IF NOT EXISTS idx_tournament_participants_player ON tournament_participants(player_id);
CREATE INDEX IF NOT EXISTS idx_tournament_matches_tournament ON tournament_matches(tournament_id);
CREATE INDEX IF NOT EXISTS idx_tournament_matches_status ON tournament_matches(status);
CREATE INDEX IF NOT EXISTS idx_tournament_matches_round ON tournament_matches(tournament_id, round);

-- Commentaires sur les tables
COMMENT ON TABLE tournaments IS 'Table principale des tournois avec informations et configuration';
COMMENT ON TABLE tournament_participants IS 'Participants inscrits aux tournois avec leurs statistiques';
COMMENT ON TABLE tournament_matches IS 'Matchs des tournois avec bracket structure et résultats';

COMMENT ON COLUMN tournaments.format IS 'Format du tournoi: single_elimination, double_elimination, round_robin';
COMMENT ON COLUMN tournaments.status IS 'Statut: draft, registration, in_progress, completed, cancelled';
COMMENT ON COLUMN tournaments.third_place_match IS 'Si true, génère un match pour la 3ème place';

COMMENT ON COLUMN tournament_participants.seed IS 'Position de seed pour la génération du bracket (1 = meilleur)';
COMMENT ON COLUMN tournament_participants.final_placement IS 'Position finale dans le tournoi (1 = champion)';

COMMENT ON COLUMN tournament_matches.bracket_type IS 'Type de bracket: winners (upper), losers (lower), finals, third_place, round_robin';
COMMENT ON COLUMN tournament_matches.round IS 'Numéro du tour (1 = premier tour, augmente vers la finale)';
COMMENT ON COLUMN tournament_matches.prerequisite_match1_id IS 'Match dont le résultat détermine player1';
COMMENT ON COLUMN tournament_matches.next_match_winner_id IS 'Match où ira le winner de ce match';
COMMENT ON COLUMN tournament_matches.next_match_loser_id IS 'Match où ira le loser (double elimination uniquement)';
