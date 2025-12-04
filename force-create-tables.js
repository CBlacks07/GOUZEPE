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

async function createTables() {
  const client = await pool.connect();

  try {
    console.log('🔄 Connexion à PostgreSQL...');

    // Lire le fichier schema.sql
    const schemaPath = path.join(__dirname, 'db/schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');

    console.log('📝 Exécution du schéma SQL...');

    await client.query('BEGIN');
    await client.query(schema);
    await client.query('COMMIT');

    console.log('✅ Tables créées avec succès !');

    // Vérifier les tables tournois
    const result = await client.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
      AND table_name LIKE 'tournament%'
      ORDER BY table_name
    `);

    console.log('\n📊 Tables tournois :');
    if (result.rows.length === 0) {
      console.log('   ❌ Aucune table trouvée !');
    } else {
      result.rows.forEach(row => {
        console.log('   ✓', row.table_name);
      });
    }

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

createTables().then(() => {
  console.log('\n✨ Terminé !');
  process.exit(0);
}).catch(err => {
  console.error('❌ Erreur fatale :', err);
  process.exit(1);
});
