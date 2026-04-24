# Déploiement 100% gratuit — Guide complet

Stack retenue pour une démo courte (1 jour) :

| Composant | Hébergeur | Plan gratuit |
|---|---|---|
| Frontend Vue/Vite | **Vercel** | Illimité |
| API Node.js + Socket.IO | **Render** | 750h/mois, endort après 15 min d'inactivité |
| PostgreSQL | **Neon** | 0.5 Go, toujours en ligne |

**Limites à connaître :**
- L'API Render s'endort après 15 min sans trafic → première requête réveille le serveur (~30s de latence). Pour la démo : fais une requête 1 min avant l'ouverture.
- Render free : **pas de stockage persistant**. Les photos uploadées et les backups SQL disparaissent à chaque redémarrage. OK pour une démo d'un jour.
- Neon : 0.5 Go max, largement suffisant pour la démo.

---

## 0 — Correction préalable dans le code

Le fichier `frontend/src/composables/useRealtimeSocket.js` force le port `:3005`, ce qui ne marche pas sur Render (pas de port custom en HTTPS). Il faut qu'il utilise la même URL que l'API.

**Remplacer la fonction `resolveApiBase()` (lignes 4-9) par :**

```js
function resolveApiBase() {
  if (import.meta.env.VITE_API_URL) return import.meta.env.VITE_API_URL
  const fromStorage = (typeof localStorage !== 'undefined' && localStorage.getItem('efoot.api')) || ''
  if (fromStorage) return fromStorage
  if (typeof window !== 'undefined') return `${window.location.protocol}//${window.location.hostname}:3005`
  return 'http://localhost:3005'
}
```

---

## 1 — Base de données sur Neon

1. Aller sur [console.neon.tech](https://console.neon.tech) → **Sign up** (compte GitHub le plus rapide)
2. **Create Project** :
   - Nom : `gouzepe-efoot`
   - Postgres version : **17**
   - Region : **Frankfurt (eu-central-1)** (plus proche de la France)
3. Sur le dashboard, copier la **Connection string** (format `postgresql://user:pass@ep-xxx.eu-central-1.aws.neon.tech/neondb?sslmode=require`)
4. Aller dans **SQL Editor** (menu gauche) et coller tout le contenu de `db/schema.sql` → **Run**
5. Optionnel : coller `db/seed.sql` pour créer l'admin par défaut (`admin@gz.local` / `Admin123`)

**Noter la Connection string** → on l'appellera `DATABASE_URL` dans la suite.

---

## 2 — API Node.js sur Render

### 2.1 Pousser le code sur GitHub

Si ce n'est pas déjà fait :
```bash
cd c:/Users/CCL/Desktop/GOUZEPE_APP
git add -A
git commit -m "Prep déploiement Render/Vercel"
git push origin main
```

### 2.2 Créer le service

