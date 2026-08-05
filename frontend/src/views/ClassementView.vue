<template>
  <AppLayout :season-label="currentSeasonName">
    <div class="page-wrap classement-wrap">

      <!-- Filtres -->
      <div class="flex flex-wrap gap-3 items-end mb-4 reveal controls-bar">
        <div>
          <label class="label">Saison</label>
          <select v-model="selectedSeason" @change="onSeasonChange" class="input w-52">
            <option v-for="s in seasons" :key="s.id" :value="s.id">
              {{ s.name }}{{ s.is_closed ? ' (clôturée)' : '' }}
            </option>
          </select>
        </div>
        <button v-if="auth.isAdmin" @click="newSeasonModal = true" class="btn-primary text-sm">
          <PlusIcon class="w-3.5 h-3.5" /> Créer saison
        </button>
        <div>
          <label class="label">Recherche</label>
          <input v-model="search" type="text" class="input w-52" placeholder="Nom ou ID joueur…" />
        </div>
        <label class="flex items-center gap-2 text-sm cursor-pointer" style="color:var(--muted)">
          <input type="checkbox" v-model="showWin" class="w-4 h-4" /> Vict. %
        </label>
        <label class="flex items-center gap-2 text-sm cursor-pointer" style="color:var(--muted)">
          <input type="checkbox" v-model="showForm" class="w-4 h-4" /> Forme (5)
        </label>
        <button @click="printSeasonA4" class="btn text-sm" title="Imprimer le classement saison au format A4">
          <PrinterIcon class="w-4 h-4" /> Imprimer saison
        </button>
        <button @click="openCompareModal" class="btn">
          <ArrowLeftRightIcon class="w-4 h-4" /> Comparer
        </button>
        <button @click="openTournamentsModal" class="btn">
          <TrophyIcon class="w-4 h-4" /> Tournois
        </button>
        <button @click="streakModal = true" class="btn" title="Meilleures séries de journées gagnées d'affilée">
          <FlameIcon class="w-4 h-4" /> Séries
        </button>
        <button @click="load" class="btn" :disabled="loading">
          <RefreshCwIcon class="w-4 h-4" :class="{ 'animate-spin': loading }" />
        </button>
      </div>

      <!-- Seuil + Journée selector -->
      <div class="flex flex-wrap gap-4 items-center mb-4 reveal delay-1 controls-meta">
        <p class="text-xs" style="color:var(--muted)">
          Seuil de classement : <strong>{{ threshold }}</strong> participation(s) (25% des Journées)
        </p>
      </div>
      <div class="flex flex-wrap gap-2 items-center mb-6 reveal delay-1 controls-day">
        <span class="text-sm" style="color:var(--muted)">Journée confirmée :</span>
        <select v-model="selectedDay" class="input w-52">
          <option value="">— choisir —</option>
          <option v-for="d in confirmedDays" :key="d" :value="d">{{ fmtDate(d) }}</option>
        </select>
        <button :disabled="!selectedDay" @click="viewDay" class="btn text-sm">Afficher</button>
        <button v-if="auth.isAdmin" :disabled="!selectedDay" @click="goEditDay" class="btn-primary text-sm">
          Modifier
        </button>
        <button :disabled="!selectedDay" @click="printSelectedDay" class="btn text-sm" title="Imprimer cette journée au format PDF">
          Imprimer cette journée
        </button>
        <button v-if="auth.isAdmin" :disabled="!selectedDay" @click="deleteDay" class="btn text-sm"
                style="background:#2a0c0c;border-color:#7f1d1d;color:#fecaca">
          Supprimer
        </button>
      </div>

      <div v-if="loading" class="text-center py-12" style="color:var(--muted)">Chargement…</div>
      <template v-else>

        <!-- Table Classés -->
        <h3 class="text-base font-bold mb-3">Classés (≥ {{ threshold }} participation(s))</h3>
        <div class="table-shell overflow-x-auto mb-8 reveal delay-2">
          <table class="data-table">
            <thead>
              <tr>
                <th class="text-center w-10">Rang</th>
                <th>Nom</th>
                <th class="text-center">ID</th>
                <th class="text-center">Total</th>
                <th class="text-center">Particip.</th>
                <th class="text-center">Moyenne</th>
                <th class="text-center">Titres D1</th>
                <th class="text-center">Titres D2</th>
                <th class="text-center">Équipes</th>
                <th v-if="showWin" class="text-center">Vict. %</th>
                <th v-if="showForm" class="text-center">Forme</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="!classedRows.length">
                <td :colspan="9 + (showWin ? 1 : 0) + (showForm ? 1 : 0)"
                    class="text-center py-6" style="color:var(--muted)">Aucun joueur classé.</td>
              </tr>
              <tr v-for="(row, i) in classedRows" :key="row.id">
                <td class="text-center">
                  <span v-if="i === 0" class="rank-medal rank-gold">1</span>
                  <span v-else-if="i === 1" class="rank-medal rank-silver">2</span>
                  <span v-else-if="i === 2" class="rank-medal rank-bronze">3</span>
                  <span v-else style="color:var(--muted)">{{ i + 1 }}</span>
                </td>
                <td>
                  <div class="name-cell">
                    <button @click="openPlayerTitles(row)"
                            class="text-sm underline" style="background:none;border:none;color:inherit;cursor:pointer;padding:0">
                      {{ row.name || row.id }}
                    </button>
                    <span class="text-xs px-1.5 py-0.5 rounded" style="background:rgba(37,99,235,.15);color:#60a5fa">
                      D1 {{ aggMap.get(row.id)?.d1 || 0 }}
                    </span>
                    <span class="text-xs px-1.5 py-0.5 rounded" style="background:color-mix(in srgb, var(--blue) 16%, transparent);color:var(--blue-l)">
                      D2 {{ aggMap.get(row.id)?.d2 || 0 }}
                    </span>
                  </div>
                </td>
                <td class="text-center text-sm" style="color:var(--muted)">{{ row.id }}</td>
                <td class="text-center font-bold">{{ row.total }}</td>
                <td class="text-center">
                  <span>{{ row.participations }}</span>
                  <div class="w-16 h-1.5 rounded-full mx-auto mt-1 overflow-hidden" style="background:var(--border)">
                    <div class="h-full rounded-full" style="background:linear-gradient(90deg,var(--green),var(--blue))"
                         :style="{ width: partPct(row) + '%' }"></div>
                  </div>
                </td>
                <td class="text-center">{{ (row.moyenne || 0).toFixed(2) }}</td>
                <td class="text-center">{{ row.won_d1 ?? 0 }}</td>
                <td class="text-center">{{ row.won_d2 ?? 0 }}</td>
                <td class="text-center">{{ row.teams_used ?? 0 }}</td>
                <td v-if="showWin" class="text-center" style="color:var(--muted)">{{ winPct(row) }}%</td>
                <td v-if="showForm" class="text-center font-mono text-sm">
                  <span v-for="(c, ci) in formChars(row)" :key="ci"
                        :style="c === 'V' ? 'color:#22c55e;font-weight:700' : c === 'D' ? 'color:#ef4444' : 'color:var(--muted)'">
                    {{ c }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Table Non Classés -->
        <h3 class="text-base font-bold mb-3">Non Classés (&lt; {{ threshold }} participation(s))</h3>
        <div class="table-shell overflow-x-auto reveal delay-2">
          <table class="data-table" style="opacity:.8">
            <thead>
              <tr>
                <th class="text-center w-10">Rang</th>
                <th>Nom</th>
                <th class="text-center">ID</th>
                <th class="text-center">Total</th>
                <th class="text-center">Particip.</th>
                <th class="text-center">Moyenne</th>
                <th class="text-center">Titres D1</th>
                <th class="text-center">Titres D2</th>
                <th class="text-center">Équipes</th>
                <th v-if="showWin" class="text-center">Vict. %</th>
                <th v-if="showForm" class="text-center">Forme</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="!unclassedRows.length">
                <td :colspan="9 + (showWin ? 1 : 0) + (showForm ? 1 : 0)"
                    class="text-center py-6" style="color:var(--muted)">Aucun.</td>
              </tr>
              <tr v-for="(row, i) in unclassedRows" :key="row.id">
                <td class="text-center" style="color:var(--muted)">{{ i + 1 }}</td>
                <td class="text-sm">{{ row.name || row.id }}</td>
                <td class="text-center text-sm" style="color:var(--muted)">{{ row.id }}</td>
                <td class="text-center">{{ row.total }}</td>
                <td class="text-center">{{ row.participations }}</td>
                <td class="text-center">{{ (row.moyenne || 0).toFixed(2) }}</td>
                <td class="text-center">{{ row.won_d1 ?? 0 }}</td>
                <td class="text-center">{{ row.won_d2 ?? 0 }}</td>
                <td class="text-center">{{ row.teams_used ?? 0 }}</td>
                <td v-if="showWin" class="text-center" style="color:var(--muted)">{{ winPct(row) }}%</td>
                <td v-if="showForm" class="text-center font-mono text-sm">
                  <span v-for="(c, ci) in formChars(row)" :key="ci"
                        :style="c === 'V' ? 'color:#22c55e' : c === 'D' ? 'color:#ef4444' : 'color:var(--muted)'">
                    {{ c }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>
    </div>

    <!-- Modal: Journée detail -->
    <BaseModal :open="dayModal" :title="'Journée — ' + fmtDate(selectedDay)" @close="dayModal = false" size="lg">
      <div v-if="dayPayloadData">
        <div v-for="div in ['d1', 'd2']" :key="div" class="mb-5">
          <h4 class="font-bold mb-2">Division {{ div.toUpperCase() }}</h4>
          <div v-if="!(dayPayloadData[div]?.length)" class="text-sm" style="color:var(--muted)">
            Aucune confrontation.
          </div>
          <table v-else class="data-table text-sm">
            <thead>
              <tr>
                <th>Joueur 1</th>
                <th class="text-center">Aller</th>
                <th class="text-center">Retour</th>
                <th>Joueur 2</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(m, mi) in dayPayloadData[div]" :key="mi">
                <td>{{ m.p1 }}</td>
                <td class="text-center">
                  {{ m.a1 != null ? m.a1 + ' – ' + m.a2 : '—' }}
                </td>
                <td class="text-center">
                  {{ m.r1 != null ? m.r1 + ' – ' + m.r2 : '—' }}
                </td>
                <td>{{ m.p2 }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-if="dayPayloadData.champions?.d1?.id || dayPayloadData.champions?.d2?.id"
             class="mt-4 p-3 rounded-xl text-sm" style="background:var(--panel);border:1px solid var(--border)">
          <p v-if="dayPayloadData.champions?.d1?.id">
            <TrophyIcon class="w-4 h-4 inline" style="color:#eab308" /> Champion D1 : <strong>{{ dayPayloadData.champions.d1.id }}</strong>
            <span v-if="dayPayloadData.champions.d1.team" style="color:var(--muted)">
              — {{ dayPayloadData.champions.d1.team }}
            </span>
          </p>
          <p v-if="dayPayloadData.champions?.d2?.id">
            <TrophyIcon class="w-4 h-4 inline" style="color:#eab308" /> Champion D2 : <strong>{{ dayPayloadData.champions.d2.id }}</strong>
            <span v-if="dayPayloadData.champions.d2.team" style="color:var(--muted)">
              — {{ dayPayloadData.champions.d2.team }}
            </span>
          </p>
        </div>
      </div>
      <div v-else class="text-center py-6" style="color:var(--muted)">Chargement…</div>
    </BaseModal>

    <!-- Modal: Comparateur -->
    <BaseModal :open="compareModal" title="Comparateur de joueurs" @close="compareModal = false" size="lg">
      <div class="space-y-4">
        <!-- Sélecteurs -->
        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="label">Joueur A</label>
            <select v-model="cmpA" class="input">
              <option value="">—</option>
              <optgroup label="Membres">
                <option v-for="p in memberPlayers" :key="p.id" :value="p.id" :disabled="p.id === cmpB">{{ p.name }} ({{ p.id }})</option>
              </optgroup>
              <optgroup v-if="guestPlayers.length" label="Invités">
                <option v-for="p in guestPlayers" :key="p.id" :value="p.id" :disabled="p.id === cmpB">{{ p.name }} ({{ p.id }})</option>
              </optgroup>
            </select>
          </div>
          <div>
            <label class="label">Joueur B</label>
            <select v-model="cmpB" class="input">
              <option value="">—</option>
              <optgroup label="Membres">
                <option v-for="p in memberPlayers" :key="p.id" :value="p.id" :disabled="p.id === cmpA">{{ p.name }} ({{ p.id }})</option>
              </optgroup>
              <optgroup v-if="guestPlayers.length" label="Invités">
                <option v-for="p in guestPlayers" :key="p.id" :value="p.id" :disabled="p.id === cmpA">{{ p.name }} ({{ p.id }})</option>
              </optgroup>
            </select>
          </div>
        </div>
        <button @click="runCompare" class="btn-primary" :disabled="!cmpA || !cmpB || cmpLoading">
          <Loader2Icon v-if="cmpLoading" class="w-3.5 h-3.5 animate-spin" /> Comparer
        </button>

        <div v-if="cmpResult" class="space-y-3 text-sm">

          <!-- En-tête noms -->
          <div class="grid grid-cols-3 font-bold text-center py-2 px-3 rounded-xl"
               style="background:var(--panel);border:1px solid var(--border)">
            <span class="truncate text-left">{{ cmpResult.nameA }}</span>
            <span style="color:var(--muted)" class="text-xs self-center">vs</span>
            <span class="truncate text-right">{{ cmpResult.nameB }}</span>
          </div>

          <!-- Stats saison générales -->
          <div class="rounded-xl overflow-hidden" style="border:1px solid var(--border)">
            <div class="px-3 py-1.5 text-xs font-semibold uppercase tracking-wide" style="background:var(--panel);color:var(--muted);border-bottom:1px solid var(--border)">
              Classement général
            </div>
            <div v-for="row in cmpResult.rows" :key="row.label"
                 class="grid grid-cols-3 text-center py-1.5 px-3"
                 style="border-bottom:1px solid color-mix(in srgb,var(--border) 50%,transparent)">
              <span :class="row.desc !== null && Number(row.a) > Number(row.b) ? 'font-bold text-gz-green' : row.desc !== null && Number(row.a) < Number(row.b) ? 'text-gz-red' : ''">{{ row.a }}</span>
              <span class="text-xs" style="color:var(--muted)">{{ row.label }}</span>
              <span :class="row.desc !== null && Number(row.b) > Number(row.a) ? 'font-bold text-gz-green' : row.desc !== null && Number(row.b) < Number(row.a) ? 'text-gz-red' : ''">{{ row.b }}</span>
            </div>
          </div>

          <!-- Face-à-face journées -->
          <div class="rounded-xl overflow-hidden" style="border:1px solid var(--border)">
            <div class="px-3 py-1.5 text-xs font-semibold uppercase tracking-wide" style="background:var(--panel);color:var(--muted);border-bottom:1px solid var(--border)">
              Face-à-face — {{ cmpResult.h2h.total }} match(s) · journées · tournois · duels
            </div>

            <template v-if="cmpResult.h2h.total > 0">
              <!-- Bilan W-D-L centré -->
              <div class="grid grid-cols-3 text-center py-3 px-3"
                   style="border-bottom:1px solid color-mix(in srgb,var(--border) 40%,transparent)">
                <div>
                  <div class="text-xl font-bold"
                       :class="cmpResult.h2h.p1.wins > cmpResult.h2h.p2.wins ? 'text-gz-green' : cmpResult.h2h.p1.wins < cmpResult.h2h.p2.wins ? 'text-gz-red' : ''">
                    {{ cmpResult.h2h.p1.wins }}
                  </div>
                  <div class="text-xs" style="color:var(--muted)">Victoires</div>
                </div>
                <div>
                  <div class="text-xl font-bold" style="color:var(--muted)">{{ cmpResult.h2h.p1.draws }}</div>
                  <div class="text-xs" style="color:var(--muted)">Nuls</div>
                </div>
                <div>
                  <div class="text-xl font-bold"
                       :class="cmpResult.h2h.p2.wins > cmpResult.h2h.p1.wins ? 'text-gz-green' : cmpResult.h2h.p2.wins < cmpResult.h2h.p1.wins ? 'text-gz-red' : ''">
                    {{ cmpResult.h2h.p2.wins }}
                  </div>
                  <div class="text-xs" style="color:var(--muted)">Victoires</div>
                </div>
              </div>
              <!-- Buts -->
              <template v-for="stat in [
                { label:'Buts marqués',   a: cmpResult.h2h.p1.gf, b: cmpResult.h2h.p2.gf, desc: true },
                { label:'Buts encaissés', a: cmpResult.h2h.p1.ga, b: cmpResult.h2h.p2.ga, desc: false },
              ]" :key="stat.label">
                <div class="grid grid-cols-3 text-center py-1.5 px-3"
                     style="border-bottom:1px solid color-mix(in srgb,var(--border) 40%,transparent)">
                  <span :class="stat.desc ? (stat.a > stat.b ? 'font-bold text-gz-green' : stat.a < stat.b ? 'text-gz-red' : '') : (stat.a < stat.b ? 'font-bold text-gz-green' : stat.a > stat.b ? 'text-gz-red' : '')">{{ stat.a }}</span>
                  <span class="text-xs" style="color:var(--muted)">{{ stat.label }}</span>
                  <span :class="stat.desc ? (stat.b > stat.a ? 'font-bold text-gz-green' : stat.b < stat.a ? 'text-gz-red' : '') : (stat.b < stat.a ? 'font-bold text-gz-green' : stat.b > stat.a ? 'text-gz-red' : '')">{{ stat.b }}</span>
                </div>
              </template>

              <!-- Par division (journées) -->
              <template v-for="(dv, divName) in cmpResult.h2h.byDiv" :key="divName">
                <div v-if="dv.legs > 0" class="grid grid-cols-3 text-center py-1.5 px-3"
                     style="border-bottom:1px solid color-mix(in srgb,var(--border) 40%,transparent)">
                  <span :class="dv.wins1 > dv.wins2 ? 'font-bold text-gz-green' : dv.wins1 < dv.wins2 ? 'text-gz-red' : ''">{{ dv.wins1 }}V {{ dv.draws }}N {{ dv.wins2 }}D</span>
                  <span class="text-xs" style="color:var(--muted)">{{ divName }} ({{ dv.legs }} matchs)</span>
                  <span :class="dv.wins2 > dv.wins1 ? 'font-bold text-gz-green' : dv.wins2 < dv.wins1 ? 'text-gz-red' : ''">{{ dv.wins2 }}V {{ dv.draws }}N {{ dv.wins1 }}D</span>
                </div>
              </template>

              <!-- Par source -->
              <template v-for="src in sourceBreakdown" :key="src.key">
                <div v-if="src.legs > 0" class="grid grid-cols-3 text-center py-1.5 px-3"
                     style="border-bottom:1px solid color-mix(in srgb,var(--border) 40%,transparent)">
                  <span :class="src.wins1 > src.wins2 ? 'font-bold text-gz-green' : src.wins1 < src.wins2 ? 'text-gz-red' : ''">{{ src.wins1 }}V {{ src.draws }}N {{ src.wins2 }}D</span>
                  <span class="text-xs" style="color:var(--muted)">{{ src.label }} ({{ src.legs }} matchs)</span>
                  <span :class="src.wins2 > src.wins1 ? 'font-bold text-gz-green' : src.wins2 < src.wins1 ? 'text-gz-red' : ''">{{ src.wins2 }}V {{ src.draws }}N {{ src.wins1 }}D</span>
                </div>
              </template>

              <!-- Toutes les confrontations -->
              <div v-if="cmpResult.h2h.recent.length" class="px-3 py-2">
                <div class="text-xs font-semibold uppercase tracking-wide mb-2" style="color:var(--muted)">
                  Confrontations ({{ cmpResult.h2h.recent.length }})
                </div>
                <div class="space-y-1 max-h-64 overflow-y-auto pr-1">
                  <div v-for="(leg, li) in cmpResult.h2h.recent" :key="li"
                       class="flex items-center gap-2 py-1 text-xs"
                       style="border-bottom:1px solid color-mix(in srgb,var(--border) 30%,transparent)">
                    <span class="shrink-0 px-1.5 py-0.5 rounded text-[10px] font-semibold" :style="sourceBadge(leg.source)">
                      {{ sourceShort(leg.source) }}
                    </span>
                    <span class="shrink-0 w-16" style="color:var(--muted)">{{ leg.date || '—' }}</span>
                    <span class="flex-1 truncate" style="color:var(--muted)">{{ leg.context }}</span>
                    <span class="shrink-0 font-bold tabular-nums"
                          :class="leg.gf1 > leg.ga1 ? 'text-gz-green' : leg.gf1 < leg.ga1 ? 'text-gz-red' : ''">
                      {{ leg.gf1 }} – {{ leg.ga1 }}
                    </span>
                  </div>
                </div>
              </div>
            </template>
            <div v-else class="py-3 px-3 text-center text-xs" style="color:var(--muted)">
              Aucune confrontation dans les journées enregistrées.
            </div>
          </div>

        </div>
      </div>
    </BaseModal>

    <!-- Modal: Tournois de la saison -->
    <BaseModal :open="tournamentsModal" title="Tournois de la saison" @close="tournamentsModal = false" size="lg">
      <div v-if="tournamentsLoading" class="text-center py-8" style="color:var(--muted)">
        <Loader2Icon class="w-5 h-5 animate-spin inline" /> Chargement…
      </div>
      <div v-else-if="!tournamentsList.length" class="text-center py-8 text-sm" style="color:var(--muted)">
        Aucun tournoi comptant pour le titre dans cette saison.
      </div>
      <div v-else class="space-y-4">
        <p class="text-xs" style="color:var(--muted)">
          Seuls les tournois <strong>membres comptant pour le titre</strong> sont listés.
          Points = points gagnés pour le Classement Général.
        </p>

        <!-- Sélecteur de tournoi (chips) -->
        <div class="flex gap-1.5 flex-wrap">
          <button v-for="t in tournamentsOrdered" :key="t.id"
                  @click="activeTournamentId = t.id"
                  class="px-3 py-1 rounded-full text-xs font-semibold transition-all"
                  :style="activeTournamentId === t.id
                    ? 'background:rgba(37,99,235,.18);color:#60a5fa;border:1px solid rgba(37,99,235,.5)'
                    : 'background:var(--card);color:var(--muted);border:1px solid var(--border)'">
            {{ t.name }}
          </button>
        </div>

        <!-- Tournoi actif -->
        <div v-if="activeTournament" :key="activeTournament.id"
             class="rounded-xl overflow-hidden reveal" style="border:1px solid var(--border)">
          <!-- En-tête tournoi -->
          <div class="px-3 py-2 flex flex-wrap items-center justify-between gap-2"
               style="background:var(--panel);border-bottom:1px solid var(--border)">
            <div class="font-bold text-sm flex items-center gap-2">
              <TrophyIcon class="w-4 h-4" style="color:#eab308" />
              {{ activeTournament.name }}
              <span class="text-xs font-normal" style="color:var(--muted)">{{ formatTitleLabel(activeTournament.format) }}</span>
            </div>
            <div class="text-xs" style="color:var(--muted)">
              {{ activeTournament.played_at ? fmtDate(String(activeTournament.played_at).slice(0,10)) : '—' }}
              · {{ activeTournament.eligible_count }}/{{ activeTournament.participants_count }} classé(s)
              <span v-if="activeTournament.rows && activeTournament.rows.length"> · <TrophyIcon class="w-3 h-3 inline" style="color:#eab308" /> {{ activeTournament.rows[0].name }}</span>
            </div>
          </div>

          <!-- Table participants -->
          <div class="overflow-x-auto">
            <table class="data-table text-sm w-full">
              <thead>
                <tr>
                  <th class="text-center w-10">Rang</th>
                  <th>Participant</th>
                  <th class="text-center">Matchs</th>
                  <th class="text-center">V-N-D</th>
                  <th class="text-center">Pts saison</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in activeTournament.rows" :key="r.rank + '-' + (r.player_id || r.name)"
                    :style="!r.eligible ? 'opacity:.55' : ''">
                  <td class="text-center" style="color:var(--muted)">{{ r.rank }}</td>
                  <td>
                    {{ r.name }}
                    <span v-if="!r.eligible" class="text-[10px] px-1.5 py-0.5 rounded ml-1"
                          style="background:rgba(148,163,184,.18);color:var(--muted)">non classé</span>
                  </td>
                  <td class="text-center">{{ r.played }}</td>
                  <td class="text-center" style="color:var(--muted)">{{ r.wins }}-{{ r.draws }}-{{ r.losses }}</td>
                  <td class="text-center font-bold">{{ r.season_points != null ? r.season_points : '—' }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </BaseModal>

    <!-- Modal: Titres joueur -->
    <BaseModal :open="!!playerTitles" :title="'Titres — ' + (playerTitles?.name || playerTitles?.id || '')"
               @close="playerTitles = null" size="md">
      <div v-if="playerTitles">
        <div class="flex gap-3 items-center mb-4">
          <select v-model="titlesFilter" class="input w-40">
            <option value="all">D1 + D2</option>
            <option value="D1">Division 1</option>
            <option value="D2">Division 2</option>
          </select>
          <span class="text-sm" style="color:var(--muted)">{{ filteredTitles.length }} titre(s)</span>
        </div>
        <div v-if="!filteredTitles.length" class="text-center py-4 text-sm" style="color:var(--muted)">
          Aucun titre.
        </div>
        <div v-else class="space-y-2">
          <div v-for="t in filteredTitles" :key="t.date + t.div"
               class="flex justify-between items-center px-3 py-2 rounded-lg text-sm"
               style="background:var(--panel);border:1px solid var(--border)">
            <span class="font-medium">{{ t.div }}</span>
            <span style="color:var(--muted)">{{ fmtDate(t.date) }}</span>
            <span style="color:var(--muted)">{{ t.team || '—' }}</span>
          </div>
        </div>
      </div>
    </BaseModal>

    <!-- Modal: Créer saison -->
    <BaseModal :open="newSeasonModal" title="Créer une saison" @close="newSeasonModal = false" size="sm">
      <div>
        <label class="label">Nom de la saison</label>
        <input v-model="newSeasonName" type="text" class="input" placeholder="ex: Saison 1 — 2025" />
        <p class="text-xs mt-2" style="color:var(--amber,#f59e0b)">
          Démarrer une nouvelle saison <strong>clôture la saison en cours</strong> (elle reste consultable, mais ses journées ne sont plus modifiables comme « courante »).
        </p>
      </div>
      <template #footer>
        <button @click="newSeasonModal = false" class="btn">Annuler</button>
        <button @click="createSeason" class="btn-primary" :disabled="!newSeasonName.trim() || creatingSeason">
          <Loader2Icon v-if="creatingSeason" class="w-3.5 h-3.5 animate-spin" /> Créer
        </button>
      </template>
    </BaseModal>

    <!-- Modal: Meilleures séries -->
    <BaseModal :open="streakModal" title="Meilleures séries" @close="streakModal = false" size="md">
      <p class="text-sm mb-3" style="color:var(--muted)">
        Plus grand nombre de journées (titre D1) remportées d'affilée, par joueur.
      </p>
      <div v-if="!streakRanking.length" class="text-sm py-4 text-center" style="color:var(--muted)">
        Aucune donnée de champion de journée pour cette saison.
      </div>
      <div v-else class="streak-list">
        <div v-for="(r, i) in streakRanking" :key="r.id" class="streak-row">
          <span class="streak-rank" :class="{ gold: i === 0 }">{{ i + 1 }}</span>
          <div class="min-w-0 flex-1">
            <div class="streak-name">{{ r.name }}</div>
            <div class="streak-id">({{ r.id }})</div>
          </div>
          <span class="streak-val" :class="{ gold: i === 0 }">
            <FlameIcon v-if="i === 0" class="w-3.5 h-3.5 inline" /> {{ r.streak }}
            <small>journée{{ r.streak > 1 ? 's' : '' }}</small>
          </span>
        </div>
      </div>
    </BaseModal>

  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import AppLayout from '@/components/layout/AppLayout.vue'
import BaseModal from '@/components/ui/BaseModal.vue'
import { useAPI, mediaUrl } from '@/composables/useAPI'
import { useAuthStore } from '@/stores/auth'
import { useSiteSettings } from '@/stores/siteSettings'
import { useToast } from '@/composables/useToast'
import { useSessionState } from '@/composables/useSessionState'
import { ArrowLeftRightIcon, RefreshCwIcon, PlusIcon, Loader2Icon, PrinterIcon, TrophyIcon, FlameIcon } from 'lucide-vue-next'

const api    = useAPI()
const auth   = useAuthStore()
const site   = useSiteSettings()
const router = useRouter()
const { success, error: toastError } = useToast()

/* ====== State ====== */
const seasons        = ref([])
const selectedSeason = ref(null)
const loading        = ref(false)
const standingsData  = ref([])   // [{id, name, total, participations, moyenne, won_d1, won_d2, teams_used}]
const daysCount      = ref(0)
const confirmedDays  = ref([])

// SEASON_AGG (Win%, Forme, D1/D2 count)
const aggMap          = ref(new Map()) // id -> {J, V, form:[], d1, d2}
const championsByPlayer = ref(new Map()) // id -> [{date, div, team}]

const search   = ref('')
const showWin  = ref(true)
const showForm = ref(true)

const selectedDay    = ref('')
const dayModal       = ref(false)
const dayPayloadData = ref(null)

const compareModal = ref(false)
const cmpA         = ref('')
const cmpB         = ref('')
const cmpResult    = ref(null)
const cmpLoading   = ref(false)
const allPlayers   = ref([])
const playersAll   = ref([])   // liste complète /players (inclut les invités)
const roleById     = ref(new Map())
const rolesLoaded  = ref(false)

const tournamentsModal    = ref(false)
const streakModal         = ref(false)
const tournamentsLoading  = ref(false)
const tournamentsList     = ref([])
const activeTournamentId  = ref(null)

const playerTitles  = ref(null)
const titlesFilter  = ref('all')

const newSeasonModal  = ref(false)
const newSeasonName   = ref('')
const creatingSeason  = ref(false)
let aggBuildVersion   = 0
let aggPromise        = null

useSessionState('efoot.ui.classement.v1', {
  selectedSeason,
  search,
  showWin,
  showForm,
  selectedDay,
  dayModal,
  compareModal,
  cmpA,
  cmpB,
  newSeasonModal,
})

/* ====== Computed ====== */
const currentSeasonName = computed(() => {
  const s = seasons.value.find(x => x.id === selectedSeason.value)
  return s ? s.name : 'Classements'
})

const threshold = computed(() =>
  daysCount.value ? Math.ceil(daysCount.value * 0.25) : 0
)

const orderedData = computed(() => {
  return [...standingsData.value].sort((a, b) => {
    const m = Number(b?.moyenne || 0) - Number(a?.moyenne || 0)
    if (m) return m
    const t = Number(b?.total || 0) - Number(a?.total || 0)
    if (t) return t
    return String(a?.name || a?.id || '').localeCompare(String(b?.name || b?.id || ''), 'fr', { sensitivity: 'base' })
  })
})

const filteredData = computed(() => {
  const q = search.value.toLowerCase()
  return orderedData.value.filter(r =>
    !isInviteRow(r) &&
    (!q || (r.name || '').toLowerCase().includes(q) || (r.id || '').toLowerCase().includes(q))
  )
})

const classedRows   = computed(() => filteredData.value.filter(r => (r.participations || 0) >= threshold.value))
const unclassedRows = computed(() => filteredData.value.filter(r => (r.participations || 0) < threshold.value))

// Meilleure série de journées (D1) gagnées d'affilée, par joueur
const streakByPlayerId = computed(() => {
  const seq = []
  for (const [id, list] of championsByPlayer.value) {
    for (const c of list) if (c.div === 'D1') seq.push({ id, date: c.date })
  }
  seq.sort((a, b) => String(a.date).localeCompare(String(b.date)))
  const best = new Map()
  let cur = null, len = 0
  for (const c of seq) {
    if (c.id === cur) len++
    else { cur = c.id; len = 1 }
    if (len > (best.get(cur) || 0)) best.set(cur, len)
  }
  return best
})
const streakRanking = computed(() => {
  const nameById = new Map((orderedData.value || []).map(r => [r.id, r.name]))
  const out = []
  for (const [id, s] of streakByPlayerId.value) {
    if (s < 1) continue
    out.push({ id, name: nameById.get(id) || id, streak: s })
  }
  return out.sort((a, b) => b.streak - a.streak || String(a.name || a.id).localeCompare(String(b.name || b.id), 'fr'))
})

const seasonHighlights = computed(() => {
  const rows = classedRows.value
  if (!rows.length) return null
  const withAgg = rows.filter(r => (aggMap.value.get(r.id)?.J || 0) > 0)
  const champion = rows[0]

  // Retourne tous les ex-æquo pour un critère (score arrondi à 2 décimales)
  const topTied = (arr, scoreFn) => {
    if (!arr.length) return []
    const scored = arr.map(r => ({ r, s: Math.round(scoreFn(r) * 100) }))
    const best = Math.max(...scored.map(x => x.s))
    return scored.filter(x => x.s === best).map(x => x.r)
  }

  const agg  = r => aggMap.value.get(r.id) || {}
  const ratio = (r, num, den) => { const a = agg(r); return a[den] ? (a[num] / a[den]).toFixed(2) : '—' }

  const regularPlayers    = topTied(rows,     r => r.participations || 0)
  const teamsPlayers      = topTied(rows,     r => r.teams_used || 0)
  const defPlayers        = topTied(withAgg,  r => agg(r).J ? -(agg(r).BC / agg(r).J) : -999)
  const attPlayers        = topTied(withAgg,  r => agg(r).J ?  (agg(r).BP / agg(r).J) :    0)

  // Meilleure série de journées (D1) gagnées d'affilée (calcul partagé)
  const streakBestById = streakByPlayerId.value
  const bestStreakVal = rows.reduce((m, r) => Math.max(m, streakBestById.get(r.id) || 0), 0)
  const streakPlayers = bestStreakVal > 1
    ? rows.filter(r => (streakBestById.get(r.id) || 0) === bestStreakVal)
    : []

  return {
    champion,
    highlights: [
      { icon: svgIcon('calendar'), title: 'Plus régulier',      players: regularPlayers,    detail: `${regularPlayers[0]?.participations || 0} journées jouées` },
      { icon: svgIcon('shirt'),    title: "Plus d'équipes",      players: teamsPlayers,      detail: `${teamsPlayers[0]?.teams_used || 0} équipes différentes` },
      { icon: svgIcon('shield'),   title: 'Meilleure défense',  players: defPlayers,        detail: defPlayers[0] ? `${ratio(defPlayers[0], 'BC', 'J')} buts encaissés/match` : '—' },
      { icon: svgIcon('target'),   title: 'Meilleure attaque',  players: attPlayers,        detail: attPlayers[0] ? `${ratio(attPlayers[0], 'BP', 'J')} buts marqués/match`   : '—' },
      { icon: svgIcon('flame'),    title: 'Meilleure série',    players: streakPlayers,     detail: bestStreakVal > 1 ? `${bestStreakVal} journées gagnées d'affilée` : 'Aucune série de 2+ journées' },
    ],
  }
})

// Détails par division (D1 / D2) : titres, meilleure défense, meilleure attaque
const seasonDivisionHighlights = computed(() => {
  const rows = filteredData.value
  if (!rows.length) return null

  const topTied = (arr, scoreFn) => {
    if (!arr.length) return []
    const scored = arr.map(r => ({ r, s: Math.round(scoreFn(r) * 100) }))
    const best = Math.max(...scored.map(x => x.s))
    return scored.filter(x => x.s === best).map(x => x.r)
  }
  const agg = r => aggMap.value.get(r.id) || {}

  const buildDiv = (div) => {
    const played = rows.filter(r => (agg(r)[`J_${div}`] || 0) > 0)
    const defPlayers = topTied(played, r => agg(r)[`J_${div}`] ? -(agg(r)[`BC_${div}`] / agg(r)[`J_${div}`]) : -999)
    const attPlayers = topTied(played, r => agg(r)[`J_${div}`] ? (agg(r)[`BP_${div}`] / agg(r)[`J_${div}`]) : 0)
    const ratio = (r, num) => { const a = agg(r); return a[`J_${div}`] ? (a[`${num}_${div}`] / a[`J_${div}`]).toFixed(2) : '—' }

    // Le(s) plus titré(s) dans cette division cette saison
    const titleCounts = new Map()
    for (const [id, list] of championsByPlayer.value) {
      const n = list.filter(c => c.div === div.toUpperCase()).length
      if (n > 0) titleCounts.set(id, n)
    }
    let bestTitleN = 0
    for (const n of titleCounts.values()) if (n > bestTitleN) bestTitleN = n
    const titlePlayers = bestTitleN > 0 ? rows.filter(r => (titleCounts.get(r.id) || 0) === bestTitleN) : []

    return {
      titles:  { icon: svgIcon('trophy'), title: `Titres ${div.toUpperCase()}`,          players: titlePlayers, detail: bestTitleN > 0 ? `${bestTitleN} journée(s) remportée(s)` : 'Aucun titre' },
      defense: { icon: svgIcon('shield'), title: `Meilleure défense ${div.toUpperCase()}`, players: defPlayers,  detail: defPlayers[0] ? `${ratio(defPlayers[0], 'BC')} buts encaissés/match` : '—' },
      attack:  { icon: svgIcon('target'), title: `Meilleure attaque ${div.toUpperCase()}`, players: attPlayers,  detail: attPlayers[0] ? `${ratio(attPlayers[0], 'BP')} buts marqués/match`   : '—' },
    }
  }

  return { d1: buildDiv('d1'), d2: buildDiv('d2') }
})

const filteredTitles = computed(() => {
  if (!playerTitles.value) return []
  const list = championsByPlayer.value.get(playerTitles.value.id) || []
  return titlesFilter.value === 'all' ? list : list.filter(t => t.div === titlesFilter.value)
})

// Joueurs scindés membres / invités pour les sélecteurs du comparateur
const memberPlayers = computed(() => allPlayers.value.filter(p => !p.invite))
const guestPlayers  = computed(() => allPlayers.value.filter(p => p.invite))

const SVG_TROPHY = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#ca8a04" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6"/><path d="M18 9h1.5a2.5 2.5 0 0 0 0-5H18"/><path d="M4 22h16"/><path d="M10 14.66V17c0 .55-.47.98-.97 1.21C7.85 18.75 7 20.24 7 22"/><path d="M14 14.66V17c0 .55.47.98.97 1.21C16.15 18.75 17 20.24 17 22"/><path d="M18 2H6v7a6 6 0 0 0 12 0V2Z"/></svg>'

function svgIcon(name) {
  const icons = {
    trophy:   SVG_TROPHY,
    calendar: '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#3b82f6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><path d="M16 2v4"/><path d="M8 2v4"/><path d="M3 10h18"/></svg>',
    shirt:    '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8b5cf6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.38 3.46 16 2a4 4 0 0 1-8 0L3.62 3.46a2 2 0 0 0-1.34 2.23l.58 3.47a1 1 0 0 0 .99.84H6v10c0 1.1.9 2 2 2h8a2 2 0 0 0 2-2V10h2.15a1 1 0 0 0 .99-.84l.58-3.47a2 2 0 0 0-1.34-2.23z"/></svg>',
    shield:   '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#06b6d4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"/></svg>',
    target:   '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#22c55e" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="6"/><circle cx="12" cy="12" r="2"/></svg>',
    star:     '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#ca8a04" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>',
    flame:    '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#f97316" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z"/></svg>',
  }
  return icons[name] || ''
}

/* ====== Helpers ====== */
function partPct(row) {
  return daysCount.value ? Math.round((row.participations || 0) * 100 / daysCount.value) : 0
}

function winPct(row) {
  const a = aggMap.value.get(row.id)
  if (!a || !a.J) return 0
  return Math.round(a.V * 100 / a.J)
}

function formChars(row) {
  const a = aggMap.value.get(row.id)
  return (a?.form || []).slice(-5)
}

function fmtDate(d) {
  if (!d) return '—'
  try {
    return new Date(d + 'T12:00:00').toLocaleDateString('fr-FR', {
      weekday: 'long', day: '2-digit', month: 'long', year: 'numeric'
    })
  } catch (_) { return d }
}

/* ====== Lifecycle ====== */
onMounted(async () => {
  await loadPlayerRoles()
  await loadSeasons()
})

async function loadPlayerRoles() {
  try {
    const { data } = await api.get('/players')
    playersAll.value = data.players || []
    roleById.value = new Map(
      playersAll.value.map(p => [String(p.player_id), String(p.role || 'MEMBRE').toUpperCase()])
    )
    rolesLoaded.value = true
  } catch (_) {
    rolesLoaded.value = false
  }
}

function isInviteId(id) {
  return String(id || '').startsWith('G_')
}

function isInviteRow(row) {
  const id = String(row?.id || '')
  if (!id) return false
  if (isInviteId(id)) return true
  const rowRole = String(row?.role || '').toUpperCase()
  if (rowRole === 'INVITE') return true
  if (roleById.value.has(id)) return roleById.value.get(id) === 'INVITE'
  return rolesLoaded.value // joueur non enregistré => considéré invité/éphémère
}

/* ====== Data loading ====== */
async function loadSeasons() {
  try {
    const previousSeason = selectedSeason.value
    const { data } = await api.get('/seasons')
    seasons.value = data.seasons || []
    const canKeepPrevious = seasons.value.some((s) => s.id === previousSeason)
    if (canKeepPrevious) selectedSeason.value = previousSeason
    else {
      const current = seasons.value.find(s => !s.is_closed) || seasons.value[0]
      if (current) selectedSeason.value = current.id
    }
    if (selectedSeason.value) await load()
  } catch (_) {}
}

async function onSeasonChange() {
  await load()
}

async function load() {
  if (!selectedSeason.value) return
  loading.value = true
  try {
    const [stRes, daysRes] = await Promise.all([
      api.get(`/seasons/${selectedSeason.value}/standings`),
      api.get(`/seasons/${selectedSeason.value}/matchdays`)
    ])
    standingsData.value = stRes.data.standings || []
    const days = daysRes.data.days || []
    daysCount.value = days.length
    confirmedDays.value = [...days].reverse()
    // Membres classés (depuis le classement de la saison)
    const list = standingsData.value
      .filter(r => !isInviteRow(r))
      .map(r => ({ id: r.id, name: r.name || r.id, invite: false }))
    // + Invités (absents des standings car non classés) depuis /players
    const seen = new Set(list.map(p => p.id))
    for (const p of playersAll.value) {
      const id = String(p.player_id)
      const isInv = String(p.role || '').toUpperCase() === 'INVITE' || isInviteId(id)
      if (isInv && !seen.has(id)) {
        list.push({ id, name: p.name || id, invite: true })
        seen.add(id)
      }
    }
    list.sort((a, b) => String(a.name).localeCompare(String(b.name), 'fr', { sensitivity: 'base' }))
    allPlayers.value = list
    // Build agg in background (non-blocking)
    aggPromise = buildSeasonAgg(days)
  } catch (_) {}
  loading.value = false
}

async function buildSeasonAgg(days) {
  const runVersion = ++aggBuildVersion
  const agg = new Map()
  const champs = new Map()
  const ensure = id => {
    if (!agg.has(id)) agg.set(id, {
      J: 0, V: 0, N: 0, D: 0, BP: 0, BC: 0, form: [], d1: 0, d2: 0,
      J_d1: 0, BP_d1: 0, BC_d1: 0, J_d2: 0, BP_d2: 0, BC_d2: 0,
    })
    return agg.get(id)
  }
  for (const day of days) {
    if (runVersion !== aggBuildVersion) return
    try {
      const { data: p } = await api.get(`/matchdays/${day}`)
      if (runVersion !== aggBuildVersion) return
      for (const div of ['d1', 'd2']) {
        for (const m of (p[div] || [])) {
          if (!m.p1 || !m.p2) continue
          const A = ensure(m.p1), B = ensure(m.p2)
          if (m.a1 != null && m.a2 != null) {
            A.J++; B.J++; A.BP += Number(m.a1); A.BC += Number(m.a2); B.BP += Number(m.a2); B.BC += Number(m.a1)
            A[`J_${div}`]++; B[`J_${div}`]++
            A[`BP_${div}`] += Number(m.a1); A[`BC_${div}`] += Number(m.a2)
            B[`BP_${div}`] += Number(m.a2); B[`BC_${div}`] += Number(m.a1)
            if (m.a1 > m.a2)      { A.V++; B.D++; A.form.push('V'); B.form.push('D') }
            else if (m.a1 < m.a2) { B.V++; A.D++; B.form.push('V'); A.form.push('D') }
            else                   { A.N++; B.N++; A.form.push('N'); B.form.push('N') }
          }
          if (m.r1 != null && m.r2 != null) {
            const A2 = ensure(m.p2), B2 = ensure(m.p1) // p2 at home in retour
            A2.J++; B2.J++; A2.BP += Number(m.r2); A2.BC += Number(m.r1); B2.BP += Number(m.r1); B2.BC += Number(m.r2)
            A2[`J_${div}`]++; B2[`J_${div}`]++
            A2[`BP_${div}`] += Number(m.r2); A2[`BC_${div}`] += Number(m.r1)
            B2[`BP_${div}`] += Number(m.r1); B2[`BC_${div}`] += Number(m.r2)
            if (m.r2 > m.r1)      { A2.V++; B2.D++; A2.form.push('V'); B2.form.push('D') }
            else if (m.r2 < m.r1) { B2.V++; A2.D++; B2.form.push('V'); A2.form.push('D') }
            else                   { A2.N++; B2.N++; A2.form.push('N'); B2.form.push('N') }
          }
          if (div === 'd1') { ensure(m.p1).d1++; ensure(m.p2).d1++ }
          else              { ensure(m.p1).d2++; ensure(m.p2).d2++ }
        }
      }
      const c1 = p?.champions?.d1, c2 = p?.champions?.d2
      if (c1?.id) {
        const arr = champs.get(c1.id) || []
        arr.push({ date: day, div: 'D1', team: c1.team || '' })
        champs.set(c1.id, arr)
      }
      if (c2?.id) {
        const arr = champs.get(c2.id) || []
        arr.push({ date: day, div: 'D2', team: c2.team || '' })
        champs.set(c2.id, arr)
      }
    } catch (_) {}
  }
  if (runVersion !== aggBuildVersion) return
  aggMap.value = agg
  championsByPlayer.value = champs
}

/* ====== Day actions ====== */
async function viewDay() {
  if (!selectedDay.value) return
  dayPayloadData.value = null
  dayModal.value = true
  try {
    const { data } = await api.get(`/matchdays/${selectedDay.value}`)
    dayPayloadData.value = data
  } catch (_) {}
}

function goEditDay() {
  if (!selectedDay.value) return
  router.push({ path: '/', query: { day: selectedDay.value } })
}

function escapeHtml(value) {
  return String(value ?? '').replace(/[&<>"']/g, (m) => ({
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;',
  }[m]))
}

function displayNameOf(id) {
  const key = String(id || '')
  if (!key) return ''
  const inStandings = standingsData.value.find((r) => String(r.id) === key)
  return inStandings?.name || key
}

function computeStandingsDay(rows) {
  const agg = {}
  const add = (A, B, ga, gb) => {
    if (ga == null || gb == null) return
    if (!agg[A]) agg[A] = { J: 0, V: 0, N: 0, D: 0, BP: 0, BC: 0 }
    if (!agg[B]) agg[B] = { J: 0, V: 0, N: 0, D: 0, BP: 0, BC: 0 }
    agg[A].J += 1; agg[B].J += 1
    agg[A].BP += ga; agg[A].BC += gb
    agg[B].BP += gb; agg[B].BC += ga
    if (ga > gb) { agg[A].V += 1; agg[B].D += 1 }
    else if (ga < gb) { agg[B].V += 1; agg[A].D += 1 }
    else { agg[A].N += 1; agg[B].N += 1 }
  }
  for (const m of (rows || [])) {
    if (!m.p1 || !m.p2) continue
    if (m.a1 != null && m.a2 != null) add(m.p1, m.p2, m.a1, m.a2)
    if (m.r1 != null && m.r2 != null) add(m.p2, m.p1, m.r2, m.r1)
  }
  const arr = Object.entries(agg).map(([id, x]) => ({
    id,
    ...x,
    PTS: x.V * 3 + x.N,
    DIFF: x.BP - x.BC,
    role: isInviteId(id) ? 'INVITE' : (roleById.value.get(String(id)) || 'MEMBRE'),
  }))
  arr.sort((a, b) =>
    b.PTS - a.PTS ||
    b.DIFF - a.DIFF ||
    b.BP - a.BP ||
    String(a.id).localeCompare(String(b.id), 'fr', { sensitivity: 'base' })
  )
  return arr
}

function splitAndRankDaily(st) {
  const main = st.filter((x) => String(x.role || '').toUpperCase() !== 'INVITE')
  const inv = st.filter((x) => String(x.role || '').toUpperCase() === 'INVITE')
  main.forEach((r, idx) => { r.RANK = idx + 1 })
  inv.forEach((r) => { r.RANK = '—' })
  return { main, inv }
}

async function logoDataURL() {
  const tryFetch = async (path) => {
    if (!path) return null
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
  const logoPath = mediaUrl(site.settings.brand.logo)
  return (await tryFetch(logoPath))
    || (await tryFetch('/assets/logo.png'))
    || (await tryFetch('/assets/icons/apple-touch-icon.png'))
    || (await tryFetch('assets/logo.png'))
    || (await tryFetch('assets/icons/apple-touch-icon.png'))
}

async function printSelectedDay() {
  if (!selectedDay.value) return
  try {
    const { data: payload } = await api.get(`/matchdays/${selectedDay.value}`)
    const day = selectedDay.value

    const st1 = computeStandingsDay(payload?.d1 || [])
    const st2 = computeStandingsDay(payload?.d2 || [])
    const { main: main1, inv: inv1 } = splitAndRankDaily(st1)
    const { main: main2, inv: inv2 } = splitAndRankDaily(st2)

    const css = '@page{size:A4;margin:12mm;}body{font:12px/1.35 "Segoe UI",Roboto,Arial,sans-serif;color:#111;}h1{font-size:18px;margin:0 0 8px;display:flex;align-items:center;gap:8px}h1 img{height:28px} h2{font-size:14px;margin:10px 0 6px;} .tbl{width:100%;border-collapse:collapse;border:1px solid #444;} .tbl th,.tbl td{border:1px solid #444;padding:4px 6px;text-align:center} .tbl thead th{background:#efefef;} .champ{text-align:center;margin:6px 0 10px;font-weight:900;color:#cc0000;font-size:17px;} .verdict{margin-top:8px;font-weight:800;color:#1d4ed8;text-align:center;font-size:15px;} .sepRow td{background:#f7f7f7;font-style:italic}'

    const renderMatches = (rows) => {
      let h = '<table class="tbl"><thead><tr><th>Domicile</th><th>Extérieur</th><th>Aller</th><th>Retour</th></tr></thead><tbody>'
      for (const m of (rows || [])) {
        const a = (m.a1 != null || m.a2 != null) ? `${m.a1 ?? ''} - ${m.a2 ?? ''}` : ''
        const r = (m.r1 != null || m.r2 != null) ? `${m.r1 ?? ''} - ${m.r2 ?? ''}` : ''
        h += `<tr><td>${escapeHtml(m.p1 || '')}</td><td>${escapeHtml(m.p2 || '')}</td><td>${escapeHtml(a)}</td><td>${escapeHtml(r)}</td></tr>`
      }
      return h + '</tbody></table>'
    }

    const renderStand = (title, mainRows, invRows) => {
      let h = `<h2>${escapeHtml(title)}</h2><table class="tbl"><thead><tr><th>Rang</th><th>Nom</th><th>ID</th><th>J</th><th>V</th><th>N</th><th>D</th><th>BM</th><th>BC</th><th>Diff</th><th>PTS</th></tr></thead><tbody>`
      const row = (r) => `<tr><td>${r.RANK}</td><td>${escapeHtml(displayNameOf(r.id))}</td><td>${escapeHtml(r.id)}</td><td>${r.J}</td><td>${r.V}</td><td>${r.N}</td><td>${r.D}</td><td>${r.BP}</td><td>${r.BC}</td><td>${r.DIFF}</td><td>${r.PTS}</td></tr>`
      for (const r of mainRows) h += row(r)
      if (invRows.length) {
        h += '<tr class="sepRow"><td colspan="11">Invités (non classés)</td></tr>'
        for (const r of invRows) h += row(r)
      }
      return h + '</tbody></table>'
    }

    const c1 = payload?.champions?.d1 || {}
    const c2 = payload?.champions?.d2 || {}
    const team1 = (c1.team || '').toUpperCase() || '—'
    const team2 = (c2.team || '').toUpperCase() || '—'
    const logo = await logoDataURL()

    let html = `<!doctype html><html lang="fr"><head><meta charset="utf-8"/><title>Résultats — ${day}</title><style>${css}</style></head><body onload="window.print()">`
    html += `<h1>${logo ? `<img src="${logo}" alt="logo">` : ''}GOUZEPE GAMING CLUB — Journée du ${new Date(day).toLocaleDateString('fr-FR')}</h1>`
    html += '<h2>SCORES D1</h2>' + renderMatches(payload?.d1 || [])
    html += `<div class="champ">${SVG_TROPHY} ${escapeHtml(c1.id || '—')} — CHAMPION avec ${escapeHtml(team1)}</div>`
    html += renderStand('CLASSEMENT D1', main1, inv1)
    html += '<h2>SCORES D2</h2>' + renderMatches(payload?.d2 || [])
    html += `<div class="champ">${SVG_TROPHY} ${escapeHtml(c2.id || '—')} — CHAMPION avec ${escapeHtml(team2)}</div>`
    html += renderStand('CLASSEMENT D2', main2, inv2)

    const printBarrageAffiche = payload?.barrage?.ids || '—'
    const printBarrageWinner = payload?.barrage?.winner ? displayNameOf(payload.barrage.winner) : '—'
    html += '<h2>BARRAGES</h2><table class="tbl"><thead><tr><th>Affiche</th><th>Gagnant</th></tr></thead><tbody>'
    html += `<tr><td>${escapeHtml(printBarrageAffiche)}</td><td style="font-weight:700;color:#16a34a">${escapeHtml(printBarrageWinner)}</td></tr></tbody></table>`
    html += `<div class="verdict">*** ${escapeHtml(payload?.barrage?.label || '—')}</div>`
    if (payload?.barrage?.notes) {
      html += `<div style="margin-top:8px"><b>Notes :</b><br>${escapeHtml(payload.barrage.notes).replace(/\r?\n/g, '<br>')}</div>`
    }
    html += '</body></html>'

    const url = URL.createObjectURL(new Blob([html], { type: 'text/html' }))
    const w = window.open(url, '_blank')
    if (!w) { toastError('Popup bloquée. Autorise les popups pour imprimer.'); return }
    w.addEventListener('unload', () => URL.revokeObjectURL(url), { once: true })
  } catch (_) {
    toastError('Erreur lors de l’impression de la journée')
  }
}

async function printSeasonA4() {
  if (aggPromise) await aggPromise
  const css = `
    @page{size:A4;margin:12mm;}
    body{font:12px/1.4 Segoe UI,Roboto,Arial,sans-serif;color:#111;}
    h1{font-size:18px;margin:0 0 6px;display:flex;align-items:center;gap:8px}
    h1 img{height:26px}
    h2{font-size:13px;margin:14px 0 5px;font-weight:700}
    table{width:100%;border-collapse:collapse;border:1px solid #ccc}
    th,td{border:1px solid #ccc;padding:4px 6px;text-align:center}
    thead th{background:#f0f0f0;font-weight:700}
    .muted{color:#64748b;font-size:11px;margin-bottom:10px}
    .bilan{margin-top:18px;page-break-inside:avoid}
    .champion-box{
      display:flex;flex-direction:column;align-items:center;justify-content:center;
      padding:14px 16px;border-radius:8px;text-align:center;
      background:#fffbeb;border:2px solid #ca8a04;margin-bottom:10px
    }
    .champion-box .crown{font-size:22px;line-height:1;margin-bottom:4px;font-weight:900;color:#ca8a04}
    .champ-label{font-size:9px;font-weight:800;letter-spacing:.1em;color:#92400e;text-transform:uppercase}
    .champ-name{font-size:20px;font-weight:900;color:#78350f;line-height:1.1}
    .champ-id{font-size:11px;color:#92400e}
    .champ-stats{font-size:10px;color:#a16207;margin-top:3px}
    .highlights{display:grid;grid-template-columns:repeat(5,1fr);gap:6px}
    .hl-card{border:1px solid #ccc;border-radius:6px;padding:8px 5px;text-align:center;background:#fafafa}
    .hl-icon{font-size:16px;line-height:1;margin-bottom:2px}
    .hl-title{font-size:8px;font-weight:700;text-transform:uppercase;letter-spacing:.06em;color:#64748b}
    .hl-name{font-size:11px;font-weight:800;color:#111;margin-top:3px;word-break:break-word}
    .hl-id{font-size:9px;color:#64748b}
    .hl-detail{font-size:9px;color:#94a3b8;margin-top:2px}
    .div-breakdown{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-top:12px}
    .div-block{border:1px solid #ddd;border-radius:8px;padding:8px;background:#fff}
    .div-block h3{font-size:11px;margin:0 0 6px;font-weight:800;text-transform:uppercase;letter-spacing:.06em;color:#334155}
    .div-block .highlights{grid-template-columns:repeat(3,1fr)}
  `
  const logo = await logoDataURL()

  const headRow = () => {
    let h = '<tr><th>#</th><th>Nom</th><th>ID</th><th>Total</th><th>Particip.</th><th>D1</th><th>D2</th><th>Moyenne</th><th>Titres D1</th><th>Titres D2</th><th>Équipes diff.</th>'
    if (showWin.value)  h += '<th>Vict. %</th>'
    if (showForm.value) h += '<th>Forme (5)</th>'
    return h + '</tr>'
  }

  const rowsHTML = (rows) => rows.map((p, i) => {
    const a = aggMap.value.get(p.id) || {}
    let r = `<tr><td>${i + 1}</td><td>${escapeHtml(p.name || p.id || '')}</td><td>${escapeHtml(p.id || '')}</td><td>${p.total ?? 0}</td><td>${p.participations ?? 0}</td><td>${a.d1 || 0}</td><td>${a.d2 || 0}</td><td>${(p.moyenne || 0).toFixed(2)}</td><td>${p.won_d1 ?? 0}</td><td>${p.won_d2 ?? 0}</td><td>${p.teams_used ?? 0}</td>`
    if (showWin.value)  r += `<td>${winPct(p)}%</td>`
    if (showForm.value) r += `<td>${escapeHtml(formChars(p).join(''))}</td>`
    return r + '</tr>'
  }).join('')

  // Bilan section
  const hl = seasonHighlights.value
  let bilanHtml = ''
  if (hl) {
    const champ = hl.champion
    bilanHtml += `
    <div class="bilan">
      <h2>Bilan de la saison</h2>
      <div class="champion-box">
        <div class="crown">${SVG_TROPHY.replace('width="16"','width="28"').replace('height="16"','height="28"')}</div>
        <div>
          <div class="champ-label">Champion de la saison</div>
          <div class="champ-name">${escapeHtml(champ.name || champ.id)}</div>
          <div class="champ-id">(${escapeHtml(champ.id)})</div>
          <div class="champ-stats">${champ.total ?? 0} pts &bull; ${champ.participations ?? 0} particip. &bull; moy. ${Number(champ.moyenne || 0).toFixed(2)} &bull; ${champ.won_d1 ?? 0} titre(s) D1</div>
        </div>
      </div>
      <div class="highlights">`
    for (const card of hl.highlights) {
      const names = (card.players || []).map(p => escapeHtml(p.name || p.id)).join(' &amp; ')
      const ids   = (card.players || []).map(p => '(' + escapeHtml(p.id) + ')').join(' &amp; ')
      bilanHtml += `
        <div class="hl-card">
          <div class="hl-icon">${card.icon}</div>
          <div class="hl-title">${escapeHtml(card.title)}</div>
          <div class="hl-name">${names || '—'}</div>
          <div class="hl-id">${ids}</div>
          <div class="hl-detail">${escapeHtml(card.detail)}</div>
        </div>`
    }
    bilanHtml += '</div>'

    // Détails par division (D1 / D2)
    const dh = seasonDivisionHighlights.value
    if (dh) {
      const renderDivCard = (card) => {
        const names = (card.players || []).map(p => escapeHtml(p.name || p.id)).join(' &amp; ')
        const ids   = (card.players || []).map(p => '(' + escapeHtml(p.id) + ')').join(' &amp; ')
        return `
          <div class="hl-card">
            <div class="hl-icon">${card.icon}</div>
            <div class="hl-title">${escapeHtml(card.title)}</div>
            <div class="hl-name">${names || '—'}</div>
            <div class="hl-id">${ids}</div>
            <div class="hl-detail">${escapeHtml(card.detail)}</div>
          </div>`
      }
      const renderDivBlock = (label, d) => `
        <div class="div-block">
          <h3>Détails ${label}</h3>
          <div class="highlights">
            ${renderDivCard(d.titles)}${renderDivCard(d.defense)}${renderDivCard(d.attack)}
          </div>
        </div>`
      bilanHtml += `<div class="div-breakdown">${renderDivBlock('D1', dh.d1)}${renderDivBlock('D2', dh.d2)}</div>`
    }

    bilanHtml += '</div>'
  }

  const seasonLabel = currentSeasonName.value || 'Saison'
  let html = `<!doctype html><html><head><meta charset="utf-8"><title>Classement — ${escapeHtml(seasonLabel)}</title><style>${css}</style></head><body onload="window.print()">`
  html += `<h1>${logo ? `<img src="${logo}" alt="logo">` : ''}Classement Général — ${escapeHtml(seasonLabel)}</h1>`
  html += `<div class="muted">Seuil de classement : ${threshold.value} participations (25% des journées) &bull; Journées: ${daysCount.value}</div>`
  html += `<h2>Classés</h2><table><thead>${headRow()}</thead><tbody>${rowsHTML(classedRows.value)}</tbody></table>`
  html += `<h2>Non classés</h2><table><thead>${headRow()}</thead><tbody>${rowsHTML(unclassedRows.value)}</tbody></table>`
  html += bilanHtml
  html += '</body></html>'

  const url = URL.createObjectURL(new Blob([html], { type: 'text/html' }))
  const w = window.open(url, '_blank')
  if (!w) { toastError('Popup bloquée. Autorise les popups pour imprimer.'); return }
  w.addEventListener('unload', () => URL.revokeObjectURL(url), { once: true })
}

async function deleteDay() {
  if (!selectedDay.value) return
  if (!confirm(`Supprimer définitivement la Journée du ${fmtDate(selectedDay.value)} ?`)) return
  try {
    await api.delete(`/matchdays/${selectedDay.value}`)
    success('Journée supprimée')
    selectedDay.value = ''
    await load()
  } catch (_) {
    toastError('Erreur lors de la suppression')
  }
}

/* ====== Compare ====== */
const SOURCE_META = {
  journee: { label: 'Journées', short: 'Journée', bg: 'rgba(37,99,235,.15)',  fg: '#60a5fa' },
  tournoi: { label: 'Tournois', short: 'Tournoi', bg: 'rgba(168,85,247,.18)', fg: '#c084fc' },
  duel:    { label: 'Duels',    short: 'Duel',    bg: 'rgba(148,163,184,.18)', fg: 'var(--muted)' },
}

const sourceBreakdown = computed(() => {
  const bs = cmpResult.value?.h2h?.bySource || {}
  return ['journee', 'tournoi', 'duel'].map(key => ({
    key,
    label: SOURCE_META[key].label,
    legs:  bs[key]?.legs || 0,
    wins1: bs[key]?.wins1 || 0,
    draws: bs[key]?.draws || 0,
    wins2: bs[key]?.wins2 || 0,
  }))
})

function sourceShort(s) { return SOURCE_META[s]?.short || s || '—' }
function sourceBadge(s) {
  const m = SOURCE_META[s] || SOURCE_META.duel
  return `background:${m.bg};color:${m.fg}`
}

function openCompareModal() {
  cmpResult.value = null
  compareModal.value = true
}

/* ====== Tournois de la saison ====== */
const FORMAT_LABELS = {
  single_elimination: 'Élimination directe',
  double_elimination: 'Double élimination',
  round_robin: 'Round Robin',
  groups_knockout: 'Groupes + phase finale',
}
function formatTitleLabel(f) { return FORMAT_LABELS[f] || f || '' }

// Plus récents en premier (la liste API est triée par date croissante)
const tournamentsOrdered = computed(() => [...tournamentsList.value].reverse())
const activeTournament = computed(() =>
  tournamentsList.value.find(t => t.id === activeTournamentId.value) || null)

async function openTournamentsModal() {
  tournamentsModal.value = true
  activeTournamentId.value = null
  if (!selectedSeason.value) { tournamentsList.value = []; return }
  tournamentsLoading.value = true
  try {
    const { data } = await api.get(`/seasons/${selectedSeason.value}/tournaments-breakdown`)
    tournamentsList.value = data.tournaments || []
    activeTournamentId.value = tournamentsOrdered.value[0]?.id ?? null
  } catch (_) {
    tournamentsList.value = []
    toastError('Erreur lors du chargement des tournois')
  } finally {
    tournamentsLoading.value = false
  }
}

async function runCompare() {
  if (!cmpA.value || !cmpB.value) return
  cmpLoading.value = true
  cmpResult.value = null
  try {
    const pA = allPlayers.value.find(p => p.id === cmpA.value)
    const pB = allPlayers.value.find(p => p.id === cmpB.value)
    const sA = standingsData.value.find(r => r.id === cmpA.value) || {}
    const sB = standingsData.value.find(r => r.id === cmpB.value) || {}
    const aggA = aggMap.value.get(cmpA.value) || {}
    const aggB = aggMap.value.get(cmpB.value) || {}

    // H2H : journées + tournois + duels
    let h2h = { total: 0, p1: { wins:0, draws:0, losses:0, gf:0, ga:0 }, p2: { wins:0, draws:0, losses:0, gf:0, ga:0 }, byDiv: {}, bySource: {}, recent: [] }
    try {
      const { data } = await api.get('/players/h2h', {
        params: { p1: cmpA.value, p2: cmpB.value, season: selectedSeason.value || '' }
      })
      h2h = {
        total:    data.total_legs || 0,
        p1:       data.p1 || {},
        p2:       data.p2 || {},
        byDiv:    data.by_division || {},
        bySource: data.by_source || {},
        recent:   data.recent || [],
      }
    } catch (_) {}

    cmpResult.value = {
      nameA: pA?.name || cmpA.value,
      nameB: pB?.name || cmpB.value,
      rows: [
        { label: 'Total de points',     a: sA.total ?? 0,                       b: sB.total ?? 0,                       desc: true },
        { label: 'Moyenne / participation', a: Number(sA.moyenne || 0).toFixed(2),  b: Number(sB.moyenne || 0).toFixed(2),  desc: true, numeric: true },
        { label: 'Participations',      a: sA.participations ?? 0,              b: sB.participations ?? 0,              desc: true },
        { label: 'Journées D1',         a: aggA.d1 ?? 0,                        b: aggB.d1 ?? 0,                        desc: true },
        { label: 'Journées D2',         a: aggA.d2 ?? 0,                        b: aggB.d2 ?? 0,                        desc: true },
        { label: 'Titres D1',           a: sA.won_d1 ?? 0,                      b: sB.won_d1 ?? 0,                      desc: true },
        { label: 'Titres D2',           a: sA.won_d2 ?? 0,                      b: sB.won_d2 ?? 0,                      desc: true },
        { label: 'Équipes différentes', a: sA.teams_used ?? 0,                  b: sB.teams_used ?? 0,                  desc: true },
        { label: 'Win %',               a: winPct(sA) + '%',                    b: winPct(sB) + '%',                    desc: true, numeric: true },
        { label: 'Forme (5 derniers)',  a: formChars(sA).join(' ') || '—',     b: formChars(sB).join(' ') || '—',     desc: null },
      ],
      h2h,
    }
  } catch (e) {
    toastError('Erreur lors de la comparaison')
  }
  cmpLoading.value = false
}

/* ====== Player titles ====== */
function openPlayerTitles(row) {
  titlesFilter.value = 'all'
  playerTitles.value = row
}

/* ====== Create season ====== */
async function createSeason() {
  if (!newSeasonName.value.trim()) return
  creatingSeason.value = true
  try {
    await api.post('/seasons', { name: newSeasonName.value.trim() })
    success('Saison créée')
    newSeasonName.value = ''
    newSeasonModal.value = false
    await loadSeasons()
  } catch (e) {
    toastError('Erreur lors de la création')
  }
  creatingSeason.value = false
}
</script>

<style scoped>
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
  opacity: 0.24;
  filter: saturate(0.95) contrast(1.05);
}

:root.light .bg-video {
  opacity: 0.08;
  filter: saturate(0.8) contrast(1);
}

:root.light .bg-overlay {
  background:
    radial-gradient(58vw 48vh at 10% 0%, rgba(93, 116, 185, 0.08), transparent 62%),
    radial-gradient(58vw 52vh at 88% 100%, rgba(111, 132, 200, 0.07), transparent 62%);
}

:root.light .bg-vignette {
  background: linear-gradient(180deg, rgba(238, 241, 246, 0.6), rgba(238, 241, 246, 0.76));
}

.bg-overlay {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(60vw 50vh at 10% 0%, rgba(59, 130, 246, 0.2), transparent 58%),
    radial-gradient(60vw 55vh at 88% 100%, rgba(34, 197, 94, 0.16), transparent 58%);
}

.bg-vignette {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(2, 6, 23, 0.52), rgba(2, 6, 23, 0.66));
}

.classement-wrap {
  position: relative;
  z-index: 1;
  width: 100%;
}

.table-shell {
  border: 1px solid rgba(148, 163, 184, 0.22);
  border-radius: 12px;
  background: color-mix(in srgb, var(--card) 90%, transparent);
  overflow-x: auto;
  overflow-y: hidden;
  -webkit-overflow-scrolling: touch;
  transition: border-color 180ms ease, box-shadow 180ms ease, transform 180ms ease;
}

.table-shell:hover {
  border-color: color-mix(in srgb, var(--border) 68%, #60a5fa 32%);
  box-shadow: 0 10px 24px rgba(2, 6, 23, 0.2);
  transform: translateY(-1px);
}

.controls-bar,
.controls-meta,
.controls-day {
  position: relative;
}

:root.light .controls-bar,
:root.light .controls-meta,
:root.light .controls-day {
  background: rgba(255, 255, 255, 0.92);
  border: 1px solid rgba(33, 51, 98, 0.14);
  border-radius: 12px;
  padding: 10px 12px;
  box-shadow: 0 6px 14px rgba(14, 27, 58, 0.08);
}

:root.light .controls-meta p,
:root.light .controls-day span {
  color: #495d87 !important;
}

:root.light .table-shell {
  background: rgba(255, 255, 255, 0.97);
  border-color: rgba(33, 51, 98, 0.16);
  box-shadow: 0 6px 16px rgba(15, 26, 56, 0.07);
}

:root.light .table-shell :deep(.data-table thead th) {
  color: #50638e;
  background: rgba(93, 116, 185, 0.07);
  border-bottom: 1px solid rgba(93, 116, 185, 0.2);
}

:root.light .table-shell :deep(.data-table tbody td) {
  color: #1b2746;
  border-bottom: 1px solid rgba(33, 51, 98, 0.1);
}

.table-shell :deep(.data-table thead th) {
  border-bottom: 1px solid rgba(148, 163, 184, 0.24);
}

.table-shell :deep(.data-table tbody td) {
  border-bottom: 1px solid rgba(148, 163, 184, 0.12);
}

.table-shell :deep(.data-table th.text-center),
.table-shell :deep(.data-table td.text-center) {
  text-align: center !important;
}

.table-shell :deep(.data-table tbody tr:last-child td) {
  border-bottom: none;
}

.name-cell {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
  min-width: 0;
}

.reveal {
  animation: rise-in 460ms ease both;
}

.delay-1 {
  animation-delay: 90ms;
}

.delay-2 {
  animation-delay: 160ms;
}

@keyframes rise-in {
  from {
    opacity: 0;
    transform: translateY(8px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@media (min-width: 1024px) {
  .classement-wrap {
    max-width: none;
    padding: clamp(14px, 2.1vw, 30px);
  }
}

@media (max-width: 1023px) {
  .classement-wrap {
    max-width: 80rem;
    margin: 0 auto;
    padding: 1.5rem 1rem;
  }
}

@media (min-width: 640px) and (max-width: 1023px) {
  .classement-wrap {
    padding: 1.5rem 1.5rem;
  }
}

@media (prefers-reduced-motion: reduce) {
  .reveal {
    animation: none !important;
  }

  .table-shell {
    transition: none !important;
  }
}

.rank-medal {
  display: inline-flex; align-items: center; justify-content: center;
  width: 22px; height: 22px; border-radius: 50%; font-size: 11px; font-weight: 800;
}
.rank-gold   { background: #ca8a04; color: #fff; }
.rank-silver { background: #94a3b8; color: #fff; }
.rank-bronze { background: #b45309; color: #fff; }

/* Meilleures séries */
.streak-list { display: flex; flex-direction: column; gap: .35rem; }
.streak-row {
  display: flex; align-items: center; gap: .7rem;
  padding: .5rem .65rem; border-radius: 9px;
  border: 1px solid color-mix(in srgb, var(--border) 55%, transparent);
  background: color-mix(in srgb, var(--panel) 55%, transparent);
}
.streak-rank {
  flex: none; width: 1.6rem; height: 1.6rem; display: grid; place-items: center;
  border-radius: 50%; font-weight: 800; font-size: .78rem; color: var(--muted);
  background: color-mix(in srgb, var(--panel) 70%, transparent); border: 1px solid var(--border);
}
.streak-rank.gold { color: #fff; background: linear-gradient(135deg, #f59e0b, #ca8a04); border-color: transparent; }
.streak-name { font-weight: 600; font-size: .9rem; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.streak-id { font-size: .72rem; color: var(--muted); }
.streak-val { flex: none; font-family: var(--font-title); font-weight: 800; font-size: 1rem; font-variant-numeric: tabular-nums; }
.streak-val.gold { color: #f59e0b; }
.streak-val small { font-size: .58rem; font-weight: 600; color: var(--muted); margin-left: .2rem; }

</style>

