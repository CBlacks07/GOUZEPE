<template>
  <AppLayout :season-label="currentSeason?.name || 'Saison'">
    <div class="home-page">
      <div class="home-content">

      <!-- HERO -->
      <section class="hero-section reveal">
        <!-- GOUZEPE Gaming Club — en haut -->
        <div class="hero-club">
          <span class="hero-club-name">GOUZEPE</span>
          <span class="hero-club-label">Gaming Club</span>
        </div>

        <!-- Bande photos défilante infinie -->
        <div class="hero-photos-track-wrap" aria-hidden="true">
          <div class="hero-photos-track">
            <div
              v-for="(src, i) in [...shuffledPhotos, ...shuffledPhotos]"
              :key="src + i"
              class="hero-photo-frame"
              :style="{ '--fi': i % shuffledPhotos.length }"
            >
              <div class="hero-photo-clip">
                <img :src="src" alt="" class="hero-photo-img" loading="lazy" />
              </div>
            </div>
          </div>
        </div>

        <!-- Corps : texte + visuel -->
        <div class="hero-body">
          <div class="hero-left">
            <h2 class="hero-title">
              Bienvenue au club
              <span class="hero-accent hero-typing">{{ typedText }}<span class="hero-cursor" aria-hidden="true">|</span></span>
            </h2>
            <p class="hero-sub reveal delay-1">Saisons intenses, matchs aller/retour, barrages, duels et classements en temps réel.</p>
            <div class="flex flex-wrap gap-2 reveal delay-2">
              <router-link to="/duel" class="btn-primary">Lancer un duel</router-link>
              <router-link to="/classement" class="btn">Voir le classement</router-link>
              <router-link to="/profil" class="btn-ghost">Mon espace</router-link>
            </div>
          </div>

          <!-- Visuel animé droite -->
          <div class="hero-visual" aria-hidden="true">
            <div class="hero-ring hero-ring-outer"></div>
            <div class="hero-ring hero-ring-inner"></div>
            <div class="hero-glow"></div>
            <Transition name="hero-img" mode="out-in">
              <div v-if="heroSlides[heroSlideIndex]" :key="heroSlideIndex" :class="['hero-img-wrap', heroSlides[heroSlideIndex].anim]">
                <img :src="heroSlides[heroSlideIndex].src" :alt="heroSlides[heroSlideIndex].alt" class="hero-slide-img" />
              </div>
            </Transition>
            <div class="hero-dots" aria-hidden="true">
              <span v-for="(_, i) in heroSlides" :key="i" :class="['hero-dot', { active: i === heroSlideIndex }]" />
            </div>
          </div>
        </div>
      </section>      <!-- News + Next fixture -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-6 reveal delay-1">
        <div class="card card-news">
          <div class="mini-head">
            <h3 class="font-semibold">À la une</h3>
            <span class="live-chip">LIVE</span>
          </div>
          <p class="mini-sub">Dernière journée publiée : {{ headlineLastPublishedLabel || '—' }}</p>

          <div v-if="loadingNews" class="text-sm" style="color:var(--muted)">Chargement…</div>
          <div v-else class="space-y-2">
            <div v-if="!newsItems.length" class="text-sm" style="color:var(--muted)">Aucune journée publiée.</div>
            <div v-for="(item, idx) in newsItems" :key="item.title" class="mini-row" :class="{ 'mini-row--champion': idx < 2 }">
              <span class="text-sm" style="color:var(--muted)">{{ item.title }}</span>
              <span class="text-sm font-medium">{{ item.meta }}</span>
            </div>

            <Transition name="insight-fade" mode="out-in">
              <div v-if="currentHeadlineFlash" :key="'headline-' + headlineFlashIndex" class="insight-box">
                <span class="insight-tag">{{ currentHeadlineFlash.tag }}</span>
                <p class="insight-text">{{ currentHeadlineFlash.text }}</p>
              </div>
            </Transition>
          </div>
        </div>

        <div class="card card-next">
          <div class="mini-head">
            <h3 class="font-semibold">Prochaine journée</h3>
            <span class="next-pill">{{ nextFixtureStatus }}</span>
          </div>

          <div v-if="loadingNextFixture" class="text-sm" style="color:var(--muted)">Chargement…</div>
          <div v-else class="space-y-3">
            <div class="flex justify-between items-center">
              <div>
                <p class="font-medium">{{ nextFixtureLabel }}</p>
                <p v-if="nextFixtureMeta" class="text-sm" style="color:var(--muted)">{{ nextFixtureMeta }}</p>
              </div>
              <button v-if="nextFixtureDay" @click="goToDay(nextFixtureDay)" class="btn text-sm" title="Ouvrir cette journée">Voir</button>
            </div>

            <p class="text-xs" style="color:var(--muted)">Pronostics</p>
            <Transition name="insight-fade" mode="out-in">
              <div v-if="currentNextInsight" :key="'next-' + nextInsightIndex" class="insight-box insight-box--alt">
                <span class="insight-tag insight-tag--alt">{{ currentNextInsight.tag }}</span>
                <p class="insight-text">{{ currentNextInsight.text }}</p>
              </div>
            </Transition>
            <div v-if="nextInsights.length > 1" class="insight-dots" aria-hidden="true">
              <span
                v-for="(_, i) in nextInsights"
                :key="'dot-' + i"
                class="insight-dot"
                :class="{ active: i === nextInsightIndex }"
              />
            </div>
          </div>
        </div>
      </div>
      <!-- ===== GESTION JOURNÉE ===== -->
      <div class="card reveal delay-2">
        <!-- Barre de contrôle -->
        <div class="flex flex-wrap gap-2 items-center mb-4">
          <h3 class="font-semibold text-lg mr-2">Gestion de journée</h3>
          <input type="date" v-model="selectedDate" @change="onDateChange" class="input w-44" />
          <select v-model="dayStatusDisplay" class="input w-36" disabled>
            <option value="new">Nouvelle</option>
            <option value="draft">Brouillon</option>
            <option value="confirmed">Confirmée</option>
          </select>
          <span class="text-xs px-2 py-1 rounded-full text-sm"
                :style="dayStatusDisplay === 'confirmed' ? 'background:color-mix(in srgb, var(--green) 16%, transparent);color:var(--green)' :
                         dayStatusDisplay === 'draft'     ? 'background:color-mix(in srgb, var(--blue) 16%, transparent);color:var(--blue)' :
                                                            'background:rgba(148,163,184,.1);color:var(--muted)'">
            {{ dayInfo }}
          </span>
          <div class="flex-1"></div>
          <button @click="printDaySheet" class="btn text-sm" title="Imprimer la feuille de la journée">
            Imprimer (PDF)
          </button>
          <button @click="loadDay" class="btn text-sm" title="Recharger les données de la journée">
            Rafraîchir
          </button>
          <template v-if="auth.isAdmin">
            <button @click="openParticipantsModal" class="btn-primary text-sm" title="Ajouter, retirer et répartir les participants">Gérer participants</button>
            <button @click="clearScores('d1')" class="btn text-sm"
                    title="Effacer tous les scores de la Division 1"
                    style="background:rgba(245,158,11,.14);border-color:#b45309">Effacer D1</button>
            <button @click="clearScores('d2')" class="btn text-sm"
                    title="Effacer tous les scores de la Division 2"
                    style="background:rgba(245,158,11,.14);border-color:#b45309">Effacer D2</button>
            <button @click="clearAllMatches" class="btn text-sm"
                    title="Supprimer toutes les confrontations D1 et D2"
                    style="background:#2a0c0c;border-color:#7f1d1d;color:#fecaca">Supprimer confrontations</button>
            <button @click="saveDraft(false)" class="btn text-sm" :disabled="saving" title="Sauvegarder la journée en brouillon">
              <Loader2Icon v-if="saving" class="w-3.5 h-3.5 animate-spin" /> Brouillon
            </button>
            <button @click="openConfirmModal" class="btn-primary text-sm" :disabled="publishing" title="Publier et confirmer définitivement la journée">
              <Loader2Icon v-if="publishing" class="w-3.5 h-3.5 animate-spin" /> Publier
            </button>
          </template>
        </div>

        <!-- Recherche confrontation -->
        <div class="flex flex-wrap gap-2 items-center mb-4">
          <input v-model="matchSearch" type="text" class="input flex-1 min-w-48"
                 placeholder="Rechercher confrontation (ID joueur)…"
                 @keydown.enter="searchMatch" />
          <select v-model="matchSearchDiv" class="input w-36">
            <option value="all">D1 + D2</option>
            <option value="d1">Division 1</option>
            <option value="d2">Division 2</option>
          </select>
          <button @click="searchMatch" class="btn text-sm" title="Rechercher un joueur dans les confrontations">Chercher</button>
          <span v-if="matchSearchInfo" class="text-xs" style="color:var(--muted)">{{ matchSearchInfo }}</span>
        </div>

        <div
          v-if="loadingDayTournaments || dayTournaments.length"
          class="mb-4 rounded-xl p-3"
          style="border:1px solid var(--border);background:color-mix(in srgb, var(--panel) 82%, transparent)"
        >
          <div class="flex items-center justify-between gap-2 flex-wrap mb-3">
            <h4 class="font-medium">Tournoi(x) membre de la date sélectionnée</h4>
            <span v-if="loadingDayTournaments" class="text-xs" style="color:var(--muted)">Chargement...</span>
            <span v-else class="text-xs" style="color:var(--muted)">{{ dayTournaments.length }} tournoi(s)</span>
          </div>

          <div v-if="loadingDayTournaments" class="text-sm" style="color:var(--muted)">
            Récupération des tournois du jour...
          </div>
          <div v-else class="space-y-3">
            <article
              v-for="t in dayTournaments"
              :key="'day-tournament-' + t.tournament.id"
              class="rounded-xl p-3"
              style="border:1px solid rgba(148,163,184,.22);background:rgba(2,6,23,.18)"
            >
              <div class="flex items-start justify-between gap-2 flex-wrap mb-2">
                <div>
                  <p class="font-semibold">{{ t.tournament.name }}</p>
                  <p class="text-xs" style="color:var(--muted)">
                    {{ tournamentFormatLabel(t.tournament.format) }} • {{ tournamentStatusLabel(t.tournament.status) }}
                    <span v-if="t.tournament.starts_at">• {{ formatTournamentDateTime(t.tournament.starts_at) }}</span>
                  </p>
                </div>
                <span class="text-xs px-2 py-1 rounded-full"
                      :style="tournamentStatusStyle(t.tournament.status)">
                  {{ tournamentStatusLabel(t.tournament.status) }}
                </span>
              </div>

              <div v-if="t.tournament.day_comment" class="text-sm mb-3"
                   style="border:1px solid rgba(59,130,246,.35);background:rgba(59,130,246,.08);padding:8px;border-radius:10px">
                <strong>Commentaire:</strong> {{ t.tournament.day_comment }}
              </div>

              <div v-if="t.matches?.length" class="overflow-x-auto table-shell mb-3"
                   :style="tournamentMatchesForDay(t.matches).length > 6 ? 'max-height:260px;overflow-y:auto' : ''">
                <table class="w-full text-sm standings-table" style="border-collapse:collapse">
                  <thead>
                    <tr class="text-xs uppercase" style="color:var(--muted)">
                      <th class="py-1 px-2 text-left">Confrontation</th>
                      <th class="py-1 px-2 text-center">Score</th>
                      <th class="py-1 px-2 text-center">Statut</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="m in tournamentMatchesForDay(t.matches)" :key="'day-tm-' + t.tournament.id + '-' + m.id">
                      <td class="py-1 px-2">{{ m.p1_name || 'TBD' }} vs {{ m.p2_name || 'TBD' }}</td>
                      <td class="py-1 px-2 text-center">{{ tournamentScoreLabel(m) }}</td>
                      <td class="py-1 px-2 text-center" style="color:var(--muted)">{{ matchStatusLabel(m.status) }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <div class="grid grid-cols-1 xl:grid-cols-2 gap-3">
                <div v-if="Array.isArray(t.standings) && t.standings.length" class="overflow-x-auto table-shell">
                  <p class="text-xs uppercase mb-2" style="color:var(--muted)">Classement tournoi</p>
                  <table class="w-full text-sm standings-table" style="border-collapse:collapse">
                    <thead>
                      <tr class="text-xs uppercase" style="color:var(--muted)">
                        <th class="py-1 px-2 text-left">#</th>
                        <th class="py-1 px-2 text-left">Joueur</th>
                        <th class="py-1 px-2 text-center">J</th>
                        <th class="py-1 px-2 text-center">Pts</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="(s, idx) in t.standings" :key="'rr-' + t.tournament.id + '-' + (s.participant_id || idx)">
                        <td class="py-1 px-2">{{ idx + 1 }}</td>
                        <td class="py-1 px-2">{{ s.name }}</td>
                        <td class="py-1 px-2 text-center">{{ s.played ?? (s.w + s.d + s.l) }}</td>
                        <td class="py-1 px-2 text-center">{{ s.pts ?? s.points }}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
                <div v-else-if="t.standings?.groups?.length" class="space-y-2">
                  <div
                    v-for="grp in t.standings.groups"
                    :key="'tg-' + t.tournament.id + '-' + grp.group_no"
                    class="overflow-x-auto table-shell"
                  >
                    <p class="text-xs uppercase mb-2" style="color:var(--muted)">Groupe {{ String.fromCharCode(65 + Number(grp.group_no || 0)) }}</p>
                    <table class="w-full text-sm standings-table" style="border-collapse:collapse">
                      <thead>
                        <tr class="text-xs uppercase" style="color:var(--muted)">
                          <th class="py-1 px-2 text-left">#</th>
                          <th class="py-1 px-2 text-left">Joueur</th>
                          <th class="py-1 px-2 text-center">J</th>
                          <th class="py-1 px-2 text-center">Pts</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr v-for="(s, idx) in grp.standings || []" :key="'g-row-' + t.tournament.id + '-' + grp.group_no + '-' + (s.participant_id || idx)">
                          <td class="py-1 px-2">{{ idx + 1 }}</td>
                          <td class="py-1 px-2">{{ s.name }}</td>
                          <td class="py-1 px-2 text-center">{{ s.played ?? (s.w + s.d + s.l) }}</td>
                          <td class="py-1 px-2 text-center">{{ s.pts ?? s.points }}</td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>

                <div v-if="t.final_ranking?.length && t.tournament.format !== 'round_robin'" class="overflow-x-auto table-shell">
                  <p class="text-xs uppercase mb-2" style="color:var(--muted)">Classement final</p>
                  <table class="w-full text-sm standings-table" style="border-collapse:collapse">
                    <thead>
                      <tr class="text-xs uppercase" style="color:var(--muted)">
                        <th class="py-1 px-2 text-left">Rang</th>
                        <th class="py-1 px-2 text-left">Joueur</th>
                        <th class="py-1 px-2 text-center">Victoires</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="row in t.final_ranking" :key="'fr-' + t.tournament.id + '-' + row.participant_id">
                        <td class="py-1 px-2">{{ row.rank }}</td>
                        <td class="py-1 px-2">{{ row.display_name }}</td>
                        <td class="py-1 px-2 text-center">{{ row.wins }}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </article>
          </div>
        </div>

        <div v-if="loadingDay" class="text-center py-10" style="color:var(--muted)">Chargement de la journée…</div>
        <div v-else class="grid grid-cols-1 xl:grid-cols-2 gap-6">

          <!-- D1 -->
          <div>
            <div class="flex items-center justify-between mb-2">
              <h4 class="font-medium">Division 1 — Confrontations (Aller/Retour)</h4>
              <button v-if="auth.isAdmin" @click="addMatch('d1')" class="btn text-xs" title="Ajouter une confrontation vide en D1">Ajouter ligne</button>
            </div>
            <div class="overflow-x-auto table-shell" style="max-height:480px;overflow-y:auto">
              <table class="w-full text-sm matches-table" style="border-collapse:separate;border-spacing:0 4px">
                <thead>
                  <tr class="text-xs uppercase" style="color:var(--muted)">
                    <th class="p-2 text-left sortable-col" @click="onSortHeader('d1', 'p1')" :title="sortTitle('d1', 'p1')">
                      Joueur 1 <span class="sort-indicator">{{ sortIndicator('d1', 'p1') }}</span>
                    </th>
                    <th class="p-2 text-center">ALLER / RETOUR</th>
                    <th class="p-2 text-left sortable-col" @click="onSortHeader('d1', 'p2')" :title="sortTitle('d1', 'p2')">
                      Joueur 2 <span class="sort-indicator">{{ sortIndicator('d1', 'p2') }}</span>
                    </th>
                    <th v-if="auth.isAdmin" class="p-2 w-8"></th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-if="!d1Matches.length">
                    <td colspan="4" class="text-center py-4 text-sm" style="color:var(--muted)">Aucune confrontation.</td>
                  </tr>
                  <tr v-for="(m, i) in d1Matches" :key="'d1-' + i"
                      :id="'d1-match-' + i"
                      class="transition-colors"
                      :style="highlightSet.has('d1-'+i) ? 'outline:2px solid #3b82f6;border-radius:8px' : ''">
                    <td class="p-1">
                      <input v-if="auth.isAdmin" v-model="m.p1" list="players-dl"
                             class="input text-sm px-2 py-1 player-id-input" placeholder="ID"
                             @input="onMatchInput" />
                      <span v-else class="font-medium player-id-text">{{ m.p1 || '—' }}</span>
                    </td>
                    <td class="p-1 text-center">
                      <!-- Aller row -->
                      <div class="flex items-center gap-1 justify-center mb-1">
                        <input v-if="auth.isAdmin" v-model="m.a1" type="number" min="0"
                               class="input text-sm text-center px-1 py-1" style="width:44px"
                               @input="onMatchInput" />
                        <span v-else class="text-center" style="width:24px">{{ m.a1 ?? '—' }}</span>
                        <span class="text-xs" style="color:var(--muted)">–</span>
                        <input v-if="auth.isAdmin" v-model="m.a2" type="number" min="0"
                               class="input text-sm text-center px-1 py-1" style="width:44px"
                               @input="onMatchInput" />
                        <span v-else class="text-center" style="width:24px">{{ m.a2 ?? '—' }}</span>
                      </div>
                      <!-- Retour row -->
                      <div class="flex items-center gap-1 justify-center" style="opacity:.7">
                        <input v-if="auth.isAdmin" v-model="m.r1" type="number" min="0"
                               class="input text-sm text-center px-1 py-1" style="width:44px"
                               @input="onMatchInput" />
                        <span v-else class="text-center" style="width:24px">{{ m.r1 ?? '—' }}</span>
                        <span class="text-xs" style="color:var(--muted)">–</span>
                        <input v-if="auth.isAdmin" v-model="m.r2" type="number" min="0"
                               class="input text-sm text-center px-1 py-1" style="width:44px"
                               @input="onMatchInput" />
                        <span v-else class="text-center" style="width:24px">{{ m.r2 ?? '—' }}</span>
                      </div>
                    </td>
                    <td class="p-1">
                      <input v-if="auth.isAdmin" v-model="m.p2" list="players-dl"
                             class="input text-sm px-2 py-1 player-id-input" placeholder="ID"
                             @input="onMatchInput" />
                      <span v-else class="font-medium player-id-text">{{ m.p2 || '—' }}</span>
                    </td>
                    <td v-if="auth.isAdmin" class="p-1 text-center">
                      <button @click="removeMatch('d1', i)" title="Supprimer"
                              style="background:none;border:none;cursor:pointer;color:#ef4444;padding:4px">
                        <Trash2Icon class="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Classement D1 -->
            <h5 class="font-medium mt-4 mb-2 text-sm">Classement D1</h5>
            <div class="overflow-x-auto table-shell">
              <table class="w-full text-sm standings-table" style="border-collapse:collapse">
                <thead>
                  <tr class="text-xs uppercase" style="color:var(--muted)">
                    <th class="py-1 px-2 text-left">Joueur</th>
                    <th class="py-1 px-1 text-center">J</th>
                    <th class="py-1 px-1 text-center">V</th>
                    <th class="py-1 px-1 text-center">N</th>
                    <th class="py-1 px-1 text-center">D</th>
                    <th class="py-1 px-1 text-center">BM</th>
                    <th class="py-1 px-1 text-center">BC</th>
                    <th class="py-1 px-1 text-center">Diff</th>
                    <th class="py-1 px-1 text-center font-bold">PTS</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-if="!d1Standings.length">
                    <td colspan="9" class="text-center py-2 text-xs" style="color:var(--muted)">—</td>
                  </tr>
                  <tr v-for="(r, ri) in d1Standings" :key="r.id"
                      :style="r.role === 'INVITE' ? 'opacity:.65;font-style:italic' : ''">
                    <td class="py-1 px-2">
                      <span v-if="ri === 0 && r.role !== 'INVITE'" class="mr-1">🏆</span>
                      {{ r.id }}
                      <span v-if="r.role === 'INVITE'" class="text-xs ml-1" style="color:var(--muted)">(invité)</span>
                    </td>
                    <td class="text-center py-1 px-1">{{ r.J }}</td>
                    <td class="text-center py-1 px-1 font-medium" style="color:var(--green)">{{ r.V }}</td>
                    <td class="text-center py-1 px-1" style="color:var(--muted)">{{ r.N }}</td>
                    <td class="text-center py-1 px-1">{{ r.D }}</td>
                    <td class="text-center py-1 px-1">{{ r.BP }}</td>
                    <td class="text-center py-1 px-1">{{ r.BC }}</td>
                    <td class="text-center py-1 px-1"
                        :style="r.DIFF > 0 ? 'color:var(--green)' : r.DIFF < 0 ? 'color:#ef4444' : 'color:var(--muted)'">
                      {{ r.DIFF > 0 ? '+' + r.DIFF : r.DIFF }}
                    </td>
                    <td class="text-center py-1 px-1 font-bold">{{ r.PTS }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- D2 (same structure) -->
          <div>
            <div class="flex items-center justify-between mb-2">
              <h4 class="font-medium">Division 2 — Confrontations (Aller/Retour)</h4>
              <button v-if="auth.isAdmin" @click="addMatch('d2')" class="btn text-xs" title="Ajouter une confrontation vide en D2">Ajouter ligne</button>
            </div>
            <div class="overflow-x-auto table-shell" style="max-height:480px;overflow-y:auto">
              <table class="w-full text-sm matches-table" style="border-collapse:separate;border-spacing:0 4px">
                <thead>
                  <tr class="text-xs uppercase" style="color:var(--muted)">
                    <th class="p-2 text-left sortable-col" @click="onSortHeader('d2', 'p1')" :title="sortTitle('d2', 'p1')">
                      Joueur 1 <span class="sort-indicator">{{ sortIndicator('d2', 'p1') }}</span>
                    </th>
                    <th class="p-2 text-center">ALLER / RETOUR</th>
                    <th class="p-2 text-left sortable-col" @click="onSortHeader('d2', 'p2')" :title="sortTitle('d2', 'p2')">
                      Joueur 2 <span class="sort-indicator">{{ sortIndicator('d2', 'p2') }}</span>
                    </th>
                    <th v-if="auth.isAdmin" class="p-2 w-8"></th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-if="!d2Matches.length">
                    <td colspan="4" class="text-center py-4 text-sm" style="color:var(--muted)">Aucune confrontation.</td>
                  </tr>
                  <tr v-for="(m, i) in d2Matches" :key="'d2-' + i"
                      :id="'d2-match-' + i"
                      class="transition-colors"
                      :style="highlightSet.has('d2-'+i) ? 'outline:2px solid #3b82f6;border-radius:8px' : ''">
                    <td class="p-1">
                      <input v-if="auth.isAdmin" v-model="m.p1" list="players-dl"
                             class="input text-sm px-2 py-1 player-id-input" placeholder="ID"
                             @input="onMatchInput" />
                      <span v-else class="font-medium player-id-text">{{ m.p1 || '—' }}</span>
                    </td>
                    <td class="p-1 text-center">
                      <div class="flex items-center gap-1 justify-center mb-1">
                        <input v-if="auth.isAdmin" v-model="m.a1" type="number" min="0"
                               class="input text-sm text-center px-1 py-1" style="width:44px"
                               @input="onMatchInput" />
                        <span v-else class="text-center" style="width:24px">{{ m.a1 ?? '—' }}</span>
                        <span class="text-xs" style="color:var(--muted)">–</span>
                        <input v-if="auth.isAdmin" v-model="m.a2" type="number" min="0"
                               class="input text-sm text-center px-1 py-1" style="width:44px"
                               @input="onMatchInput" />
                        <span v-else class="text-center" style="width:24px">{{ m.a2 ?? '—' }}</span>
                      </div>
                      <div class="flex items-center gap-1 justify-center" style="opacity:.7">
                        <input v-if="auth.isAdmin" v-model="m.r1" type="number" min="0"
                               class="input text-sm text-center px-1 py-1" style="width:44px"
                               @input="onMatchInput" />
                        <span v-else class="text-center" style="width:24px">{{ m.r1 ?? '—' }}</span>
                        <span class="text-xs" style="color:var(--muted)">–</span>
                        <input v-if="auth.isAdmin" v-model="m.r2" type="number" min="0"
                               class="input text-sm text-center px-1 py-1" style="width:44px"
                               @input="onMatchInput" />
                        <span v-else class="text-center" style="width:24px">{{ m.r2 ?? '—' }}</span>
                      </div>
                    </td>
                    <td class="p-1">
                      <input v-if="auth.isAdmin" v-model="m.p2" list="players-dl"
                             class="input text-sm px-2 py-1 player-id-input" placeholder="ID"
                             @input="onMatchInput" />
                      <span v-else class="font-medium player-id-text">{{ m.p2 || '—' }}</span>
                    </td>
                    <td v-if="auth.isAdmin" class="p-1 text-center">
                      <button @click="removeMatch('d2', i)" title="Supprimer"
                              style="background:none;border:none;cursor:pointer;color:#ef4444;padding:4px">
                        <Trash2Icon class="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Classement D2 -->
            <h5 class="font-medium mt-4 mb-2 text-sm">Classement D2</h5>
            <div class="overflow-x-auto table-shell">
              <table class="w-full text-sm standings-table" style="border-collapse:collapse">
                <thead>
                  <tr class="text-xs uppercase" style="color:var(--muted)">
                    <th class="py-1 px-2 text-left">Joueur</th>
                    <th class="py-1 px-1 text-center">J</th>
                    <th class="py-1 px-1 text-center">V</th>
                    <th class="py-1 px-1 text-center">N</th>
                    <th class="py-1 px-1 text-center">D</th>
                    <th class="py-1 px-1 text-center">BM</th>
                    <th class="py-1 px-1 text-center">BC</th>
                    <th class="py-1 px-1 text-center">Diff</th>
                    <th class="py-1 px-1 text-center font-bold">PTS</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-if="!d2Standings.length">
                    <td colspan="9" class="text-center py-2 text-xs" style="color:var(--muted)">—</td>
                  </tr>
                  <tr v-for="(r, ri) in d2Standings" :key="r.id"
                      :style="r.role === 'INVITE' ? 'opacity:.65;font-style:italic' : ''">
                    <td class="py-1 px-2">
                      <span v-if="ri === 0 && r.role !== 'INVITE'" class="mr-1">🏆</span>
                      {{ r.id }}
                      <span v-if="r.role === 'INVITE'" class="text-xs ml-1" style="color:var(--muted)">(invité)</span>
                    </td>
                    <td class="text-center py-1 px-1">{{ r.J }}</td>
                    <td class="text-center py-1 px-1 font-medium" style="color:var(--green)">{{ r.V }}</td>
                    <td class="text-center py-1 px-1" style="color:var(--muted)">{{ r.N }}</td>
                    <td class="text-center py-1 px-1">{{ r.D }}</td>
                    <td class="text-center py-1 px-1">{{ r.BP }}</td>
                    <td class="text-center py-1 px-1">{{ r.BC }}</td>
                    <td class="text-center py-1 px-1"
                        :style="r.DIFF > 0 ? 'color:var(--green)' : r.DIFF < 0 ? 'color:#ef4444' : 'color:var(--muted)'">
                      {{ r.DIFF > 0 ? '+' + r.DIFF : r.DIFF }}
                    </td>
                    <td class="text-center py-1 px-1 font-bold">{{ r.PTS }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- Barrage (admin) -->
        <div v-if="auth.isAdmin" class="mt-6 pt-5" style="border-top:1px solid var(--border)">
          <h4 class="font-medium mb-3">Barrage D2 ↔ D1 — Les invités sont exclus</h4>
          <div class="flex flex-wrap gap-3 items-center mb-3">
            <label class="text-sm" style="color:var(--muted)">Affiche</label>
            <input v-model="barrage.ids" list="players-dl" class="input w-48"
                   placeholder="ID_D1 – ID_D2" @input="onMatchInput" />
            <button @click="autoFillBarrage" class="btn text-sm" title="Proposer automatiquement une affiche de barrage">
              <RefreshCcwIcon class="w-3.5 h-3.5" /> Proposer
            </button>
          </div>
          <div class="flex gap-3 mb-3 flex-wrap">
            <label class="flex items-center gap-2 cursor-pointer px-3 py-2 rounded-lg transition-colors"
                   :style="barrage.winner === barrageIds[0] ? 'border:1px solid var(--green);background:color-mix(in srgb, var(--green) 10%, transparent)' : 'border:1px solid var(--border)'">
              <input type="radio" v-model="barrage.winner" :value="barrageIds[0]" @change="onMatchInput" />
              <span class="text-sm font-medium">{{ barrageIds[0] || 'Joueur 1 (D1)' }}</span>
            </label>
            <label class="flex items-center gap-2 cursor-pointer px-3 py-2 rounded-lg transition-colors"
                   :style="barrage.winner === barrageIds[1] ? 'border:1px solid var(--green);background:color-mix(in srgb, var(--green) 10%, transparent)' : 'border:1px solid var(--border)'">
              <input type="radio" v-model="barrage.winner" :value="barrageIds[1]" @change="onMatchInput" />
              <span class="text-sm font-medium">{{ barrageIds[1] || 'Joueur 2 (D2)' }}</span>
            </label>
          </div>
          <p class="text-sm font-bold mb-3" style="color:#3b82f6">{{ barrageLabel }}</p>
          <div>
            <label class="label">Notes / commentaires</label>
            <textarea v-model="barrage.notes" class="input w-full" style="min-height:72px"
                      @input="onMatchInput"></textarea>
          </div>
        </div>
      </div>
    </div>

    <!-- Datalist for autocomplete -->
    <datalist id="players-dl">
      <option v-for="p in allPlayers" :key="p.player_id"
              :value="p.player_id" :label="p.player_id + ' — ' + (p.name || '')" />
    </datalist>

    <!-- Modal: Confirmer la journée -->
    <BaseModal :open="confirmModal" title="Confirmer la journée" @close="confirmModal = false" size="md">
      <div class="space-y-4">
        <p class="text-sm" style="color:var(--muted)">{{ fmtDate(selectedDate) }}</p>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <p class="text-sm mb-1" style="color:var(--muted)">
              Champion D1 : <strong>{{ d1ChampId || '—' }}</strong>
            </p>
            <label class="label">Équipe D1</label>
            <input v-model="champTeamD1" class="input" placeholder="ex: BARCELONE" maxlength="12" />
          </div>
          <div>
            <p class="text-sm mb-1" style="color:var(--muted)">
              Champion D2 : <strong>{{ d2ChampId || '—' }}</strong>
            </p>
            <label class="label">Équipe D2</label>
            <input v-model="champTeamD2" class="input" placeholder="ex: JUVENTUS" maxlength="12" />
          </div>
        </div>
        <p class="text-sm" style="color:var(--muted)">Barrage : <strong>{{ barrageLabel }}</strong></p>
        <p v-if="confirmError" class="text-sm" style="color:#ef4444">{{ confirmError }}</p>
      </div>
      <template #footer>
        <button @click="confirmModal = false" class="btn" title="Fermer sans publier">Annuler</button>
        <button @click="publishDay" class="btn-primary" :disabled="publishing" title="Confirmer et publier la journée">
          <Loader2Icon v-if="publishing" class="w-3.5 h-3.5 animate-spin" />
          Valider & Enregistrer
        </button>
      </template>
    </BaseModal>

    <!-- Modal: Gestion participants -->
    <BaseModal :open="participantsModal" title="Gérer les participants" @close="participantsModal = false" size="xl">
      <div class="space-y-4">
        <input v-model="pmSearch" type="text" class="input w-full" placeholder="Rechercher un joueur…" />
        <div class="grid grid-cols-2 gap-4">
          <!-- D1 participants -->
          <div>
            <h4 class="font-bold mb-2" style="color:var(--green)">Division 1 ({{ pmD1.length }})</h4>
            <div class="rounded-xl p-2 overflow-y-auto" style="border:1px solid var(--border);max-height:240px">
              <p v-if="!pmD1.length" class="text-center py-4 text-sm" style="color:var(--muted)">Aucun participant</p>
              <div v-for="id in pmD1" :key="id"
                   class="flex items-center justify-between px-2 py-1.5 rounded hover:bg-gz-panel text-sm">
                <span class="font-medium">{{ id }}</span>
                <button @click="pmRemove('d1', id)" title="Retirer ce joueur de la D1" style="background:none;border:none;cursor:pointer;color:#ef4444;font-size:16px">×</button>
              </div>
            </div>
          </div>
          <!-- D2 participants -->
          <div>
            <h4 class="font-bold mb-2" style="color:#60a5fa">Division 2 ({{ pmD2.length }})</h4>
            <div class="rounded-xl p-2 overflow-y-auto" style="border:1px solid var(--border);max-height:240px">
              <p v-if="!pmD2.length" class="text-center py-4 text-sm" style="color:var(--muted)">Aucun participant</p>
              <div v-for="id in pmD2" :key="id"
                   class="flex items-center justify-between px-2 py-1.5 rounded text-sm">
                <span class="font-medium">{{ id }}</span>
                <button @click="pmRemove('d2', id)" title="Retirer ce joueur de la D2" style="background:none;border:none;cursor:pointer;color:#ef4444;font-size:16px">×</button>
              </div>
            </div>
          </div>
        </div>

        <!-- Available players -->
        <div>
          <h5 class="text-sm mb-2" style="color:var(--muted)">Joueurs disponibles</h5>
          <div class="rounded-xl overflow-y-auto" style="border:1px solid var(--border);max-height:200px">
            <div v-if="!filteredPmPlayers.length" class="text-center py-4 text-sm" style="color:var(--muted)">
              {{ pmSearch ? 'Aucun résultat' : 'Tous les joueurs sont affectés' }}
            </div>
            <div v-for="p in filteredPmPlayers" :key="p.player_id"
                 class="flex items-center justify-between px-3 py-2 text-sm"
                 style="border-bottom:1px solid rgba(255,255,255,.04)">
              <span>{{ p.name || p.player_id }} <span style="color:var(--muted)">({{ p.player_id }})</span></span>
              <div class="flex gap-2">
                <button @click="pmAddPlayer(p.player_id, 'd1')" class="pm-assign-btn pm-assign-btn-d1" title="Affecter ce joueur à la Division 1">D1</button>
                <button @click="pmAddPlayer(p.player_id, 'd2')" class="pm-assign-btn pm-assign-btn-d2" title="Affecter ce joueur à la Division 2">D2</button>
              </div>
            </div>
          </div>
        </div>

        <!-- Add guest -->
        <div class="rounded-xl p-3" style="border:1px dashed var(--border)">
          <h5 class="text-sm font-bold mb-2">Ajouter un invité (éphémère)</h5>
          <div class="flex gap-2 flex-wrap">
            <input v-model="pmGuestName" type="text" class="input flex-1"
                   placeholder="Nom / pseudo de l'invité"
                   @keydown.enter="pmAddGuest('d1')" />
            <button @click="pmAddGuest('d1')" class="pm-guest-btn pm-guest-btn-d1" :disabled="!pmGuestName.trim()" title="Créer un invité et l'ajouter à la D1">D1</button>
            <button @click="pmAddGuest('d2')" class="pm-guest-btn pm-guest-btn-d2" :disabled="!pmGuestName.trim()" title="Créer un invité et l'ajouter à la D2">D2</button>
          </div>
          <p class="text-xs mt-1" style="color:var(--muted)">Ces invités n'existent que pour la journée en cours.</p>
        </div>
      </div>
      <template #footer>
        <button @click="pmReset" class="btn" title="Vider les participants D1 et D2 du modal" style="background:rgba(245,158,11,.14);border-color:#b45309">
          Réinitialiser
        </button>
        <button @click="participantsModal = false" class="btn" title="Fermer sans générer">Annuler</button>
        <button @click="openPmValidateModal" class="btn-success" title="Ouvrir la confirmation avant génération">
          Valider & Générer les matchs
        </button>
      </template>
    </BaseModal>

    <!-- Modal: Confirmation génération confrontations -->
    <BaseModal :open="pmConfirmModal" title="Valider et générer les confrontations" @close="pmConfirmModal = false" size="md">
      <div class="space-y-3">
        <p class="text-sm" style="color:var(--muted)">
          Cette action va remplacer les confrontations actuelles par une génération automatique.
        </p>
        <div class="rounded-lg p-3 text-sm" style="background:var(--panel);border:1px solid var(--border)">
          <p><strong>Division 1:</strong> {{ pmD1.length }} participant(s)</p>
          <p><strong>Division 2:</strong> {{ pmD2.length }} participant(s)</p>
        </div>
        <p class="text-xs" style="color:var(--muted)">
          Les confrontations déjà existantes gardent leurs scores. Seules les nouvelles affiches manquantes seront ajoutées.
        </p>
      </div>
      <template #footer>
        <button @click="pmConfirmModal = false" class="btn">Annuler</button>
        <button @click="pmValidate" class="btn-success">
          Valider & Générer
        </button>
      </template>
    </BaseModal>

      </div>
  </AppLayout>
</template>

<script setup>
import { ref, reactive, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import AppLayout from '@/components/layout/AppLayout.vue'
import BaseModal from '@/components/ui/BaseModal.vue'
import { useAuthStore } from '@/stores/auth'
import { useAPI } from '@/composables/useAPI'
import { useToast } from '@/composables/useToast'
import { useSessionState } from '@/composables/useSessionState'
import { onRealtimeEvent, joinRealtimeRoom, leaveRealtimeRoom } from '@/composables/useRealtimeSocket'
import { Loader2Icon, Trash2Icon, RefreshCcwIcon } from 'lucide-vue-next'

const auth   = useAuthStore()
const api    = useAPI()
const route  = useRoute()
const router = useRouter()
const { success, error: toastError, info: toastInfo } = useToast()
const MATCH_SORT_STORAGE_KEY = 'gz_accueil_match_sort_v1'

/* ====== State ====== */
const currentSeason   = ref(null)
const allPlayers      = ref([])
const playersRoleMap  = ref(new Map()) // id -> 'MEMBRE' | 'INVITE'

const selectedDate     = ref(new Date().toISOString().slice(0, 10))
const dayStatusDisplay = ref('new') // new | draft | confirmed
const dayInfo          = ref('')
const loadingDay       = ref(false)
const dayTournaments   = ref([])
const loadingDayTournaments = ref(false)
const saving           = ref(false)
const publishing       = ref(false)

// Matches: plain reactive arrays of plain objects
const d1Matches = ref([]) // [{p1, p2, a1, a2, r1, r2}]
const d2Matches = ref([])
const tempGuests = ref([]) // [{player_id, name}] — éphémères pour cette journée
const barrage = reactive({ ids: '', winner: null, notes: '' })
const matchSort = reactive({
  d1: { key: 'p1', dir: 'asc' },
  d2: { key: 'p1', dir: 'asc' }
})

// News
const loadingNews       = ref(false)
const newsItems         = ref([])
const loadingNextFixture = ref(false)
const nextFixtureLabel  = ref('Prochaine journée')
const nextFixtureStatus = ref('')
const nextFixtureDay    = ref('')
const nextFixtureMeta   = ref('')
const nextFixtureTournaments = ref([])
const recentConfirmedDays = ref([])
const headlineFlashes   = ref([])
const headlineFlashIndex = ref(0)
const nextInsights      = ref([])
const nextInsightIndex  = ref(0)
const featuredInvite    = ref(null)
let realtimeOffDraftUpdate = null
let realtimeOffDayConfirmed = null
let realtimeOffDayUpdated = null
let realtimeOffSeasonChanged = null
let realtimeOffTournamentChanged = null
let joinedDraftRoom = ''
let joinedDayRoom = ''

// Search
const matchSearch    = ref('')
const matchSearchDiv = ref('all')
const matchSearchInfo = ref('')
const highlightSet   = ref(new Set())
const lastEditAt = ref(0)
let syncTimer = null
const heroWords = ['Intensité', 'Compétition', 'Gloire']
const typedText = ref('')
let typingActive = false

function sleep(ms) { return new Promise(r => setTimeout(r, ms)) }

async function runTypingLoop() {
  typingActive = true
  let wordIdx = 0
  while (typingActive) {
    const word = heroWords[wordIdx]
    for (let i = 0; i <= word.length; i++) {
      if (!typingActive) return
      typedText.value = word.slice(0, i)
      await sleep(90)
    }
    await sleep(1800)
    for (let i = word.length; i >= 0; i--) {
      if (!typingActive) return
      typedText.value = word.slice(0, i)
      await sleep(52)
    }
    await sleep(320)
    wordIdx = (wordIdx + 1) % heroWords.length
  }
}

const shuffledPhotos = ref([])
const heroSlides     = ref([])

async function probeAssets(prefix, max = 99) {
  const v = Date.now()
  const results = await Promise.all(
    Array.from({ length: max }, (_, i) => {
      const n = i + 1
      // Try both unpadded (Photo1) and zero-padded (Photo01) formats
      const srcs = [
        `/assets/${prefix}${n}.jpg?v=${v}`,
        `/assets/${prefix}${String(n).padStart(2, '0')}.jpg?v=${v}`,
      ]
      return new Promise(resolve => {
        let resolved = false
        let pending = srcs.length
        for (const src of srcs) {
          const img = new Image()
          img.onload = () => {
            if (!resolved) { resolved = true; resolve(src) }
          }
          img.onerror = () => {
            pending--
            if (pending === 0 && !resolved) resolve(null)
          }
          img.src = src
        }
      })
    })
  )
  const found = []
  for (const r of results) {
    if (r === null) break
    found.push(r)
  }
  return found
}

function shuffle(arr) {
  const a = [...arr]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]]
  }
  return a
}
const heroSlideIndex = ref(0)
let heroSlideTimer = null
let cardsInsightsTimer = null

// Confirm modal
const confirmModal  = ref(false)
const champTeamD1   = ref('')
const champTeamD2   = ref('')
const confirmError  = ref('')

// Participants modal
const participantsModal = ref(false)
const pmConfirmModal    = ref(false)
const pmD1              = ref([]) // array of player IDs
const pmD2              = ref([])
const pmSearch          = ref('')
const pmGuestName       = ref('')

const { restored: restoredAccueilState } = useSessionState('efoot.ui.accueil.v1', {
  selectedDate,
  confirmModal,
  participantsModal,
  pmConfirmModal,
  matchSearch,
  matchSearchDiv,
  pmSearch,
})

// Auto-save timer
let autoSaveTimer = null

/* ====== Computed standings from reactive match arrays ====== */
const d1Standings = computed(() => computeStandings(d1Matches.value))
const d2Standings = computed(() => computeStandings(d2Matches.value))
const currentHeadlineFlash = computed(() => headlineFlashes.value[headlineFlashIndex.value] || null)
const currentNextInsight = computed(() => nextInsights.value[nextInsightIndex.value] || null)
const headlineLastPublishedLabel = computed(() => {
  const d = recentConfirmedDays.value[0]?.date
  return d ? fmtDate(d) : ''
})

const d1ChampId = computed(() =>
  d1Standings.value.find(r => r.role !== 'INVITE')?.id || null
)
const d2ChampId = computed(() =>
  d2Standings.value.find(r => r.role !== 'INVITE')?.id || null
)

const barrageIds = computed(() => {
  const parts = (barrage.ids || '').split(/[-–]/).map(s => s.trim())
  return [parts[0] || '', parts[1] || '']
})

const barrageLabel = computed(() => {
  const [id1, id2] = barrageIds.value
  if (!id1 || !id2) return '—'
  if (barrage.winner === id1) return `${id1} se maintient en D1 · ${id2} reste en D2`
  if (barrage.winner === id2) return `${id2} monte en D1 · ${id1} est relégué en D2`
  return `Affiche : ${id1} – ${id2}`
})

const filteredPmPlayers = computed(() => {
  const q = pmSearch.value.toLowerCase()
  const taken = new Set([...pmD1.value, ...pmD2.value])
  return allPlayers.value
    .filter(p => !taken.has(p.player_id))
    .filter(p => !q || (p.name || '').toLowerCase().includes(q) || (p.player_id || '').toLowerCase().includes(q))
})

/* ====== Standings computation ====== */
function sc(v) {
  if (v === null || v === undefined || v === '') return null
  const n = Number(v)
  return isNaN(n) ? null : n
}

function inferRoleForPlayer(id) {
  const key = String(id || '')
  if (!key) return 'MEMBRE'
  if (key.startsWith('G_')) return 'INVITE'
  return playersRoleMap.value.get(key) || 'MEMBRE'
}

function computeStandings(matches) {
  const agg = new Map()
  const ensure = id => {
    if (!agg.has(id)) agg.set(id, { id, J: 0, V: 0, N: 0, D: 0, BP: 0, BC: 0 })
    return agg.get(id)
  }
  for (const m of matches) {
    if (!m.p1 || !m.p2 || m.p1 === m.p2) continue
    const a1 = sc(m.a1), a2 = sc(m.a2)
    if (a1 !== null && a2 !== null) {
      const A = ensure(m.p1), B = ensure(m.p2)
      A.J++; B.J++; A.BP += a1; A.BC += a2; B.BP += a2; B.BC += a1
      if (a1 > a2)      { A.V++; B.D++ }
      else if (a1 < a2) { B.V++; A.D++ }
      else               { A.N++; B.N++ }
    }
    // retour: p2 is at home; A=p2, ga=r2, gb=r1
    const r1 = sc(m.r1), r2 = sc(m.r2)
    if (r1 !== null && r2 !== null) {
      const A = ensure(m.p2), B = ensure(m.p1)
      A.J++; B.J++; A.BP += r2; A.BC += r1; B.BP += r1; B.BC += r2
      if (r2 > r1)      { A.V++; B.D++ }
      else if (r2 < r1) { B.V++; A.D++ }
      else               { A.N++; B.N++ }
    }
  }
  // Apply roles
  for (const [id, row] of agg) {
    const guestFromTmp = tempGuests.value.find(g => g.player_id === id)
    row.role = guestFromTmp ? 'INVITE' : inferRoleForPlayer(id)
  }
  return [...agg.values()]
    .map(r => ({ ...r, PTS: r.V * 3 + r.N, DIFF: r.BP - r.BC }))
    .sort((a, b) => b.PTS - a.PTS || b.DIFF - a.DIFF || b.BP - a.BP || String(a.id).localeCompare(String(b.id)))
}

/* ====== Helpers ====== */
function fmtDate(d) {
  if (!d) return '—'
  try {
    return new Date(d + 'T12:00:00').toLocaleDateString('fr-FR', {
      weekday: 'long', day: '2-digit', month: 'long', year: 'numeric'
    })
  } catch (_) { return d }
}

function formatTournamentDateTime(value) {
  if (!value) return '—'
  const d = new Date(value)
  if (Number.isNaN(d.getTime())) return String(value)
  return d.toLocaleString('fr-FR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function tournamentFormatLabel(format) {
  return {
    single_elimination: 'Elimination simple',
    double_elimination: 'Double elimination',
    round_robin: 'Round Robin',
    groups_knockout: 'Groupes + Finales'
  }[format] || format || 'Tournoi'
}

function tournamentStatusLabel(status) {
  return {
    draft: 'Brouillon',
    live: 'LIVE',
    completed: 'Terminé',
    archived: 'Archivé'
  }[status] || String(status || '').trim() || '—'
}

function tournamentStatusStyle(status) {
  if (status === 'live') return 'background:color-mix(in srgb, var(--green) 15%, transparent);color:var(--green);border:1px solid color-mix(in srgb, var(--green) 45%, transparent)'
  if (status === 'completed') return 'background:color-mix(in srgb, #3b82f6 14%, transparent);color:#93c5fd;border:1px solid color-mix(in srgb, #3b82f6 45%, transparent)'
  if (status === 'draft') return 'background:color-mix(in srgb, #f59e0b 14%, transparent);color:#fbbf24;border:1px solid color-mix(in srgb, #f59e0b 45%, transparent)'
  return 'background:rgba(148,163,184,.12);color:var(--muted);border:1px solid rgba(148,163,184,.35)'
}

function tournamentMatchesForDay(matches) {
  return [...(matches || [])].sort((a, b) =>
    Number(a.round_no || 0) - Number(b.round_no || 0) ||
    Number(a.slot_no || 0) - Number(b.slot_no || 0) ||
    Number(a.id || 0) - Number(b.id || 0)
  )
}

function tournamentScoreLabel(match) {
  const s1 = match?.score_p1
  const s2 = match?.score_p2
  if (s1 === null || s1 === undefined || s2 === null || s2 === undefined) return '—'
  return `${s1} - ${s2}`
}

function matchStatusLabel(status) {
  const st = String(status || '').toLowerCase()
  if (st === 'completed' || st === 'done') return 'Terminé'
  if (st === 'ready') return 'Prêt'
  if (st === 'pending') return 'En attente'
  return st || '—'
}

function escapeHtml(input) {
  return String(input ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
}

function normalizedPlayerId(v) {
  return String(v || '').trim().toLowerCase()
}

function comparePlayerIds(a, b, dir = 'asc') {
  const aa = normalizedPlayerId(a)
  const bb = normalizedPlayerId(b)
  if (!aa && !bb) return 0
  if (!aa) return 1
  if (!bb) return -1
  const cmp = aa.localeCompare(bb, 'fr', { sensitivity: 'base' })
  return dir === 'asc' ? cmp : -cmp
}

function sortMatches(div) {
  const rows = div === 'd1' ? d1Matches.value : d2Matches.value
  const state = matchSort[div]
  if (!rows?.length || !state) return
  const primary = state.key
  const secondary = primary === 'p1' ? 'p2' : 'p1'
  rows.sort((a, b) => {
    const first = comparePlayerIds(a?.[primary], b?.[primary], state.dir)
    if (first !== 0) return first
    return comparePlayerIds(a?.[secondary], b?.[secondary], state.dir)
  })
}

function saveSortPreferences() {
  try {
    localStorage.setItem(MATCH_SORT_STORAGE_KEY, JSON.stringify({
      d1: { key: matchSort.d1.key, dir: matchSort.d1.dir },
      d2: { key: matchSort.d2.key, dir: matchSort.d2.dir }
    }))
  } catch (_) {}
}

function loadSortPreferences() {
  try {
    const raw = localStorage.getItem(MATCH_SORT_STORAGE_KEY)
    if (!raw) return
    const parsed = JSON.parse(raw)
    const apply = (div) => {
      const v = parsed?.[div]
      if (!v) return
      const keyOk = v.key === 'p1' || v.key === 'p2'
      const dirOk = v.dir === 'asc' || v.dir === 'desc'
      if (keyOk) matchSort[div].key = v.key
      if (dirOk) matchSort[div].dir = v.dir
    }
    apply('d1')
    apply('d2')
  } catch (_) {}
}

function onSortHeader(div, key) {
  const state = matchSort[div]
  if (!state) return
  if (state.key === key) state.dir = state.dir === 'asc' ? 'desc' : 'asc'
  else {
    state.key = key
    state.dir = 'asc'
  }
  sortMatches(div)
  saveSortPreferences()
  if (auth.isAdmin) onMatchInput()
}

function sortIndicator(div, key) {
  const state = matchSort[div]
  if (!state || state.key !== key) return '↕'
  return state.dir === 'asc' ? '↑' : '↓'
}

function sortTitle(div, key) {
  const state = matchSort[div]
  const label = key === 'p1' ? 'Joueur 1' : 'Joueur 2'
  const nextDir = state?.key === key && state?.dir === 'asc' ? 'décroissant' : 'croissant'
  return `Trier par ${label} (${nextDir})`
}

function buildPayload() {
  return {
    d1: d1Matches.value.map(m => ({ ...m })),
    d2: d2Matches.value.map(m => ({ ...m })),
    barrage: { ...barrage },
    champions: {
      d1: { id: d1ChampId.value, team: '' },
      d2: { id: d2ChampId.value, team: '' }
    },
    tempGuests: tempGuests.value
  }
}

function loadPayloadIntoState(p) {
  d1Matches.value = (p.d1 || []).map(m => ({ ...m }))
  d2Matches.value = (p.d2 || []).map(m => ({ ...m }))
  sortMatches('d1')
  sortMatches('d2')
  barrage.ids    = p.barrage?.ids || ''
  barrage.winner = p.barrage?.winner || null
  barrage.notes  = p.barrage?.notes || ''
  tempGuests.value = p.tempGuests || []
  // Register guest roles
  for (const g of tempGuests.value) {
    playersRoleMap.value.set(String(g.player_id), 'INVITE')
  }
}

function isCompleteMatch(m) {
  return !!(m?.p1 && m?.p2) &&
    [m.a1, m.a2, m.r1, m.r2].every(v => v !== null && v !== undefined && v !== '')
}

function hasAnyCompleteMatch() {
  return [...d1Matches.value, ...d2Matches.value].some(isCompleteMatch)
}

function hasIncompleteLines() {
  const bad = []
  const scan = (rows, label) => {
    rows.forEach((m, i) => {
      const anyScore = [m.a1, m.a2, m.r1, m.r2].some(v => v !== null && v !== undefined && v !== '')
      if (!anyScore) return
      if (!isCompleteMatch(m)) bad.push(`${label} #${i + 1}`)
    })
  }
  scan(d1Matches.value, 'D1')
  scan(d2Matches.value, 'D2')
  return bad
}

function findCrossDivisionConflicts() {
  const d1 = new Set()
  const d2 = new Set()
  d1Matches.value.forEach(m => { if (m.p1) d1.add(String(m.p1)); if (m.p2) d1.add(String(m.p2)) })
  d2Matches.value.forEach(m => { if (m.p1) d2.add(String(m.p1)); if (m.p2) d2.add(String(m.p2)) })
  return [...d1].filter(id => d2.has(id))
}

async function syncRealtimeRooms() {
  const draftRoom = selectedDate.value ? `draft:${selectedDate.value}` : ''
  const dayRoom = selectedDate.value ? `day:${selectedDate.value}` : ''

  if (joinedDraftRoom && joinedDraftRoom !== draftRoom) {
    await leaveRealtimeRoom(joinedDraftRoom)
    joinedDraftRoom = ''
  }
  if (joinedDayRoom && joinedDayRoom !== dayRoom) {
    await leaveRealtimeRoom(joinedDayRoom)
    joinedDayRoom = ''
  }
  if (draftRoom && joinedDraftRoom !== draftRoom) {
    await joinRealtimeRoom(draftRoom)
    joinedDraftRoom = draftRoom
  }
  if (dayRoom && joinedDayRoom !== dayRoom) {
    await joinRealtimeRoom(dayRoom)
    joinedDayRoom = dayRoom
  }
}

function bindRealtimeListeners() {
  if (realtimeOffDraftUpdate) return

  realtimeOffDraftUpdate = onRealtimeEvent('draft:update', async ({ date } = {}) => {
    if (!date || date !== selectedDate.value) return
    await syncCycle()
  })

  realtimeOffDayConfirmed = onRealtimeEvent('day:confirmed', async ({ date } = {}) => {
    if (!date || date !== selectedDate.value) return
    await loadDay()
    await loadHeadline()
    await loadNextFixture()
  })

  realtimeOffDayUpdated = onRealtimeEvent('day:updated', async ({ date } = {}) => {
    if (!date || date !== selectedDate.value) return
    await syncCycle()
  })

  realtimeOffTournamentChanged = onRealtimeEvent('tournament:changed', async ({ date } = {}) => {
    if (date && date === selectedDate.value) {
      await loadDayTournaments()
    }
    await loadNextFixture()
  })

  realtimeOffSeasonChanged = onRealtimeEvent('season:changed', async () => {
    await loadHeadline()
    await loadNextFixture()
  })
}

function unbindRealtimeListeners() {
  if (realtimeOffDraftUpdate) realtimeOffDraftUpdate()
  if (realtimeOffDayConfirmed) realtimeOffDayConfirmed()
  if (realtimeOffDayUpdated) realtimeOffDayUpdated()
  if (realtimeOffTournamentChanged) realtimeOffTournamentChanged()
  if (realtimeOffSeasonChanged) realtimeOffSeasonChanged()
  realtimeOffDraftUpdate = null
  realtimeOffDayConfirmed = null
  realtimeOffDayUpdated = null
  realtimeOffTournamentChanged = null
  realtimeOffSeasonChanged = null
}

/* ====== Lifecycle ====== */
onMounted(async () => {
  await Promise.all([loadSeason(), loadPlayers()])
  loadSortPreferences()
  if (route.query.day) {
    selectedDate.value = route.query.day
  } else {
    if (!restoredAccueilState.value) {
      await prefillNextSaturdayDate()
    }
  }
  bindRealtimeListeners()
  await syncRealtimeRooms()
  await loadDay()
  await loadHeadline()
  await loadNextFixture()
  restartCardInsightsTicker()
  syncTimer = setInterval(syncCycle, 15000)
  runTypingLoop()

  // Découverte dynamique des images et photos
  const anims = ['slide-float', 'slide-zoom', 'slide-spin', 'slide-drift']
  const [imgs, photos] = await Promise.all([probeAssets('image'), probeAssets('Photo')])
  heroSlides.value = imgs.map((src, i) => ({ src, alt: `GOUZEPE ${i + 1}`, anim: anims[i % anims.length] }))
  shuffledPhotos.value = shuffle(photos)

  if (heroSlides.value.length) {
    heroSlideTimer = setInterval(() => {
      heroSlideIndex.value = (heroSlideIndex.value + 1) % heroSlides.value.length
    }, 3600)
  }
})

onUnmounted(() => {
  if (autoSaveTimer) clearTimeout(autoSaveTimer)
  if (syncTimer) clearInterval(syncTimer)
  typingActive = false
  if (heroSlideTimer) clearInterval(heroSlideTimer)
  if (cardsInsightsTimer) clearInterval(cardsInsightsTimer)
  if (joinedDraftRoom) void leaveRealtimeRoom(joinedDraftRoom).catch(() => {})
  if (joinedDayRoom) void leaveRealtimeRoom(joinedDayRoom).catch(() => {})
  joinedDraftRoom = ''
  joinedDayRoom = ''
  unbindRealtimeListeners()
})

/* ====== API calls ====== */
async function loadSeason() {
  try {
    const { data } = await api.get('/season/current')
    currentSeason.value = data
  } catch (_) {}
}

async function loadPlayers() {
  try {
    const { data } = await api.get('/players')
    allPlayers.value = data.players || []
    playersRoleMap.value = new Map(
      (data.players || []).map(p => [String(p.player_id), (p.role || 'MEMBRE').toUpperCase()])
    )
  } catch (_) {}
}

async function onDateChange() {
  clearHighlights()
  await syncRealtimeRooms()
  await loadDay()
}

function nextSaturdayFrom(baseDate) {
  const d = new Date(baseDate)
  const add = ((6 - d.getDay() + 7) % 7) || 7
  d.setDate(d.getDate() + add)
  return d.toISOString().slice(0, 10)
}

async function prefillNextSaturdayDate() {
  try {
    const sid = currentSeason.value?.id
    if (!sid) {
      selectedDate.value = nextSaturdayFrom(new Date())
      return
    }
    const { data } = await api.get(`/seasons/${sid}/matchdays`)
    const days = (data.days || []).slice().sort()
    if (!days.length) {
      selectedDate.value = nextSaturdayFrom(new Date())
      return
    }
    const lastDay = days[days.length - 1]
    selectedDate.value = nextSaturdayFrom(new Date(`${lastDay}T00:00:00`))
  } catch (_) {
    selectedDate.value = nextSaturdayFrom(new Date())
  }
}

async function loadDay() {
  if (!selectedDate.value) return
  loadingDay.value = true
  loadingDayTournaments.value = true
  dayInfo.value = ''
  d1Matches.value = []
  d2Matches.value = []
  dayTournaments.value = []
  barrage.ids = ''; barrage.winner = null; barrage.notes = ''
  tempGuests.value = []

  try {
    // Try confirmed first
    const { data } = await api.get(`/matchdays/${selectedDate.value}`)
    loadPayloadIntoState(data)
    dayInfo.value = 'Journée confirmée'
    dayStatusDisplay.value = 'confirmed'
  } catch (_) {
    try {
      // Try draft
      const { data } = await api.get(`/matchdays/draft/${selectedDate.value}`)
      loadPayloadIntoState(data.payload || {})
      dayInfo.value = 'Brouillon'
      dayStatusDisplay.value = 'draft'
    } catch (_) {
      dayInfo.value = 'Nouvelle journée'
      dayStatusDisplay.value = 'new'
    }
  }
  await loadDayTournaments()
  loadingDay.value = false
}

async function loadDayTournaments() {
  if (!selectedDate.value) {
    dayTournaments.value = []
    loadingDayTournaments.value = false
    return
  }
  loadingDayTournaments.value = true
  try {
    const { data } = await api.get(`/tournaments/member/day/${selectedDate.value}`)
    dayTournaments.value = data.tournaments || []
  } catch (_) {
    dayTournaments.value = []
  } finally {
    loadingDayTournaments.value = false
  }
}

function onMatchInput() {
  lastEditAt.value = Date.now()
  clearTimeout(autoSaveTimer)
  if (auth.isAdmin) {
    autoSaveTimer = setTimeout(() => saveDraft(true), 2000)
  }
}

async function saveDraft(silent = false) {
  if (!auth.isAdmin) return
  saving.value = true
  try {
    await api.put(`/matchdays/draft/${selectedDate.value}`, buildPayload())
    if (!silent) success('Brouillon sauvegardé')
    if (dayStatusDisplay.value === 'new') dayStatusDisplay.value = 'draft'
    dayInfo.value = 'Brouillon'
  } catch (e) {
    if (!silent) toastError('Erreur de sauvegarde du brouillon')
  }
  saving.value = false
}

function openConfirmModal() {
  const incomplete = hasIncompleteLines()
  if (incomplete.length) {
    toastError(`Complète les lignes suivantes : ${incomplete.join(', ')}`)
    return
  }
  if (!hasAnyCompleteMatch()) {
    toastError('Impossible de publier : aucune confrontation complète (aller/retour).')
    return
  }
  const conflicts = findCrossDivisionConflicts()
  if (conflicts.length) {
    toastError(`Conflits D1/D2 détectés : ${conflicts.join(', ')}`)
    return
  }

  champTeamD1.value = ''
  champTeamD2.value = ''
  confirmError.value = ''
  confirmModal.value = true
}

async function publishDay() {
  const incomplete = hasIncompleteLines()
  if (incomplete.length) {
    confirmError.value = `Lignes incomplètes : ${incomplete.join(', ')}`
    return
  }
  if (!hasAnyCompleteMatch()) {
    confirmError.value = 'Aucune confrontation complète (aller/retour) à publier.'
    return
  }

  publishing.value = true
  confirmError.value = ''
  try {
    const p = buildPayload()
    p.champions.d1.team = champTeamD1.value
    p.champions.d2.team = champTeamD2.value
    await api.post('/matchdays/confirm', {
      date: selectedDate.value,
      d1: p.d1,
      d2: p.d2,
      barrage: p.barrage,
      champions: p.champions,
      tempGuests: p.tempGuests,
      season_id: currentSeason.value?.id
    })
    success('Journée publiée !')
    confirmModal.value = false
    dayStatusDisplay.value = 'confirmed'
    dayInfo.value = 'Journée confirmée'
  } catch (e) {
    confirmError.value = e.response?.data?.error || 'Erreur lors de la publication'
  }
  publishing.value = false
}

/* ====== Match operations ====== */
function addMatch(div) {
  const target = div === 'd1' ? d1Matches : d2Matches
  target.value.push({ p1: '', p2: '', a1: null, a2: null, r1: null, r2: null })
  sortMatches(div)
  onMatchInput()
}

function clearScores(div) {
  if (!confirm(`Effacer tous les scores ${div.toUpperCase()} ?`)) return
  const matches = div === 'd1' ? d1Matches : d2Matches
  matches.value.forEach(m => { m.a1 = null; m.a2 = null; m.r1 = null; m.r2 = null })
  onMatchInput()
}

function clearAllMatches() {
  if (!confirm('Supprimer toutes les confrontations (D1 & D2) ?')) return
  d1Matches.value = []
  d2Matches.value = []
  onMatchInput()
}

function removeMatch(div, i) {
  if (!confirm('Supprimer cette confrontation ?')) return
  if (div === 'd1') d1Matches.value.splice(i, 1)
  else d2Matches.value.splice(i, 1)
  onMatchInput()
}

/* ====== Search ====== */
function searchMatch() {
  clearHighlights()
  const term = (matchSearch.value || '').trim().toLowerCase()
  if (!term) return
  const hits = new Set()
  let firstEl = null

  if (matchSearchDiv.value !== 'd2') {
    d1Matches.value.forEach((m, i) => {
      if ((m.p1 || '').toLowerCase().includes(term) || (m.p2 || '').toLowerCase().includes(term)) {
        hits.add('d1-' + i)
        if (!firstEl) firstEl = document.getElementById(`d1-match-${i}`)
      }
    })
  }
  if (matchSearchDiv.value !== 'd1') {
    d2Matches.value.forEach((m, i) => {
      if ((m.p1 || '').toLowerCase().includes(term) || (m.p2 || '').toLowerCase().includes(term)) {
        hits.add('d2-' + i)
        if (!firstEl) firstEl = document.getElementById(`d2-match-${i}`)
      }
    })
  }

  highlightSet.value = hits
  matchSearchInfo.value = hits.size ? `${hits.size} résultat(s)` : 'Aucun résultat'
  if (firstEl) firstEl.scrollIntoView({ behavior: 'smooth', block: 'center' })
}

function clearHighlights() {
  highlightSet.value = new Set()
  matchSearchInfo.value = ''
}

function payloadDigest(p) {
  return JSON.stringify({
    d1: p?.d1 || [],
    d2: p?.d2 || [],
    barrage: p?.barrage || {},
    tempGuests: p?.tempGuests || []
  })
}

async function fetchServerDaySnapshot(date) {
  try {
    const { data } = await api.get(`/matchdays/${date}`)
    return { source: 'confirmed', payload: data }
  } catch (_) {}
  try {
    const { data } = await api.get(`/matchdays/draft/${date}`)
    return { source: 'draft', payload: data.payload || {} }
  } catch (_) {}
  return { source: 'none', payload: null }
}

async function syncCycle() {
  if (!selectedDate.value) return
  if (loadingDay.value || publishing.value || saving.value) return

  const recentlyEditing = (Date.now() - lastEditAt.value) < 20000
  if (auth.isAdmin && dayStatusDisplay.value !== 'confirmed' && recentlyEditing) {
    await saveDraft(true)
    return
  }
  if (recentlyEditing) return

  const remote = await fetchServerDaySnapshot(selectedDate.value)
  if (!remote.payload) return

  const currentDigest = payloadDigest(buildPayload())
  const incomingDigest = payloadDigest(remote.payload)
  if (incomingDigest && incomingDigest !== currentDigest) {
    loadPayloadIntoState(remote.payload)
    if (remote.source === 'confirmed') {
      dayStatusDisplay.value = 'confirmed'
      dayInfo.value = 'Journée confirmée'
    } else if (remote.source === 'draft') {
      dayStatusDisplay.value = 'draft'
      dayInfo.value = 'Brouillon'
    }
  }
  await loadDayTournaments()
}

/* ====== Barrage ====== */
function autoFillBarrage() {
  const d1 = d1Standings.value.filter(r => r.role !== 'INVITE')
  const d2 = d2Standings.value.filter(r => r.role !== 'INVITE')
  let d1avant = null
  if (d1.length > 2)      d1avant = d1[d1.length - 2].id
  else if (d1.length === 2) d1avant = d1[1].id
  const d2second = d2[1]?.id
  if (d1avant && d2second) {
    barrage.ids = `${d1avant} – ${d2second}`
    onMatchInput()
  }
}

/* ====== Participants modal ====== */
function openParticipantsModal() {
  // Init from current matches
  const s1 = new Set(), s2 = new Set()
  d1Matches.value.forEach(m => { if (m.p1) s1.add(m.p1); if (m.p2) s1.add(m.p2) })
  d2Matches.value.forEach(m => { if (m.p1) s2.add(m.p1); if (m.p2) s2.add(m.p2) })
  pmD1.value = [...s1]
  pmD2.value = [...s2]
  pmSearch.value = ''
  pmGuestName.value = ''
  participantsModal.value = true
}

function pmAddPlayer(id, div) {
  // Remove from other div if present
  if (div === 'd1') {
    pmD2.value = pmD2.value.filter(x => x !== id)
    if (!pmD1.value.includes(id)) pmD1.value.push(id)
  } else {
    pmD1.value = pmD1.value.filter(x => x !== id)
    if (!pmD2.value.includes(id)) pmD2.value.push(id)
  }
}

function pmRemove(div, id) {
  if (div === 'd1') pmD1.value = pmD1.value.filter(x => x !== id)
  else              pmD2.value = pmD2.value.filter(x => x !== id)
}

function pmAddGuest(div) {
  const name = pmGuestName.value.trim()
  if (!name) return
  const guestId = `G_${name.replace(/\s+/g, '_').toUpperCase()}_${Date.now().toString(36).slice(-4)}`
  tempGuests.value.push({ player_id: guestId, name })
  playersRoleMap.value.set(guestId, 'INVITE')
  if (div === 'd1') pmD1.value.push(guestId)
  else              pmD2.value.push(guestId)
  pmGuestName.value = ''
}

function pmReset() {
  pmD1.value = []
  pmD2.value = []
}

function openPmValidateModal() {
  pmConfirmModal.value = true
}

function pmValidate() {
  const d1Merge = mergeGeneratedMatches(d1Matches.value, pmD1.value)
  const d2Merge = mergeGeneratedMatches(d2Matches.value, pmD2.value)
  d1Matches.value = d1Merge.matches
  d2Matches.value = d2Merge.matches
  sortMatches('d1')
  sortMatches('d2')
  pmConfirmModal.value = false
  participantsModal.value = false
  onMatchInput()
  const added = d1Merge.added + d2Merge.added
  const total = d1Matches.value.length + d2Matches.value.length
  success(`Confrontations mises à jour : ${total} match(s) (${d1Matches.value.length} en D1, ${d2Matches.value.length} en D2). ${added} nouvelle(s) affiche(s) ajoutée(s).`)
}

function generateRoundRobin(playerIds) {
  if (playerIds.length < 2) return []
  const players = [...playerIds].sort((a, b) => String(a).localeCompare(String(b)))
  const matches = []
  if (players.length % 2 === 1) players.push(null)
  const numRounds = players.length - 1
  const half = players.length / 2
  for (let round = 0; round < numRounds; round++) {
    for (let i = 0; i < half; i++) {
      const home = players[i], away = players[players.length - 1 - i]
      if (home !== null && away !== null) {
        matches.push({ p1: home, p2: away, a1: null, a2: null, r1: null, r2: null })
      }
    }
    players.splice(1, 0, players.pop())
  }
  return matches
}

function pairKey(a, b) {
  return [String(a || ''), String(b || '')]
    .sort((x, y) => x.localeCompare(y, 'fr', { sensitivity: 'base' }))
    .join('::')
}

function hasFilledScore(m) {
  return [m?.a1, m?.a2, m?.r1, m?.r2].some(v => v !== null && v !== undefined && v !== '')
}

function mergeGeneratedMatches(existingMatches, playerIds) {
  const ids = (playerIds || []).map(x => String(x || '').trim()).filter(Boolean)
  if (ids.length < 2) return { matches: [], added: 0 }

  const allowed = new Set(ids)
  const existingByPair = new Map()

  for (const m of (existingMatches || [])) {
    const p1 = String(m?.p1 || '').trim()
    const p2 = String(m?.p2 || '').trim()
    if (!p1 || !p2 || p1 === p2) continue
    if (!allowed.has(p1) || !allowed.has(p2)) continue
    const key = pairKey(p1, p2)
    const prev = existingByPair.get(key)
    if (!prev) {
      existingByPair.set(key, { ...m })
      continue
    }
    if (hasFilledScore(m) && !hasFilledScore(prev)) {
      existingByPair.set(key, { ...m })
    }
  }

  const generated = generateRoundRobin(ids)
  const merged = []
  let added = 0

  for (const m of generated) {
    const key = pairKey(m.p1, m.p2)
    const existing = existingByPair.get(key)
    if (existing) merged.push(existing)
    else {
      merged.push(m)
      added += 1
    }
  }

  return { matches: merged, added }
}

/* ====== Navigation ====== */
function goToDay(day) {
  selectedDate.value = day
  onDateChange()
  window.scrollTo({ top: document.querySelector('.card')?.offsetTop || 0, behavior: 'smooth' })
}

function printDaySheet() {
  const hasContent = d1Matches.value.length || d2Matches.value.length
  if (!hasContent) {
    toastInfo('Aucune confrontation à imprimer pour cette journée.')
    return
  }

  const splitAndRank = (rows) => {
    const main = rows.filter(r => r.role !== 'INVITE')
    const inv  = rows.filter(r => r.role === 'INVITE')
    main.forEach((r, idx) => { r.RANK = idx + 1 })
    inv.forEach(r => { r.RANK = '—' })
    return { main, inv }
  }

  const { main: main1, inv: inv1 } = splitAndRank([...d1Standings.value])
  const { main: main2, inv: inv2 } = splitAndRank([...d2Standings.value])

  const css = '@page{size:A4;margin:12mm;}body{font:12px/1.35 "Segoe UI",Roboto,Arial,sans-serif;color:#111;}h1{font-size:18px;margin:0 0 8px;display:flex;align-items:center;gap:8px}h1 img{height:28px} h2{font-size:14px;margin:10px 0 6px;} .tbl{width:100%;border-collapse:collapse;border:1px solid #444;} .tbl th,.tbl td{border:1px solid #444;padding:4px 6px;text-align:center} .tbl thead th{background:#efefef;} .champ{text-align:center;margin:6px 0 10px;font-weight:900;color:#cc0000;font-size:17px;} .verdict{margin-top:8px;font-weight:800;color:#1d4ed8;text-align:center;font-size:15px;} .sepRow td{background:#f7f7f7;font-style:italic}'

  const renderMatches = (matches) => {
    let h = '<table class="tbl"><thead><tr><th>Domicile</th><th>Extérieur</th><th>Aller</th><th>Retour</th></tr></thead><tbody>'
    for (const m of (matches || [])) {
      const a = (m.a1 != null || m.a2 != null) ? `${m.a1 ?? ''} - ${m.a2 ?? ''}` : ''
      const r = (m.r1 != null || m.r2 != null) ? `${m.r1 ?? ''} - ${m.r2 ?? ''}` : ''
      h += `<tr><td>${escapeHtml(m.p1 || '')}</td><td>${escapeHtml(m.p2 || '')}</td><td>${escapeHtml(a)}</td><td>${escapeHtml(r)}</td></tr>`
    }
    return h + '</tbody></table>'
  }

  const renderStand = (title, mainRows, invRows) => {
    let h = `<h2>${escapeHtml(title)}</h2><table class="tbl"><thead><tr><th>Rang</th><th>Nom</th><th>ID</th><th>J</th><th>V</th><th>N</th><th>D</th><th>BM</th><th>BC</th><th>Diff</th><th>PTS</th></tr></thead><tbody>`
    const nameOf = id => { const p = allPlayers.value.find(x => x.player_id === id); return p?.name || id }
    const row = r => `<tr><td>${r.RANK}</td><td>${escapeHtml(nameOf(r.id))}</td><td>${escapeHtml(r.id)}</td><td>${r.J}</td><td>${r.V}</td><td>${r.N}</td><td>${r.D}</td><td>${r.BP}</td><td>${r.BC}</td><td>${r.DIFF > 0 ? '+' : ''}${r.DIFF}</td><td>${r.PTS}</td></tr>`
    for (const r of mainRows) h += row(r)
    if (invRows.length) {
      h += '<tr class="sepRow"><td colspan="11">Invités (non classés)</td></tr>'
      for (const r of invRows) h += row(r)
    }
    return h + '</tbody></table>'
  }

  const c1Id = d1ChampId.value || '—'
  const c2Id = d2ChampId.value || '—'
  const team1 = (champTeamD1.value || '').toUpperCase() || '—'
  const team2 = (champTeamD2.value || '').toUpperCase() || '—'

  let html = `<!doctype html><html lang="fr"><head><meta charset="utf-8"/><title>Résultats — ${escapeHtml(selectedDate.value)}</title><style>${css}</style></head><body onload="window.print()">`
  html += `<h1>GOUZEPE GAMING CLUB — Journée du ${escapeHtml(fmtDate(selectedDate.value))}</h1>`
  html += '<h2>SCORES D1</h2>' + renderMatches(d1Matches.value)
  html += `<div class="champ">🏆${escapeHtml(c1Id)} — CHAMPION avec ${escapeHtml(team1)}</div>`
  html += renderStand('CLASSEMENT D1', main1, inv1)
  html += '<h2>SCORES D2</h2>' + renderMatches(d2Matches.value)
  html += `<div class="champ">🏆${escapeHtml(c2Id)} — CHAMPION avec ${escapeHtml(team2)}</div>`
  html += renderStand('CLASSEMENT D2', main2, inv2)

  const bIds = barrage.ids || '—'
  const bWinner = barrage.winner || '—'
  html += '<h2>BARRAGES</h2><table class="tbl"><thead><tr><th>Affiche</th><th>Gagnant</th></tr></thead><tbody>'
  html += `<tr><td>${escapeHtml(bIds)}</td><td style="font-weight:700;color:#16a34a">${escapeHtml(bWinner)}</td></tr></tbody></table>`
  html += `<div class="verdict">*** ${escapeHtml(barrageLabel.value || '—')}</div>`
  if (barrage.notes) {
    html += `<div style="margin-top:8px"><b>Notes :</b><br>${escapeHtml(barrage.notes).replace(/\r?\n/g, '<br>')}</div>`
  }
  html += '</body></html>'

  const url = URL.createObjectURL(new Blob([html], { type: 'text/html' }))
  const w = window.open(url, '_blank')
  if (!w) { toastError('Popup bloquée. Autorise les popups pour imprimer.'); return }
  w.addEventListener('unload', () => URL.revokeObjectURL(url), { once: true })
}

function restartCardInsightsTicker() {
  if (cardsInsightsTimer) clearInterval(cardsInsightsTimer)
  cardsInsightsTimer = setInterval(() => {
    if (headlineFlashes.value.length > 1) {
      let nextIdx = Math.floor(Math.random() * headlineFlashes.value.length)
      if (nextIdx === headlineFlashIndex.value) {
        nextIdx = (nextIdx + 1) % headlineFlashes.value.length
      }
      headlineFlashIndex.value = nextIdx
    }
    if (nextInsights.value.length > 1) {
      let nextIdx = Math.floor(Math.random() * nextInsights.value.length)
      if (nextIdx === nextInsightIndex.value) {
        nextIdx = (nextIdx + 1) % nextInsights.value.length
      }
      nextInsightIndex.value = nextIdx
    }
  }, 3600)
}

async function fetchRecentConfirmedDays(days, limit = Number.POSITIVE_INFINITY) {
  const out = []
  const max = Number.isFinite(limit) ? Math.max(0, limit) : Number.POSITIVE_INFINITY
  for (let i = days.length - 1; i >= 0 && out.length < max; i--) {
    try {
      const { data } = await api.get(`/matchdays/${days[i]}`)
      out.push({ date: days[i], payload: data })
    } catch (_) {}
  }
  return out
}

function addLegToForm(agg, homeId, awayId, homeGoals, awayGoals) {
  if (!homeId || !awayId) return
  if (homeGoals === null || homeGoals === undefined || awayGoals === null || awayGoals === undefined) return

  const ensure = (id) => {
    if (!agg.has(id)) agg.set(id, { id, J: 0, V: 0, N: 0, D: 0, BP: 0, BC: 0 })
    return agg.get(id)
  }

  const home = ensure(homeId)
  const away = ensure(awayId)
  home.J++; away.J++
  home.BP += homeGoals; home.BC += awayGoals
  away.BP += awayGoals; away.BC += homeGoals

  if (homeGoals > awayGoals) {
    home.V++; away.D++
  } else if (homeGoals < awayGoals) {
    away.V++; home.D++
  } else {
    home.N++; away.N++
  }
}

function collectDivisionForm(recentDays, divisionKey) {
  const agg = new Map()
  for (const day of recentDays) {
    const matches = day?.payload?.[divisionKey] || []
    for (const m of matches) {
      const a1 = sc(m.a1), a2 = sc(m.a2), r1 = sc(m.r1), r2 = sc(m.r2)
      if (a1 !== null && a2 !== null) addLegToForm(agg, m.p1, m.p2, a1, a2)
      if (r1 !== null && r2 !== null) addLegToForm(agg, m.p2, m.p1, r2, r1)
    }
  }
  return [...agg.values()]
    .map(r => ({ ...r, PTS: r.V * 3 + r.N, DIFF: r.BP - r.BC }))
    .sort((a, b) => b.PTS - a.PTS || b.DIFF - a.DIFF || b.BP - a.BP || String(a.id).localeCompare(String(b.id)))
}

function extractInviteIdsFromPayload(payload) {
  const ids = new Set((payload?.tempGuests || []).map(g => String(g.player_id)))
  const scan = (matches) => {
    for (const m of matches || []) {
      for (const id of [m.p1, m.p2]) {
        if (!id) continue
        const key = String(id)
        if (key.startsWith('G_')) ids.add(key)
      }
    }
  }
  scan(payload?.d1)
  scan(payload?.d2)
  return [...ids]
}

function shuffleArray(arr) {
  const copy = [...arr]
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[copy[i], copy[j]] = [copy[j], copy[i]]
  }
  return copy
}

function rankLabel(rank) {
  if (!rank) return '—'
  return rank === 1 ? '1er' : `${rank}e`
}

function computeInviteSpotlight(recentDays) {
  // Only use the last 4 days for performance-based ranking
  const recent = recentDays.slice(0, 4)
  const byInvite = new Map()

  for (const day of recent) {
    // Build a local set of invite IDs for THIS day (tempGuests + G_ prefix + DB role)
    const dayInviteIds = new Set(
      (day.payload?.tempGuests || []).map(g => String(g.player_id))
    )
    for (const divKey of ['d1', 'd2']) {
      for (const m of day.payload?.[divKey] || []) {
        for (const pid of [m.p1, m.p2]) {
          if (!pid) continue
          const sid = String(pid)
          if (sid.startsWith('G_')) dayInviteIds.add(sid)
          if (inferRoleForPlayer(sid) === 'INVITE') dayInviteIds.add(sid)
        }
      }
    }

    for (const divKey of ['d1', 'd2']) {
      const standings = computeStandingsSimple(day?.payload?.[divKey] || [])
      standings.forEach((row, idx) => {
        const id = String(row?.id || '')
        if (!id || !dayInviteIds.has(id)) return

        if (!byInvite.has(id)) {
          byInvite.set(id, {
            id,
            pts: 0,
            diff: 0,
            bp: 0,
            bc: 0,
            V: 0,
            apps: 0,
            lastDate: '',
            lastDivision: '',
            lastRank: null,
            lastTotal: 0
          })
        }
        const agg = byInvite.get(id)
        agg.pts += Number(row.PTS || 0)
        agg.diff += Number(row.DIFF || 0)
        agg.bp += Number(row.BP || 0)
        agg.bc += Number(row.BC || 0)
        agg.V += Number(row.V || 0)
        agg.apps += 1

        const isNewerDay = !agg.lastDate || day.date > agg.lastDate
        if (isNewerDay) {
          agg.lastDate = day.date
          agg.lastDivision = divKey.toUpperCase()
          agg.lastRank = idx + 1
          agg.lastTotal = standings.length
        }
      })
    }
  }

  return [...byInvite.values()]
    .map(inv => ({ ...inv, avg: inv.apps ? inv.pts / inv.apps : 0 }))
    .sort((a, b) =>
      b.avg - a.avg ||
      b.pts - a.pts ||
      b.diff - a.diff ||
      b.bp - a.bp ||
      String(a.id).localeCompare(String(b.id))
    )
}

function buildHeadlineFlashes(recentDays) {
  featuredInvite.value = computeInviteSpotlight(recentDays)
  if (!featuredInvite.value || !featuredInvite.value.length) {
    return [{
      tag: 'Invité en vue',
      text: 'Aucun invité actif détecté sur la saison en cours.'
    }]
  }

  const inv = featuredInvite.value[0]
  const avgBP = inv.apps ? (inv.bp / inv.apps).toFixed(1) : '0'
  const avgBC = inv.apps ? (inv.bc / inv.apps).toFixed(1) : '0'
  return [{
    tag: 'Invité en vue',
    text: pickRandom([
      `${inv.id} domine les invités avec ${inv.avg.toFixed(1)} pts/journée sur les dernières journées (${inv.V}V, ${inv.bp}BP). ${rankLabel(inv.lastRank)} en ${inv.lastDivision || 'D?'} lors de sa dernière sortie.`,
      `${inv.id} s'impose comme l'invité le plus performant récemment — ${inv.pts} pts en ${inv.apps} journée(s), ${avgBP} buts/journée. Capable de bousculer la hiérarchie.`,
      `${inv.id} fait parler sur les dernières journées : ${inv.V} victoire(s), ${inv.diff > 0 ? '+' : ''}${inv.diff} de diff. Un invité qui pèse en ${inv.lastDivision || 'D?'}.`
    ])
  }]
}

function pickRandom(arr) {
  if (!Array.isArray(arr) || !arr.length) return ''
  return arr[Math.floor(Math.random() * arr.length)] || ''
}

function maybe(probability = 0.5) {
  return Math.random() < Math.max(0, Math.min(1, Number(probability) || 0))
}

function randomBetween(min, max) {
  const lo = Math.ceil(Number(min) || 0)
  const hi = Math.floor(Number(max) || 0)
  if (hi <= lo) return lo
  return lo + Math.floor(Math.random() * (hi - lo + 1))
}

function takeRandom(arr, count) {
  return shuffleArray(arr).slice(0, Math.max(0, Math.min(arr.length, count)))
}

function averagePtsPerMatch(row) {
  const j = Number(row?.J || 0)
  if (!j) return 0
  return Number(row?.PTS || 0) / j
}

function formatAverage(value) {
  const n = Number(value || 0)
  return n.toFixed(2).replace('.', ',')
}

function pickWeightedFromTop(sortedRows, topN = 5) {
  if (!Array.isArray(sortedRows) || !sortedRows.length) return null
  const cap = Math.max(1, Math.min(topN, sortedRows.length))
  const pool = sortedRows.slice(0, cap)
  const totalWeight = pool.reduce((sum, _, idx) => sum + (cap - idx), 0)
  let roll = Math.random() * totalWeight
  for (let idx = 0; idx < pool.length; idx++) {
    roll -= (cap - idx)
    if (roll <= 0) return pool[idx]
  }
  return pool[0]
}

function buildNextInsights(recentDays, nextPayload) {
  const tournamentPicks = []
  const nextTournaments = nextFixtureTournaments.value || []
  if (nextTournaments.length) {
    const sortedTournaments = [...nextTournaments].sort((a, b) =>
      new Date(a?.tournament?.starts_at || 0).getTime() - new Date(b?.tournament?.starts_at || 0).getTime()
    )
    const lead = sortedTournaments[0]?.tournament
    if (lead) {
      const participants = Number(lead.participants_count || 0) || 0
      const at = lead.starts_at ? ` • ${formatTournamentDateTime(lead.starts_at)}` : ''
      tournamentPicks.push({
        tag: 'Tournoi',
        text: `${lead.name} (${tournamentFormatLabel(lead.format)}) • ${tournamentStatusLabel(lead.status)}${participants ? ` • ${participants} participant(s)` : ''}${at}.`
      })
      const comment = String(lead.day_comment || '').trim()
      if (comment) {
        tournamentPicks.push({
          tag: 'Commentaire tournoi',
          text: comment
        })
      }
    }
    if (sortedTournaments.length > 1) {
      tournamentPicks.push({
        tag: 'Programme tournoi',
        text: `${sortedTournaments.length} tournoi(s) membre sont programmés sur cette date.`
      })
    }
  }

  const historyDays = Array.isArray(recentDays) ? recentDays : []
  const lastTwoDays = historyDays.slice(0, 2)
  const lastFourDays = historyDays.slice(0, 4)

  // Build a complete set of invite IDs across ALL recent days
  const allInviteIds = new Set()
  for (const day of historyDays) {
    for (const g of day.payload?.tempGuests || []) allInviteIds.add(String(g.player_id))
    for (const divKey of ['d1', 'd2']) {
      for (const m of day.payload?.[divKey] || []) {
        for (const pid of [m.p1, m.p2]) {
          if (pid && String(pid).startsWith('G_')) allInviteIds.add(String(pid))
        }
      }
    }
  }
  const isInviteId = (id) => allInviteIds.has(String(id)) || String(id).startsWith('G_') || inferRoleForPlayer(id) === 'INVITE'

  const form2D1 = collectDivisionForm(lastTwoDays, 'd1').filter(r => !isInviteId(r.id))
  const form2D2 = collectDivisionForm(lastTwoDays, 'd2').filter(r => !isInviteId(r.id))
  const form4D1 = collectDivisionForm(lastFourDays, 'd1').filter(r => !isInviteId(r.id))
  const form4D2 = collectDivisionForm(lastFourDays, 'd2').filter(r => !isInviteId(r.id))

  const picks = []
  const nextPlayers = new Set(
    [...(nextPayload?.d1 || []), ...(nextPayload?.d2 || [])]
      .flatMap(m => [m?.p1, m?.p2])
      .filter(Boolean)
      .map(v => String(v))
  )
  const focusRows = (rows) => {
    if (!nextPlayers.size) return rows
    const filtered = rows.filter(r => nextPlayers.has(String(r.id)))
    return filtered.length ? filtered : rows
  }

  const buildTopPick = (rows, metric = 'ppm') => {
    const pool = rows.slice()
    if (!pool.length) return null
    if (metric === 'attack') {
      pool.sort((a, b) => Number(b.BP || 0) - Number(a.BP || 0) || String(a.id).localeCompare(String(b.id)))
    } else if (metric === 'defense') {
      pool.sort((a, b) => Number(a.BC || 0) - Number(b.BC || 0) || Number(b.J || 0) - Number(a.J || 0))
    } else if (metric === 'draw') {
      pool.sort((a, b) => Number(b.N || 0) - Number(a.N || 0) || String(a.id).localeCompare(String(b.id)))
    } else {
      pool.sort((a, b) => averagePtsPerMatch(b) - averagePtsPerMatch(a) || Number(b.PTS || 0) - Number(a.PTS || 0))
    }
    return pickWeightedFromTop(pool, Math.min(5, pool.length))
  }

  if (form2D1[0] && maybe(0.95)) {
    picks.push({
      tag: 'Dynamique D1',
      text: pickRandom([
        `${form2D1[0].id} est en forme sur les 2 dernières journées (${form2D1[0].PTS} pts).`,
        `${form2D1[0].id} accélère en D1 sur les 2 dernières journées.`,
        `${form2D1[0].id} garde un rythme élevé récemment en D1.`
      ])
    })
  }
  if (form2D2[0] && maybe(0.95)) {
    picks.push({
      tag: 'Dynamique D2',
      text: pickRandom([
        `${form2D2[0].id} monte en puissance en D2 sur les 2 dernières journées.`,
        `${form2D2[0].id} imprime le rythme D2 récemment (${form2D2[0].PTS} pts).`,
        `${form2D2[0].id} enchaîne les bonnes sorties en D2.`
      ])
    })
  }

  const topD1Two = buildTopPick(focusRows(form2D1), 'ppm')
  if (topD1Two && maybe(0.95)) {
    const d1Moy = formatAverage(averagePtsPerMatch(topD1Two))
    picks.push({
      tag: 'Forme 2J D1',
      text: pickRandom([
        `${topD1Two.id} ressort sur 2 journées en D1 (moyenne ${d1Moy}).`,
        `${topD1Two.id} se détache en D1 sur les 2 dernières journées (${d1Moy} de moyenne).`
      ])
    })
  }

  const topD2Two = buildTopPick(focusRows(form2D2), 'ppm')
  if (topD2Two && maybe(0.95)) {
    const d2Moy = formatAverage(averagePtsPerMatch(topD2Two))
    picks.push({
      tag: 'Forme 2J D2',
      text: pickRandom([
        `${topD2Two.id} ressort sur 2 journées en D2 (moyenne ${d2Moy}).`,
        `${topD2Two.id} se détache en D2 sur les 2 dernières journées (${d2Moy} de moyenne).`
      ])
    })
  }

  const topD1Four = buildTopPick(focusRows(form4D1), 'ppm')
  if (topD1Four && maybe(0.9)) {
    const d1Moy4 = formatAverage(averagePtsPerMatch(topD1Four))
    picks.push({
      tag: 'Tendance 4J D1',
      text: pickRandom([
        `${topD1Four.id} tient une bonne cadence sur 4 journées en D1 (moyenne ${d1Moy4}).`,
        `${topD1Four.id} reste régulier sur le dernier mois D1 (${d1Moy4} de moyenne).`
      ])
    })
  }

  const topD2Four = buildTopPick(focusRows(form4D2), 'ppm')
  if (topD2Four && maybe(0.9)) {
    const d2Moy4 = formatAverage(averagePtsPerMatch(topD2Four))
    picks.push({
      tag: 'Tendance 4J D2',
      text: pickRandom([
        `${topD2Four.id} tient une bonne cadence sur 4 journées en D2 (moyenne ${d2Moy4}).`,
        `${topD2Four.id} reste régulier sur le dernier mois D2 (${d2Moy4} de moyenne).`
      ])
    })
  }

  const pool2 = focusRows([...form2D1, ...form2D2])
  const pool4 = focusRows([...form4D1, ...form4D2])

  const topAttack2 = buildTopPick(pool2, 'attack')
  if (topAttack2 && maybe(0.85)) {
    picks.push({
      tag: 'Attaque 2J',
      text: pickRandom([
        `${topAttack2.id} pourrait faire des différences offensives (2J: ${topAttack2.BP} buts marqués).`,
        `${topAttack2.id} arrive avec une attaque en forme sur 2 journées (${topAttack2.BP} buts).`
      ])
    })
  }

  const topAttack4 = buildTopPick(pool4, 'attack')
  if (topAttack4 && maybe(0.8)) {
    picks.push({
      tag: 'Attaque 4J',
      text: pickRandom([
        `${topAttack4.id} reste l'un des profils offensifs les plus actifs du dernier mois (${topAttack4.BP} buts).`,
        `${topAttack4.id} maintient un rythme élevé sur 4 journées (${topAttack4.BP} buts).`
      ])
    })
  }

  const bestDefense2 = buildTopPick(pool2.filter(r => Number(r.J || 0) > 0), 'defense')
  if (bestDefense2 && maybe(0.85)) {
    picks.push({
      tag: 'Défense 2J',
      text: pickRandom([
        `${bestDefense2.id} montre un profil défensif solide sur 2 journées (${bestDefense2.BC} but(s) concédé(s)).`,
        `${bestDefense2.id} peut fermer le jeu cette journée (2J: ${bestDefense2.BC} but(s) concédé(s)).`
      ])
    })
  }

  const bestDefense4 = buildTopPick(pool4.filter(r => Number(r.J || 0) > 0), 'defense')
  if (bestDefense4 && maybe(0.8)) {
    picks.push({
      tag: 'Défense 4J',
      text: pickRandom([
        `${bestDefense4.id} reste fiable défensivement sur 4 journées (${bestDefense4.BC} but(s) concédé(s)).`,
        `${bestDefense4.id} garde un bloc solide sur le dernier mois (${bestDefense4.BC} but(s) concédé(s)).`
      ])
    })
  }

  const drawMaster2 = buildTopPick(pool2, 'draw')
  if (drawMaster2 && Number(drawMaster2.N || 0) > 0 && maybe(0.75)) {
    picks.push({
      tag: 'Équilibre 2J',
      text: pickRandom([
        `${drawMaster2.id} gère bien les matchs serrés sur 2 journées (${drawMaster2.N} nul(s)).`,
        `${drawMaster2.id} est souvent dans des scénarios fermés récemment (${drawMaster2.N} nul(s)).`
      ])
    })
  }

  const drawMaster4 = buildTopPick(pool4, 'draw')
  if (drawMaster4 && Number(drawMaster4.N || 0) > 0 && maybe(0.7)) {
    picks.push({
      tag: 'Équilibre 4J',
      text: pickRandom([
        `${drawMaster4.id} a souvent été accroché sur 4 journées (${drawMaster4.N} nul(s)).`,
        `${drawMaster4.id} maîtrise bien les matchs fermés sur le dernier mois (${drawMaster4.N} nul(s)).`
      ])
    })
  }

  if (featuredInvite.value?.length && maybe(0.65)) {
    const top = featuredInvite.value[0]
    picks.push({
      tag: 'Invité en vue',
      text: `${top.id} est l'invité le plus en forme récemment (${top.pts} pts, ${top.V}V sur ${top.apps} journée(s)).`
    })
  }

  if (nextPayload) {
    const matchCount = (nextPayload.d1?.length || 0) + (nextPayload.d2?.length || 0)
    picks.push({ tag: 'Programme', text: `${matchCount} confrontation(s) sont déjà en place pour cette journée.` })

    const allNextMatches = [...(nextPayload.d1 || []), ...(nextPayload.d2 || [])]
      .filter(m => m?.p1 && m?.p2)
    const matchKey = pickRandom(allNextMatches)
    if (matchKey) {
      picks.push({
        tag: 'Match clé',
        text: pickRandom([
          `${matchKey.p1} vs ${matchKey.p2} peut clairement peser sur la journée.`,
          `${matchKey.p1} vs ${matchKey.p2} semble être l'affiche la plus ouverte de la journée.`,
          `${matchKey.p1} vs ${matchKey.p2} devrait compter dans la hiérarchie du week-end.`
        ])
      })
    }
  } else {
    picks.push({ tag: 'Planning', text: 'La grille est ouverte : compose les affiches pour lancer les pronostics du week-end.' })
  }

  if (!picks.length) {
    picks.push({ tag: 'Focus', text: 'Données insuffisantes sur les 2 et 4 dernières journées pour générer des pronostics.' })
  }
  const upperBound = Math.min(14, picks.length)
  const lowerBound = Math.min(8, upperBound)
  const targetCount = randomBetween(lowerBound, upperBound)
  const mixed = takeRandom(picks, targetCount)
  return [...shuffleArray(tournamentPicks), ...mixed].slice(0, 10)
}

/* ====== News (À la une) ====== */
async function loadHeadline() {
  loadingNews.value = true
  try {
    if (!currentSeason.value?.id) {
      newsItems.value = [{ title: 'À la une', meta: 'Aucune saison active' }]
      headlineFlashes.value = [{ tag: 'Invité en vue', text: 'Active une saison pour générer les tendances.' }]
      return
    }

    const { data: daysData } = await api.get(`/seasons/${currentSeason.value.id}/matchdays`)
    const days = (daysData.days || []).sort()
    if (!days.length) {
      newsItems.value = [{ title: 'À la une', meta: 'Aucune journée planifiée' }]
      headlineFlashes.value = [{ tag: 'Invité en vue', text: 'Ajoute une première journée pour alimenter les highlights.' }]
      return
    }

    recentConfirmedDays.value = await fetchRecentConfirmedDays(days, days.length)
    const latest = recentConfirmedDays.value[0]
    if (!latest?.payload) {
      newsItems.value = [{ title: 'À la une', meta: 'Aucune journée publiée' }]
      headlineFlashes.value = [{ tag: 'Invité en vue', text: 'Publie la prochaine journée pour afficher les tendances.' }]
      return
    }

    const st1 = computeStandingsSimple(latest.payload.d1 || []).filter(r => inferRoleForPlayer(r.id) !== 'INVITE')
    const st2 = computeStandingsSimple(latest.payload.d2 || []).filter(r => inferRoleForPlayer(r.id) !== 'INVITE')
    const fallbackChampionD1 = st1[0]?.id || '—'
    const fallbackChampionD2 = st2[0]?.id || '—'

    const championD1Label = latest.payload.champions?.d1?.id
      ? latest.payload.champions.d1.id + (latest.payload.champions.d1.team ? ` (${latest.payload.champions.d1.team})` : '')
      : fallbackChampionD1
    const championD2Label = latest.payload.champions?.d2?.id
      ? latest.payload.champions.d2.id + (latest.payload.champions.d2.team ? ` (${latest.payload.champions.d2.team})` : '')
      : fallbackChampionD2

    newsItems.value = [
      { title: 'Champion D1', meta: championD1Label },
      { title: 'Champion D2', meta: championD2Label }
    ]

    headlineFlashes.value = buildHeadlineFlashes(recentConfirmedDays.value)
    headlineFlashIndex.value = 0
  } catch (_) {
    newsItems.value = [{ title: 'À la une', meta: 'Erreur de chargement' }]
    headlineFlashes.value = [{ tag: 'Invité en vue', text: 'Impossible de calculer les highlights pour le moment.' }]
  } finally {
    loadingNews.value = false
    restartCardInsightsTicker()
  }
}

function computeStandingsSimple(matches) {
  const agg = new Map()
  const ensure = id => { if (!agg.has(id)) agg.set(id, { id, V: 0, N: 0, D: 0, BP: 0, BC: 0 }); return agg.get(id) }
  for (const m of matches) {
    if (!m.p1 || !m.p2) continue
    const a1 = sc(m.a1), a2 = sc(m.a2), r1 = sc(m.r1), r2 = sc(m.r2)
    if (a1 !== null && a2 !== null) {
      const A = ensure(m.p1), B = ensure(m.p2)
      if (a1 > a2) { A.V++; B.D++ } else if (a1 < a2) { B.V++; A.D++ } else { A.N++; B.N++ }
      A.BP += a1; A.BC += a2; B.BP += a2; B.BC += a1
    }
    if (r1 !== null && r2 !== null) {
      const A = ensure(m.p2), B = ensure(m.p1)
      if (r2 > r1) { A.V++; B.D++ } else if (r2 < r1) { B.V++; A.D++ } else { A.N++; B.N++ }
      A.BP += r2; A.BC += r1; B.BP += r1; B.BC += r2
    }
  }
  return [...agg.values()]
    .map(r => ({ ...r, PTS: r.V * 3 + r.N, DIFF: r.BP - r.BC }))
    .sort((a, b) => b.PTS - a.PTS || b.DIFF - a.DIFF || b.BP - a.BP)
}

/* ====== Next fixture ====== */
async function loadNextFixture() {
  loadingNextFixture.value = true
  nextFixtureMeta.value = ''
  nextFixtureTournaments.value = []
  try {
    const now = new Date()
    const dow = now.getDay()
    const add = ((6 - dow + 7) % 7) || 7
    const next = new Date(now)
    next.setDate(now.getDate() + add)
    const y = next.getFullYear()
    const m = String(next.getMonth() + 1).padStart(2, '0')
    const d = String(next.getDate()).padStart(2, '0')
    const target = `${y}-${m}-${d}`

    nextFixtureLabel.value = next.toLocaleDateString('fr-FR', { weekday: 'long', day: '2-digit', month: 'long', year: 'numeric' })

    // Charger d'abord la liste des journées connues de la saison
    let knownDays = []
    if (currentSeason.value?.id) {
      try {
        const { data: daysData } = await api.get(`/seasons/${currentSeason.value.id}/matchdays`)
        knownDays = daysData.days || []
        if (!recentConfirmedDays.value.length) {
          recentConfirmedDays.value = await fetchRecentConfirmedDays([...knownDays].sort(), knownDays.length)
        }
      } catch (_) {}
    }

    let payload = null
    if (knownDays.includes(target)) {
      // Date connue → fetch confirmé
      try {
        const { data } = await api.get(`/matchdays/${target}`)
        nextFixtureStatus.value = 'Journée confirmée'
        nextFixtureDay.value = target
        payload = data
      } catch (_) {}
    } else {
      // Tenter le brouillon sans polluer la console avec un 404 certain
      try {
        const { data } = await api.get(`/matchdays/draft/${target}`)
        nextFixtureStatus.value = 'Brouillon disponible'
        nextFixtureDay.value = target
        payload = data.payload || null
      } catch (_) {
        nextFixtureStatus.value = 'Pas encore créée'
        nextFixtureDay.value = ''
      }
    }

    // Tournois membre programmés le même jour (lecture du card "Prochaine journée")
    try {
      const { data: tournamentDay } = await api.get(`/tournaments/member/day/${target}`)
      nextFixtureTournaments.value = Array.isArray(tournamentDay?.tournaments) ? tournamentDay.tournaments : []
    } catch (_) {
      nextFixtureTournaments.value = []
    }

    const tournamentCount = nextFixtureTournaments.value.length
    if (!payload && tournamentCount > 0) {
      nextFixtureStatus.value = 'Tournoi programmé'
      nextFixtureDay.value = target
    }

    if (payload) {
      const matchCount = (payload.d1?.length || 0) + (payload.d2?.length || 0)
      const inviteCount = extractInviteIdsFromPayload(payload).length
      nextFixtureMeta.value = `${matchCount} confrontation(s) prévues${inviteCount ? ` • ${inviteCount} invité(s)` : ''}${tournamentCount ? ` • ${tournamentCount} tournoi(s)` : ''}`
    } else if (tournamentCount > 0) {
      nextFixtureMeta.value = `${tournamentCount} tournoi(s) membre programmé(s)`
    } else {
      nextFixtureMeta.value = 'Aucune confrontation enregistrée pour le moment'
    }
    nextInsights.value = buildNextInsights(recentConfirmedDays.value, payload)
    nextInsightIndex.value = 0
  } catch (_) {
    nextInsights.value = [{ tag: 'Info', text: 'Pronostics indisponibles temporairement.' }]
  } finally {
    loadingNextFixture.value = false
    restartCardInsightsTicker()
  }
}
</script>

<style scoped>
.home-page {
  position: relative;
  width: 100%;
  min-height: calc(100dvh - 56px);
  overflow: hidden;
}

.bg-wrap {
  position: fixed;
  inset: 0;
  z-index: 0;
  pointer-events: none;
}

.bg-video {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  opacity: 0.28;
  filter: saturate(0.95) contrast(1.05);
}

:root.light .bg-video {
  opacity: 0.18;
}

.bg-overlay {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(70vw 55vh at 12% 0%, rgba(59, 130, 246, 0.22), transparent 58%),
    radial-gradient(70vw 60vh at 88% 100%, rgba(34, 197, 94, 0.2), transparent 58%);
}

.bg-vignette {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(2, 6, 23, 0.5), rgba(2, 6, 23, 0.65));
}

.home-content {
  position: relative;
  z-index: 1;
  width: 100%;
  padding: clamp(14px, 2.2vw, 30px);
}

.home-content :deep(.card) {
  transition: transform 180ms ease, box-shadow 180ms ease, border-color 180ms ease;
}

.home-content :deep(.card:hover) {
  transform: translateY(-2px);
  box-shadow: 0 16px 34px rgba(2, 6, 23, 0.24);
  border-color: color-mix(in srgb, var(--border) 70%, #60a5fa 30%);
}

.table-shell {
  border: 1px solid rgba(148, 163, 184, 0.18);
  border-radius: 12px;
  padding: 4px;
  background: rgba(15, 23, 42, 0.18);
}

.table-shell .matches-table thead th,
.table-shell .standings-table thead th {
  border-bottom: 1px solid rgba(148, 163, 184, 0.2);
}

.table-shell .standings-table tbody td {
  border-bottom: 1px solid rgba(148, 163, 184, 0.1);
}

.table-shell .standings-table tbody tr:last-child td {
  border-bottom: none;
}

.sortable-col {
  cursor: pointer;
  user-select: none;
}

.sortable-col:hover {
  color: #cbd5e1 !important;
}

.sort-indicator {
  margin-left: 6px;
  font-size: 10px;
  opacity: 0.8;
}

.matches-table th:nth-child(1),
.matches-table td:nth-child(1),
.matches-table th:nth-child(3),
.matches-table td:nth-child(3) {
  min-width: 190px;
}

.matches-table th:nth-child(2),
.matches-table td:nth-child(2) {
  min-width: 170px;
}

.player-id-input {
  width: 150px !important;
  max-width: 100%;
}

.player-id-text {
  display: inline-block;
  min-width: 150px;
  max-width: 220px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  vertical-align: middle;
}

button[title] {
  cursor: pointer;
}

.btn-success {
  display: inline-flex;
  align-items: center;
  gap: .375rem;
  padding: .5rem .875rem;
  border-radius: .5rem;
  border: 1px solid #16a34a;
  background: #16a34a;
  color: #fff;
  font-size: .875rem;
  font-weight: 600;
  cursor: pointer;
  white-space: nowrap;
  transition: background .15s, border-color .15s, box-shadow .15s;
  outline: none;
}

.btn-success:hover {
  background: #15803d;
  border-color: #15803d;
}

.btn-success:focus-visible {
  box-shadow: 0 0 0 2px rgba(22, 163, 74, 0.35);
}

.btn-success:disabled {
  opacity: .5;
  cursor: not-allowed;
  pointer-events: none;
}

.pm-assign-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 34px;
  height: 22px;
  padding: 0 8px;
  border-radius: 8px;
  border: 1px solid transparent;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.01em;
  transition: transform 120ms ease, box-shadow 120ms ease, border-color 120ms ease, background-color 120ms ease;
}

.pm-assign-btn-d1 {
  color: var(--green-l);
  border-color: color-mix(in srgb, var(--green) 58%, transparent);
  background: color-mix(in srgb, var(--green) 24%, transparent);
}

.pm-assign-btn-d2 {
  color: var(--blue-l);
  border-color: color-mix(in srgb, var(--blue) 58%, transparent);
  background: color-mix(in srgb, var(--blue) 24%, transparent);
}

.pm-assign-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 6px 12px rgba(3, 8, 24, 0.2);
}

