# 🏆 Section Tournois - Documentation

## Vue d'ensemble

La section Tournois de GOUZEPE eFOOTBALL permet de créer et gérer des tournois d'eFootball avec des fonctionnalités similaires à **Challonge** et **start.gg**. Le système supporte plusieurs formats de tournois et offre une gestion complète du bracket, des participants et des résultats.

## 🎯 Fonctionnalités

### Formats de tournois supportés

1. **Simple Élimination (Single Elimination)**
   - Format classique à élimination directe
   - Un joueur éliminé après une défaite
   - Option pour match de 3ème place

2. **Double Élimination (Double Elimination)**
   - Bracket Winner's (upper) et Loser's (lower)
   - Deux défaites nécessaires pour élimination
   - Grand Finals entre les vainqueurs de chaque bracket

3. **Round Robin (Championnat)**
   - Tous les joueurs s'affrontent
   - Classement basé sur victoires/défaites et différence de points
   - Idéal pour petits groupes (4-8 joueurs)

### Pour tous les utilisateurs

- ✅ Visualisation des tournois actifs et passés
- ✅ Consultation des brackets en temps réel
- ✅ Affichage du classement des participants
- ✅ Historique complet des matchs
- ✅ Notifications temps réel via Socket.IO
- ✅ Interface responsive (mobile et desktop)

### Pour les administrateurs

- ✅ Création et configuration de tournois
- ✅ Gestion des participants (ajout/retrait)
- ✅ Génération automatique des brackets
- ✅ Saisie des résultats des matchs
- ✅ Progression automatique dans les brackets
- ✅ Statistiques détaillées

## 📖 Guide d'utilisation

### Pour les joueurs

#### 1. Consulter les tournois

1. Connectez-vous à votre compte
2. Cliquez sur **🏆 Tournois** dans le menu de navigation
3. Parcourez la liste des tournois disponibles
4. Filtrez par statut (En cours, Terminé, etc.) ou format

#### 2. Voir les détails d'un tournoi

1. Cliquez sur une carte de tournoi
2. Consultez les onglets :
   - **📊 Bracket** : Visualisation de l'arbre du tournoi
   - **🏅 Classement** : Positions et statistiques des participants
   - **⚔️ Matchs** : Liste détaillée de tous les matchs

### Pour les administrateurs

#### 1. Créer un tournoi

1. Accédez à **Admin Tournois** via le menu admin
2. Remplissez le formulaire :
   - **Nom** : Nom du tournoi (ex: "Tournoi Hiver 2024")
   - **Format** : Choisir entre Simple Élimination, Double Élimination ou Round Robin
   - **Statut** : Brouillon, Inscriptions ouvertes, En cours, etc.
   - **Participants max** : Limite optionnelle
   - **Description** : Informations additionnelles
   - **Match 3ème place** : Cocher si souhaité (non applicable pour Round Robin)
3. Cliquez sur **💾 Enregistrer**

#### 2. Ajouter des participants

1. Dans la liste des tournois, cliquez sur **👥 Participants**
2. Recherchez les joueurs dans la colonne de gauche
3. Cliquez sur un joueur pour l'ajouter au tournoi
4. Les participants apparaissent dans la colonne de droite
5. Pour retirer un participant, cliquez sur son nom dans la colonne de droite

#### 3. Générer le bracket

1. Une fois tous les participants ajoutés, cliquez sur **🎯 Générer le Bracket**
2. Le système va :
   - Assigner automatiquement des seeds (positions) aux joueurs
   - Créer tous les matchs selon le format choisi
   - Organiser le bracket de manière optimale
   - Passer le statut du tournoi à "En cours"

**Note** : Le bracket ne peut être généré qu'avec au minimum 2 participants.

#### 4. Enregistrer les résultats

1. Cliquez sur **⚔️ Matchs** à côté d'un tournoi en cours
2. Pour chaque match :
   - Entrez le score du Joueur 1
   - Entrez le score du Joueur 2
   - Cliquez sur **💾 Enregistrer**
3. Le système va automatiquement :
   - Déterminer le vainqueur
   - Mettre à jour les statistiques des joueurs
   - Faire progresser les joueurs dans le bracket suivant
   - Vérifier si le tournoi est terminé

#### 5. Terminer un tournoi

Quand tous les matchs sont joués, le système :
- Détermine automatiquement le champion
- Calcule les positions finales (1er, 2ème, 3ème)
- Passe le statut à "Terminé"
- Archive le tournoi avec toutes ses données

#### 6. Modifier ou supprimer un tournoi

1. Cliquez sur **✏️ Éditer** à côté du tournoi
2. Modifiez les informations nécessaires
3. Pour supprimer : cliquez sur **🗑️ Supprimer** (action irréversible)

**Important** : Vous ne pouvez pas modifier les participants ou le bracket une fois qu'il est généré et que des matchs ont commencé.

## 🎨 Interface utilisateur

### Page Tournois (Publique)

