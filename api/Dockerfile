# ── Stage 1 : dépendances de production uniquement ───────────────────────────
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# ── Stage 2 : image finale légère ────────────────────────────────────────────
FROM node:18-alpine
WORKDIR /app

# Installer postgresql-client (pg_dump + psql) pour le système de backups
RUN apk add --no-cache postgresql-client

# Copier les dépendances depuis le stage précédent
COPY --from=deps /app/node_modules ./node_modules

# Copier le code source
COPY . .

# Créer les dossiers persistants avec les bons droits
RUN mkdir -p uploads backups && chown -R node:node /app

# Ne pas tourner en root
USER node

EXPOSE 3005

CMD ["node", "server.js"]
