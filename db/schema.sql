-- Schéma eFootball — tables alignées avec api/server.js
-- Convention: les tables métier historiquement au pluriel (users, players...) conservent
-- leur nom, tandis que les tables de journée utilisent le singulier (`matchday`, `draft`)
-- comme dans le code Node.js. Ce fichier reflète donc l'état réellement consommé
-- par l'API Express.

-- Table pour les joueurs
CREATE TABLE IF NOT EXISTS players (
  player_id       TEXT PRIMARY KEY,
  name            TEXT NOT NULL,
  role            TEXT NOT NULL DEFAULT 'MEMBRE',
  profile_pic_url TEXT,
  created_at      TIMESTAMP DEFAULT now()
);

-- Table pour les comptes utilisateurs (membres + administrateurs)
CREATE TABLE IF NOT EXISTS users (
  id            SERIAL PRIMARY KEY,
  email         TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role          TEXT NOT NULL DEFAULT 'member',
  player_id     TEXT REFERENCES players(player_id) ON UPDATE CASCADE ON DELETE SET NULL,
  created_at    TIMESTAMP DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS users_player_id_uniq
  ON users(player_id)
  WHERE player_id IS NOT NULL;

-- Table des saisons sportives
CREATE TABLE IF NOT EXISTS seasons (
  id         SERIAL PRIMARY KEY,
  name       TEXT NOT NULL,
  started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  ended_at   TIMESTAMPTZ,
  is_closed  BOOLEAN NOT NULL DEFAULT FALSE
);

-- Journées officielles confirmées
CREATE TABLE IF NOT EXISTS matchday (
  day        DATE PRIMARY KEY,
  season_id  INTEGER REFERENCES seasons(id),
  payload    JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Brouillons de journées (édition collaborative)
CREATE TABLE IF NOT EXISTS draft (
  day            DATE PRIMARY KEY,
  payload        JSONB NOT NULL,
  updated_at     TIMESTAMPTZ DEFAULT now(),
  author_user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS draft_author_idx ON draft(author_user_id);

-- Sessions d'authentification persistantes
CREATE TABLE IF NOT EXISTS sessions (
  id                   TEXT PRIMARY KEY,
  user_id              INTEGER REFERENCES users(id) ON DELETE CASCADE,
  device               TEXT,
  user_agent           TEXT,
  ip                   TEXT,
  created_at           TIMESTAMPTZ DEFAULT now(),
  last_seen            TIMESTAMPTZ DEFAULT now(),
  is_active            BOOLEAN NOT NULL DEFAULT TRUE,
  revoked_at           TIMESTAMPTZ,
  logout_at            TIMESTAMPTZ,
  cleaned_after_logout BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS sessions_user_active
  ON sessions(user_id)
  WHERE is_active;

-- Table optionnelle pour l'ancien suivi cumulé de la saison
CREATE TABLE IF NOT EXISTS season_totals (
  id         SERIAL PRIMARY KEY,
  tag        TEXT UNIQUE NOT NULL DEFAULT 'current',
  standings  JSONB NOT NULL DEFAULT '[]'::jsonb,
  closed     BOOLEAN NOT NULL DEFAULT FALSE,
  updated_at TIMESTAMP DEFAULT now()
);

INSERT INTO season_totals(tag) VALUES('current')
ON CONFLICT(tag) DO NOTHING;

-- Historique des champions par division
CREATE TABLE IF NOT EXISTS champion_result (
  day           DATE NOT NULL,
  division      TEXT NOT NULL CHECK (division IN ('D1','D2')),
  champion_name TEXT NOT NULL,
  champion_id   TEXT,
  team_code     TEXT,

  PRIMARY KEY (day, division),
  FOREIGN KEY (champion_id) REFERENCES players(player_id) ON UPDATE CASCADE ON DELETE SET NULL,
  CHECK (team_code IS NULL OR char_length(team_code) >= 4)
);

CREATE INDEX IF NOT EXISTS idx_champion_name ON champion_result(champion_name);

-- ========================================================
-- SECTION TOURNOIS - Compatible avec Challonge et start.gg
-- ========================================================

-- Table principale des tournois
CREATE TABLE IF NOT EXISTS tournaments (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  format TEXT NOT NULL CHECK (format IN ('single_elimination', 'double_elimination', 'round_robin', 'swiss')),
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'registration', 'check_in', 'in_progress', 'completed', 'cancelled')),

  -- Dates
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  registration_start TIMESTAMPTZ,
  registration_end TIMESTAMPTZ,
  check_in_opens_at TIMESTAMPTZ,
  check_in_closes_at TIMESTAMPTZ,
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,

  -- Configuration
  max_participants INTEGER,
  third_place_match BOOLEAN DEFAULT false,
  require_check_in BOOLEAN DEFAULT true,
  auto_dq_no_checkin BOOLEAN DEFAULT true,

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
  checked_in_at TIMESTAMPTZ,
  seed INTEGER,
  status TEXT NOT NULL DEFAULT 'registered' CHECK (status IN ('registered', 'checked_in', 'disqualified', 'withdrawn')),

  -- Statistiques du tournoi
  wins INTEGER DEFAULT 0,
  losses INTEGER DEFAULT 0,
  points_for INTEGER DEFAULT 0,
  points_against INTEGER DEFAULT 0,

  -- Position finale
  final_placement INTEGER,

  UNIQUE(tournament_id, player_id)
);

-- Table des matchs de tournoi
CREATE TABLE IF NOT EXISTS tournament_matches (
  id SERIAL PRIMARY KEY,
  tournament_id INTEGER NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,

  -- Identification du match dans le bracket
  round INTEGER NOT NULL,
  match_number INTEGER NOT NULL,
  bracket_type TEXT DEFAULT 'winners' CHECK (bracket_type IN ('winners', 'losers', 'finals', 'third_place', 'round_robin')),

  -- Participants
  player1_id TEXT REFERENCES players(player_id) ON DELETE SET NULL,
  player2_id TEXT REFERENCES players(player_id) ON DELETE SET NULL,

  -- IDs des matchs précédents
  prerequisite_match1_id INTEGER REFERENCES tournament_matches(id) ON DELETE SET NULL,
  prerequisite_match2_id INTEGER REFERENCES tournament_matches(id) ON DELETE SET NULL,

  -- Progression
  player1_from TEXT CHECK (player1_from IN ('winner', 'loser', 'seed')),
  player2_from TEXT CHECK (player2_from IN ('winner', 'loser', 'seed')),

  -- Résultats
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'walkover')),
  player1_score INTEGER,
  player2_score INTEGER,
  winner_id TEXT REFERENCES players(player_id) ON DELETE SET NULL,

  -- Match suivant
  next_match_winner_id INTEGER REFERENCES tournament_matches(id) ON DELETE SET NULL,
  next_match_loser_id INTEGER REFERENCES tournament_matches(id) ON DELETE SET NULL,
  next_match_winner_slot TEXT CHECK (next_match_winner_slot IN ('player1', 'player2')),
  next_match_loser_slot TEXT CHECK (next_match_loser_slot IN ('player1', 'player2')),

  -- Métadonnées
  scheduled_at TIMESTAMPTZ,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,

  -- Position d'affichage
  display_order INTEGER,

  UNIQUE(tournament_id, round, match_number, bracket_type)
);