.pm-assign-btn:focus-visible {
  outline: none;
  box-shadow: 0 0 0 2px color-mix(in srgb, var(--blue) 30%, transparent);
}

.pm-guest-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 48px;
  height: 40px;
  padding: 0 14px;
  border-radius: 10px;
  border: 1px solid transparent;
  color: #fff;
  font-size: 22px;
  font-weight: 800;
  line-height: 1;
  transition: transform 120ms ease, box-shadow 120ms ease, filter 120ms ease;
}

.pm-guest-btn-d1 {
  background: var(--green);
  border-color: color-mix(in srgb, var(--green) 80%, #000 20%);
}

.pm-guest-btn-d2 {
  background: var(--blue);
  border-color: color-mix(in srgb, var(--blue) 80%, #000 20%);
}

.pm-guest-btn:hover:not(:disabled) {
  transform: translateY(-1px);
  filter: brightness(1.04);
  box-shadow: 0 10px 18px rgba(3, 8, 24, 0.24);
}

.pm-guest-btn:disabled {
  opacity: .45;
  cursor: not-allowed;
}

:root.light .pm-assign-btn-d1 {
  color: #1a3272;
  border-color: rgba(30, 63, 159, 0.5);
  background: rgba(30, 63, 159, 0.14);
}

:root.light .pm-assign-btn-d2 {
  color: #243a7e;
  border-color: rgba(93, 116, 185, 0.5);
  background: rgba(93, 116, 185, 0.14);
}

@media (max-width: 768px) {
  .matches-table th:nth-child(1),
  .matches-table td:nth-child(1),
  .matches-table th:nth-child(3),
  .matches-table td:nth-child(3),
  .matches-table th:nth-child(2),
  .matches-table td:nth-child(2) {
    min-width: 0;
  }

  .player-id-input {
    width: 90px !important;
  }

  .player-id-text {
    min-width: 90px;
    max-width: 120px;
  }
}

.mini-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.mini-sub {
  margin: -4px 0 10px;
  font-size: 12px;
  color: var(--muted);
}

.live-chip,
.next-pill {
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  padding: 4px 8px;
  border-radius: 999px;
  border: 1px solid var(--border);
  color: var(--muted);
  background: rgba(148, 163, 184, 0.08);
}

.live-chip {
  color: #86efac;
  border-color: rgba(34, 197, 94, 0.45);
  background: rgba(22, 163, 74, 0.18);
  animation: pulse-live 1.8s ease-in-out infinite;
}

:root.light .live-chip {
  color: #166534;
  border-color: rgba(22, 163, 74, 0.42);
  background: rgba(22, 163, 74, 0.16);
}

.card-news,
.card-next {
  position: relative;
  overflow: hidden;
}

.card-news::before,
.card-next::before {
  content: '';
  position: absolute;
  inset: 0 0 auto 0;
  height: 1px;
  background: linear-gradient(90deg, rgba(59, 130, 246, 0), rgba(59, 130, 246, 0.45), rgba(59, 130, 246, 0));
}

.mini-row {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  gap: 10px;
  padding: 7px 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.04);
}

.mini-row--champion {
  padding-top: 9px;
  padding-bottom: 9px;
}

.mini-row--champion span:last-child {
  color: #e5e7eb;
  font-weight: 700;
}

.insight-box {
  margin-top: 10px;
  padding: 10px 12px;
  border-radius: 12px;
  border: 1px solid rgba(59, 130, 246, 0.22);
  background: linear-gradient(140deg, rgba(59, 130, 246, 0.1), rgba(2, 132, 199, 0.06));
  min-height: 68px;
}

.insight-box--alt {
  border-color: rgba(34, 197, 94, 0.25);
  background: linear-gradient(140deg, rgba(34, 197, 94, 0.1), rgba(14, 116, 144, 0.05));
}

.insight-tag {
  display: inline-flex;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  color: #93c5fd;
  margin-bottom: 4px;
}

.insight-tag--alt {
  color: #86efac;
}

.insight-text {
  margin: 0;
  line-height: 1.35;
  font-size: 13px;
}

.insight-dots {
  display: flex;
  gap: 6px;
}

.insight-dot {
  width: 7px;
  height: 7px;
  border-radius: 999px;
  background: rgba(148, 163, 184, 0.3);
}

.insight-dot.active {
  background: var(--green);
}

.insight-fade-enter-active,
.insight-fade-leave-active {
  transition: opacity 220ms ease, transform 220ms ease;
}

.insight-fade-enter-from {
  opacity: 0;
  transform: translateY(8px);
}

.insight-fade-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}

