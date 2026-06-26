/*
 * Service worker "kill-switch".
 *
 * L'application Vue n'utilise PAS de service worker (les assets sont déjà
 * hashés par Vite et l'index.html est servi en no-cache). Ce fichier existe
 * uniquement pour DÉSINSTALLER proprement l'ancien service worker de la version
 * HTML, qui pouvait servir du cache périmé (d'où l'obligation de vider le cache
 * pour voir les mises à jour).
 *
 * Au prochain passage du navigateur, ce SW prend la place de l'ancien, supprime
 * tous les caches, se désinscrit, puis recharge les onglets ouverts.
 */

self.addEventListener('install', () => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    // 1) Purge de tous les caches (anciens HTML/API)
    try {
      const keys = await caches.keys();
      await Promise.all(keys.map((k) => caches.delete(k)));
    } catch (_) {}

    // 2) Désinscription de ce service worker
    try {
      await self.registration.unregister();
    } catch (_) {}

    // 3) Rechargement des onglets ouverts pour repartir sur la version fraîche
    try {
      const clients = await self.clients.matchAll({ type: 'window' });
      for (const client of clients) {
        try { client.navigate(client.url); } catch (_) {}
      }
    } catch (_) {}
  })());
});

// Aucune interception réseau : on laisse le navigateur faire ses requêtes
// normalement (network direct), pour ne jamais resservir du cache.
