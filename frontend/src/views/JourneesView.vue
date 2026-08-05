<template>
  <AppLayout season-label="Journées">
    <div class="journees-page">
      <div class="journees-content">

      <!-- ===== GESTION JOURNÉE ===== -->
      <div class="day-workspace">

        <!-- ── Toolbar compacte ── -->
        <div class="day-toolbar">
          <div class="day-toolbar-left">
            <div class="day-date-wrap">
              <input type="date" v-model="selectedDate" @change="onDateChange" class="input day-date-input" />
            </div>
            <span :class="['day-status-pill',
              dayStatusDisplay === 'confirmed' ? 'status-confirmed' :
              dayStatusDisplay === 'draft'     ? 'status-draft'     : 'status-new']">
              {{ dayInfo }}
            </span>
          </div>

          <div class="day-toolbar-right">
            <!-- Recherche rapide -->
            <div class="day-search-wrap">
              <input v-model="matchSearch" type="text" class="input day-search-input"
                     placeholder="Rechercher joueur…" @keydown.enter="searchMatch" />
              <select v-model="matchSearchDiv" class="input day-search-div">
                <option value="all">D1+D2</option>
                <option value="d1">D1</option>
                <option value="d2">D2</option>
              </select>
              <button @click="searchMatch" class="btn text-xs px-2" title="Chercher">
                <SearchIcon class="w-3.5 h-3.5" />
              </button>
            </div>

            <!-- Actions courantes -->
            <button @click="printDaySheet" class="btn text-xs gap-1" title="Imprimer">
              <PrinterIcon class="w-3.5 h-3.5" />
              <span class="hidden sm:inline">PDF</span>
            </button>
            <button @click="loadDay" class="btn text-xs p-2" title="Rafraîchir">
              <RefreshCwIcon class="w-3.5 h-3.5" />
            </button>

            <!-- Actions admin -->
            <template v-if="auth.isAdmin">
              <button @click="openParticipantsModal" class="btn-primary text-xs gap-1">
                <UsersIcon class="w-3.5 h-3.5" />
                <span class="hidden md:inline">Participants</span>
              </button>
              <button @click="saveDraft(false)" class="btn text-xs gap-1" :disabled="saving">
                <Loader2Icon v-if="saving" class="w-3.5 h-3.5 animate-spin" />
                <SaveIcon v-else class="w-3.5 h-3.5" />
                <span class="hidden md:inline">Brouillon</span>
              </button>
              <button @click="openConfirmModal" class="btn-primary text-xs gap-1" :disabled="publishing">
                <Loader2Icon v-if="publishing" class="w-3.5 h-3.5 animate-spin" />
                <span>Publier</span>
              </button>

              <!-- Actions destructives dans un details -->
              <details class="day-danger-menu">
                <summary class="btn text-xs p-2" title="Actions avancées">
                  <MoreVerticalIcon class="w-3.5 h-3.5" />
                </summary>
                <div class="day-danger-dropdown">
                  <button @click="clearScores('d1')" class="danger-item">Effacer scores D1</button>
                  <button @click="clearScores('d2')" class="danger-item">Effacer scores D2</button>
                  <button @click="clearAllMatches" class="danger-item danger-item--red">Supprimer confrontations</button>
                </div>
              </details>
            </template>
          </div>
        </div>
        <p v-if="matchSearchInfo" class="text-xs px-1" style="color:var(--muted)">{{ matchSearchInfo }}</p>

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

        <div v-if="loadingDay" class="day-loading">
          <div class="day-spinner" />
          <span>Chargement de la journée…</span>
        </div>
        <div v-else class="day-divisions-grid">

          <!-- D1 -->
          <div class="day-division-card">
            <div class="day-division-header day-division-header--d1">
              <div class="day-div-badge">D1</div>
              <h4 class="day-div-title">Division 1</h4>
              <span class="day-div-count">{{ d1Matches.length }} confrontation(s)</span>
              <button v-if="auth.isAdmin" @click="addMatch('d1')" class="btn text-xs ml-auto" title="Ajouter une ligne">+ Ajouter</button>
            </div>
            <div class="overflow-x-auto table-shell" style="max-height:480px;overflow-y:auto;-webkit-overflow-scrolling:touch">
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
            <h5 class="day-standings-title">Classement D1</h5>
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
                      <TrophyIcon v-if="ri === 0 && r.role !== 'INVITE'" class="w-3.5 h-3.5 inline mr-1" style="color:#eab308" />
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

          <!-- D2 -->
          <div class="day-division-card">
            <div class="day-division-header day-division-header--d2">
              <div class="day-div-badge day-div-badge--d2">D2</div>
              <h4 class="day-div-title">Division 2</h4>
              <span class="day-div-count">{{ d2Matches.length }} confrontation(s)</span>
              <button v-if="auth.isAdmin" @click="addMatch('d2')" class="btn text-xs ml-auto" title="Ajouter une ligne">+ Ajouter</button>
            </div>
            <div class="overflow-x-auto table-shell" style="max-height:480px;overflow-y:auto;-webkit-overflow-scrolling:touch">
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
            <h5 class="day-standings-title">Classement D2</h5>
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
                      <TrophyIcon v-if="ri === 0 && r.role !== 'INVITE'" class="w-3.5 h-3.5 inline mr-1" style="color:#eab308" />
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

        <!-- Barrage -->
        <div v-if="auth.isAdmin" class="day-barrage-card">
          <div class="day-division-header" style="border-bottom:1px solid rgba(59,130,246,.2);background:rgba(59,130,246,.06)">
            <div class="day-div-badge" style="background:rgba(59,130,246,.15);color:#3b82f6">B</div>
            <h4 class="day-div-title">Barrage D2 ↔ D1</h4>
            <span class="day-div-count">Les invités sont exclus</span>
          </div>
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
      </div><!-- /day-workspace -->

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

      </div><!-- /journees-content -->
    </div><!-- /journees-page -->
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
import { Loader2Icon, Trash2Icon, RefreshCcwIcon, SearchIcon, PrinterIcon, SaveIcon, UsersIcon, MoreVerticalIcon, RefreshCwIcon, TrophyIcon } from 'lucide-vue-next'