.hero-section {
  width: 100%;
  padding: clamp(18px, 3vw, 36px);
  border: 1px solid var(--border);
  border-radius: 16px;
  background: color-mix(in srgb, var(--panel) 78%, transparent);
  backdrop-filter: blur(5px);
  margin-bottom: 16px;
  display: flex;
  flex-direction: column;
  gap: clamp(12px, 2vw, 20px);
}

/* ── Corps : texte + visuel côte à côte ── */
.hero-body {
  display: flex;
  align-items: center;
  gap: clamp(20px, 4vw, 48px);
}

.hero-left {
  flex: 1 1 0;
  min-width: 0;
}

/* ── Visuel animé ── */
.hero-visual {
  flex: 0 0 clamp(160px, 28vw, 340px);
  height: clamp(160px, 28vw, 340px);
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Anneaux rotatifs */
.hero-ring {
  position: absolute;
  inset: 0;
  border-radius: 50%;
  border: 1.5px solid transparent;
  pointer-events: none;
}
.hero-ring-outer {
  border-color: rgba(22, 163, 74, 0.22);
  animation: ring-cw 12s linear infinite;
  box-shadow: 0 0 18px rgba(22, 163, 74, 0.08);
}
.hero-ring-outer::before {
  content: '';
  position: absolute;
  top: -4px; left: 40%;
  width: 8px; height: 8px;
  border-radius: 50%;
  background: #16a34a;
  box-shadow: 0 0 10px 3px rgba(22, 163, 74, 0.6);
}
.hero-ring-inner {
  inset: 18px;
  border-color: rgba(59, 130, 246, 0.18);
  animation: ring-ccw 9s linear infinite;
}
.hero-ring-inner::before {
  content: '';
  position: absolute;
  bottom: -4px; right: 38%;
  width: 6px; height: 6px;
  border-radius: 50%;
  background: #3b82f6;
  box-shadow: 0 0 8px 2px rgba(59, 130, 246, 0.55);
}

/* Halo de fond */
.hero-glow {
  position: absolute;
  inset: 15%;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(22, 163, 74, 0.18) 0%, transparent 72%);
  animation: glow-pulse 3.5s ease-in-out infinite;
  pointer-events: none;
}

