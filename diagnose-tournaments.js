#!/usr/bin/env node

/**
 * Script de diagnostic complet pour la fonctionnalité Tournois
 */

const http = require('http');
const { Pool } = require('pg');
const path = require('path');

require('dotenv').config({ path: path.join(__dirname, 'api/.env') });

const API_BASE = 'http://localhost:3005';

// Colors for console
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m'
};

function log(color, symbol, message) {
  console.log(`${colors[color]}${symbol} ${message}${colors.reset}`);
}

function testRoute(path, method = 'GET') {
  return new Promise((resolve, reject) => {
    const url = new URL(path, API_BASE);

    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname,
      method: method,
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 5000
    };

    const req = http.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        resolve({
          status: res.statusCode,
          data: data,
          headers: res.headers
        });
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Timeout'));
    });

    req.end();
  });
}

async function checkDatabase() {
  console.log('\n' + '='.repeat(60));
  log('blue', '🔍', 'VÉRIFICATION DE LA BASE DE DONNÉES');
  console.log('='.repeat(60));

  const pool = new Pool({
    host: process.env.PGHOST || 'localhost',
    port: parseInt(process.env.PGPORT || '5432'),
    database: process.env.PGDATABASE || 'EFOOTBALL',
    user: process.env.PGUSER || 'postgres',
    password: process.env.PGPASSWORD || 'Admin123',
  });

  try {
    const client = await pool.connect();

    // Vérifier si les tables existent
    const tablesResult = await client.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
      AND table_name LIKE 'tournament%'
      ORDER BY table_name
    `);

    if (tablesResult.rows.length === 0) {
      log('red', '❌', 'AUCUNE TABLE TOURNOIS TROUVÉE !');
      log('yellow', '⚠️ ', 'Vous devez exécuter: node fix-tournaments-tables.js');
      client.release();
      await pool.end();
      return false;
    }

    log('green', '✓', `${tablesResult.rows.length} tables tournois trouvées:`);
    tablesResult.rows.forEach(row => {
      console.log(`    - ${row.table_name}`);
    });

    // Vérifier la structure de la table tournaments
    const columnsResult = await client.query(`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns
      WHERE table_name = 'tournaments'
      ORDER BY ordinal_position
    `);

    console.log('\n  Colonnes de la table "tournaments":');
    const hasCreatedBy = columnsResult.rows.some(row => row.column_name === 'created_by');

    columnsResult.rows.forEach(row => {
      const marker = row.column_name === 'created_by' ? '✓' : ' ';
      console.log(`    ${marker} ${row.column_name} (${row.data_type})`);
    });

    if (!hasCreatedBy) {
      log('red', '❌', 'COLONNE "created_by" MANQUANTE !');
      log('yellow', '⚠️ ', 'Vous devez exécuter: node fix-tournaments-tables.js');
      client.release();
      await pool.end();
      return false;
    } else {
      log('green', '✓', 'Structure de la table correcte');
    }

    // Compter les tournois existants
    const countResult = await client.query('SELECT COUNT(*) FROM tournaments');
    const count = parseInt(countResult.rows[0].count);
    log('blue', 'ℹ️ ', `${count} tournoi(s) dans la base de données`);

    client.release();
    await pool.end();
    return true;

  } catch (error) {
    log('red', '❌', `Erreur de connexion à PostgreSQL: ${error.message}`);
    if (error.code === 'ECONNREFUSED') {
      log('yellow', '⚠️ ', 'PostgreSQL ne semble pas démarré');
      log('yellow', '⚠️ ', 'Vérifiez les services Windows (services.msc)');
    }
    await pool.end();
    return false;
  }
}

async function checkServer() {
  console.log('\n' + '='.repeat(60));
  log('blue', '🔍', 'VÉRIFICATION DU SERVEUR NODE.JS');
  console.log('='.repeat(60));

  // Test /health
  try {
    log('blue', '→', 'Test de la route /health...');
    const result = await testRoute('/health');

    if (result.status === 200) {
      log('green', '✓', 'Serveur Node.js fonctionne !');
      console.log(`    ${result.data}`);
    } else {
      log('red', '❌', `Erreur: Status ${result.status}`);
      return false;
    }
  } catch (error) {
    log('red', '❌', `Serveur inaccessible: ${error.message}`);
    if (error.message === 'Timeout' || error.code === 'ECONNREFUSED') {
      log('yellow', '⚠️ ', 'Le serveur Node.js ne semble pas démarré');
      log('yellow', '⚠️ ', 'Exécutez: cd api && npm start');
    }
    return false;
  }

  return true;
}

async function checkTournamentsRoutes() {
  console.log('\n' + '='.repeat(60));
  log('blue', '🔍', 'VÉRIFICATION DES ROUTES TOURNOIS');
  console.log('='.repeat(60));

  // Test /tournaments (sans auth)
  try {
    log('blue', '→', 'Test de la route GET /tournaments...');
    const result = await testRoute('/tournaments');

    if (result.status === 401) {
      log('green', '✓', 'Route existe (401 Unauthorized - normal sans token)');
    } else if (result.status === 404) {
      log('red', '❌', 'Route NOT FOUND - Le module n\'est pas chargé !');
      log('yellow', '⚠️ ', 'Vérifiez que server.js charge bien tournaments.js');
      log('yellow', '⚠️ ', 'Redémarrez le serveur après toute modification');
      return false;
    } else if (result.status === 200) {
      log('green', '✓', 'Route fonctionne !');
      try {
        const data = JSON.parse(result.data);
        log('blue', 'ℹ️ ', `${data.tournaments?.length || 0} tournoi(s) retourné(s)`);
      } catch (e) {}
    } else if (result.status === 500) {
      log('red', '❌', 'Erreur serveur 500 !');
      console.log(`    ${result.data}`);
      log('yellow', '⚠️ ', 'Il y a probablement une erreur dans le code ou la BDD');
      return false;
    } else {
      log('yellow', '⚠️', `Status inattendu: ${result.status}`);
      console.log(`    ${result.data}`);
    }

  } catch (error) {
    log('red', '❌', `Erreur: ${error.message}`);
    return false;
  }

  return true;
}

async function checkServerLogs() {
  console.log('\n' + '='.repeat(60));
  log('blue', '🔍', 'INSTRUCTIONS POUR VÉRIFIER LES LOGS SERVEUR');
  console.log('='.repeat(60));

  console.log(`
  Si vous voyez toujours des problèmes, vérifiez les logs du serveur:

  1. Ouvrez le terminal où votre serveur Node.js tourne
  2. Cherchez les messages d'erreur en rouge
  3. Si vous voyez des erreurs SQL, c'est que la BDD a un problème
  4. Si vous voyez "Cannot find module", il manque un fichier

  Logs typiques à chercher:
  - "Erreur lors de la récupération des tournois"
  - "la colonne t.created_by n'existe pas"
  - "setupTournamentRoutes is not a function"
  `);
}

async function provideSolution() {
  console.log('\n' + '='.repeat(60));
  log('magenta', '🔧', 'SOLUTIONS RECOMMANDÉES');
  console.log('='.repeat(60));

  console.log(`
  ${colors.yellow}1. CORRIGER LA BASE DE DONNÉES${colors.reset}
     cd C:\\Users\\CCL\\Desktop\\GOUZEPE_APP
     node fix-tournaments-tables.js

  ${colors.yellow}2. REDÉMARRER LE SERVEUR${colors.reset}
     Arrêtez le serveur (Ctrl+C) puis:
     cd api
     npm start

  ${colors.yellow}3. VIDER LE CACHE DU NAVIGATEUR${colors.reset}
     Appuyez sur Ctrl+Shift+R (ou Cmd+Shift+R sur Mac)

  ${colors.yellow}4. SI ÇA NE MARCHE TOUJOURS PAS${colors.reset}
     Ouvrez la console du navigateur (F12) et regardez les erreurs
     Puis envoyez-moi les messages d'erreur
  `);
}

async function main() {
  console.log('\n' + '█'.repeat(60));
  log('magenta', '🏆', 'DIAGNOSTIC COMPLET - FONCTIONNALITÉ TOURNOIS');
  console.log('█'.repeat(60));

  const dbOk = await checkDatabase();
  const serverOk = await checkServer();

  if (!dbOk || !serverOk) {
    await provideSolution();
    process.exit(1);
  }

  const routesOk = await checkTournamentsRoutes();

  await checkServerLogs();
  await provideSolution();

  console.log('\n' + '█'.repeat(60));
  if (dbOk && serverOk && routesOk) {
    log('green', '✅', 'TOUT SEMBLE CORRECT !');
    console.log(`
    Si la page ne fonctionne toujours pas:
    1. Videz le cache du navigateur (Ctrl+Shift+R)
    2. Vérifiez la console du navigateur (F12)
    3. Envoyez-moi les erreurs que vous voyez
    `);
  } else {
    log('red', '❌', 'DES PROBLÈMES ONT ÉTÉ DÉTECTÉS');
    log('yellow', '→', 'Suivez les solutions ci-dessus');
  }
  console.log('█'.repeat(60) + '\n');

  process.exit(0);
}

main().catch(err => {
  log('red', '❌', `Erreur fatale: ${err.message}`);
  console.error(err);
  process.exit(1);
});
