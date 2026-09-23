<template>
  <AppLayout season-label="Administration">
    <div class="page-wrap console">
      <div class="mb-6">
        <h1 class="title">Tableau de bord</h1>
        <p class="sub">Gère les deux pôles du club et les réglages communs.</p>
      </div>

      <section v-for="g in ADMIN_GROUPS" :key="g.key" class="grp">
        <div :class="['grp-head', g.key]"><span class="dot"></span> {{ g.title }}</div>
        <div class="cards">
          <RouterLink v-for="c in g.links" :key="c.to" :to="c.to" class="ac">
            <component :is="c.icon" class="ac-ic" />
            <div>
              <strong>{{ c.label }}
                <span v-if="c.badge === 'membership' && pendingCount > 0" class="badge-count">{{ pendingCount > 9 ? '9+' : pendingCount }}</span>
              </strong>
              <span>{{ c.desc }}</span>
            </div>
          </RouterLink>
        </div>
      </section>
    </div>
  </AppLayout>
</template>

<script setup>
import { RouterLink } from 'vue-router'
import AppLayout from '@/components/layout/AppLayout.vue'
import { useMembershipNotif } from '@/composables/useMembershipNotif'
import { ADMIN_GROUPS } from '@/composables/useNavigation'

const { pendingCount } = useMembershipNotif()
</script>

<style scoped>
.console { max-width: 64rem; }
.title { font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .04em; font-size: 1.5rem; }
.sub { color: var(--muted); margin-top: .25rem; }

.grp { margin-bottom: 2rem; }
.grp-head { display: flex; align-items: center; gap: .6rem; font-family: var(--font-title); font-weight: 700; text-transform: uppercase; letter-spacing: .06em; font-size: .95rem; margin-bottom: 1rem; }
.grp-head .dot { width: .7rem; height: .7rem; border-radius: 50%; }
.grp-head.efoot .dot { background: #3b82f6; }
.grp-head.tekken .dot { background: #ff5a2c; }
.grp-head.club .dot { background: var(--muted); }

.cards { display: grid; gap: .9rem; grid-template-columns: 1fr; }
.ac { display: flex; align-items: center; gap: .9rem; padding: 1rem 1.1rem; background: var(--card); border: 1px solid var(--border); border-radius: 14px; text-decoration: none; color: var(--text); transition: transform .15s, border-color .15s; }
.ac:hover { transform: translateY(-2px); border-color: color-mix(in srgb, var(--accent) 45%, var(--border)); }
.ac-ic { width: 1.5rem; height: 1.5rem; color: var(--accent); flex: none; }
.ac strong { display: block; font-weight: 600; }
.ac span { display: block; font-size: .82rem; color: var(--muted); }

.soon-tag { font-size: .62rem; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; color: var(--accent-l); border: 1px solid color-mix(in srgb, var(--accent) 40%, transparent); padding: .05rem .4rem; border-radius: 999px; margin-left: .35rem; vertical-align: middle; }
.badge-count { display: inline-grid; place-items: center; min-width: 1.1rem; height: 1.1rem; padding: 0 .25rem; border-radius: 999px; background: var(--red); color: #fff; font-size: .7rem; font-weight: 700; margin-left: .35rem; }

@media (min-width: 640px) { .cards { grid-template-columns: 1fr 1fr; } }
@media (min-width: 1000px) { .cards { grid-template-columns: repeat(3, 1fr); } }
</style>
