#!/usr/bin/env node

/**
 * Script de migration pour ajouter les tables de tournois
 * Usage: node db/migrate_tournaments.js
 */

const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

// Charger les variables d'environnement
require('dotenv').config({ path: path.join(__dirname, '../api/.env') });

const pool = new Pool({
  host: process.env.PGHOST || 'localhost',
  port: parseInt(process.env.PGPORT || '5432'),
  database: process.env.PGDATABASE || 'EFOOTBALL',
  user: process.env.PGUSER || 'postgres',
  password: process.env.PGPASSWORD || 'Admin123',
});

async function runMigration() {
  const client = await pool.connect();

  try {
    console.log('🔄 Début de la migration des tables de tournois...\n');

    // Lire le fichier SQL
    const sqlPath = path.join(__dirname, 'schema_tournaments.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');

    // Exécuter le script SQL
    await client.query('BEGIN');
    await client.query(sql);
    await client.query('COMMIT');

    console.log('✅ Migration réussie !');
    console.log('\nTables créées :');
    console.log('  - tournaments');
    console.log('  - tournament_participants');
    console.log('  - tournament_matches');
    console.log('\nIndex créés :');
    console.log('  - idx_tournaments_status');
    console.log('  - idx_tournaments_created_at');
    console.log('  - idx_tournament_participants_tournament');
    console.log('  - idx_tournament_participants_player');
    console.log('  - idx_tournament_matches_tournament');
    console.log('  - idx_tournament_matches_status');
    console.log('  - idx_tournament_matches_round');

    // Vérifier les tables
    const result = await client.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
      AND table_name LIKE 'tournament%'
      ORDER BY table_name
    `);

    console.log('\n📊 Tables de tournois dans la base de données :');
    result.rows.forEach(row => {
      console.log(`  ✓ ${row.table_name}`);
    });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Erreur lors de la migration :', error.message);
    console.error('\nDétails :', error);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

// Exécuter la migration
runMigration().then(() => {
  console.log('\n✨ Migration terminée avec succès !');
  process.exit(0);
}).catch(err => {
  console.error('❌ Erreur fatale :', err);
  process.exit(1);
});
