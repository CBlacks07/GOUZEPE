#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

require('dotenv').config({ path: path.join(__dirname, 'api/.env') });

const pool = new Pool({
  host: process.env.PGHOST || 'localhost',
  port: parseInt(process.env.PGPORT || '5432'),
  database: process.env.PGDATABASE || 'EFOOTBALL',
  user: process.env.PGUSER || 'postgres',
  password: process.env.PGPASSWORD || 'Admin123',
});

async function fixTables() {
  const client = await pool.connect();

  try {
    console.log('🔄 Connexion à PostgreSQL...');

    await client.query('BEGIN');

    console.log('🗑️  Suppression des anciennes tables tournois...');

    // Supprimer les tables dans le bon ordre (à cause des foreign keys)
    await client.query('DROP TABLE IF EXISTS tournament_matches CASCADE');
    await client.query('DROP TABLE IF EXISTS tournament_participants CASCADE');
    await client.query('DROP TABLE IF EXISTS tournaments CASCADE');

    console.log('✅ Anciennes tables supprimées');

    console.log('📝 Création des nouvelles tables...');

    // Créer les tables avec le bon schéma
    await client.query(`
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
        third_place_match BOOLEAN DEFAULT false,

        -- Métadonnées
        created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
        winner_id TEXT REFERENCES players(player_id) ON DELETE SET NULL,
        runner_up_id TEXT REFERENCES players(player_id) ON DELETE SET NULL,
        third_place_id TEXT REFERENCES players(player_id) ON DELETE SET NULL,

        -- Statistiques
        total_matches INTEGER DEFAULT 0,
        completed_matches INTEGER DEFAULT 0
      );
    `);

    await client.query(`
      -- Table des participants aux tournois
      CREATE TABLE IF NOT EXISTS tournament_participants (
        id SERIAL PRIMARY KEY,
        tournament_id INTEGER NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
        player_id TEXT NOT NULL REFERENCES players(player_id) ON DELETE CASCADE,

        -- Statut
        registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
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
    `);

    await client.query(`
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
    `);

    console.log('📊 Création des index...');

    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_tournaments_status ON tournaments(status);
      CREATE INDEX IF NOT EXISTS idx_tournaments_created_at ON tournaments(created_at DESC);
      CREATE INDEX IF NOT EXISTS idx_tournament_participants_tournament ON tournament_participants(tournament_id);
      CREATE INDEX IF NOT EXISTS idx_tournament_participants_player ON tournament_participants(player_id);
      CREATE INDEX IF NOT EXISTS idx_tournament_matches_tournament ON tournament_matches(tournament_id);
      CREATE INDEX IF NOT EXISTS idx_tournament_matches_status ON tournament_matches(status);
      CREATE INDEX IF NOT EXISTS idx_tournament_matches_round ON tournament_matches(tournament_id, round);
    `);

    await client.query('COMMIT');

    console.log('✅ Tables recréées avec succès !');

    // Vérifier les colonnes de la table tournaments
    const result = await client.query(`
      SELECT column_name, data_type
      FROM information_schema.columns
      WHERE table_name = 'tournaments'
      ORDER BY ordinal_position
    `);

    console.log('\n📋 Colonnes de la table tournaments :');
    result.rows.forEach(row => {
      console.log(`   - ${row.column_name} (${row.data_type})`);
    });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Erreur :', error.message);
    console.error('\nDétails complets :');
    console.error(error);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

fixTables().then(() => {
  console.log('\n✨ Terminé ! Redémarrez le serveur avec "npm start"');
  process.exit(0);
}).catch(err => {
  console.error('❌ Erreur fatale :', err);
  process.exit(1);
});
