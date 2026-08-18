<template>
  <div class="legal">
    <PublicNav />

    <section class="section">
      <div class="section-head">
        <h1>Politique de confidentialité</h1>
        <p>Dernière mise à jour : {{ lastUpdate }}</p>
      </div>

      <div class="card legal-card">
        <h2>Qui sommes-nous</h2>
        <p>
          <strong>GOUZEPE GAMING CLUB</strong>, association basée à Lomé (Togo), est responsable du traitement
          des données personnelles collectées sur ce site. Pour toute question, tu peux nous écrire à
          <a href="mailto:contact@gouzepe-gaming.com">contact@gouzepe-gaming.com</a>.
        </p>

        <h2>Quelles données on collecte</h2>
        <p>Selon ton usage du site, on peut collecter :</p>
        <ul class="legal-list">
          <li><strong>Demande d'adhésion :</strong> nom, email, téléphone, date de naissance, profession, adresse, plateforme de jeu, fréquence de jeu, jeu(x) pratiqué(s), message libre.</li>
          <li><strong>Compte membre</strong> (une fois la demande approuvée) : email, mot de passe (stocké de façon chiffrée, jamais en clair), pseudonyme joueur, ainsi que les données liées à ton activité sur le site (résultats, classements, tournois).</li>
        </ul>

        <h2>Pourquoi on les utilise</h2>
        <ul class="legal-list">
          <li>Étudier et traiter les demandes d'adhésion</li>
          <li>Créer et gérer ton compte membre</li>
          <li>Te contacter par email (confirmation de demande, réponse à une demande, informations du club)</li>
          <li>Faire fonctionner les fonctionnalités du site (classements, tournois, profils joueurs)</li>
        </ul>

        <h2>Qui y a accès</h2>
        <p>
          Seuls les administrateurs du club, via un accès protégé par authentification, consultent ces données.
          Elles ne sont ni vendues ni partagées à des fins commerciales ou publicitaires. Elles transitent en
          revanche par nos prestataires techniques, dans la stricte mesure nécessaire au fonctionnement du site :
          hébergement (Vercel, Render), base de données (Neon) et envoi des emails automatiques (Resend).
        </p>

        <h2>Cookies et traceurs</h2>
        <p>
          Ce site n'utilise aucun cookie de suivi publicitaire ni outil d'analyse tiers. La connexion à ton
          compte repose sur un jeton de session stocké localement dans ton navigateur (non un cookie), utile
          uniquement pour te reconnaître pendant ta session et jamais transmis à des tiers.
        </p>

        <h2>Durée de conservation</h2>
        <ul class="legal-list">
          <li>Les données d'une <strong>demande d'adhésion refusée</strong> sont conservées le temps du traitement puis supprimées dans un délai raisonnable.</li>
          <li>Les données d'un <strong>membre actif</strong> sont conservées pendant la durée de son adhésion.</li>
          <li>Un membre qui quitte le club peut demander la suppression de ses données à tout moment.</li>
        </ul>

        <h2>Tes droits</h2>
        <p>
          Tu peux à tout moment demander l'accès, la rectification ou la suppression de tes données personnelles
          en écrivant à <a href="mailto:contact@gouzepe-gaming.com">contact@gouzepe-gaming.com</a>.
        </p>

        <h2>Mineurs</h2>
        <p>
          Si le/la candidat(e) à l'adhésion est mineur(e), l'accord d'un parent ou tuteur légal est requis pour
          finaliser l'inscription.
        </p>

        <h2>Sécurité</h2>
        <p>
          Les mots de passe sont chiffrés (jamais stockés en clair), les échanges avec le site sont sécurisés
          (HTTPS) et l'accès aux données des membres est réservé aux administrateurs authentifiés.
        </p>

        <h2>Modifications</h2>
        <p>
          Cette politique peut être mise à jour ; la date en haut de page indique la dernière version en vigueur.
        </p>
      </div>
    </section>

    <PublicFooter />
  </div>
</template>

<script setup>
import PublicNav from '@/components/public/PublicNav.vue'
import PublicFooter from '@/components/public/PublicFooter.vue'

const lastUpdate = '18 août 2026'
</script>

<style scoped>
.legal { position: relative; z-index: 1; color: var(--text); }
.section { max-width: none; padding: 4rem clamp(1.25rem, 4vw, 4rem); }
.section-head { max-width: 46rem; margin: 0 auto 2rem; }
.section-head h1 { font-family: var(--font-title); font-weight: 700; font-size: clamp(1.8rem, 4vw, 2.6rem); text-transform: uppercase; letter-spacing: .04em; margin: 0 0 .5rem; }
.section-head h1::after { content: ''; display: block; width: 3rem; height: 3px; margin-top: .7rem; border-radius: 3px; background: var(--accent); }
.section-head p { color: var(--muted); margin: 0; font-size: .85rem; }

.legal-card { max-width: 46rem; margin: 0 auto; padding: 1.75rem clamp(1.25rem, 4vw, 2.25rem); line-height: 1.7; }
.legal-card h2 {
  font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .03em;
  font-size: 1.05rem; color: var(--text); margin: 2rem 0 .8rem;
}
.legal-card h2:first-child { margin-top: 0; }
.legal-card p { color: var(--muted); margin: 0 0 .9rem; }
.legal-card a { color: var(--accent-l); text-decoration: none; }
.legal-card a:hover { text-decoration: underline; }
.legal-list { list-style: none; padding: 0; margin: 0 0 .9rem; display: grid; gap: .5rem; }
.legal-list li { color: var(--muted); padding-left: 1.1rem; position: relative; }
.legal-list li::before { content: '—'; position: absolute; left: 0; color: var(--accent-l); }
.legal-list strong { color: var(--text); }
</style>