- **Grille de tournois** : Affichage en cartes avec informations clés
- **Filtres** : Par statut et format
- **Badges de statut** : Codes couleur pour identification rapide
  - 🔵 Bleu : Inscriptions ouvertes
  - 🟡 Jaune : En cours
  - 🟢 Vert : Terminé
  - ⚪ Gris : Brouillon
  - 🔴 Rouge : Annulé

### Page Admin Tournois

- **Formulaire de création** : Interface claire avec validation
- **Liste des tournois** : Tableau avec actions rapides
- **Modales de gestion** :
  - **Participants** : Double colonne drag-and-drop
  - **Matchs** : Formulaires de saisie de scores

### Visualisation du Bracket

- **Arbre hiérarchique** : Rounds organisés de gauche à droite
- **Cartes de match** :
  - Bordure verte : Match terminé
  - Bordure orange : Match en cours
  - Fond gris : Match en attente (TBD - To Be Determined)
- **Winner's et Loser's Bracket** : Séparés visuellement (Double Élimination)

## 🔧 Architecture technique

### Base de données

#### Table `tournaments`
```sql
- id (SERIAL PRIMARY KEY)
- name (TEXT) : Nom du tournoi
- description (TEXT) : Description
- format (TEXT) : 'single_elimination', 'double_elimination', 'round_robin'
- status (TEXT) : 'draft', 'registration', 'in_progress', 'completed', 'cancelled'
- created_at, registration_start, registration_end, start_date, end_date
- max_participants (INTEGER)
- third_place_match (BOOLEAN)
- created_by (INTEGER) : Référence users(id)
- winner_id, runner_up_id, third_place_id : Références players(player_id)
- total_matches, completed_matches (INTEGER)
```

#### Table `tournament_participants`
```sql
- id (SERIAL PRIMARY KEY)
- tournament_id (INTEGER) : Référence tournaments(id)
- player_id (TEXT) : Référence players(player_id)
- registered_at (TIMESTAMPTZ)
- seed (INTEGER) : Position de seed pour bracket
- status (TEXT) : 'registered', 'checked_in', 'disqualified', 'withdrawn'
- wins, losses, points_for, points_against (INTEGER)
- final_placement (INTEGER) : Position finale (1, 2, 3, ...)
```

#### Table `tournament_matches`
```sql
- id (SERIAL PRIMARY KEY)
- tournament_id (INTEGER)
- round, match_number (INTEGER)
- bracket_type (TEXT) : 'winners', 'losers', 'finals', 'third_place', 'round_robin'
- player1_id, player2_id (TEXT)
- prerequisite_match1_id, prerequisite_match2_id (INTEGER)
- player1_from, player2_from (TEXT) : 'winner', 'loser', 'seed'
- status (TEXT) : 'pending', 'in_progress', 'completed', 'walkover'
- player1_score, player2_score (INTEGER)
- winner_id (TEXT)
- next_match_winner_id, next_match_loser_id (INTEGER)
- next_match_winner_slot, next_match_loser_slot (TEXT) : 'player1', 'player2'
- scheduled_at, started_at, completed_at (TIMESTAMPTZ)
```

### Routes API

#### Routes publiques (authentification requise)

```
GET    /tournaments              - Liste des tournois (avec filtres)
GET    /tournaments/:id          - Détails d'un tournoi
GET    /tournaments/:id/standings - Classement du tournoi
```

#### Routes admin (role 'admin' requis)

```
POST   /tournaments                              - Créer un tournoi
PUT    /tournaments/:id                          - Modifier un tournoi
DELETE /tournaments/:id                          - Supprimer un tournoi
POST   /tournaments/:id/participants             - Ajouter un participant
DELETE /tournaments/:id/participants/:playerId   - Retirer un participant
POST   /tournaments/:id/generate-bracket         - Générer le bracket
PUT    /tournaments/:tournamentId/matches/:matchId - Enregistrer résultat
```

### Algorithmes de génération de brackets

#### Simple Élimination
```javascript
- Calcul du bracket size (puissance de 2 supérieure)
- Seeding standard (1 vs dernier, 2 vs avant-dernier, etc.)
- Génération de tous les rounds jusqu'à la finale
- Liaison automatique des matchs (winner progresse)
```

#### Double Élimination
```javascript
- Winner's Bracket identique à Single Elimination
- Loser's Bracket avec nombre de rounds = (winner_rounds - 1) * 2
- Alternance entre losers du winner's et winners du loser's
- Grand Finals entre les deux vainqueurs finaux
```

#### Round Robin
```javascript
- Génération de tous les matchs possibles (n * (n-1) / 2)
- Tous les joueurs s'affrontent une fois
- Classement final basé sur W/L et différence de points
```

### Socket.IO Events

```javascript
// Émis par le serveur
'tournament:created'         - Nouveau tournoi créé
'tournament:updated'         - Tournoi modifié
'tournament:deleted'         - Tournoi supprimé
'tournament:participant_added'   - Participant ajouté
'tournament:participant_removed' - Participant retiré
'tournament:bracket_generated'   - Bracket généré
'tournament:match_updated'       - Résultat de match enregistré

// Rooms disponibles
tournament:${id}  - Rejoindre pour recevoir les updates d'un tournoi
```