-- Table des litiges de matchs (Disputes System)
CREATE TABLE IF NOT EXISTS match_disputes (
  id SERIAL PRIMARY KEY,
  match_id INTEGER NOT NULL REFERENCES tournament_matches(id) ON DELETE CASCADE,
  tournament_id INTEGER NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,

  -- Parties impliquées
  reported_by_player_id TEXT NOT NULL REFERENCES players(player_id) ON DELETE CASCADE,
  disputed_against_player_id TEXT REFERENCES players(player_id) ON DELETE CASCADE,

  -- Scores rapportés
  reporter_score1 INTEGER,
  reporter_score2 INTEGER,
  opponent_score1 INTEGER,
  opponent_score2 INTEGER,

  -- Détails du litige
  reason TEXT,
  reporter_comment TEXT,
  opponent_comment TEXT,

  -- Statut et résolution
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'under_review', 'resolved', 'cancelled')),
  resolved_by_admin_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  admin_notes TEXT,
  resolution_comment TEXT,
  final_score1 INTEGER,
  final_score2 INTEGER,

  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  resolved_at TIMESTAMPTZ,

  -- Priorité
  priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent'))
);

-- Table des preuves de matchs (Evidence System)
CREATE TABLE IF NOT EXISTS match_evidence (
  id SERIAL PRIMARY KEY,
  match_id INTEGER NOT NULL REFERENCES tournament_matches(id) ON DELETE CASCADE,
  dispute_id INTEGER REFERENCES match_disputes(id) ON DELETE CASCADE,

  -- Soumis par
  submitted_by_player_id TEXT NOT NULL REFERENCES players(player_id) ON DELETE CASCADE,

  -- Type de preuve
  evidence_type TEXT NOT NULL CHECK (evidence_type IN ('screenshot', 'video', 'replay_file', 'external_link', 'text_note')),

  -- Données
  file_path TEXT,
  file_name TEXT,
  file_size INTEGER,
  external_url TEXT,
  text_content TEXT,

  -- Métadonnées
  description TEXT,
  verified_by_admin_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  is_verified BOOLEAN DEFAULT false,

  -- Timestamps
  uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index pour les tournois
CREATE INDEX IF NOT EXISTS idx_tournaments_status ON tournaments(status);
CREATE INDEX IF NOT EXISTS idx_tournaments_created_at ON tournaments(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tournament_participants_tournament ON tournament_participants(tournament_id);
CREATE INDEX IF NOT EXISTS idx_tournament_participants_player ON tournament_participants(player_id);
CREATE INDEX IF NOT EXISTS idx_tournament_matches_tournament ON tournament_matches(tournament_id);
CREATE INDEX IF NOT EXISTS idx_tournament_matches_status ON tournament_matches(status);
CREATE INDEX IF NOT EXISTS idx_tournament_matches_round ON tournament_matches(tournament_id, round);
CREATE INDEX IF NOT EXISTS idx_match_disputes_match ON match_disputes(match_id);
CREATE INDEX IF NOT EXISTS idx_match_disputes_status ON match_disputes(status);
CREATE INDEX IF NOT EXISTS idx_match_disputes_tournament ON match_disputes(tournament_id);
CREATE INDEX IF NOT EXISTS idx_match_evidence_match ON match_evidence(match_id);
CREATE INDEX IF NOT EXISTS idx_match_evidence_dispute ON match_evidence(dispute_id);