1. Aller sur [render.com](https://render.com) → **Sign up** avec GitHub
2. **New +** → **Web Service**
3. **Connect a repository** : sélectionner `Gouzepe-efootball`
4. Configuration :
   - **Name** : `gouzepe-api`
   - **Region** : `Frankfurt`
   - **Branch** : `main`
   - **Root Directory** : `api`
   - **Runtime** : `Node`
   - **Build Command** : `npm install`
   - **Start Command** : `node server.js`
   - **Instance Type** : `Free`

### 2.3 Variables d'environnement

Dans la section **Environment Variables**, ajouter :

| Clé | Valeur |
|---|---|
| `DATABASE_URL` | La Connection string Neon (copiée plus haut) |
| `PGSSL` | `true` |
| `PGSSL_FORCE` | `true` |
| `JWT_SECRET` | `1XS1r4QJNp6AtkjORvKUU01RZRfzbGV+echJsio9gq8lAOc2NW7sSYsQuncE6+o9` |
| `PORT` | `3005` |
| `HOST` | `0.0.0.0` |
| `CORS_ORIGIN` | `*` (on resserrera après avoir l'URL Vercel) |
| `NODE_VERSION` | `18` |

### 2.4 Lancer le déploiement

Cliquer **Create Web Service**. Render build et démarre l'API (~3-5 min).

**URL finale** : `https://gouzepe-api.onrender.com` (Render te donne l'URL exacte).

**Vérifier** : ouvrir `https://gouzepe-api.onrender.com/health` ou `/api/health` → doit renvoyer un JSON OK.

---

## 3 — Frontend sur Vercel

### 3.1 Créer le projet

1. Aller sur [vercel.com](https://vercel.com) → **Sign up** avec GitHub
2. **Add New... → Project**
3. Sélectionner `Gouzepe-efootball`
4. Configuration :
   - **Framework Preset** : `Vite` (auto-détecté)
   - **Root Directory** : cliquer **Edit** → choisir `frontend`
   - **Build Command** : `npm run build` (par défaut)
   - **Output Directory** : `dist` (par défaut)
   - **Install Command** : `npm install` (par défaut)

### 3.2 Variables d'environnement

Dans **Environment Variables**, ajouter :

| Clé | Valeur |
|---|---|
| `VITE_API_URL` | `https://gouzepe-api.onrender.com` (l'URL Render de l'étape 2.4) |

### 3.3 Déployer

Cliquer **Deploy**. Attendre ~1-2 min.

**URL finale** : `https://gouzepe-efootball.vercel.app` (ou nom similaire).

---

## 4 — Finaliser le CORS

Une fois l'URL Vercel connue, retourner sur Render :

1. Render → `gouzepe-api` → **Environment**
2. Modifier `CORS_ORIGIN` :
   - Valeur : `https://gouzepe-efootball.vercel.app` (remplacer par ton URL exacte)
3. **Save Changes** → Render redémarre l'API automatiquement

---

## 5 — Premier lancement

1. Ouvrir `https://gouzepe-efootball.vercel.app`
2. Se connecter : `admin@gz.local` / `Admin123`
3. Importer les données depuis une sauvegarde locale si besoin :
   - Menu **Sauvegardes** → importer un fichier SQL exporté depuis l'instance locale

### Exporter les données locales pour les importer en prod

Depuis ton PC (Docker local) :
```bash
docker exec gouzepe_app-db-1 pg_dump -U gouzepe -d EFOOTBALL --data-only --inserts > dump-data.sql
```

Puis dans Neon → SQL Editor, coller le contenu de `dump-data.sql` (ou utiliser `psql` avec la Connection string Neon).

---

## 6 — Astuces pour le jour J

### Réveiller l'API avant le début

Render endort l'API après 15 min. Avant l'ouverture au public :
```bash
curl https://gouzepe-api.onrender.com/health
```
Attendre 30s que le serveur se réveille, puis tout sera fluide.

### Garder l'API éveillée (optionnel, pas officiellement autorisé)

Pour une démo courte, utiliser un service comme [cron-job.org](https://cron-job.org) (gratuit) qui ping l'API toutes les 10 min. **Attention** : Render peut détecter et bannir si abusé.

### Si problème de CORS

Dans la console du navigateur, si tu vois `CORS error` :
- Vérifier que `CORS_ORIGIN` sur Render contient bien l'URL Vercel **exacte** (sans slash final)
- Tester en mettant `CORS_ORIGIN=*` temporairement

### Si problème de connexion Postgres

- Vérifier `PGSSL=true` et `PGSSL_FORCE=true` sur Render
- Neon exige SSL obligatoire
- Vérifier que `DATABASE_URL` contient bien `?sslmode=require` à la fin

### Socket.IO ne se connecte pas

- Vérifier que la correction de l'étape 0 a bien été faite
- Vérifier que `VITE_API_URL` est bien défini sur Vercel (et qu'un redeploy a été fait après l'avoir ajouté)

---

## 7 — Checklist finale

- [ ] Correction `useRealtimeSocket.js` appliquée + commit + push
- [ ] Projet Neon créé + schema.sql exécuté + seed.sql exécuté
- [ ] Connection string Neon copiée
- [ ] Service Render créé pointant sur `api/`
- [ ] Variables d'env Render renseignées (DATABASE_URL, PGSSL, JWT_SECRET…)
- [ ] API Render déployée, `/health` OK
- [ ] Projet Vercel créé pointant sur `frontend/`
- [ ] `VITE_API_URL` renseignée sur Vercel
- [ ] Frontend Vercel déployé
- [ ] `CORS_ORIGIN` Render mis à jour avec l'URL Vercel
- [ ] Login admin OK sur l'URL Vercel
- [ ] Données importées (si nécessaire)

---

## 8 — Après la démo

Render free ne garde rien en disque (pas de uploads persistants). Neon free garde la DB tant que le projet n'est pas supprimé. Vercel garde le déploiement indéfiniment.

Pour passer en production plus sérieuse plus tard, voir mon autre recommandation : **Railway** (~5$/mois) qui garde uploads + backups persistants.