## 🚀 Installation et configuration

### Prérequis

- Node.js 14+
- PostgreSQL 12+
- Base de données EFOOTBALL existante

### Installation

1. **Les tables sont automatiquement créées** au démarrage du serveur grâce à `ensureSchema()` dans `api/server.js`

2. **Vérification manuelle** (optionnel) :
```bash
cd api
node test_db.js
```

3. **Migration manuelle** (si nécessaire) :
```bash
node db/migrate_tournaments.js
```

### Configuration

Aucune configuration supplémentaire n'est nécessaire. Le module tournois utilise :
- La même base de données PostgreSQL
- Le même système d'authentification JWT
- Le même serveur Socket.IO

## 📊 Exemples d'utilisation

### Créer un tournoi simple élimination à 8 joueurs

```javascript
// Via l'API
POST /tournaments
{
  "name": "Tournoi Printemps 2024",
  "description": "Tournoi saisonnier du club",
  "format": "single_elimination",
  "max_participants": 8,
  "third_place_match": true
}

// Ajouter 8 joueurs
POST /tournaments/1/participants
{ "player_id": "PLAYER_1" }
...

// Générer le bracket
POST /tournaments/1/generate-bracket

// Résultat : 8 matchs de 1er tour, 4 de 2ème, 2 de demi-finale, 1 finale, 1 match 3ème place
```

### Créer un tournoi round robin à 4 joueurs

```javascript
POST /tournaments
{
  "name": "Mini Tournoi",
  "format": "round_robin",
  "max_participants": 4
}

// Ajouter 4 joueurs
// Générer le bracket

// Résultat : 6 matchs (chaque joueur joue 3 matchs)
```

## 🐛 Dépannage

### Problème : Le bracket ne se génère pas
- **Vérifier** : Au moins 2 participants inscrits
- **Vérifier** : Statut du tournoi = 'draft' ou 'registration'
- **Solution** : Ajouter plus de participants

### Problème : Impossible d'enregistrer un résultat
- **Vérifier** : Les deux joueurs sont présents dans le match (pas de TBD)
- **Vérifier** : Le match est en statut 'pending'
- **Solution** : Compléter d'abord les matchs précédents

### Problème : Les joueurs ne progressent pas dans le bracket
- **Cause** : Bug dans la liaison des matchs
- **Solution** : Vérifier les champs `next_match_winner_id` et `next_match_winner_slot`

### Problème : Erreur 403 lors du push git
- **Cause** : Le nom de branche ne commence pas par 'claude/' ou ne se termine pas par le session ID
- **Solution** : Utiliser le nom de branche correct fourni

## 📝 Bonnes pratiques

### Avant de démarrer un tournoi
1. ✅ Créer le tournoi en mode "Brouillon"
2. ✅ Ajouter tous les participants
3. ✅ Vérifier les noms et seeds
4. ✅ Passer en mode "Inscriptions ouvertes" si nécessaire
5. ✅ Générer le bracket une fois prêt
6. ✅ Passer en mode "En cours"

### Pendant le tournoi
1. ✅ Enregistrer les résultats au fur et à mesure
2. ✅ Vérifier la progression automatique
3. ✅ Communiquer les horaires de matchs aux joueurs

### Après le tournoi
1. ✅ Vérifier le classement final
2. ✅ Archiver (statut "Terminé")
3. ✅ Exporter les statistiques si nécessaire

## 🔒 Sécurité

- ✅ Authentification JWT requise pour toutes les routes
- ✅ Contrôle d'accès basé sur les rôles (admin uniquement pour création/modification)
- ✅ Validation des entrées utilisateur
- ✅ Requêtes paramétrées pour prévenir les injections SQL
- ✅ Cascade des suppressions configurée correctement
- ✅ Sessions révoquées après inactivité

## 🎯 Roadmap futures améliorations

### Phase 1 (Actuel) ✅
- [x] Simple Élimination
- [x] Double Élimination
- [x] Round Robin
- [x] Interface admin complète
- [x] Visualisation des brackets

### Phase 2 (Future)
- [ ] Swiss System
- [ ] Inscription automatique des joueurs
- [ ] Horaires de matchs programmables
- [ ] Notifications email/push
- [ ] Exports PDF des brackets
- [ ] Statistiques avancées
- [ ] Système de seeds automatique basé sur ELO

### Phase 3 (Future)
- [ ] Tournois multi-phases
- [ ] Groupes + knockout stage
- [ ] Streaming integration
- [ ] Chat en direct
- [ ] Mobile app native

## 📞 Support

Pour toute question ou problème :
1. Consulter cette documentation
2. Vérifier les logs du serveur (`logs/api.log`)
3. Contacter l'administrateur système

## 🏅 Crédits

Développé pour GOUZEPE eFOOTBALL par Claude (Anthropic)
Compatible avec Challonge et start.gg workflows

---

**Version**: 1.0.0
**Dernière mise à jour**: 2024-12-03
