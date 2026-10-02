// Garde-fous des rafraîchissements temps réel des écrans de tournoi.

// Suit les enregistrements en cours de CETTE page. Le serveur renvoie un événement temps réel
// à tous les clients, l'auteur de la saisie compris : sans garde-fou, la page se recharge toute
// seule juste après avoir déjà mis ses données à jour. On ignore donc les événements tant qu'un
// enregistrement est en cours (peu importe sa durée, contrairement à un délai fixe, trop court
// quand le serveur est lent), puis pendant un court délai de grâce : l'événement peut arriver
// juste après la réponse.
export function createSaveGuard(graceMs = 2500) {
  let inflight = 0
  let endedAt = 0
  return {
    begin() { inflight += 1 },
    end() { inflight = Math.max(0, inflight - 1); endedAt = Date.now() },
    isEcho() { return inflight > 0 || Date.now() - endedAt < graceMs },
  }
}

// Regroupe les rafales d'événements : un seul rechargement à la fois, et au plus un de plus si
// d'autres événements sont arrivés pendant qu'il tournait.
export function createCoalescedRefresh(fn, delayMs = 300) {
  let timer = null
  let running = false
  let again = false

  async function run() {
    if (running) { again = true; return }
    running = true
    try {
      await fn()
    } finally {
      running = false
      if (again) { again = false; trigger() }
    }
  }
  function trigger() {
    clearTimeout(timer)
    timer = setTimeout(run, delayMs)
  }
  return { trigger, cancel: () => clearTimeout(timer) }
}