/* Conteneur image — remplit le cercle intérieur */
.hero-img-wrap {
  position: relative;
  z-index: 2;
  width: calc(100% - 44px);
  height: calc(100% - 44px);
  border-radius: 50%;
  overflow: hidden;
  box-shadow: 0 0 32px rgba(22, 163, 74, 0.28);
}
.hero-slide-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center;
  display: block;
}

/* Animation par slide */
.slide-float .hero-slide-img { animation: float-anim 4s ease-in-out infinite; }
.slide-zoom  .hero-slide-img { animation: zoom-pulse 3.5s ease-in-out infinite; }
.slide-spin  .hero-slide-img { animation: spin-float 7s ease-in-out infinite; }
.slide-drift .hero-slide-img { animation: drift-anim 5s ease-in-out infinite; }

/* Dots */
.hero-dots {
  position: absolute;
  bottom: -18px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 6px;
  z-index: 3;
}
.hero-dot {
  width: 6px; height: 6px;
  border-radius: 50%;
  background: rgba(148, 163, 184, 0.4);
  transition: background 0.3s, transform 0.3s;
}
.hero-dot.active {
  background: var(--green);
  transform: scale(1.35);
  box-shadow: 0 0 6px rgba(22, 163, 74, 0.6);
}

/* ── Transitions image ── */
.hero-img-enter-active { animation: img-in  0.65s cubic-bezier(0.22,1,0.36,1) both; }
.hero-img-leave-active { animation: img-out 0.4s ease both; }