const SVG_TROPHY = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#ca8a04" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6"/><path d="M18 9h1.5a2.5 2.5 0 0 0 0-5H18"/><path d="M4 22h16"/><path d="M10 14.66V17c0 .55-.47.98-.97 1.21C7.85 18.75 7 20.24 7 22"/><path d="M14 14.66V17c0 .55.47.98.97 1.21C16.15 18.75 17 20.24 17 22"/><path d="M18 2H6v7a6 6 0 0 0 12 0V2Z"/></svg>'

const auth   = useAuthStore()
const api    = useAPI()
const route  = useRoute()
const router = useRouter()
const { success, error: toastError, info: toastInfo } = useToast()
const MATCH_SORT_STORAGE_KEY = 'gz_journees_match_sort_v1'

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

// Search
const matchSearch    = ref('')
const matchSearchDiv = ref('all')
const matchSearchInfo = ref('')
const highlightSet   = ref(new Set())
const lastEditAt = ref(0)
let syncTimer = null
let realtimeOffDraftUpdate = null
let realtimeOffDayConfirmed = null
let realtimeOffDayUpdated = null
let realtimeOffTournamentChanged = null
let joinedDraftRoom = ''
let joinedDayRoom = ''

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

// Auto-save timer
let autoSaveTimer = null

const { restored: restoredJourneesState } = useSessionState('efoot.ui.journees.v1', {
  selectedDate,
  confirmModal,
  participantsModal,
  pmConfirmModal,
  matchSearch,
  matchSearchDiv,
  pmSearch,
})

/* ====== Computed standings from reactive match arrays ====== */
const d1Standings = computed(() => computeStandings(d1Matches.value))
const d2Standings = computed(() => computeStandings(d2Matches.value))

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
  })

  realtimeOffDayUpdated = onRealtimeEvent('day:updated', async ({ date } = {}) => {
    if (!date || date !== selectedDate.value) return
    await syncCycle()
  })

  realtimeOffTournamentChanged = onRealtimeEvent('tournament:changed', async ({ date } = {}) => {
    if (date && date === selectedDate.value) {
      await loadDayTournaments()
    }
  })
}

