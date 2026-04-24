-- Schéma eFootball — tables alignées avec api/server.js
-- Convention: les tables métier historiquement au pluriel (users, players...) conservent
-- leur nom, tandis que les tables de journée utilisent le singulier (`matchday`, `draft`)
-- comme dans le code Node.js. Ce fichier reflÃ¨te donc l'état réellement consommé
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

-- Tournois (v1: élimination directe)
CREATE TABLE IF NOT EXISTS tournaments (
  id               SERIAL PRIMARY KEY,
  slug             TEXT UNIQUE NOT NULL,
  name             TEXT NOT NULL,
  format           TEXT NOT NULL DEFAULT 'single_elimination',
  status           TEXT NOT NULL DEFAULT 'draft',
  starts_at        TIMESTAMPTZ,
  ended_at         TIMESTAMPTZ,
  winner_name      TEXT,
  member_tournament BOOLEAN NOT NULL DEFAULT FALSE,
  counts_for_title  BOOLEAN NOT NULL DEFAULT FALSE,
  day_comment      TEXT,
  rr_match_mode    TEXT NOT NULL DEFAULT 'single',
  rr_standings_mode TEXT NOT NULL DEFAULT 'goals',
  nb_groups        SMALLINT,
  qualifiers_per_group SMALLINT,
  created_by       INTEGER REFERENCES users(id) ON DELETE SET NULL,
  season_id        INTEGER REFERENCES seasons(id) ON DELETE SET NULL,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (format IN ('single_elimination','round_robin','double_elimination','groups_knockout')),
  CHECK (rr_match_mode IN ('single','home_away')),
  CHECK (rr_standings_mode IN ('goals','wins')),
  CHECK (status IN ('draft','live','completed','archived'))
);

CREATE INDEX IF NOT EXISTS tournaments_status_idx ON tournaments(status);
CREATE INDEX IF NOT EXISTS tournaments_created_at_idx ON tournaments(created_at DESC);
CREATE INDEX IF NOT EXISTS tournaments_season_idx ON tournaments(season_id);

CREATE TABLE IF NOT EXISTS tournament_participants (
  id            SERIAL PRIMARY KEY,
  tournament_id INTEGER NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
  display_name  TEXT NOT NULL,
  player_id     TEXT REFERENCES players(player_id) ON UPDATE CASCADE ON DELETE SET NULL,
  seed          INTEGER,
  group_no      SMALLINT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS tp_display_name_uniq
  ON tournament_participants(tournament_id, lower(display_name));

CREATE UNIQUE INDEX IF NOT EXISTS tournament_participants_seed_uniq
  ON tournament_participants(tournament_id, seed)
  WHERE seed IS NOT NULL;

CREATE TABLE IF NOT EXISTS tournament_matches (
  id                    SERIAL PRIMARY KEY,
  tournament_id         INTEGER NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
  round_no              INTEGER NOT NULL,
  slot_no               INTEGER NOT NULL,
  best_of               INTEGER NOT NULL DEFAULT 1,
  p1_participant_id     INTEGER REFERENCES tournament_participants(id) ON DELETE SET NULL,
  p2_participant_id     INTEGER REFERENCES tournament_participants(id) ON DELETE SET NULL,
  score_p1              INTEGER,
  score_p2              INTEGER,
  winner_participant_id INTEGER REFERENCES tournament_participants(id) ON DELETE SET NULL,
  status                TEXT NOT NULL DEFAULT 'pending',
  walkover              BOOLEAN NOT NULL DEFAULT false,
  next_match_id         INTEGER REFERENCES tournament_matches(id) ON DELETE SET NULL,
  next_match_slot       SMALLINT CHECK (next_match_slot IN (1,2)),
  started_at            TIMESTAMPTZ,
  finished_at           TIMESTAMPTZ,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (round_no > 0),
  CHECK (slot_no > 0),
  CHECK (best_of > 0),
  CHECK (status IN ('pending','ready','completed')),
  UNIQUE(tournament_id, round_no, slot_no)
);

CREATE INDEX IF NOT EXISTS tournament_matches_tournament_round_idx
  ON tournament_matches(tournament_id, round_no, slot_no);

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
