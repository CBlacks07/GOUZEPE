<template>
  <footer class="lfoot">
    <div class="lfoot-top">
      <div class="lfoot-brand">
        <RouterLink to="/" class="brand"><img class="brand-logo" :src="logo" alt="logo" /> {{ brand.name }} {{ brand.tagline }}</RouterLink>
        <p class="lfoot-tag">Communauté eSport basée à Lomé (Togo), dédiée à la compétition eFootball &amp; Tekken.</p>
        <RouterLink to="/inscription" class="btn-primary lfoot-join">Devenir membre</RouterLink>
      </div>

      <div class="lfoot-col">
        <span class="lfoot-h">Le club</span>
        <RouterLink to="/">Accueil</RouterLink>
        <RouterLink to="/efootball">eFootball</RouterLink>
        <RouterLink to="/tekken">Tekken</RouterLink>
        <RouterLink to="/membres">Membres</RouterLink>
      </div>

      <div class="lfoot-col">
        <span class="lfoot-h">Compétition</span>
        <RouterLink to="/classements">Classements</RouterLink>
        <RouterLink to="/palmares">Palmarès</RouterLink>
        <RouterLink to="/records">Records</RouterLink>
        <RouterLink to="/reglement-championnat">Règlement eFootball</RouterLink>
      </div>

      <div v-if="hasContact" class="lfoot-col">
        <span class="lfoot-h">Contact</span>
        <a v-if="contact.email" :href="`mailto:${contact.email}`" class="lfoot-contact-link">
          <MailIcon class="w-3.5 h-3.5" /> {{ contact.email }}
        </a>
        <a v-if="contact.phone" :href="`tel:${contact.phone.replace(/\s+/g, '')}`" class="lfoot-contact-link">
          <PhoneIcon class="w-3.5 h-3.5" /> {{ contact.phone }}
        </a>
        <a v-if="contact.whatsapp" :href="contact.whatsapp" target="_blank" rel="noopener" class="lfoot-contact-link">
          <MessageCircleIcon class="w-3.5 h-3.5" /> WhatsApp
        </a>
        <a v-if="contact.discord" :href="contact.discord" target="_blank" rel="noopener" class="lfoot-contact-link">
          <HashIcon class="w-3.5 h-3.5" /> Discord
        </a>
        <a v-if="contact.facebook" :href="contact.facebook" target="_blank" rel="noopener" class="lfoot-contact-link">
          <ThumbsUpIcon class="w-3.5 h-3.5" /> Facebook
        </a>
        <a v-if="contact.instagram" :href="contact.instagram" target="_blank" rel="noopener" class="lfoot-contact-link">
          <CameraIcon class="w-3.5 h-3.5" /> Instagram
        </a>
      </div>
    </div>

    <div class="lfoot-inner">
      <span class="lfoot-copy">© {{ year }} {{ brand.name }} — eFootball &amp; Tekken</span>
      <div class="lfoot-legal">
        <RouterLink to="/mentions-legales">Mentions légales</RouterLink>
        <span class="lfoot-legal-sep">·</span>
        <RouterLink to="/confidentialite">Politique de confidentialité</RouterLink>
      </div>
    </div>
  </footer>
</template>

<script setup>
import { computed } from 'vue'
import { RouterLink } from 'vue-router'
import { MailIcon, PhoneIcon, MessageCircleIcon, HashIcon, ThumbsUpIcon, CameraIcon } from 'lucide-vue-next'
import { useSiteSettings } from '@/stores/siteSettings'
import { mediaUrl } from '@/composables/useAPI'

const year = new Date().getFullYear()
const site = useSiteSettings()
const brand = computed(() => site.settings.brand)
const logo = computed(() => mediaUrl(site.settings.brand.logo))
const contact = computed(() => site.settings.contact || {})
const hasContact = computed(() => Object.values(contact.value).some(v => String(v || '').trim()))
</script>

<style scoped>
.lfoot { position: relative; border-top: 1px solid var(--border); background: color-mix(in srgb, var(--bg) 85%, transparent); }
.lfoot::before {
  content: ''; position: absolute; top: -1px; left: 0; right: 0; height: 2px;
  background: linear-gradient(90deg, transparent, var(--accent), transparent);
  opacity: .6;
}

.lfoot-top {
  max-width: none; padding: 2.8rem clamp(1.25rem, 4vw, 4rem) 2rem;
  display: grid; gap: 2.2rem; grid-template-columns: 1fr;
}
.lfoot-brand { display: flex; flex-direction: column; align-items: flex-start; gap: .7rem; }
.brand { display: inline-flex; align-items: center; gap: .5rem; font-family: var(--font-title); font-weight: 700; letter-spacing: .05em; color: var(--text); text-decoration: none; transition: color .15s; }
.brand:hover { color: var(--accent-l); }
.brand-logo { width: 28px; height: 28px; border-radius: 7px; object-fit: cover; }
.lfoot-tag { color: var(--muted); font-size: .85rem; line-height: 1.55; margin: 0; max-width: 26rem; }
.lfoot-join { font-size: .82rem; padding: .5rem 1.1rem; margin-top: .2rem; }

.lfoot-col { display: flex; flex-direction: column; gap: .6rem; min-width: 0; }
.lfoot-h { font-family: var(--font-title); font-weight: 800; text-transform: uppercase; letter-spacing: .08em; font-size: .7rem; color: var(--accent-l); margin-bottom: .3rem; }
.lfoot-col a { color: var(--muted); text-decoration: none; font-size: .88rem; transition: color .15s; word-break: break-word; }
.lfoot-col a:hover { color: var(--accent-l); }
.lfoot-contact-link { display: inline-flex; align-items: center; gap: .5rem; }
.lfoot-contact-link svg { flex: none; color: var(--accent-l); opacity: .85; }

.lfoot-inner {
  max-width: none; padding: 1.1rem clamp(1.25rem, 4vw, 4rem) 1.5rem;
  border-top: 1px solid color-mix(in srgb, var(--border) 60%, transparent);
  display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: .5rem 1.5rem;
}
.lfoot-copy { color: var(--muted); font-size: .8rem; }
.lfoot-legal { display: flex; align-items: center; gap: .5rem; flex-wrap: wrap; }
.lfoot-legal a { color: var(--muted); text-decoration: none; font-size: .8rem; transition: color .15s; }
.lfoot-legal a:hover { color: var(--accent-l); }
.lfoot-legal-sep { color: var(--border); font-size: .8rem; }

@media (min-width: 720px) {
  .lfoot-top { grid-template-columns: 1.4fr .8fr .8fr 1fr; }
}
</style>