/* ── Keyframes ── */
@keyframes ring-cw  { from { transform: rotate(0deg); }   to { transform: rotate(360deg); } }
@keyframes ring-ccw { from { transform: rotate(0deg); }   to { transform: rotate(-360deg); } }

@keyframes glow-pulse {
  0%, 100% { opacity: 0.6; transform: scale(1); }
  50%       { opacity: 1;   transform: scale(1.12); }
}
@keyframes float-anim {
  0%, 100% { transform: translateY(0); }
  50%       { transform: translateY(-14px); }
}
@keyframes zoom-pulse {
  0%, 100% { transform: scale(1);    filter: drop-shadow(0 8px 24px rgba(22,163,74,.35)); }
  50%       { transform: scale(1.07); filter: drop-shadow(0 12px 32px rgba(22,163,74,.55)); }
}
@keyframes spin-float {
  0%   { transform: translateY(0)    rotate(0deg); }
  25%  { transform: translateY(-8px) rotate(5deg); }
  50%  { transform: translateY(-14px) rotate(0deg); }
  75%  { transform: translateY(-6px) rotate(-5deg); }
  100% { transform: translateY(0)    rotate(0deg); }
}
@keyframes drift-anim {
  0%, 100% { transform: translateX(0); }
  50%       { transform: translateX(10px); }
}
@keyframes img-in {
  from { opacity: 0; transform: scale(0.88) translateY(14px); }
  to   { opacity: 1; transform: scale(1)    translateY(0); }
}
@keyframes img-out {
  from { opacity: 1; transform: scale(1); }
  to   { opacity: 0; transform: scale(1.06) translateY(-10px); }
}

