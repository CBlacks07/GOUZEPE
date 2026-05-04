#!/usr/bin/env node

/**
 * Migration pour ajouter les fonctionnalités professionnelles
 * - Système de Check-in
 * - Système de Litiges
 * - Système de Preuves
 * - Format Suisse
 */

const { Pool } = require('pg');
const path = require('path');

require('dotenv').config({ path: path.join(__dirname, '../api/.env') });

const pool = new Pool({
  host: process.env.PGHOST || 'localhost',
  port: parseInt(process.env.PGPORT || '5432'),
  database: process.env.PGDATABASE || 'EFOOTBALL',
  user: process.env.PGUSER || 'postgres',
  password: process.env.PGPASSWORD || 'Admin123',
});

async function migrate() {
  const client = await pool.connect();

  try {
    console.log('🔄 Démarrage de la migration des fonctionnalités professionnelles...\n');

    await client.query('BEGIN');

    // 1. Ajouter les colonnes check-in à tournaments
    console.log('📝 Ajout des colonnes check-in à la table tournaments...');
    await client.query(`
      ALTER TABLE tournaments
      ADD COLUMN IF NOT EXISTS check_in_opens_at TIMESTAMPTZ,
      ADD COLUMN IF NOT EXISTS check_in_closes_at TIMESTAMPTZ,
      ADD COLUMN IF NOT EXISTS require_check_in BOOLEAN DEFAULT true,
      ADD COLUMN IF NOT EXISTS auto_dq_no_checkin BOOLEAN DEFAULT true
    `);

    // 2. Mettre à jour le format pour inclure 'swiss'
    console.log('📝 Ajout du format Suisse...');
    await client.query(`
      ALTER TABLE tournaments
      DROP CONSTRAINT IF EXISTS tournaments_format_check
    `);
    await client.query(`
      ALTER TABLE tournaments
      ADD CONSTRAINT tournaments_format_check
      CHECK (format IN ('single_elimination', 'double_elimination', 'round_robin', 'swiss'))
    `);

    // 3. Mettre à jour le status pour inclure 'check_in'
    console.log('📝 Ajout du statut check_in...');
    await client.query(`
      ALTER TABLE tournaments
      DROP CONSTRAINT IF EXISTS tournaments_status_check
    `);
    await client.query(`
      ALTER TABLE tournaments
      ADD CONSTRAINT tournaments_status_check
      CHECK (status IN ('draft', 'registration', 'check_in', 'in_progress', 'completed', 'cancelled'))
    `);

    // 4. Ajouter checked_in_at à tournament_participants
    console.log('📝 Ajout de checked_in_at à tournament_participants...');
    await client.query(`
      ALTER TABLE tournament_participants
      ADD COLUMN IF NOT EXISTS checked_in_at TIMESTAMPTZ
    `);

    // 5. Créer la table match_disputes
    console.log('📝 Création de la table match_disputes...');
    await client.query(`
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
      )
    `);

    // 6. Créer la table match_evidence
    console.log('📝 Création de la table match_evidence...');
    await client.query(`
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
      )
    `);

    // 7. Créer les index
    console.log('📊 Création des index...');
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_match_disputes_match ON match_disputes(match_id);
      CREATE INDEX IF NOT EXISTS idx_match_disputes_status ON match_disputes(status);
      CREATE INDEX IF NOT EXISTS idx_match_disputes_tournament ON match_disputes(tournament_id);
      CREATE INDEX IF NOT EXISTS idx_match_evidence_match ON match_evidence(match_id);
      CREATE INDEX IF NOT EXISTS idx_match_evidence_dispute ON match_evidence(dispute_id);
    `);

    await client.query('COMMIT');

    console.log('\n✅ Migration terminée avec succès !');
    console.log('\n📋 Fonctionnalités ajoutées :');
    console.log('   ✓ Système de Check-in (timestamps + auto-DQ)');
    console.log('   ✓ Format Suisse (swiss)');
    console.log('   ✓ Système de Litiges (match_disputes)');
    console.log('   ✓ Système de Preuves (match_evidence)');
    console.log('\n🔄 Redémarrez le serveur Node.js pour appliquer les changements.\n');

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('\n❌ Erreur lors de la migration:', error);
    console.error('\n💡 La migration a été annulée (ROLLBACK).\n');
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

migrate().catch(err => {
  console.error('❌ Erreur fatale:', err);
  process.exit(1);
});