function unbindRealtimeListeners() {
  if (realtimeOffDraftUpdate) realtimeOffDraftUpdate()
  if (realtimeOffDayConfirmed) realtimeOffDayConfirmed()
  if (realtimeOffDayUpdated) realtimeOffDayUpdated()
  if (realtimeOffTournamentChanged) realtimeOffTournamentChanged()
  realtimeOffDraftUpdate = null
  realtimeOffDayConfirmed = null
  realtimeOffDayUpdated = null
  realtimeOffTournamentChanged = null
}

/* ====== Lifecycle ====== */
onMounted(async () => {
  await Promise.all([loadSeason(), loadPlayers()])
  loadSortPreferences()
  if (route.query.day) {
    selectedDate.value = route.query.day
  } else {
    if (!restoredJourneesState.value) {
      await prefillNextSaturdayDate()
    }
  }
  bindRealtimeListeners()
  await syncRealtimeRooms()
  await loadDay()
  syncTimer = setInterval(syncCycle, 15000)
})

onUnmounted(() => {
  if (autoSaveTimer) clearTimeout(autoSaveTimer)
  if (syncTimer) clearInterval(syncTimer)
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

/* ====== Print ====== */
async function printDaySheet() {
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

  async function logoDataURL() {
    const tryFetch = async (path) => {
      try {
        const r = await fetch(path, { cache: 'no-store' })
        if (!r.ok) return null
        const blob = await r.blob()
        return await new Promise((resolve) => {
          const fr = new FileReader()
          fr.onload = () => resolve(fr.result)
          fr.readAsDataURL(blob)
        })
      } catch (_) {
        return null
      }
    }
    return (await tryFetch('/assets/logo.png'))
      || (await tryFetch('/assets/icons/apple-touch-icon.png'))
      || (await tryFetch('assets/logo.png'))
      || (await tryFetch('assets/icons/apple-touch-icon.png'))
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
  const logo = await logoDataURL()

  let html = `<!doctype html><html lang="fr"><head><meta charset="utf-8"/><title>Résultats — ${escapeHtml(selectedDate.value)}</title><style>${css}</style></head><body onload="window.print()">`
  html += `<h1>${logo ? `<img src="${logo}" alt="logo">` : ''}GOUZEPE GAMING CLUB — Journée du ${escapeHtml(fmtDate(selectedDate.value))}</h1>`
  html += '<h2>SCORES D1</h2>' + renderMatches(d1Matches.value)
  html += `<div class="champ">${SVG_TROPHY} ${escapeHtml(c1Id)} — CHAMPION avec ${escapeHtml(team1)}</div>`
  html += renderStand('CLASSEMENT D1', main1, inv1)
  html += '<h2>SCORES D2</h2>' + renderMatches(d2Matches.value)
  html += `<div class="champ">${SVG_TROPHY} ${escapeHtml(c2Id)} — CHAMPION avec ${escapeHtml(team2)}</div>`
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
</script>

<style scoped>
.journees-page {
  position: relative;
  width: 100%;
  min-height: calc(100dvh - 56px);
}

.journees-content {
  position: relative;
  z-index: 1;
  width: 100%;
  padding: clamp(14px, 2.2vw, 30px);
}

.table-shell {
  border: 1px solid rgba(148, 163, 184, 0.18);
  border-radius: 12px;
  padding: 4px;
  background: rgba(15, 23, 42, 0.18);
  overflow-x: auto;
  overflow-y: hidden;
  -webkit-overflow-scrolling: touch;
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

.standings-table { min-width: 520px; }
.matches-table { min-width: 560px; }

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

/* ── Day workspace ── */
.day-workspace { display: flex; flex-direction: column; gap: 1rem; }

.day-toolbar {
  display: flex; align-items: center; justify-content: space-between;
  flex-wrap: wrap; gap: .6rem;
  background: color-mix(in srgb, var(--panel) 90%, transparent);
  border: 1px solid rgba(148,163,184,.14); border-radius: 14px;
  padding: .75rem 1rem;
  position: sticky; top: 68px; z-index: 10;
  backdrop-filter: blur(10px);
}
.day-toolbar-left { display: flex; align-items: center; gap: .6rem; flex-wrap: wrap; }
.day-toolbar-right { display: flex; align-items: center; gap: .4rem; flex-wrap: wrap; margin-left: auto; }
.day-date-input { width: 140px !important; font-size: .82rem; }
.day-status-pill { font-size: .68rem; font-weight: 800; text-transform: uppercase; letter-spacing: .07em; padding: 3px 10px; border-radius: 99px; white-space: nowrap; }
.status-confirmed { background: rgba(34,197,94,.12); color: #22c55e; }
.status-draft     { background: rgba(95,141,255,.12); color: #5f8dff; }
.status-new       { background: rgba(148,163,184,.1); color: var(--muted); }
.day-search-wrap { display: flex; align-items: center; gap: .3rem; }
.day-search-input { width: 140px !important; font-size: .8rem; }
.day-search-div { width: 72px !important; font-size: .78rem; }

/* Dropdown danger menu */
.day-danger-menu { position: relative; }
.day-danger-menu summary { list-style: none; cursor: pointer; }
.day-danger-menu summary::-webkit-details-marker { display: none; }
.day-danger-dropdown {
  position: absolute; right: 0; top: calc(100% + 4px); z-index: 50;
  background: var(--panel); border: 1px solid rgba(148,163,184,.2);
  border-radius: 10px; padding: .35rem; min-width: 180px;
  box-shadow: 0 8px 24px rgba(2,6,23,.4);
  display: flex; flex-direction: column; gap: .25rem;
}
.danger-item { background: none; border: none; cursor: pointer; font-size: .82rem; font-family: inherit; padding: .45rem .7rem; border-radius: 7px; text-align: left; color: var(--muted); transition: background .12s, color .12s; }
.danger-item:hover { background: rgba(245,158,11,.1); color: #fbbf24; }
.danger-item--red:hover { background: rgba(212,60,73,.1); color: #ef4444; }

.day-loading { display: flex; align-items: center; gap: .75rem; color: var(--muted); font-size: .88rem; padding: 2rem 1rem; }
.day-spinner { width: 20px; height: 20px; border: 2px solid rgba(34,197,94,.2); border-top-color: #22c55e; border-radius: 50%; animation: spinDay .6s linear infinite; flex-shrink: 0; }
@keyframes spinDay { to { transform: rotate(360deg); } }

.day-divisions-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1rem; }

.day-division-card {
  background: color-mix(in srgb, var(--card) 90%, transparent);
  border: 1px solid rgba(148,163,184,.12); border-radius: 16px;
  overflow: hidden;
}
.day-division-header {
  display: flex; align-items: center; gap: .6rem;
  padding: .7rem 1rem; border-bottom: 1px solid rgba(148,163,184,.1);
  background: rgba(148,163,184,.03);
}
.day-division-header--d1 { border-bottom-color: rgba(34,197,94,.2); background: rgba(34,197,94,.04); }
.day-division-header--d2 { border-bottom-color: rgba(95,141,255,.2); background: rgba(95,141,255,.04); }
.day-div-badge { font-size: .65rem; font-weight: 900; letter-spacing: .08em; padding: 3px 8px; border-radius: 99px; background: rgba(34,197,94,.15); color: #22c55e; }
.day-div-badge--d2 { background: rgba(95,141,255,.15); color: #5f8dff; }
.day-div-title { font-size: .88rem; font-weight: 700; }
.day-div-count { font-size: .72rem; color: var(--muted); }

.day-standings-title { font-size: .72rem; font-weight: 800; text-transform: uppercase; letter-spacing: .08em; color: var(--muted); margin: 1rem 1rem .5rem; }

.day-barrage-card {
  background: color-mix(in srgb, var(--card) 90%, transparent);
  border: 1px solid rgba(59,130,246,.15); border-radius: 16px;
  overflow: hidden;
}
.day-barrage-card > .flex,
.day-barrage-card > div:not(.day-division-header) { padding: 0 1rem 1rem; }
</style>