/* Cache le visuel sur très petit écran */
@media (max-width: 540px) {
  .hero-visual { display: none; }
}

/* === Bande photos défilante infinie === */
.hero-photos-track-wrap {
  overflow: hidden;
  padding: 10px 0;
  mask-image: linear-gradient(to right, transparent 0%, black 6%, black 94%, transparent 100%);
  -webkit-mask-image: linear-gradient(to right, transparent 0%, black 6%, black 94%, transparent 100%);
}

.hero-photos-track-wrap:hover .hero-photos-track {
  animation-play-state: paused;
}

.hero-photos-track {
  display: flex;
  gap: 14px;
  width: max-content;
  animation: photo-scroll 28s linear infinite;
}

@keyframes photo-scroll {
  0%   { transform: translateX(0); }
  100% { transform: translateX(-50%); }
}

/* frame : gère seulement le flottement */
.hero-photo-frame {
  flex: 0 0 clamp(90px, 10vw, 130px);
  height: clamp(90px, 10vw, 130px);
  animation: photo-float calc(3s + var(--fi, 0) * 0.4s) ease-in-out infinite alternate;
  animation-delay: calc(var(--fi, 0) * -0.35s);
  will-change: transform;
  z-index: 1;
}

.hero-photo-frame:hover {
  animation-play-state: paused;
  z-index: 5;
}

