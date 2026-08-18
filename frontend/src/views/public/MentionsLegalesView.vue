<template>
  <div class="legal">
    <PublicNav />

    <section class="section">
      <div class="section-head">
        <h1>Mentions légales</h1>
        <p>Dernière mise à jour : {{ lastUpdate }}</p>
      </div>

      <div class="card legal-card">
        <h2>Éditeur du site</h2>
        <p>
          Le site <strong>gouzepe-gaming.com</strong> est édité par <strong>GOUZEPE GAMING CLUB</strong>,
          association apolitique, laïque et à but non lucratif régie par la loi du 1<sup>er</sup> juillet 1901
          et le décret du 16 août 1901, déclarée auprès des autorités togolaises compétentes sous le
          récépissé n° 879OLA474NMP.
        </p>
        <ul class="legal-list">
          <li><strong>Siège social :</strong> Agbalépédogan, Commune Golfe 5, Préfecture du Golfe, 07 BP 76 04, Lomé — Togo</li>
          <li><strong>Contact :</strong> <a href="mailto:contact@gouzepe-gaming.com">contact@gouzepe-gaming.com</a></li>
          <li><strong>Responsable de la publication :</strong> Ahlonko Emmanuel AQUEREBURU, fondateur de GOUZEPE GAMING CLUB</li>
        </ul>

        <h2>Hébergement</h2>
        <p>Le site et ses services sont hébergés par les prestataires suivants :</p>
        <ul class="legal-list">
          <li><strong>Site web (frontend) :</strong> Vercel Inc. — 340 S Lemon Ave #4133, Walnut, CA 91789, États-Unis — <a href="https://vercel.com" target="_blank" rel="noopener">vercel.com</a></li>
          <li><strong>API / serveur applicatif :</strong> Render Services, Inc. — <a href="https://render.com" target="_blank" rel="noopener">render.com</a></li>
          <li><strong>Base de données :</strong> Neon, Inc. — <a href="https://neon.tech" target="_blank" rel="noopener">neon.tech</a></li>
          <li><strong>Envoi des emails du club :</strong> Resend — <a href="https://resend.com" target="_blank" rel="noopener">resend.com</a></li>
        </ul>

        <h2>Propriété intellectuelle</h2>
        <p>
          L'ensemble des contenus présents sur ce site (textes, logo, visuels, mise en page) est la propriété
          de GOUZEPE GAMING CLUB, sauf mention contraire. Toute reproduction, représentation ou diffusion, totale
          ou partielle, sans autorisation préalable est interdite.
        </p>

        <h2>Liens et réseaux sociaux</h2>
        <p>
          Ce site peut proposer des liens vers des plateformes tierces (Discord, Facebook, Instagram, WhatsApp...).
          GOUZEPE GAMING CLUB n'est pas responsable du contenu ni des pratiques de confidentialité de ces
          plateformes, qui disposent de leurs propres conditions d'utilisation.
        </p>

        <h2>Limitation de responsabilité</h2>
        <p>
          Les informations diffusées sur ce site (classements, résultats, palmarès...) le sont à titre indicatif.
          Le club met tout en œuvre pour en assurer l'exactitude mais ne saurait être tenu responsable d'erreurs,
          d'omissions ou d'une indisponibilité temporaire du site.
        </p>

        <h2>Droit applicable</h2>
        <p>Les présentes mentions légales sont soumises au droit togolais.</p>
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
.legal-list li { color: var(--muted); }
.legal-list strong { color: var(--text); }
</style>
