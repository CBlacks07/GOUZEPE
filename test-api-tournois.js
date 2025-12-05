#!/usr/bin/env node

/**
 * Script de test pour vérifier les routes API Tournois
 */

const http = require('http');

const API_BASE = 'http://localhost:3005';

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
      }
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

    req.setTimeout(5000, () => {
      req.destroy();
      reject(new Error('Timeout'));
    });

    req.end();
  });
}

async function runTests() {
  console.log('🔍 Test des routes API Tournois...\n');

  // Test 1: Route de base
  console.log('1️⃣ Test GET /tournaments');
  try {
    const result = await testRoute('/tournaments');
    console.log(`   Status: ${result.status}`);
    if (result.status === 200) {
      console.log('   ✅ Route fonctionne !');
      console.log('   Data:', result.data.substring(0, 100) + '...');
    } else if (result.status === 401) {
      console.log('   ⚠️  401 Unauthorized - Normal, authentification requise');
    } else if (result.status === 404) {
      console.log('   ❌ 404 Not Found - La route n\'existe pas !');
    } else {
      console.log('   ❌ Erreur:', result.status);
    }
  } catch (error) {
    console.log('   ❌ Erreur:', error.message);
  }

  console.log('');

  // Test 2: Route health check
  console.log('2️⃣ Test GET /health');
  try {
    const result = await testRoute('/health');
    console.log(`   Status: ${result.status}`);
    if (result.status === 200) {
      console.log('   ✅ Serveur fonctionne !');
      console.log('   Data:', result.data);
    } else {
      console.log('   ❌ Erreur:', result.status);
    }
  } catch (error) {
    console.log('   ❌ Erreur:', error.message);
  }

  console.log('');
  console.log('📝 Résumé:');
  console.log('   Si vous voyez "401 Unauthorized" pour /tournaments, c\'est NORMAL.');
  console.log('   Cela signifie que la route existe mais nécessite une authentification.');
  console.log('   Si vous voyez "404 Not Found", il y a un problème de configuration.');
  console.log('');
}

runTests().catch(console.error);