.hero-photo-frame:hover .hero-photo-clip {
  box-shadow: 0 10px 32px rgba(22, 163, 74, 0.4);
  border-color: rgba(22, 163, 74, 0.5);
  transform: scale(1.1);
}

/* clip : gère le masque, la bordure et le contenu */
.hero-photo-clip {
  width: 100%;
  height: 100%;
  border-radius: 12px;
  overflow: hidden;
  border: 2px solid rgba(255, 255, 255, 0.07);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.45);
  transition: transform 0.3s ease, box-shadow 0.3s ease, border-color 0.3s ease;
  background: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
}

@keyframes photo-float {
  0%   { transform: translateY(-5px) rotate(-1.5deg); }
  50%  { transform: translateY(2px)  rotate(0.5deg);  }
  100% { transform: translateY(6px)  rotate(1.8deg);  }
}

.hero-photo-img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  object-position: center;
  display: block;
  background: #ffffff;
}

/* === GOUZEPE Gaming Club === */
.hero-club {
  margin: 0;
  display: flex;
  align-items: baseline;
  gap: 10px;
  flex-wrap: wrap;
}

.hero-club-name {
  display: inline;
  font-size: clamp(26px, 3.8vw, 48px);
  font-weight: 900;
  letter-spacing: -0.02em;
  background: linear-gradient(105deg, #16a34a 0%, #4ade80 30%, #22d3ee 58%, #60a5fa 80%, #16a34a 100%);
  background-size: 300% 100%;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: club-reveal 0.65s cubic-bezier(0.16, 1, 0.3, 1) both,
             shimmer-club 4.5s linear 0.8s infinite;
}

.hero-club-label {
  display: inline;
  font-size: clamp(12px, 1.6vw, 18px);
  font-weight: 700;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: var(--text);
  opacity: 0.72;
  animation: club-reveal 0.65s cubic-bezier(0.16, 1, 0.3, 1) 0.18s both;
}

@keyframes club-reveal {
  from { opacity: 0; transform: translateY(18px); }
  to   { opacity: 1; transform: translateY(0); }
}

@keyframes shimmer-club {
  0%   { background-position: 300% 0; }
  100% { background-position: -300% 0; }
}

/* === Bienvenue au club (réduit) === */
.hero-title {
  margin: 0;
  font-size: clamp(20px, 3vw, 36px);
  line-height: 1.12;
  font-weight: 800;
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  gap: 10px;
}

.hero-accent {
  color: var(--green);
  text-shadow: 0 8px 22px color-mix(in srgb, var(--green) 35%, transparent);
}

.hero-sub {
  margin: 12px 0 0;
  max-width: 920px;
  color: var(--muted);
  font-size: clamp(14px, 1.8vw, 18px);
}

:root.light .bg-video {
  opacity: 0.1;
  filter: saturate(0.85) contrast(1);
}

:root.light .bg-overlay {
  background:
    radial-gradient(65vw 50vh at 12% 0%, rgba(59, 130, 246, 0.08), transparent 62%),
    radial-gradient(65vw 55vh at 88% 100%, rgba(34, 197, 94, 0.07), transparent 62%);
}

:root.light .bg-vignette {
  background: linear-gradient(180deg, rgba(248, 250, 252, 0.58), rgba(248, 250, 252, 0.72));
}

:root.light .hero-section {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: none;
}

:root.light .hero-sub {
  color: #475569;
}

:root.light .home-content :deep(.card) {
  background: rgba(255, 255, 255, 0.94);
  border-color: rgba(148, 163, 184, 0.28);
}

:root.light .home-content :deep(.card:hover) {
  box-shadow: 0 10px 24px rgba(15, 23, 42, 0.12);
}

:root.light .mini-row {
  border-bottom: 1px solid rgba(15, 23, 42, 0.08);
}

:root.light .mini-row--champion span:last-child {
  color: #0f172a;
}

:root.light .insight-box {
  border-color: rgba(59, 130, 246, 0.3);
  background: linear-gradient(140deg, rgba(59, 130, 246, 0.09), rgba(2, 132, 199, 0.04));
}

:root.light .insight-box--alt {
  border-color: rgba(22, 163, 74, 0.28);
  background: linear-gradient(140deg, rgba(34, 197, 94, 0.1), rgba(14, 116, 144, 0.04));
}

:root.light .insight-text {
  color: #1f2937;
}

.reveal {
  animation: rise-in 520ms ease both;
}

.delay-1 {
  animation-delay: 110ms;
}

.delay-2 {
  animation-delay: 200ms;
}

.hero-typing {
  white-space: nowrap;
  display: inline;
}

.hero-cursor {
  display: inline-block;
  margin-left: 1px;
  color: var(--green);
  font-weight: 400;
  animation: cursor-blink 0.75s step-end infinite;
}

@keyframes cursor-blink {
  0%, 100% { opacity: 1; }
  50%       { opacity: 0; }
}

@keyframes rise-in {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes pulse-live {
  0%,
  100% { box-shadow: 0 0 0 0 rgba(22, 163, 74, 0.24); }
  50% { box-shadow: 0 0 0 8px rgba(22, 163, 74, 0); }
}

@media (prefers-reduced-motion: reduce) {
  .reveal,
  .delay-1,
  .delay-2 {
    animation: none !important;
  }

  .home-content :deep(.card),
  .live-chip,
  .insight-fade-enter-active,
  .insight-fade-leave-active,
  .hero-cursor {
    transition: none !important;
    animation: none !important;
  }
}
</style>
