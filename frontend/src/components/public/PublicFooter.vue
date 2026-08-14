<template>
  <footer class="lfoot">
    <div class="lfoot-top">
      <div class="lfoot-brand">
        <span class="brand"><img class="brand-logo" :src="logo" alt="logo" /> {{ brand.name }} {{ brand.tagline }}</span>
        <p class="lfoot-tag">Club eFootball &amp; Tekken.</p>
        <RouterLink to="/inscription" class="btn-primary lfoot-join">Devenir membre</RouterLink>
      </div>

      <div class="lfoot-col">
        <span class="lfoot-h">Explorer</span>
        <RouterLink to="/classements">Classements</RouterLink>
        <RouterLink to="/palmares">Palmarès</RouterLink>
        <RouterLink to="/records">Records</RouterLink>
        <RouterLink to="/membres">Membres</RouterLink>
      </div>

      <div v-if="hasContact" class="lfoot-col">
        <span class="lfoot-h">Contact</span>
        <a v-if="contact.email" :href="`mailto:${contact.email}`">{{ contact.email }}</a>
        <a v-if="contact.phone" :href="`tel:${contact.phone.replace(/\s+/g, '')}`">{{ contact.phone }}</a>
        <a v-if="contact.whatsapp" :href="contact.whatsapp" target="_blank" rel="noopener">WhatsApp</a>
        <a v-if="contact.discord" :href="contact.discord" target="_blank" rel="noopener">Discord</a>
        <a v-if="contact.facebook" :href="contact.facebook" target="_blank" rel="noopener">Facebook</a>
        <a v-if="contact.instagram" :href="contact.instagram" target="_blank" rel="noopener">Instagram</a>
      </div>
    </div>

    <div class="lfoot-inner">
      <span class="lfoot-copy">© {{ year }} {{ brand.name }} — eFootball &amp; Tekken</span>
    </div>
  </footer>
</template>

<script setup>
import { computed } from 'vue'
import { RouterLink } from 'vue-router'
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
.lfoot { border-top: 1px solid var(--border); background: color-mix(in srgb, var(--bg) 85%, transparent); }

.lfoot-top {
  max-width: none; padding: 2.4rem clamp(1.25rem, 4vw, 4rem) 1.6rem;
  display: grid; gap: 2rem; grid-template-columns: 1fr;
}
.lfoot-brand { display: flex; flex-direction: column; align-items: flex-start; gap: .6rem; }
.brand { display: inline-flex; align-items: center; gap: .5rem; font-family: var(--font-title); font-weight: 700; letter-spacing: .05em; }
.brand-logo { width: 28px; height: 28px; border-radius: 7px; object-fit: cover; }
.lfoot-tag { color: var(--muted); font-size: .85rem; margin: 0; }
.lfoot-join { font-size: .82rem; padding: .5rem 1.1rem; }

.lfoot-col { display: flex; flex-direction: column; gap: .55rem; }
.lfoot-h { font-family: var(--font-title); font-weight: 800; text-transform: uppercase; letter-spacing: .06em; font-size: .72rem; color: var(--muted); margin-bottom: .2rem; }
.lfoot-col a { color: var(--muted); text-decoration: none; font-size: .88rem; transition: color .15s; word-break: break-word; }
.lfoot-col a:hover { color: var(--accent-l); }

.lfoot-inner {
  max-width: none; padding: 1rem clamp(1.25rem, 4vw, 4rem) 1.5rem;
  border-top: 1px solid color-mix(in srgb, var(--border) 60%, transparent);
}
.lfoot-copy { color: var(--muted); font-size: .8rem; }

@media (min-width: 720px) {
  .lfoot-top { grid-template-columns: 1.3fr 1fr 1fr; }
}
</style>
