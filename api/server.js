// server.js â€” GOUZEPE eFOOT API (Express + PostgreSQL + Socket.IO)
require('dotenv').config();

const express = require('express');
const http = require('http');
const path = require('path');
const fs = require('fs');
const os = require('os');
const cors = require('cors');
const helmet = require('helmet');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const dayjs = require('dayjs');
const crypto = require('crypto');
const { spawn } = require('child_process');

/* ====== Config ====== */
const PORT = parseInt(process.env.PORT || '3005', 10);
const HOST = process.env.HOST || '0.0.0.0'; // 0.0.0.0 pour accepter les connexions réseau, localhost pour local uniquement
const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) throw new Error('Missing JWT_SECRET env var');
const EMAIL_DOMAIN = process.env.EMAIL_DOMAIN || 'gz.local';

/* ====== Database ====== */
const localHosts = new Set(['localhost','127.0.0.1']);
const parsedDbUrl = (()=>{ try { return process.env.DATABASE_URL ? new URL(process.env.DATABASE_URL) : null; } catch(_) { return null; } })();
const inferLocal = parsedDbUrl ? localHosts.has(parsedDbUrl.hostname) : localHosts.has(String(process.env.PGHOST||'').toLowerCase());

const forceSSL = process.env.PGSSL_FORCE === 'true';
const useSSL = forceSSL ? true : (inferLocal ? false : process.env.PGSSL === 'true');

const pgOpts = process.env.DATABASE_URL
  ? { connectionString: process.env.DATABASE_URL, ssl: useSSL ? { rejectUnauthorized:false } : false }
  : {
      host: process.env.PGHOST || '127.0.0.1',
      port: +(process.env.PGPORT || 5432),
      database: process.env.PGDATABASE || 'EFOOTBALL',
      user: process.env.PGUSER || 'postgres',
      password: process.env.PGPASSWORD || 'Admin123',
      ssl: useSSL ? { rejectUnauthorized:false } : false,
    };

const pool = new Pool(pgOpts);

/* ====== App ====== */
const app = express();
const server = http.createServer(app);

// Configuration CORS
const defaultCorsOrigins = [
  'http://localhost:3000',
  'http://localhost:5173',
  'https://gouzepe.vercel.app'
].join(',');
const allowedOrigins = (process.env.CORS_ORIGIN || defaultCorsOrigins)
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);

function isAllowedOrigin(origin) {
  // Pas d'origin = requete serveur-a-serveur, curl, Electron, etc.
  if (!origin) return true;
  if (allowedOrigins.includes('*')) return true;
  if (allowedOrigins.includes(origin)) return true;

  try {
    const originUrl = new URL(origin);
    const hostname = originUrl.hostname;

    // Localhost
    if (hostname === 'localhost' || hostname === '127.0.0.1') return true;

    // Reseau local
    if (
      /^192\.168\.\d+\.\d+$/.test(hostname) ||
      /^10\.\d+\.\d+\.\d+$/.test(hostname) ||
      /^172\.(1[6-9]|2[0-9]|3[0-1])\.\d+\.\d+$/.test(hostname)
    ) {
      return true;
    }

    // Vercel previews du projet gouzepe (ex: gouzepe-git-main-xxx.vercel.app)
    if (/^gouzepe(?:-[a-z0-9-]+)?\.vercel\.app$/i.test(hostname)) return true;
  } catch (_e) {
    // Invalid origin URL
  }

  return false;
}

const corsOptions = {
  origin: (origin, cb) => cb(null, isAllowedOrigin(origin)),
  credentials: false,
  methods: ['GET','POST','PUT','PATCH','DELETE','OPTIONS'],
  allowedHeaders: ['Authorization','Content-Type'],
  exposedHeaders: ['Content-Length'],
  maxAge: 86400,
  optionsSuccessStatus: 204
};

const io = require('socket.io')(server, {
  cors: {
    origin: (origin, cb) => cb(null, isAllowedOrigin(origin)),
    methods: ['GET','POST','PUT','PATCH','DELETE','OPTIONS']
  }
});

/* ====== Middlewares ====== */
app.use(helmet({ crossOriginResourcePolicy: { policy: "cross-origin" } }));
app.use(cors(corsOptions));
app.options('*', cors(corsOptions));
app.use(express.json({ limit: '2mb' }));
app.use(express.urlencoded({ extended: true }));

/* ====== Uploads ====== */
const UP = path.join(__dirname, 'uploads');
const UP_PLAYERS = path.join(UP, 'players');
fs.mkdirSync(UP_PLAYERS, { recursive:true });
app.use('/uploads', express.static(UP));

const BACKUP_DIR = path.join(__dirname, 'backups');
const BACKUP_UPLOADS_DIR = path.join(BACKUP_DIR, '_uploads');
fs.mkdirSync(BACKUP_DIR, { recursive: true });
fs.mkdirSync(BACKUP_UPLOADS_DIR, { recursive: true });

/* ====== Static files (web) ====== */
const WEB_DIR = path.join(__dirname, '../web');
app.use('/assets', express.static(path.join(WEB_DIR, 'assets')));
app.use('/fonds', express.static(path.join(WEB_DIR, 'fonds')));
app.use(express.static(WEB_DIR));
app.use('/web', express.static(WEB_DIR));
app.get('/', (_req, res) => res.redirect('/login.html'));

const upload = multer({
  storage: multer.diskStorage({
    destination: (_req, _file, cb)=> cb(null, UP_PLAYERS),
    filename: (req, file, cb)=>{
      const ext = (file.originalname||'jpg').toLowerCase().split('.').pop();
      const who = req.user?.player_id || 'unknown';
      cb(null, `${who}_${Date.now().toString(36)}.${ext}`);
    }
  }),
  fileFilter: (_req,file,cb)=> cb(/^image\/(png|jpe?g|webp|gif)$/i.test(file.mimetype||'')?null:new Error('image requise'), true),
  limits:{ fileSize: 2*1024*1024 }
});

const restoreUpload = multer({
  storage: multer.diskStorage({
    destination: (_req, _file, cb) => cb(null, BACKUP_UPLOADS_DIR),
    filename: (_req, file, cb) => {
      const base = String(file.originalname || 'restore.sql')
        .replace(/[^a-zA-Z0-9_.-]/g, '_')
        .replace(/\.+/g, '.');
      cb(null, `${Date.now()}_${base}`);
    }
  }),
  fileFilter: (_req, file, cb) => {
    const name = String(file.originalname || '').toLowerCase();
    if (!name.endsWith('.sql')) return cb(new Error('Fichier .sql requis'));
    cb(null, true);
  },
  limits: { fileSize: 1024 * 1024 * 500 } // 500 MB
});

/* ====== Helpers ====== */
const q   = (sql, params=[]) => pool.query(sql, params);
const ok  = (res, data={}) => res.json(data);
const bad = (res, code=400, msg='Bad request') => res.status(code).json({ error: String(msg) });
const normEmail = (x)=>{ x=String(x||'').trim().toLowerCase(); if(!x) return x; if(!x.includes('@')) x=`${x}@${EMAIL_DOMAIN}`; return x; };
const newId = ()=> (crypto.randomUUID ? crypto.randomUUID() : (Date.now().toString(36)+Math.random().toString(36).slice(2,10)));
const clientIp = (req)=> (req.headers['x-forwarded-for']||req.socket.remoteAddress||'').toString().split(',')[0].trim();
const deviceLabel = (req)=> { const d=(req.headers['x-device-name']||'').toString().trim(); const ua=(req.headers['user-agent']||'').toString().trim(); return [d,ua].filter(Boolean).join(' â€¢ ').slice(0,180) || 'Appareil'; };

const AUTO_BACKUP_ENABLED = process.env.AUTO_BACKUP_ENABLED !== 'false';
const BACKUP_AUTO_DAY = Number(process.env.BACKUP_AUTO_DAY || 6); // samedi
const BACKUP_AUTO_HOUR = Number(process.env.BACKUP_AUTO_HOUR || 23);
const BACKUP_AUTO_MINUTE = Number(process.env.BACKUP_AUTO_MINUTE || 0);
const BACKUP_RETENTION_DAYS = Number(process.env.BACKUP_RETENTION_DAYS || 30);
const BACKUP_TICK_MS = 30 * 1000;

let backupJobRunning = false;
let lastAutoBackupSlot = '';

function findWindowsPgBinary(executableName) {
  const roots = [process.env.ProgramFiles, process.env['ProgramFiles(x86)']].filter(Boolean);
  for (const root of roots) {
    const pgRoot = path.join(root, 'PostgreSQL');
    if (!fs.existsSync(pgRoot)) continue;
    let versions = [];
    try {
      versions = fs.readdirSync(pgRoot, { withFileTypes: true })
        .filter((d) => d.isDirectory())
        .map((d) => d.name)
        .sort((a, b) => b.localeCompare(a, undefined, { numeric: true, sensitivity: 'base' }));
    } catch (_) {
      versions = [];
    }
    for (const version of versions) {
      const candidate = path.join(pgRoot, version, 'bin', executableName);
      if (fs.existsSync(candidate)) return candidate;
    }
  }
  return null;
}

function resolvePgCommand(command) {
  const isWin = process.platform === 'win32';
  const executable = isWin ? `${command}.exe` : command;
  const byCommandEnv =
    command === 'pg_dump'
      ? process.env.PG_DUMP_PATH
      : (command === 'psql' ? process.env.PSQL_PATH : '');

  if (byCommandEnv && fs.existsSync(byCommandEnv)) return byCommandEnv;

  if (process.env.PG_BIN_DIR) {
    const fromBinDir = path.join(process.env.PG_BIN_DIR, executable);
    if (fs.existsSync(fromBinDir)) return fromBinDir;
  }

  if (isWin) {
    const autoFound = findWindowsPgBinary(executable);
    if (autoFound) return autoFound;
  }

  return executable;
}

function runProcess(command, args, env) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, { env, stdio: ['ignore', 'pipe', 'pipe'] });
    let stdout = '';
    let stderr = '';
    child.stdout.on('data', (chunk) => { stdout += String(chunk); });
    child.stderr.on('data', (chunk) => { stderr += String(chunk); });
    child.on('error', (err) => {
      if (err && err.code === 'ENOENT') {
        return reject(new Error(
          `${path.basename(command)} introuvable. Configure PG_BIN_DIR (ex: C:\\Program Files\\PostgreSQL\\18\\bin) ou ajoute PostgreSQL au PATH.`
        ));
      }
      return reject(err);
    });
    child.on('close', (code) => {
      if (code === 0) return resolve({ stdout, stderr });
      reject(new Error(`${command} failed (${code}): ${stderr || stdout}`));
    });
  });
}

function pgCommandEnv() {
  const env = { ...process.env };
  const password = process.env.PGPASSWORD || pgOpts.password;
  if (password) env.PGPASSWORD = String(password);
  env.PGSSLMODE = useSSL ? 'require' : 'disable';
  return env;
}

function pgConnectionArgs() {
  if (process.env.DATABASE_URL) {
    return ['--dbname', process.env.DATABASE_URL];
  }
  return [
    '--host', String(process.env.PGHOST || '127.0.0.1'),
    '--port', String(process.env.PGPORT || 5432),
    '--username', String(process.env.PGUSER || 'postgres'),
    '--dbname', String(process.env.PGDATABASE || 'EFOOTBALL'),
  ];
}

function sanitizeSqlFileName(name) {
  const base = path.basename(String(name || ''));
  if (!/^[a-zA-Z0-9_.-]+\.sql$/.test(base)) return null;
  return base;
}

function backupFilePath(fileName) {
  const safe = sanitizeSqlFileName(fileName);
  if (!safe) return null;
  return path.join(BACKUP_DIR, safe);
}

function backupSourceFromName(fileName) {
  if (fileName.startsWith('auto_')) return 'auto';
  if (fileName.startsWith('manual_')) return 'manual';
  if (fileName.startsWith('uploaded_')) return 'uploaded';
  return 'unknown';
}

function listBackups() {
  const entries = fs.readdirSync(BACKUP_DIR, { withFileTypes: true })
    .filter((e) => e.isFile() && e.name.endsWith('.sql'))
    .map((e) => {
      const fullPath = path.join(BACKUP_DIR, e.name);
      const st = fs.statSync(fullPath);
      return {
        name: e.name,
        sizeBytes: st.size,
        updatedAt: st.mtime.toISOString(),
        source: backupSourceFromName(e.name),
      };
    })
    .sort((a, b) => new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime());
  return entries;
}

function pruneAutoBackups() {
  if (!Number.isFinite(BACKUP_RETENTION_DAYS) || BACKUP_RETENTION_DAYS <= 0) return;
  const cutoff = Date.now() - (BACKUP_RETENTION_DAYS * 24 * 60 * 60 * 1000);
  for (const file of listBackups()) {
    if (file.source !== 'auto') continue;
    const updated = new Date(file.updatedAt).getTime();
    if (updated < cutoff) {
      const full = backupFilePath(file.name);
      if (full && fs.existsSync(full)) fs.unlinkSync(full);
    }
  }
}

async function createDatabaseBackup(kind = 'manual') {
  if (backupJobRunning) throw new Error('Une operation de sauvegarde/restauration est deja en cours');
  backupJobRunning = true;
  try {
    const stamp = new Date().toISOString().slice(0, 19).replace('T', '_').replace(/:/g, '-');
    const prefix = kind === 'auto' ? 'auto' : 'manual';
    const fileName = `${prefix}_${stamp}.sql`;
    const outPath = path.join(BACKUP_DIR, fileName);

    const args = [
      ...pgConnectionArgs(),
      '--clean',
      '--if-exists',
      '--no-owner',
      '--no-privileges',
      '--encoding', 'UTF8',
      '--file', outPath,
    ];
    await runProcess(resolvePgCommand('pg_dump'), args, pgCommandEnv());

    if (kind === 'auto') pruneAutoBackups();

    const created = listBackups().find((b) => b.name === fileName);
    return created || { name: fileName, sizeBytes: 0, updatedAt: new Date().toISOString(), source: prefix };
  } finally {
    backupJobRunning = false;
  }
}

async function restoreFromSqlFile(sqlPath) {
  if (backupJobRunning) throw new Error('Une operation de sauvegarde/restauration est deja en cours');
  backupJobRunning = true;
  try {
    if (!sqlPath || !fs.existsSync(sqlPath)) throw new Error('Fichier SQL introuvable');

    // Ã‰tape 1 : vider le schéma proprement pour éviter les conflits de FK
    const resetArgs = [
      ...pgConnectionArgs(),
      '--set', 'ON_ERROR_STOP=1',
      '--command', 'DROP SCHEMA public CASCADE; CREATE SCHEMA public;',
    ];
    await runProcess(resolvePgCommand('psql'), resetArgs, pgCommandEnv());

    // Ã‰tape 2 : restaurer le fichier SQL
    const args = [
      ...pgConnectionArgs(),
      '--set', 'ON_ERROR_STOP=1',
      '--file', sqlPath,
    ];
    await runProcess(resolvePgCommand('psql'), args, pgCommandEnv());
  } finally {
    backupJobRunning = false;
  }
}

function nextAutoBackupDate(from = new Date()) {
  const next = new Date(from);
  next.setUTCSeconds(0, 0);
  next.setUTCHours(BACKUP_AUTO_HOUR, BACKUP_AUTO_MINUTE, 0, 0);
  const shift = (BACKUP_AUTO_DAY - next.getUTCDay() + 7) % 7;
  next.setUTCDate(next.getUTCDate() + shift);
  if (next <= from) next.setUTCDate(next.getUTCDate() + 7);
  return next;
}

async function runAutoBackupTick() {
  if (!AUTO_BACKUP_ENABLED) return;
  const now = new Date();
  if (now.getUTCDay() !== BACKUP_AUTO_DAY) return;
  if (now.getUTCHours() !== BACKUP_AUTO_HOUR) return;
  if (now.getUTCMinutes() !== BACKUP_AUTO_MINUTE) return;

  const slot = now.toISOString().slice(0, 16); // YYYY-MM-DDTHH:mm UTC
  if (slot === lastAutoBackupSlot) return;
  lastAutoBackupSlot = slot;

  try {
    const b = await createDatabaseBackup('auto');
    console.log(`[backup] auto backup created: ${b.name}`);
  } catch (e) {
    console.error('[backup] auto backup failed:', e.message || e);
  }
}

/* ====== Presence (in-memory) ====== */
const PRESENCE_TTL_MS = 70 * 1000;
const presence = { players: new Map() }; // player_id -> lastSeen (ms)

/* ====== Team key helper ====== */
const TEAM_KEY_LEN = parseInt(process.env.TEAM_KEY_LEN || '4', 10);
function teamKey(raw){
  if(!raw) return '';
  let s = String(raw)
    .normalize('NFD').replace(/[\u0300-\u036f]/g,'')                 // accents
    .replace(/\p{Emoji_Presentation}|\p{Extended_Pictographic}/gu,'')// emoji/drapeaux
    .toUpperCase()
    .replace(/\b(FC|CF|SC|AC|REAL|THE)\b/g, ' ')
    .replace(/[^A-Z0-9]+/g,'')
    .trim();
  return s.slice(0, TEAM_KEY_LEN);
}

/* ====== Schema (tolérant) ====== */
async function ensureSchema(){
  /* duels */
  await q(`CREATE TABLE IF NOT EXISTS duels(
    id SERIAL PRIMARY KEY,
    p1_id TEXT NOT NULL,
    p2_id TEXT NOT NULL,
    score_a INT NOT NULL,
    score_b INT NOT NULL,
    played_at TIMESTAMPTZ DEFAULT now(),
    created_at TIMESTAMPTZ DEFAULT now()
  )`);

  /* users (ajouts "soft") */
  await q(`CREATE TABLE IF NOT EXISTS users(
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'member',
    player_id TEXT,
    created_at TIMESTAMP DEFAULT now(),
    last_login TIMESTAMP
  )`);
  await q(`ALTER TABLE users ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT now()`);
  await q(`ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login TIMESTAMP`);
  await q(`ALTER TABLE users ADD COLUMN IF NOT EXISTS player_id TEXT`);
  await q(`ALTER TABLE users ADD COLUMN IF NOT EXISTS role TEXT`);
  await q(`
  DO $$
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='id') THEN
      IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relkind='S' AND relname='users_id_seq') THEN
        CREATE SEQUENCE users_id_seq;
      END IF;
      ALTER TABLE users ADD COLUMN id INTEGER;
      ALTER TABLE users ALTER COLUMN id SET DEFAULT nextval('users_id_seq');
      UPDATE users SET id = nextval('users_id_seq') WHERE id IS NULL;
      BEGIN
        ALTER TABLE users ADD PRIMARY KEY (id);
      EXCEPTION WHEN duplicate_table THEN
      END;
    END IF;
  END$$;
  `);

  /* sessions */
  await q(`CREATE TABLE IF NOT EXISTS sessions(
    id TEXT PRIMARY KEY,
    user_id INTEGER,
    device TEXT,
    user_agent TEXT,
    ip TEXT,
    created_at TIMESTAMP DEFAULT now(),
    last_seen TIMESTAMP DEFAULT now(),
    is_active BOOLEAN NOT NULL DEFAULT true,
    revoked_at TIMESTAMP,
    logout_at TIMESTAMP,
    cleaned_after_logout BOOLEAN NOT NULL DEFAULT false
  )`);
  await q(`CREATE INDEX IF NOT EXISTS sessions_user_active ON sessions(user_id) WHERE is_active`);

  /* seasons */
  await q(`CREATE TABLE IF NOT EXISTS seasons(
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    ended_at TIMESTAMPTZ,
    is_closed BOOLEAN NOT NULL DEFAULT false
  )`);

  /* matchday */
  await q(`CREATE TABLE IF NOT EXISTS matchday(
    day DATE PRIMARY KEY,
    season_id INTEGER,
    payload JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
  )`);

  /* draft */
  await q(`CREATE TABLE IF NOT EXISTS draft(
    day DATE PRIMARY KEY,
    payload JSONB NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now(),
    author_user_id INTEGER
  )`);
  await q(`CREATE INDEX IF NOT EXISTS draft_author_idx ON draft(author_user_id)`);

  /* players */
  await q(`CREATE TABLE IF NOT EXISTS players(
    player_id TEXT PRIMARY KEY,
    name      TEXT NOT NULL,
    role      TEXT NOT NULL DEFAULT 'MEMBRE',
    profile_pic_url TEXT,
    created_at TIMESTAMP DEFAULT now()
  )`);
  await q(`ALTER TABLE players ADD COLUMN IF NOT EXISTS profile_pic_url TEXT`);

  /* tournaments (single elimination v1) */
  await q(`CREATE TABLE IF NOT EXISTS tournaments(
    id SERIAL PRIMARY KEY,
    slug TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    format TEXT NOT NULL DEFAULT 'single_elimination',
    status TEXT NOT NULL DEFAULT 'draft',
    starts_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    winner_player_id TEXT REFERENCES players(player_id) ON UPDATE CASCADE ON DELETE SET NULL,
    created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    season_id INTEGER REFERENCES seasons(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (format IN ('single_elimination')),
    CHECK (status IN ('draft','live','completed','archived'))
  )`);
  await q(`CREATE INDEX IF NOT EXISTS tournaments_status_idx ON tournaments(status)`);
  await q(`CREATE INDEX IF NOT EXISTS tournaments_created_at_idx ON tournaments(created_at DESC)`);

  await q(`CREATE TABLE IF NOT EXISTS tournament_participants(
    id SERIAL PRIMARY KEY,
    tournament_id INTEGER NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
    player_id TEXT NOT NULL REFERENCES players(player_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    seed INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(tournament_id, player_id)
  )`);
  await q(`CREATE UNIQUE INDEX IF NOT EXISTS tournament_participants_seed_uniq
           ON tournament_participants(tournament_id, seed)
           WHERE seed IS NOT NULL`);

  await q(`CREATE TABLE IF NOT EXISTS tournament_matches(
    id SERIAL PRIMARY KEY,
    tournament_id INTEGER NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
    round_no INTEGER NOT NULL,
    slot_no INTEGER NOT NULL,
    best_of INTEGER NOT NULL DEFAULT 1,
    p1_participant_id INTEGER REFERENCES tournament_participants(id) ON DELETE SET NULL,
    p2_participant_id INTEGER REFERENCES tournament_participants(id) ON DELETE SET NULL,
    score_p1 INTEGER,
    score_p2 INTEGER,
    winner_participant_id INTEGER REFERENCES tournament_participants(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    walkover BOOLEAN NOT NULL DEFAULT false,
    next_match_id INTEGER REFERENCES tournament_matches(id) ON DELETE SET NULL,
    next_match_slot SMALLINT CHECK (next_match_slot IN (1,2)),
    started_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (round_no > 0),
    CHECK (slot_no > 0),
    CHECK (best_of > 0),
    CHECK (status IN ('pending','ready','completed')),
    UNIQUE(tournament_id, round_no, slot_no)
  )`);
  await q(`CREATE INDEX IF NOT EXISTS tournament_matches_tournament_round_idx
           ON tournament_matches(tournament_id, round_no, slot_no)`);

  /* migrations: nouvelles colonnes pour double élimination */
  await q(`ALTER TABLE tournament_matches
    ADD COLUMN IF NOT EXISTS bracket_side TEXT NOT NULL DEFAULT 'W',
    ADD COLUMN IF NOT EXISTS loser_next_match_id INTEGER REFERENCES tournament_matches(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS loser_next_match_slot SMALLINT`);

  /* migrations: phase de groupe */
  await q(`ALTER TABLE tournament_matches ADD COLUMN IF NOT EXISTS group_no SMALLINT`);
  await q(`ALTER TABLE tournament_participants ADD COLUMN IF NOT EXISTS group_no SMALLINT`);
  await q(`ALTER TABLE tournaments ADD COLUMN IF NOT EXISTS nb_groups SMALLINT`);
  await q(`ALTER TABLE tournaments ADD COLUMN IF NOT EXISTS qualifiers_per_group SMALLINT`);

  /* migrations: participants libres (style Challonge) */
  await q(`ALTER TABLE tournament_participants ADD COLUMN IF NOT EXISTS display_name TEXT NOT NULL DEFAULT ''`);
  // Backfill display_name from players table for existing participants
  await q(`UPDATE tournament_participants tp SET display_name = COALESCE(p.name, tp.player_id)
    FROM players p WHERE p.player_id = tp.player_id AND tp.display_name = ''`);
  // Make player_id optional
  await q(`DO $$ BEGIN ALTER TABLE tournament_participants ALTER COLUMN player_id DROP NOT NULL;
    EXCEPTION WHEN OTHERS THEN NULL; END$$`);
  // Drop old unique on (tournament_id, player_id) â€” incompatible avec NULLs multiples
  await q(`ALTER TABLE tournament_participants DROP CONSTRAINT IF EXISTS tournament_participants_tournament_id_player_id_key`);
  // New unique: un nom unique (insensible casse) par tournoi
  await q(`CREATE UNIQUE INDEX IF NOT EXISTS tp_display_name_uniq
    ON tournament_participants(tournament_id, lower(display_name))`);
  // winner_name text sur tournaments (remplace le JOIN players pour le vainqueur)
  await q(`ALTER TABLE tournaments ADD COLUMN IF NOT EXISTS winner_name TEXT`);
  await q(`ALTER TABLE tournaments ADD COLUMN IF NOT EXISTS member_tournament BOOLEAN NOT NULL DEFAULT true`);
  await q(`ALTER TABLE tournaments ADD COLUMN IF NOT EXISTS day_comment TEXT`);
  await q(`ALTER TABLE tournaments ADD COLUMN IF NOT EXISTS rr_match_mode TEXT NOT NULL DEFAULT 'single'`);
  await q(`ALTER TABLE tournaments ADD COLUMN IF NOT EXISTS rr_standings_mode TEXT NOT NULL DEFAULT 'goals'`);
  await q(`ALTER TABLE tournaments ADD COLUMN IF NOT EXISTS season_id INTEGER REFERENCES seasons(id) ON DELETE SET NULL`);
  await q(`CREATE INDEX IF NOT EXISTS tournaments_season_idx ON tournaments(season_id)`);
  /* migration: tournoi comptant pour le titre D1 */
  await q(`ALTER TABLE tournaments ADD COLUMN IF NOT EXISTS counts_for_title BOOLEAN NOT NULL DEFAULT FALSE`);
  // Backfill winner_name depuis winner_player_id existants
  await q(`UPDATE tournaments t SET winner_name = p.name
    FROM players p WHERE p.player_id = t.winner_player_id AND t.winner_name IS NULL`);

  /* migration: contrainte format étendue */
  await q(`DO $$
  DECLARE v_cname TEXT;
  BEGIN
    SELECT constraint_name INTO v_cname
    FROM information_schema.table_constraints
    WHERE table_name='tournaments' AND constraint_type='CHECK'
      AND constraint_name ILIKE '%format%' LIMIT 1;
    IF v_cname IS NOT NULL THEN
      EXECUTE format('ALTER TABLE tournaments DROP CONSTRAINT %I', v_cname);
    END IF;
  EXCEPTION WHEN OTHERS THEN NULL;
  END$$`);
  await q(`DO $$
  BEGIN
    ALTER TABLE tournaments ADD CONSTRAINT tournaments_format_chk
      CHECK (format IN ('single_elimination','round_robin','double_elimination','groups_knockout'));
  EXCEPTION WHEN duplicate_object THEN NULL;
  END$$`);
  await q(`DO $$
  BEGIN
    ALTER TABLE tournaments ADD CONSTRAINT tournaments_rr_match_mode_chk
      CHECK (rr_match_mode IN ('single','home_away'));
  EXCEPTION WHEN duplicate_object THEN NULL;
  END$$`);
  await q(`DO $$
  BEGIN
    ALTER TABLE tournaments ADD CONSTRAINT tournaments_rr_standings_mode_chk
      CHECK (rr_standings_mode IN ('goals','wins'));
  EXCEPTION WHEN duplicate_object THEN NULL;
  END$$`);

  /* seed admin (optional) */
  const seedAdmin = process.env.SEED_ADMIN_ON_BOOT === 'true';
  if (seedAdmin) {
    const adminEmail = process.env.ADMIN_EMAIL || 'admin@gz.local';
    const adminPass  = process.env.ADMIN_PASSWORD || 'admin';
    const row = await q(`SELECT id FROM users WHERE email=$1`,[adminEmail]);
    if(row.rowCount===0){
      const hash = await bcrypt.hash(adminPass,10);
      await q(`INSERT INTO users(email,password_hash,role) VALUES ($1,$2,'admin')`,[adminEmail,hash]);
      console.log(`Seed admin user ${adminEmail}`);
    }
  }

  /* season par défaut */
  const s = await q(`SELECT id FROM seasons WHERE is_closed=false ORDER BY id DESC LIMIT 1`);
  let activeSeasonId = s.rows[0]?.id || null;
  if (s.rowCount === 0) {
    const ins = await q(`INSERT INTO seasons(name,is_closed) VALUES ('Saison courante', false) RETURNING id`);
    activeSeasonId = ins.rows[0]?.id || null;
  }
  if (activeSeasonId) {
    await q(`UPDATE tournaments SET season_id=$1 WHERE season_id IS NULL`, [activeSeasonId]);
  }
}

/* ====== Auth & sessions ====== */
function signToken(user, sessionId){
  return jwt.sign(
    { uid:user.id, role:user.role, email:user.email, sid:sessionId },
    JWT_SECRET,
    { expiresIn: '24h' }
  );
}
function auth(req,res,next){
  (async ()=>{
    try{
      const h=req.headers.authorization||'';
      const tok=h.startsWith('Bearer ')?h.slice(7):'';
      if(!tok) return bad(res,401,'No token');
      const p = jwt.verify(tok, JWT_SECRET);

      const r = await q(`SELECT is_active,last_seen FROM sessions WHERE id=$1`, [p.sid]);
      if(!r.rowCount || !r.rows[0].is_active) return bad(res,401,'Session revoked');

      const last = r.rows[0].last_seen;
      if (last && Date.now() - new Date(last).getTime() > 24*3600*1000){
        await q(`UPDATE sessions SET is_active=false, revoked_at=now() WHERE id=$1`, [p.sid]);
        return bad(res,401,'Session expired');
      }

      req.user = p;
      q(`UPDATE sessions SET last_seen=now(), ip=$2, user_agent=$3 WHERE id=$1`,
        [p.sid, clientIp(req), (req.headers['user-agent']||'').slice(0,200)]).catch(()=>{});
      next();
    }catch(e){ return bad(res,401,'Invalid token'); }
  })();
}
function adminOnly(req,res,next){
  if((req.user?.role||'member')!=='admin') return bad(res,403,'Admin only');
  next();
}

/* ====== Health ====== */
app.get('/healthz', (_req,res)=> ok(res,{ ok:true, service:'gouzepe-api', ts:Date.now() }));
app.get('/health',  (_req,res)=> ok(res,{ ok:true, service:'gouzepe-api', ts:Date.now() }));

/* ====== Rate limiter (in-memory, no dep) ====== */
const _rlStore = new Map()
function makeRateLimit(maxReqs, windowMs) {
  return function rateLimit(req, res, next) {
    const key = req.ip || 'unknown'
    const now = Date.now()
    let entry = _rlStore.get(key)
    if (!entry || now > entry.resetAt) {
      entry = { count: 0, resetAt: now + windowMs }
      _rlStore.set(key, entry)
    }
    entry.count++
    if (entry.count > maxReqs) {
      res.set('Retry-After', Math.ceil((entry.resetAt - now) / 1000))
      return res.status(429).json({ error: 'Trop de tentatives. Réessayez plus tard.' })
    }
    next()
  }
}
const loginRateLimit = makeRateLimit(10, 15 * 60 * 1000) // 10 essais / 15 min par IP

/* ====== Auth (single-session simple) ====== */
app.post('/auth/login', loginRateLimit, async (req,res)=>{
  let {email,password}=req.body||{};
  email = normEmail(email);
  if(!email||!password) return bad(res,400,'email/password requis');

  const r=await q(`SELECT id,email,role,password_hash FROM users WHERE email=$1`,[email]);
  if(r.rowCount===0) return bad(res,401,'Utilisateur inconnu');
  const u=r.rows[0];
  const match = await bcrypt.compare(password, u.password_hash);
  if(!match) return bad(res,401,'Mot de passe incorrect');

  await q(`UPDATE sessions SET is_active=false, revoked_at=now() WHERE user_id=$1 AND is_active=true`, [u.id]);

  const sid = newId();
  await q(`INSERT INTO sessions(id,user_id,device,user_agent,ip) VALUES ($1,$2,$3,$4,$5)`,
    [sid, u.id, deviceLabel(req), (req.headers['user-agent']||'').slice(0,200), clientIp(req)]);

  const token = signToken(u, sid);
  await q(`UPDATE users SET last_login=now() WHERE id=$1`, [u.id]);
  ok(res,{ token, user:{id:u.id,email:u.email,role:u.role}, expHours:24 });
});
app.get('/auth/me', auth, async (req,res)=>{
  const r=await q(`SELECT id,email,role,player_id FROM users WHERE id=$1`,[req.user.uid]);
  if(!r.rowCount) return bad(res,404,'User not found');
  ok(res,{ user:r.rows[0] });
});
app.post('/auth/logout', auth, async (req,res)=>{
  await q(`UPDATE sessions SET is_active=false, revoked_at=now(), logout_at=now() WHERE id=$1`, [req.user.sid]);
  ok(res,{ ok:true });
});

/* ====== Presence ====== */
async function getLinkedPlayerId(userId){
  const r=await q(`SELECT player_id FROM users WHERE id=$1`,[userId]);
  return r.rows[0]?.player_id || null;
}
app.post('/presence/ping', auth, async (req,res)=>{
  const pid = await getLinkedPlayerId(req.user.uid);
  if(pid){ presence.players.set(pid, Date.now()); }
  ok(res,{ ok:true, now:Date.now() });
});
app.get('/presence/online', auth, async (_req,res)=>{
  const now=Date.now();
  const online=[];
  for(const [pid,ts] of presence.players){
    if(now - ts < PRESENCE_TTL_MS) online.push({ player_id:pid, lastSeen:ts });
  }
  ok(res,{ online });
});

/* ====== Admin users ====== */
app.get('/admin/users', auth, adminOnly, async (_req,res)=>{
  const r=await q(`SELECT id,email,role,created_at FROM users ORDER BY created_at DESC NULLS LAST, id DESC`);
  ok(res,{ users:r.rows });
});
app.post('/admin/users', auth, adminOnly, async (req,res)=>{
  let { email, password, role } = req.body||{};
  email = normEmail(email);
  role = (role||'member').toLowerCase()==='admin'?'admin':'member';
  if(!email||!password) return bad(res,400,'email/password requis');
  try{
    const hash=await bcrypt.hash(password,10);
    const r=await q(`INSERT INTO users(email,password_hash,role) VALUES ($1,$2,$3)
                     ON CONFLICT(email) DO UPDATE SET password_hash=EXCLUDED.password_hash, role=EXCLUDED.role
                     RETURNING id,email,role,created_at`,[email,hash,role]);
    ok(res,{ user:r.rows[0] });
  }catch(e){
    if(e.code==='23505') return bad(res,409,'email déjÃ  utilisé');
    throw e;
  }
});
app.put('/admin/users/:id', auth, adminOnly, async (req,res)=>{
  const id=+req.params.id;
  let { email, role, password } = req.body||{};
  email = email ? normEmail(email) : undefined;
  const u=(await q(`SELECT id,email,role FROM users WHERE id=$1`,[id])).rows[0];
  if(!u) return bad(res,404,'introuvable');
  const newEmail = email || u.email;
  const newRole  = (role||u.role)==='admin'?'admin':'member';
  if(password){
    const hash=await bcrypt.hash(password,10);
    await q(`UPDATE users SET email=$1, role=$2, password_hash=$3 WHERE id=$4`,[newEmail,newRole,hash,id]);
  }else{
    await q(`UPDATE users SET email=$1, role=$2 WHERE id=$3`,[newEmail,newRole,id]);
  }
  const r=await q(`SELECT id,email,role,created_at FROM users WHERE id=$1`,[id]);
  ok(res,{ user:r.rows[0] });
});
app.delete('/admin/users/:id', auth, adminOnly, async (req,res)=>{
  await q(`DELETE FROM users WHERE id=$1`,[+req.params.id]);
  ok(res,{ ok:true });
});

/* ====== Admin backups ====== */
app.get('/admin/backups', auth, adminOnly, async (_req, res) => {
  try {
    const nextRun = AUTO_BACKUP_ENABLED ? nextAutoBackupDate() : null;
    ok(res, {
      backups: listBackups(),
      running: backupJobRunning,
      schedule: {
        enabled: AUTO_BACKUP_ENABLED,
        dayOfWeek: BACKUP_AUTO_DAY,
        hour: BACKUP_AUTO_HOUR,
        minute: BACKUP_AUTO_MINUTE,
        nextRun: nextRun ? nextRun.toISOString() : null,
        timezone: 'UTC',
      }
    });
  } catch (e) {
    bad(res, 500, e.message || 'Erreur backup');
  }
});

app.post('/admin/backups/create', auth, adminOnly, async (_req, res) => {
  try {
    const backup = await createDatabaseBackup('manual');
    ok(res, { ok: true, backup });
  } catch (e) {
    bad(res, 500, e.message || 'Creation sauvegarde impossible');
  }
});

app.get('/admin/backups/:fileName/download', auth, adminOnly, async (req, res) => {
  const fullPath = backupFilePath(req.params.fileName);
  if (!fullPath || !fs.existsSync(fullPath)) return bad(res, 404, 'Fichier introuvable');
  res.download(fullPath, path.basename(fullPath));
});

app.delete('/admin/backups/:fileName', auth, adminOnly, async (req, res) => {
  try {
    if (backupJobRunning) return bad(res, 409, 'Operation sauvegarde/restauration en cours');
    const fullPath = backupFilePath(req.params.fileName);
    if (!fullPath || !fs.existsSync(fullPath)) return bad(res, 404, 'Fichier introuvable');
    fs.unlinkSync(fullPath);
    ok(res, { ok: true, deleted: path.basename(fullPath) });
  } catch (e) {
    bad(res, 500, e.message || 'Suppression sauvegarde impossible');
  }
});

app.post('/admin/backups/restore-existing', auth, adminOnly, async (req, res) => {
  try {
    const fileName = String(req.body?.file || '');
    const fullPath = backupFilePath(fileName);
    if (!fullPath || !fs.existsSync(fullPath)) return bad(res, 404, 'Fichier introuvable');

    await restoreFromSqlFile(fullPath);
    ok(res, { ok: true, restoredFrom: path.basename(fullPath) });
  } catch (e) {
    bad(res, 500, e.message || 'Restauration impossible');
  }
});

app.post('/admin/backups/restore-upload', auth, adminOnly, restoreUpload.single('sqlFile'), async (req, res) => {
  let archivedPath = null;
  try {
    if (!req.file) return bad(res, 400, 'Fichier .sql requis');
    const originalSafe = String(req.file.originalname || 'restore.sql').replace(/[^a-zA-Z0-9_.-]/g, '_');
    const archivedName = `uploaded_${new Date().toISOString().slice(0, 19).replace('T', '_').replace(/:/g, '-')}_${originalSafe}`;
    archivedPath = path.join(BACKUP_DIR, archivedName);
    fs.renameSync(req.file.path, archivedPath);

    await restoreFromSqlFile(archivedPath);
    ok(res, { ok: true, restoredFrom: path.basename(archivedPath) });
  } catch (e) {
    if (req.file?.path && fs.existsSync(req.file.path)) {
      try { fs.unlinkSync(req.file.path); } catch (_) {}
    }
    if (archivedPath && fs.existsSync(archivedPath)) {
      try { fs.unlinkSync(archivedPath); } catch (_) {}
    }
    bad(res, 500, e.message || 'Restauration upload impossible');
  }
});

/* ====== Tournaments (single elimination v1) ====== */
function sanitizeTournamentName(raw) {
  const name = String(raw || '').trim().replace(/\s+/g, ' ');
  if (!name) return '';
  return name.slice(0, 120);
}

function slugifyTournamentName(raw) {
  const base = sanitizeTournamentName(raw)
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 60);
  const suffix = Math.random().toString(36).slice(2, 7);
  return `${base || 'tournoi'}-${suffix}`;
}

function nextPowerOfTwo(n) {
  let p = 1;
  while (p < n) p <<= 1;
  return p;
}

function seededBracketOrder(size) {
  if (size <= 1) return [1];
  let arr = [1, 2];
  let current = 2;
  while (current < size) {
    const max = current * 2 + 1;
    const next = [];
    for (const v of arr) {
      next.push(v);
      next.push(max - v);
    }
    arr = next;
    current *= 2;
  }
  return arr;
}

function parseScoreValue(v) {
  const n = Number(v);
  if (!Number.isFinite(n) || n < 0 || !Number.isInteger(n)) return null;
  return n;
}

async function getTournamentBundle(tournamentId) {
  const t = await q(`
    SELECT
      t.id, t.slug, t.name, t.format, t.status, t.starts_at, t.ended_at,
      t.winner_name, t.member_tournament, t.counts_for_title, t.day_comment, t.season_id,
      t.rr_match_mode, t.rr_standings_mode,
      t.nb_groups, t.qualifiers_per_group,
      t.created_at, t.updated_at,
      (SELECT COUNT(*)::int FROM tournament_participants tp WHERE tp.tournament_id=t.id) AS participants_count
    FROM tournaments t
    WHERE t.id=$1
  `, [tournamentId]);
  if (!t.rowCount) return null;

  const participants = await q(`
    SELECT tp.id, tp.display_name AS name, tp.display_name, tp.player_id, tp.seed, tp.group_no
    FROM tournament_participants tp
    WHERE tp.tournament_id=$1
    ORDER BY tp.seed ASC NULLS LAST, tp.id ASC
  `, [tournamentId]);

  const matches = await q(`
    SELECT
      m.id, m.round_no, m.slot_no, m.group_no, m.best_of, m.score_p1, m.score_p2, m.status,
      m.walkover, m.next_match_id, m.next_match_slot, m.started_at, m.finished_at,
      m.bracket_side, m.loser_next_match_id, m.loser_next_match_slot,
      m.p1_participant_id, m.p2_participant_id, m.winner_participant_id,
      tp1.display_name AS p1_name,
      tp2.display_name AS p2_name,
      tpw.display_name AS winner_name
    FROM tournament_matches m
    LEFT JOIN tournament_participants tp1 ON tp1.id=m.p1_participant_id
    LEFT JOIN tournament_participants tp2 ON tp2.id=m.p2_participant_id
    LEFT JOIN tournament_participants tpw ON tpw.id=m.winner_participant_id
    WHERE m.tournament_id=$1
    ORDER BY m.round_no ASC, m.slot_no ASC
  `, [tournamentId]);

  return {
    tournament: t.rows[0],
    participants: participants.rows,
    matches: matches.rows,
  };
}

function normalizeDateKey(input) {
  const raw = String(input || '').trim();
  if (!raw) return '';
  const short = raw.slice(0, 10);
  if (/^\d{4}-\d{2}-\d{2}$/.test(short)) return short;
  const d = new Date(raw);
  if (Number.isNaN(d.getTime())) return '';
  return d.toISOString().slice(0, 10);
}

function emitTournamentRealtime(tournamentLike, reason = 'updated') {
  const t = tournamentLike?.tournament || tournamentLike || {};
  const tournamentId = Number(t.id);
  if (!Number.isInteger(tournamentId) || tournamentId <= 0) return;

  const day = normalizeDateKey(t.starts_at);
  const payload = {
    tournamentId,
    reason,
    status: t.status || null,
    member_tournament: t.member_tournament !== false,
    date: day || null,
    at: new Date().toISOString(),
  };

  io.emit('tournament:changed', payload);
  io.to(`tournament:${tournamentId}`).emit('tournament:changed', payload);
  if (day) {
    io.to(`day:${day}`).emit('tournaments:day:update', payload);
    io.emit('tournaments:day:update', payload);
  }
}

async function assignWinnerToNextMatch(client, tournamentId, matchRow, winnerParticipantId) {
  if (!matchRow.next_match_id) {
    // Ne pas marquer terminé si c'est un match de phase de groupe
    if (matchRow.bracket_side === 'G') return;
    await client.query(`
      UPDATE tournaments t
      SET
        winner_name = tp.display_name,
        status='completed',
        ended_at=COALESCE(t.ended_at, now()),
        updated_at=now()
      FROM tournament_participants tp
      WHERE t.id=$1 AND tp.id=$2
    `, [tournamentId, winnerParticipantId]);
    return;
  }

  const next = await client.query(`
    SELECT id, status, p1_participant_id, p2_participant_id
    FROM tournament_matches
    WHERE id=$1 AND tournament_id=$2
    FOR UPDATE
  `, [matchRow.next_match_id, tournamentId]);
  if (!next.rowCount) return;
  const nx = next.rows[0];
  const slotCol = matchRow.next_match_slot === 2 ? 'p2_participant_id' : 'p1_participant_id';
  const existing = slotCol === 'p1_participant_id' ? nx.p1_participant_id : nx.p2_participant_id;
  if (existing && existing !== winnerParticipantId) {
    throw new Error('Bracket inconsistant: slot suivant déjÃ  occupé');
  }

  let p1 = nx.p1_participant_id;
  let p2 = nx.p2_participant_id;
  if (slotCol === 'p1_participant_id') p1 = winnerParticipantId;
  else p2 = winnerParticipantId;

  const newStatus = nx.status === 'completed' ? nx.status : (p1 && p2 ? 'ready' : 'pending');
  await client.query(`
    UPDATE tournament_matches
    SET p1_participant_id=$1, p2_participant_id=$2, status=$3, updated_at=now()
    WHERE id=$4
  `, [p1, p2, newStatus, nx.id]);
}

/* Réinitialise en cascade tous les matchs downstream qui dépendaient d'un participant */
async function cascadeResetWinner(client, tournamentId, startNextMatchId, removedParticipantId) {
  const queue = [];
  const visited = new Set();
  if (startNextMatchId && removedParticipantId) {
    queue.push({ matchId: startNextMatchId, participantId: removedParticipantId });
  }

  while (queue.length) {
    const current = queue.shift();
    if (!current?.matchId || !current?.participantId) continue;

    const visitKey = `${current.matchId}:${current.participantId}`;
    if (visited.has(visitKey)) continue;
    visited.add(visitKey);

    const r = await client.query(`
      SELECT id, p1_participant_id, p2_participant_id, winner_participant_id,
             status, next_match_id, loser_next_match_id
      FROM tournament_matches WHERE id=$1 AND tournament_id=$2 FOR UPDATE
    `, [current.matchId, tournamentId]);
    if (!r.rowCount) continue;
    const nx = r.rows[0];

    const isP1 = nx.p1_participant_id === current.participantId;
    const isP2 = nx.p2_participant_id === current.participantId;
    if (!isP1 && !isP2) continue;

    const previousWinner = nx.winner_participant_id;
    const previousLoser = previousWinner
      ? (previousWinner === nx.p1_participant_id ? nx.p2_participant_id : nx.p1_participant_id)
      : null;
    const slotCol = isP1 ? 'p1_participant_id' : 'p2_participant_id';

    await client.query(`
      UPDATE tournament_matches
      SET ${slotCol}=NULL, winner_participant_id=NULL, score_p1=NULL, score_p2=NULL,
          status='pending', walkover=false, finished_at=NULL, updated_at=now()
      WHERE id=$1
    `, [nx.id]);

    // Si le tournoi avait été complété par ce participant, le remettre live
    await client.query(`
      UPDATE tournaments SET status='live', winner_name=NULL, ended_at=NULL, updated_at=now()
      WHERE id=$1 AND status='completed'
    `, [tournamentId]);

    if (previousWinner && nx.next_match_id) {
      queue.push({ matchId: nx.next_match_id, participantId: previousWinner });
    }
    if (previousLoser && nx.loser_next_match_id) {
      queue.push({ matchId: nx.loser_next_match_id, participantId: previousLoser });
    }
  }
}

async function resolveLoserRoute(client, tournamentId, matchRow) {
  let targetMatchId = Number(matchRow?.loser_next_match_id || 0) || null;
  let targetSlot = Number(matchRow?.loser_next_match_slot || 1) === 2 ? 2 : 1;

  const side = String(matchRow?.bracket_side || '').toUpperCase();
  if (side !== 'W') return { targetMatchId, targetSlot };

  const wbRound = Number(matchRow?.round_no || 0);
  const wbSlot = Number(matchRow?.slot_no || 0);
  if (!Number.isInteger(wbRound) || wbRound <= 0 || !Number.isInteger(wbSlot) || wbSlot <= 0) {
    return { targetMatchId, targetSlot };
  }

  const maxWbRes = await client.query(`
    SELECT MAX(round_no)::int AS max_round
    FROM tournament_matches
    WHERE tournament_id=$1 AND bracket_side='W'
  `, [tournamentId]);
  const wbMaxRound = Number(maxWbRes.rows?.[0]?.max_round || 0);
  if (!wbMaxRound) return { targetMatchId, targetSlot };

  let expectedLbRound;
  let expectedLbSlot;
  let expectedLbEntrySlot;

  if (wbRound === 1) {
    expectedLbRound = 11;
    expectedLbSlot = Math.ceil(wbSlot / 2);
    expectedLbEntrySlot = wbSlot % 2 === 1 ? 1 : 2;
  } else if (wbRound < wbMaxRound) {
    // WB round r losers feed LB round k = 2*(r-1), i.e. round_no = 10 + k.
    expectedLbRound = 10 + (2 * (wbRound - 1));
    expectedLbSlot = wbSlot;
    expectedLbEntrySlot = 2;
  } else {
    // WB final loser feeds LB final as slot 2.
    expectedLbRound = 10 + (2 * (wbMaxRound - 1));
    expectedLbSlot = 1;
    expectedLbEntrySlot = 2;
  }

  const lb = await client.query(`
    SELECT id
    FROM tournament_matches
    WHERE tournament_id=$1 AND bracket_side='L' AND round_no=$2 AND slot_no=$3
    LIMIT 1
  `, [tournamentId, expectedLbRound, expectedLbSlot]);

  if (!lb.rowCount) return { targetMatchId, targetSlot };

  const expectedMatchId = lb.rows[0].id;
  if (targetMatchId !== expectedMatchId || targetSlot !== expectedLbEntrySlot) {
    await client.query(`
      UPDATE tournament_matches
      SET loser_next_match_id=$1, loser_next_match_slot=$2, updated_at=now()
      WHERE id=$3
    `, [expectedMatchId, expectedLbEntrySlot, matchRow.id]);
    targetMatchId = expectedMatchId;
    targetSlot = expectedLbEntrySlot;
  }

  return { targetMatchId, targetSlot };
}

async function autoAdvanceWalkovers(client, tournamentId) {
  function feederCanStillProduce(rows, feeder) {
    if (!feeder || feeder.status === 'completed') return false;
    if (feeder.p1_participant_id || feeder.p2_participant_id) return true;
    const upstream = rows.filter(
      (other) => other.next_match_id === feeder.id || other.loser_next_match_id === feeder.id
    );
    if (!upstream.length) return false;
    return upstream.some((other) => other.status !== 'completed');
  }

  for (;;) {
    const rows = await client.query(`
      SELECT id, tournament_id, round_no, slot_no, p1_participant_id, p2_participant_id, status,
             next_match_id, next_match_slot, bracket_side, loser_next_match_id, loser_next_match_slot
      FROM tournament_matches
      WHERE tournament_id=$1
      ORDER BY round_no ASC, slot_no ASC
      FOR UPDATE
    `, [tournamentId]);

    let progressed = false;
    for (const m of rows.rows) {
      if (m.status === 'completed') continue;
      const hasP1 = !!m.p1_participant_id;
      const hasP2 = !!m.p2_participant_id;
      if ((hasP1 ? 1 : 0) + (hasP2 ? 1 : 0) !== 1) continue;

      // Ne pas auto-compléter si un match amont (winner ou loser route) n'est pas terminé
      const hasPendingFeeder = rows.rows.some((other) => {
        if (!(other.next_match_id === m.id || other.loser_next_match_id === m.id)) return false;
        return feederCanStillProduce(rows.rows, other);
      });
      if (hasPendingFeeder) continue;

      const winner = m.p1_participant_id || m.p2_participant_id;
      const score1 = m.p1_participant_id ? 1 : 0;
      const score2 = m.p2_participant_id ? 1 : 0;
      await client.query(`
        UPDATE tournament_matches
        SET winner_participant_id=$1, score_p1=$2, score_p2=$3, status='completed',
            walkover=true, finished_at=COALESCE(finished_at, now()), updated_at=now()
        WHERE id=$4
      `, [winner, score1, score2, m.id]);

      await assignWinnerToNextMatch(client, tournamentId, m, winner);
      progressed = true;
    }
    if (!progressed) break;
  }

  await client.query(`
    UPDATE tournament_matches
    SET status='ready', updated_at=now()
    WHERE tournament_id=$1
      AND status='pending'
      AND p1_participant_id IS NOT NULL
      AND p2_participant_id IS NOT NULL
  `, [tournamentId]);
}

/* â”€â”€ assignLoserToNextMatch â”€â”€ */
async function assignLoserToNextMatch(client, tournamentId, matchRow, loserParticipantId, resolvedRoute = null) {
  if (!loserParticipantId) return;
  const route = resolvedRoute || await resolveLoserRoute(client, tournamentId, matchRow);
  if (!route?.targetMatchId) return;
  const next = await client.query(`
    SELECT id, status, p1_participant_id, p2_participant_id
    FROM tournament_matches WHERE id=$1 AND tournament_id=$2 FOR UPDATE
  `, [route.targetMatchId, tournamentId]);
  if (!next.rowCount) return;
  const nx = next.rows[0];
  let targetSlot = route.targetSlot === 2 ? 2 : 1;
  let slotCol = targetSlot === 2 ? 'p2_participant_id' : 'p1_participant_id';
  let existing = slotCol === 'p1_participant_id' ? nx.p1_participant_id : nx.p2_participant_id;
  if (existing && existing !== loserParticipantId) {
    const altSlot = targetSlot === 1 ? 2 : 1;
    const altCol = altSlot === 2 ? 'p2_participant_id' : 'p1_participant_id';
    const altExisting = altCol === 'p1_participant_id' ? nx.p1_participant_id : nx.p2_participant_id;
    if (!altExisting || altExisting === loserParticipantId) {
      targetSlot = altSlot;
      slotCol = altCol;
      existing = altExisting;
      await client.query(`
        UPDATE tournament_matches
        SET loser_next_match_slot=$1, updated_at=now()
        WHERE id=$2
      `, [targetSlot, matchRow.id]);
    } else {
      throw new Error('Bracket inconsistant: slot loser déjà occupé');
    }
  }
  let p1 = nx.p1_participant_id;
  let p2 = nx.p2_participant_id;
  if (slotCol === 'p2_participant_id') p2 = loserParticipantId;
  else p1 = loserParticipantId;
  const newStatus = nx.status === 'completed' ? nx.status : (p1 && p2 ? 'ready' : 'pending');
  await client.query(`
    UPDATE tournament_matches SET p1_participant_id=$1, p2_participant_id=$2, status=$3, updated_at=now()
    WHERE id=$4
  `, [p1, p2, newStatus, nx.id]);
}

/* â”€â”€ Round Robin standings â”€â”€ */
async function computeRoundRobinStandings(clientOrPool, tournamentId) {
  const db = clientOrPool || pool;
  const tCfg = await db.query(`
    SELECT rr_standings_mode
    FROM tournaments
    WHERE id=$1
  `, [tournamentId]);
  const standingsMode = String(tCfg.rows?.[0]?.rr_standings_mode || 'goals');
  const parts = await db.query(`
    SELECT tp.id AS participant_id, tp.display_name AS name
    FROM tournament_participants tp
    WHERE tp.tournament_id=$1 ORDER BY tp.seed ASC NULLS LAST, tp.id ASC
  `, [tournamentId]);
  const stats = new Map();
  parts.rows.forEach(r => {
    stats.set(r.participant_id, { participant_id:r.participant_id, name:r.name, pts:0, w:0, d:0, l:0, bf:0, bc:0, played:0 });
  });
  const matches = await db.query(`
    SELECT m.score_p1, m.score_p2,
           m.p1_participant_id AS p1_pid, m.p2_participant_id AS p2_pid
    FROM tournament_matches m
    WHERE m.tournament_id=$1 AND m.status='completed'
  `, [tournamentId]);
  matches.rows.forEach(m => {
    const p1 = stats.get(m.p1_pid);
    const p2 = stats.get(m.p2_pid);
    if (!p1 || !p2) return;
    p1.played++; p2.played++;
    p1.bf += m.score_p1; p1.bc += m.score_p2;
    p2.bf += m.score_p2; p2.bc += m.score_p1;
    if (m.score_p1 > m.score_p2)      { p1.w++; p2.l++; }
    else if (m.score_p2 > m.score_p1) { p2.w++; p1.l++; }
    else                               { p1.d++; p2.d++; }
  });
  return [...stats.values()].map((s) => {
    const diff = s.bf - s.bc;
    const pts = standingsMode === 'wins' ? s.w : (s.w * 3 + s.d);
    return { ...s, diff, pts };
  }).sort((a, b) => {
    if (b.pts !== a.pts) return b.pts - a.pts;
    if (standingsMode === 'wins') {
      if (b.w !== a.w) return b.w - a.w;
      if (a.played !== b.played) return a.played - b.played;
      return String(a.name || '').localeCompare(String(b.name || ''), 'fr');
    }
    if (b.diff !== a.diff) return b.diff - a.diff;
    if (b.bf !== a.bf) return b.bf - a.bf;
    return String(a.name || '').localeCompare(String(b.name || ''), 'fr');
  });
}

async function computeGroupStandings(clientOrPool, tournamentId, group_no) {
  const db = clientOrPool || pool;
  const parts = await db.query(`
    SELECT tp.id AS participant_id, tp.display_name AS name
    FROM tournament_participants tp
    WHERE tp.tournament_id=$1 AND tp.group_no=$2
    ORDER BY tp.seed ASC NULLS LAST, tp.id ASC
  `, [tournamentId, group_no]);
  const stats = new Map();
  parts.rows.forEach(r => {
    stats.set(r.participant_id, { participant_id:r.participant_id, name:r.name, pts:0, w:0, d:0, l:0, bf:0, bc:0, played:0 });
  });
  const matches = await db.query(`
    SELECT m.score_p1, m.score_p2, m.p1_participant_id AS p1_pid, m.p2_participant_id AS p2_pid
    FROM tournament_matches m
    WHERE m.tournament_id=$1 AND m.group_no=$2 AND m.status='completed'
  `, [tournamentId, group_no]);
  matches.rows.forEach(m => {
    const p1 = stats.get(m.p1_pid), p2 = stats.get(m.p2_pid);
    if (!p1 || !p2) return;
    p1.played++; p2.played++;
    p1.bf += m.score_p1; p1.bc += m.score_p2;
    p2.bf += m.score_p2; p2.bc += m.score_p1;
    if (m.score_p1 > m.score_p2)      { p1.pts+=3; p1.w++; p2.l++; }
    else if (m.score_p2 > m.score_p1) { p2.pts+=3; p2.w++; p1.l++; }
    else                               { p1.pts+=1; p1.d++; p2.pts+=1; p2.d++; }
  });
  return [...stats.values()].map(s => ({ ...s, diff: s.bf - s.bc })).sort((a,b) => {
    if (b.pts !== a.pts) return b.pts - a.pts;
    if (b.diff !== a.diff) return b.diff - a.diff;
    return b.bf - a.bf;
  });
}

/* â”€â”€ Bracket generation: Groups + Knockout â”€â”€ */
async function generateGroupsKnockout(client, id, participants, nb_groups, qual_per_group) {
  const rows = participants.rows;
  const count = rows.length;
  // Distribute players across groups: player[i] â†’ group (i % nb_groups)
  for (let i = 0; i < count; i++) {
    const gn = i % nb_groups;
    await client.query(`UPDATE tournament_participants SET group_no=$1 WHERE id=$2`, [gn, rows[i].id]);
  }
  // Generate round-robin matches per group with bracket_side='G'
  let slot = 1;
  for (let gn = 0; gn < nb_groups; gn++) {
    const gPlayers = rows.filter((_, i) => i % nb_groups === gn);
    for (let i = 0; i < gPlayers.length - 1; i++) {
      for (let j = i + 1; j < gPlayers.length; j++) {
        await client.query(`
          INSERT INTO tournament_matches(tournament_id,round_no,slot_no,p1_participant_id,p2_participant_id,status,bracket_side,group_no)
          VALUES($1,1,$2,$3,$4,'ready','G',$5)
        `, [id, slot++, gPlayers[i].id, gPlayers[j].id, gn]);
      }
    }
  }
}

async function checkRoundRobinCompletion(client, tournamentId) {
  const rem = await client.query(`
    SELECT COUNT(*) FROM tournament_matches WHERE tournament_id=$1 AND status!='completed'
  `, [tournamentId]);
  await client.query(`UPDATE tournaments SET status='live', updated_at=now() WHERE id=$1 AND status='draft'`, [tournamentId]);
  if (Number(rem.rows[0].count) === 0) {
    const standings = await computeRoundRobinStandings(client, tournamentId);
    const winner = standings[0];
    await client.query(`
      UPDATE tournaments SET status='completed', winner_name=$1, ended_at=now(), updated_at=now()
      WHERE id=$2
    `, [winner?.name || null, tournamentId]);
  }
}

function shuffleArray(list) {
  const arr = Array.isArray(list) ? [...list] : [];
  for (let i = arr.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    const tmp = arr[i];
    arr[i] = arr[j];
    arr[j] = tmp;
  }
  return arr;
}

function buildSeededSlots(bracketSize, participantRows) {
  const ids = shuffleArray((participantRows || []).map((p) => p?.id).filter(Boolean));
  const seedingOrder = seededBracketOrder(bracketSize);
  const seedToIndex = new Map(seedingOrder.map((seed, idx) => [seed, idx]));
  const slots = new Array(bracketSize).fill(null);
  for (let rank = 1; rank <= ids.length; rank += 1) {
    const slotIndex = seedToIndex.get(rank);
    if (slotIndex === undefined) continue;
    slots[slotIndex] = ids[rank - 1];
  }
  return slots;
}

/* â”€â”€ Bracket generation: Single Elimination â”€â”€ */
async function generateSingleElimination(client, id, participants, roundOffset = 0) {
  const count = participants.rowCount;
  const bracketSize = nextPowerOfTwo(count);
  const rounds = Math.log2(bracketSize);
  const slots = buildSeededSlots(bracketSize, participants.rows);
  const keyToMatch = new Map();
  for (let roundNo = 1; roundNo <= rounds; roundNo++) {
    const matchesInRound = bracketSize >> roundNo;
    for (let slotNo = 1; slotNo <= matchesInRound; slotNo++) {
      const p1 = roundNo === 1 ? slots[(slotNo - 1) * 2] : null;
      const p2 = roundNo === 1 ? slots[(slotNo - 1) * 2 + 1] : null;
      const status = roundNo === 1 && p1 && p2 ? 'ready' : 'pending';
      const ins = await client.query(`
        INSERT INTO tournament_matches(tournament_id,round_no,slot_no,p1_participant_id,p2_participant_id,status,bracket_side)
        VALUES($1,$2,$3,$4,$5,$6,'W') RETURNING id,round_no,slot_no
      `, [id, roundNo + roundOffset, slotNo, p1, p2, status]);
      keyToMatch.set(`${roundNo}:${slotNo}`, ins.rows[0].id);
    }
  }
  for (let roundNo = 1; roundNo < rounds; roundNo++) {
    for (let slotNo = 1; slotNo <= bracketSize >> roundNo; slotNo++) {
      await client.query(`UPDATE tournament_matches SET next_match_id=$1,next_match_slot=$2,updated_at=now() WHERE id=$3`,
        [keyToMatch.get(`${roundNo + 1}:${Math.ceil(slotNo / 2)}`), slotNo % 2 === 1 ? 1 : 2, keyToMatch.get(`${roundNo}:${slotNo}`)]);
    }
  }
}

/* â”€â”€ Bracket generation: Round Robin â”€â”€ */
async function generateRoundRobin(client, id, participants, rrMatchMode = 'single') {
  const rows = participants.rows;
  let slot = 1;
  const withHomeAway = String(rrMatchMode || 'single') === 'home_away';
  for (let i = 0; i < rows.length - 1; i++) {
    for (let j = i + 1; j < rows.length; j++) {
      await client.query(`
        INSERT INTO tournament_matches(tournament_id,round_no,slot_no,p1_participant_id,p2_participant_id,status,bracket_side)
        VALUES($1,1,$2,$3,$4,'ready','W')
      `, [id, slot++, rows[i].id, rows[j].id]);
      if (withHomeAway) {
        await client.query(`
          INSERT INTO tournament_matches(tournament_id,round_no,slot_no,p1_participant_id,p2_participant_id,status,bracket_side)
          VALUES($1,2,$2,$3,$4,'ready','W')
        `, [id, slot++, rows[j].id, rows[i].id]);
      }
    }
  }
}

/* â”€â”€ Bracket generation: Double Elimination â”€â”€ */
async function generateDoubleElimination(client, id, participants) {
  const count = participants.rowCount;
  const bracketSize = nextPowerOfTwo(count);
  const wbRounds = Math.log2(bracketSize);
  const slots = buildSeededSlots(bracketSize, participants.rows);
  const wbRoundMatchCounts = [];
  for (let rn = 1; rn <= wbRounds; rn += 1) wbRoundMatchCounts.push(bracketSize >> rn);

  // Winner Bracket
  const wbKey = new Map();
  for (let rn = 1; rn <= wbRounds; rn++) {
    const matchCount = wbRoundMatchCounts[rn - 1];
    for (let sn = 1; sn <= matchCount; sn++) {
      const p1 = rn === 1 ? slots[(sn - 1) * 2] : null;
      const p2 = rn === 1 ? slots[(sn - 1) * 2 + 1] : null;
      const st = rn === 1 && p1 && p2 ? 'ready' : 'pending';
      const ins = await client.query(`
        INSERT INTO tournament_matches(tournament_id,round_no,slot_no,p1_participant_id,p2_participant_id,status,bracket_side)
        VALUES($1,$2,$3,$4,$5,$6,'W') RETURNING id
      `, [id, rn, sn, p1, p2, st]);
      wbKey.set(`${rn}:${sn}`, ins.rows[0].id);
    }
  }
  // WB internal winner links (WB final links to GF below)
  for (let rn = 1; rn < wbRounds; rn++) {
    const fromCount = wbRoundMatchCounts[rn - 1];
    for (let sn = 1; sn <= fromCount; sn++) {
      await client.query(`UPDATE tournament_matches SET next_match_id=$1,next_match_slot=$2,updated_at=now() WHERE id=$3`,
        [wbKey.get(`${rn + 1}:${Math.ceil(sn / 2)}`), sn % 2 === 1 ? 1 : 2, wbKey.get(`${rn}:${sn}`)]);
    }
  }

  if (wbRounds < 2) {
    // Only 2 players: WB final IS the GF, no LB needed
    return;
  }

  // Loser Bracket
  const lbRounds = 2 * (wbRounds - 1);
  const lbRoundMatchCounts = [];
  for (let k = 1; k <= lbRounds; k++) {
    const j = Math.ceil(k / 2);
    lbRoundMatchCounts.push(bracketSize >> (j + 1));
  }
  const lbKey = new Map();
  for (let k = 1; k <= lbRounds; k++) {
    const lbRound = 10 + k;
    const matchCount = lbRoundMatchCounts[k - 1];
    for (let s = 1; s <= matchCount; s++) {
      const ins = await client.query(`
        INSERT INTO tournament_matches(tournament_id,round_no,slot_no,status,bracket_side)
        VALUES($1,$2,$3,'pending','L') RETURNING id
      `, [id, lbRound, s]);
      lbKey.set(`${lbRound}:${s}`, ins.rows[0].id);
    }
  }

  // Grand Final
  const gfIns = await client.query(`
    INSERT INTO tournament_matches(tournament_id,round_no,slot_no,status,bracket_side)
    VALUES($1,20,1,'pending','GF') RETURNING id
  `, [id]);
  const gfId = gfIns.rows[0].id;

  // WB R1 losers -> LB R11 (play each other)
  for (let s = 1; s <= wbRoundMatchCounts[0]; s++) {
    const lbSlot = Math.ceil(s / 2);
    const lbPSlot = s % 2 === 1 ? 1 : 2;
    const lbId = lbKey.get(`11:${lbSlot}`);
    if (lbId) await client.query(`UPDATE tournament_matches SET loser_next_match_id=$1,loser_next_match_slot=$2,updated_at=now() WHERE id=$3`,
      [lbId, lbPSlot, wbKey.get(`1:${s}`)]);
  }
  // WB R2..R(n-1) losers -> LB even rounds as p2
  for (let wbK = 2; wbK <= wbRounds - 1; wbK++) {
    const lbRound = 10 + (2 * (wbK - 1));
    const loserCount = wbRoundMatchCounts[wbK - 1];
    for (let s = 1; s <= loserCount; s++) {
      const lbId = lbKey.get(`${lbRound}:${s}`);
      if (lbId) await client.query(`UPDATE tournament_matches SET loser_next_match_id=$1,loser_next_match_slot=2,updated_at=now() WHERE id=$2`,
        [lbId, wbKey.get(`${wbK}:${s}`)]);
    }
  }
  // WB Final loser -> LB Final as p2
  const lbFinalRound = 10 + lbRounds;
  const lbFinalId = lbKey.get(`${lbFinalRound}:1`);
  if (lbFinalId) await client.query(`UPDATE tournament_matches SET loser_next_match_id=$1,loser_next_match_slot=2,updated_at=now() WHERE id=$2`,
    [lbFinalId, wbKey.get(`${wbRounds}:1`)]);

  // LB internal links (winner progression)
  for (let k = 1; k < lbRounds; k++) {
    const fromRound = 10 + k;
    const toRound = 10 + k + 1;
    const fromCount = lbRoundMatchCounts[k - 1];
    const toCount = lbRoundMatchCounts[k];
    for (let s = 1; s <= fromCount; s++) {
      const fromId = lbKey.get(`${fromRound}:${s}`);
      let toSlot, toPSlot;
      if (fromCount === toCount) { toSlot = s; toPSlot = 1; }
      else                       { toSlot = Math.ceil(s/2); toPSlot = s%2===1?1:2; }
      const toId = lbKey.get(`${toRound}:${toSlot}`);
      if (fromId && toId) await client.query(`UPDATE tournament_matches SET next_match_id=$1,next_match_slot=$2,updated_at=now() WHERE id=$3`,
        [toId, toPSlot, fromId]);
    }
  }

  // LB Final â†’ GF as p2, WB Final â†’ GF as p1
  if (lbFinalId) await client.query(`UPDATE tournament_matches SET next_match_id=$1,next_match_slot=2,updated_at=now() WHERE id=$2`, [gfId, lbFinalId]);
  await client.query(`UPDATE tournament_matches SET next_match_id=$1,next_match_slot=1,updated_at=now() WHERE id=$2`, [gfId, wbKey.get(`${wbRounds}:1`)]);
}

app.get('/tournaments/:id/standings', auth, async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) return bad(res, 400, 'id invalide');
  try {
    const t = await q(`SELECT format, nb_groups, rr_match_mode, rr_standings_mode FROM tournaments WHERE id=$1`, [id]);
    if (!t.rowCount) return bad(res, 404, 'Tournoi introuvable');
    const { format, nb_groups, rr_match_mode, rr_standings_mode } = t.rows[0];
    if (format === 'round_robin') {
      const standings = await computeRoundRobinStandings(null, id);
      return ok(res, {
        standings,
        standings_mode: rr_standings_mode || 'goals',
        match_mode: rr_match_mode || 'single',
      });
    }
    if (format === 'groups_knockout') {
      const count = nb_groups || 2;
      const groups = [];
      for (let gn = 0; gn < count; gn++) {
        const standings = await computeGroupStandings(null, id, gn);
        groups.push({ group_no: gn, standings });
      }
      return ok(res, { groups });
    }
    return bad(res, 400, 'Classement disponible pour round robin / groupes uniquement');
  } catch(e) { bad(res, 500, e.message); }
});

app.get('/tournaments', auth, async (req, res) => {
  try {
    const includeArchived = req.user?.role === 'admin' && String(req.query.all || '') === '1';
    const rows = await q(`
      SELECT
        t.id, t.slug, t.name, t.format, t.status, t.starts_at, t.ended_at,
        t.winner_name, t.member_tournament, t.counts_for_title, t.day_comment, t.season_id,
        t.rr_match_mode, t.rr_standings_mode,
        t.created_at, t.updated_at,
        (SELECT COUNT(*)::int FROM tournament_participants tp WHERE tp.tournament_id=t.id) AS participants_count
      FROM tournaments t
      ${includeArchived ? '' : `WHERE t.status <> 'archived'`}
      ORDER BY
        CASE t.status WHEN 'live' THEN 0 WHEN 'draft' THEN 1 WHEN 'completed' THEN 2 ELSE 3 END,
        t.created_at DESC
    `);
    ok(res, { tournaments: rows.rows });
  } catch (e) {
    bad(res, 500, e.message || 'Impossible de charger les tournois');
  }
});

app.get('/tournaments/:id', auth, async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) return bad(res, 400, 'id invalide');
  try {
    const bundle = await getTournamentBundle(id);
    if (!bundle) return bad(res, 404, 'Tournoi introuvable');
    ok(res, bundle);
  } catch (e) {
    bad(res, 500, e.message || 'Impossible de charger le tournoi');
  }
});

app.post('/admin/tournaments', auth, adminOnly, async (req, res) => {
  const name = sanitizeTournamentName(req.body?.name);
  const startsAt = req.body?.starts_at ? new Date(req.body.starts_at) : null;
  if (!name) return bad(res, 400, 'Nom du tournoi requis');
  const allowedFormats = ['single_elimination','round_robin','double_elimination','groups_knockout'];
  const format = allowedFormats.includes(req.body?.format) ? req.body.format : 'single_elimination';
  const rrMatchMode = req.body?.rr_match_mode === 'home_away' ? 'home_away' : 'single';
  const rrStandingsMode = req.body?.rr_standings_mode === 'wins' ? 'wins' : 'goals';
  const memberTournament = req.body?.member_tournament === undefined ? false : !!req.body.member_tournament;
  const countsForTitle = memberTournament ? !!req.body?.counts_for_title : false;
  const dayComment = String(req.body?.day_comment || '').trim() || null;
  const slug = slugifyTournamentName(name);
  try {
    let seasonId = null;
    if (req.body?.season_id !== undefined && req.body?.season_id !== null && req.body?.season_id !== '') {
      seasonId = Number(req.body.season_id);
      if (!Number.isInteger(seasonId) || seasonId <= 0) return bad(res, 400, 'season_id invalide');
      const chk = await q(`SELECT 1 FROM seasons WHERE id=$1`, [seasonId]);
      if (!chk.rowCount) return bad(res, 404, 'Saison introuvable');
    } else {
      seasonId = await currentSeasonId();
    }

    const created = await q(`
      INSERT INTO tournaments(slug,name,format,status,starts_at,created_by,member_tournament,counts_for_title,season_id,day_comment,rr_match_mode,rr_standings_mode)
      VALUES($1,$2,$3,'draft',$4,$5,$6,$7,$8,$9,$10,$11)
      RETURNING id
    `, [slug, name, format, (startsAt && !Number.isNaN(startsAt.getTime())) ? startsAt.toISOString() : null, req.user.uid, memberTournament, countsForTitle, seasonId, dayComment, rrMatchMode, rrStandingsMode]);
    const bundle = await getTournamentBundle(created.rows[0].id);
    emitTournamentRealtime(bundle, 'created');
    ok(res, bundle);
  } catch (e) {
    bad(res, 500, e.message || 'Création du tournoi impossible');
  }
});

const updateTournamentHandler = async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) return bad(res, 400, 'id invalide');
  const fields = [];
  const values = [];

  if (req.body?.name !== undefined) {
    const nm = sanitizeTournamentName(req.body.name);
    if (!nm) return bad(res, 400, 'Nom invalide');
    fields.push(`name=$${values.length + 1}`);
    values.push(nm);
  }
  if (req.body?.starts_at !== undefined) {
    const dt = req.body.starts_at ? new Date(req.body.starts_at) : null;
    if (dt && Number.isNaN(dt.getTime())) return bad(res, 400, 'Date de début invalide');
    fields.push(`starts_at=$${values.length + 1}`);
    values.push(dt ? dt.toISOString() : null);
  }
  if (req.body?.status !== undefined) {
    const st = String(req.body.status || '').toLowerCase();
    if (!['draft', 'live', 'completed', 'archived'].includes(st)) return bad(res, 400, 'Statut invalide');
    fields.push(`status=$${values.length + 1}`);
    values.push(st);
    // Réinitialiser le vainqueur et la date de fin si on repasse en live/draft
    if (st === 'live' || st === 'draft') {
      fields.push(`winner_name=NULL`);
      fields.push(`ended_at=NULL`);
    }
  }
  let countsForTitleAlreadySet = false;
  if (req.body?.member_tournament !== undefined) {
    const memberVal = !!req.body.member_tournament;
    fields.push(`member_tournament=$${values.length + 1}`);
    values.push(memberVal);
    // Si on décoche "membre", on force counts_for_title à false directement ici
    if (!memberVal) {
      fields.push(`counts_for_title=$${values.length + 1}`);
      values.push(false);
      countsForTitleAlreadySet = true;
    }
  }
  if (req.body?.counts_for_title !== undefined && !countsForTitleAlreadySet) {
    fields.push(`counts_for_title=$${values.length + 1}`);
    values.push(!!req.body.counts_for_title);
  }
  if (req.body?.day_comment !== undefined) {
    const text = String(req.body.day_comment || '').trim();
    fields.push(`day_comment=$${values.length + 1}`);
    values.push(text || null);
  }
  if (req.body?.season_id !== undefined) {
    const raw = req.body.season_id;
    if (raw === null || raw === '') {
      fields.push(`season_id=NULL`);
    } else {
      const seasonId = Number(raw);
      if (!Number.isInteger(seasonId) || seasonId <= 0) return bad(res, 400, 'season_id invalide');
      const chk = await q(`SELECT 1 FROM seasons WHERE id=$1`, [seasonId]);
      if (!chk.rowCount) return bad(res, 404, 'Saison introuvable');
      fields.push(`season_id=$${values.length + 1}`);
      values.push(seasonId);
    }
  }
  if (req.body?.rr_match_mode !== undefined) {
    const mode = req.body.rr_match_mode === 'home_away'
      ? 'home_away'
      : (req.body.rr_match_mode === 'single' ? 'single' : null);
    if (!mode) return bad(res, 400, 'rr_match_mode invalide');
    fields.push(`rr_match_mode=$${values.length + 1}`);
    values.push(mode);
  }
  if (req.body?.rr_standings_mode !== undefined) {
    const mode = req.body.rr_standings_mode === 'wins'
      ? 'wins'
      : (req.body.rr_standings_mode === 'goals' ? 'goals' : null);
    if (!mode) return bad(res, 400, 'rr_standings_mode invalide');
    fields.push(`rr_standings_mode=$${values.length + 1}`);
    values.push(mode);
  }
  if (!fields.length) return bad(res, 400, 'Aucune modification demandée');
  fields.push(`updated_at=now()`);
  values.push(id);

  try {
    const upd = await q(`UPDATE tournaments SET ${fields.join(', ')} WHERE id=$${values.length} RETURNING id`, values);
    if (!upd.rowCount) return bad(res, 404, 'Tournoi introuvable');
    const bundle = await getTournamentBundle(id);
    emitTournamentRealtime(bundle, 'updated');
    ok(res, bundle);
  } catch (e) {
    bad(res, 500, e.message || 'Mise Ã  jour impossible');
  }
};

app.patch('/admin/tournaments/:id', auth, adminOnly, updateTournamentHandler);
app.put('/admin/tournaments/:id', auth, adminOnly, updateTournamentHandler);

app.delete('/admin/tournaments/:id', auth, adminOnly, async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) return bad(res, 400, 'id invalide');
  try {
    const t = await q(`SELECT id, name, status, member_tournament, starts_at FROM tournaments WHERE id=$1`, [id]);
    if (!t.rowCount) return bad(res, 404, 'Tournoi introuvable');
    const row = t.rows[0];
    if (row.member_tournament) {
      const ackDelete = req.body?.confirm_member_delete === true;
      const ackPoints = req.body?.confirm_points_reset === true;
      if (!ackDelete || !ackPoints) {
        return bad(res, 400, 'Suppression protégée: confirme la suppression et la réinitialisation des points du classement.');
      }
    }
    await q(`DELETE FROM tournaments WHERE id=$1`, [id]);
    emitTournamentRealtime(row, 'deleted');
    if (row.member_tournament) io.emit('season:changed');
    ok(res, {
      ok: true,
      deleted: {
        id: row.id,
        name: row.name,
        member_tournament: row.member_tournament
      },
      standings_recomputed: true
    });
  } catch (e) {
    bad(res, 500, e.message || 'Suppression impossible');
  }
});

app.get('/tournaments/member/day/:date', auth, async (req, res) => {
  const date = String(req.params.date || '').trim();
  if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) return bad(res, 400, 'date invalide (YYYY-MM-DD)');
  try {
    const rows = await q(`
      SELECT id
      FROM tournaments
      WHERE member_tournament=true
        AND status <> 'archived'
        AND starts_at IS NOT NULL
        AND starts_at >= $1::date
        AND starts_at < ($1::date + INTERVAL '1 day')
      ORDER BY starts_at ASC, id ASC
    `, [date]);

    const tournaments = [];
    for (const r of rows.rows) {
      const bundle = await getTournamentBundle(r.id);
      if (!bundle?.tournament) continue;

      let standings = null;
      if (bundle.tournament.format === 'round_robin') {
        standings = await computeRoundRobinStandings(null, bundle.tournament.id);
      } else if (bundle.tournament.format === 'groups_knockout') {
        const count = bundle.tournament.nb_groups || 2;
        const groups = [];
        for (let gn = 0; gn < count; gn++) {
          const st = await computeGroupStandings(null, bundle.tournament.id, gn);
          groups.push({ group_no: gn, standings: st });
        }
        standings = { groups };
      }

      const finalRanking = rankTournamentParticipants(bundle.tournament, bundle.participants || [], bundle.matches || []);
      tournaments.push({
        ...bundle,
        standings,
        final_ranking: finalRanking
      });
    }
    ok(res, { date, tournaments });
  } catch (e) {
    bad(res, 500, e.message || 'Impossible de charger les tournois du jour');
  }
});

app.put('/admin/tournaments/:id/participants', auth, adminOnly, async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) return bad(res, 400, 'id invalide');
  // Accept array of free-text names (Challonge style)
  const raw = Array.isArray(req.body?.names) ? req.body.names : [];
  const names = raw.map((x) => String(x || '').trim()).filter(Boolean);
  if (names.length < 2) return bad(res, 400, 'Au moins 2 participants requis');
  const lowerNames = names.map(n => n.toLowerCase());
  if (new Set(lowerNames).size !== names.length) return bad(res, 400, 'Noms en doublon');
  if (names.some(n => n.length > 64)) return bad(res, 400, 'Nom trop long (max 64 caractÃ¨res)');

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const t = await client.query(`SELECT id, status, member_tournament FROM tournaments WHERE id=$1 FOR UPDATE`, [id]);
    if (!t.rowCount) { await client.query('ROLLBACK'); return bad(res, 404, 'Tournoi introuvable'); }
    if (['completed', 'archived'].includes(t.rows[0].status)) {
      await client.query('ROLLBACK'); return bad(res, 400, 'Tournoi verrouillé');
    }
    const isMemberTournament = t.rows[0].member_tournament !== false;

    await client.query(`DELETE FROM tournament_matches WHERE tournament_id=$1`, [id]);
    await client.query(`DELETE FROM tournament_participants WHERE tournament_id=$1`, [id]);

    let rowsToInsert = [];
    if (isMemberTournament) {
      const seenPlayerIds = new Set();
      for (const token of names) {
        const ref = String(token || '').trim();
        const found = await client.query(`
          SELECT player_id, name
          FROM players
          WHERE lower(player_id)=lower($1) OR lower(name)=lower($1)
          ORDER BY CASE WHEN lower(player_id)=lower($1) THEN 0 ELSE 1 END, player_id ASC
          LIMIT 3
        `, [ref]);
        if (!found.rowCount) {
          await client.query('ROLLBACK');
          return bad(res, 400, `Joueur introuvable: ${ref}`);
        }
        const hasExactPlayerId = found.rows.some((r) => String(r.player_id || '').toLowerCase() === ref.toLowerCase());
        if (!hasExactPlayerId && found.rowCount > 1) {
          await client.query('ROLLBACK');
          return bad(res, 400, `Nom ambigu: ${ref}`);
        }
        const picked = found.rows[0];
        if (seenPlayerIds.has(picked.player_id)) {
          await client.query('ROLLBACK');
          return bad(res, 400, `Doublon joueur: ${picked.name || picked.player_id}`);
        }
        seenPlayerIds.add(picked.player_id);
        rowsToInsert.push({
          display_name: picked.name || picked.player_id,
          player_id: picked.player_id,
        });
      }
    } else {
      rowsToInsert = names.map((displayName) => ({ display_name: displayName, player_id: null }));
    }

    if (rowsToInsert.length < 2) {
      await client.query('ROLLBACK');
      return bad(res, 400, 'Au moins 2 participants requis');
    }

    for (let i = 0; i < rowsToInsert.length; i++) {
      await client.query(`
        INSERT INTO tournament_participants(tournament_id, display_name, player_id, seed)
        VALUES($1,$2,$3,$4)
      `, [id, rowsToInsert[i].display_name, rowsToInsert[i].player_id, i + 1]);
    }

    await client.query(`
      UPDATE tournaments SET status='draft', winner_name=NULL, ended_at=NULL, updated_at=now()
      WHERE id=$1
    `, [id]);
    await client.query('COMMIT');

    const bundle = await getTournamentBundle(id);
    emitTournamentRealtime(bundle, 'participants');
    ok(res, bundle);
  } catch (e) {
    try { await client.query('ROLLBACK'); } catch (_) {}
    bad(res, 500, e.message || 'Mise Ã  jour des participants impossible');
  } finally {
    client.release();
  }
});

app.post('/admin/tournaments/:id/generate', auth, adminOnly, async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) return bad(res, 400, 'id invalide');

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const t = await client.query(`
      SELECT id, format, status, rr_match_mode FROM tournaments WHERE id=$1 FOR UPDATE
    `, [id]);
    if (!t.rowCount) {
      await client.query('ROLLBACK');
      return bad(res, 404, 'Tournoi introuvable');
    }
    const fmt = t.rows[0].format;
    const rrMatchMode = t.rows[0].rr_match_mode || 'single';
    if (t.rows[0].status === 'archived') {
      await client.query('ROLLBACK');
      return bad(res, 400, 'Tournoi archivé');
    }

    const participants = await client.query(`
      SELECT id, seed
      FROM tournament_participants
      WHERE tournament_id=$1
      ORDER BY seed ASC NULLS LAST, id ASC
    `, [id]);
    const count = participants.rowCount;
    if (count < 2) {
      await client.query('ROLLBACK');
      return bad(res, 400, 'Il faut au moins 2 participants');
    }

    await client.query(`DELETE FROM tournament_matches WHERE tournament_id=$1`, [id]);

    if (fmt === 'round_robin') {
      await generateRoundRobin(client, id, participants, rrMatchMode);
    } else if (fmt === 'double_elimination') {
      await generateDoubleElimination(client, id, participants);
    } else if (fmt === 'groups_knockout') {
      const nb_groups = Math.max(2, parseInt(req.body?.nb_groups || 2, 10));
      const qual_per_group = Math.max(1, parseInt(req.body?.qualifiers_per_group || 2, 10));
      await client.query(`UPDATE tournaments SET nb_groups=$1, qualifiers_per_group=$2, updated_at=now() WHERE id=$3`, [nb_groups, qual_per_group, id]);
      await generateGroupsKnockout(client, id, participants, nb_groups, qual_per_group);
    } else {
      await generateSingleElimination(client, id, participants);
    }

    if (fmt !== 'round_robin' && fmt !== 'groups_knockout') {
      await autoAdvanceWalkovers(client, id);
    }
    await client.query(`
      UPDATE tournaments
      SET status = CASE WHEN status='completed' THEN status ELSE 'live' END, updated_at=now()
      WHERE id=$1
    `, [id]);

    await client.query('COMMIT');
    const bundle = await getTournamentBundle(id);
    emitTournamentRealtime(bundle, 'generated');
    ok(res, bundle);
  } catch (e) {
    try { await client.query('ROLLBACK'); } catch (_) {}
    bad(res, 500, e.message || 'Génération du bracket impossible');
  } finally {
    client.release();
  }
});

app.post('/admin/tournaments/:id/generate-knockout', auth, adminOnly, async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) return bad(res, 400, 'id invalide');
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const t = await client.query(`
      SELECT id, format, status, nb_groups, qualifiers_per_group FROM tournaments WHERE id=$1 FOR UPDATE
    `, [id]);
    if (!t.rowCount) { await client.query('ROLLBACK'); return bad(res, 404, 'Tournoi introuvable'); }
    const { format, status, nb_groups, qualifiers_per_group } = t.rows[0];
    if (format !== 'groups_knockout') { await client.query('ROLLBACK'); return bad(res, 400, 'Format non applicable'); }
    if (status === 'archived') { await client.query('ROLLBACK'); return bad(res, 400, 'Tournoi archivé'); }
    const nbG = nb_groups || 2;
    const qualPG = qualifiers_per_group || 2;
    // Vérifier que tous les matchs de groupe sont terminés
    const pending = await client.query(`
      SELECT COUNT(*) FROM tournament_matches WHERE tournament_id=$1 AND bracket_side='G' AND status!='completed'
    `, [id]);
    if (Number(pending.rows[0].count) > 0) {
      await client.query('ROLLBACK');
      return bad(res, 400, 'La phase de groupes n\'est pas encore terminée');
    }
    // Construire la liste des qualifiés : G0-1er, G1-1er, ..., G0-2e, G1-2e, ...
    const perGroup = [];
    for (let gn = 0; gn < nbG; gn++) {
      const standings = await computeGroupStandings(client, id, gn);
      perGroup.push(standings.slice(0, qualPG));
    }
    const qualifiers = [];
    for (let rank = 0; rank < qualPG; rank++) {
      for (let gn = 0; gn < nbG; gn++) {
        if (perGroup[gn][rank]) qualifiers.push({ id: perGroup[gn][rank].participant_id });
      }
    }
    if (qualifiers.length < 2) {
      await client.query('ROLLBACK');
      return bad(res, 400, 'Pas assez de qualifiés pour générer le tableau final');
    }
    // Supprimer les matchs knockout existants (garder les matchs de groupe)
    await client.query(`DELETE FROM tournament_matches WHERE tournament_id=$1 AND (bracket_side IS NULL OR bracket_side != 'G')`, [id]);
    // Générer le bracket SE depuis les qualifiés (round_no offset 100 pour éviter conflit avec les matchs de groupe)
    const fakeParticipants = { rows: qualifiers, rowCount: qualifiers.length };
    await generateSingleElimination(client, id, fakeParticipants, 100);
    await autoAdvanceWalkovers(client, id);
    await client.query('COMMIT');
    const bundle = await getTournamentBundle(id);
    emitTournamentRealtime(bundle, 'knockout-generated');
    ok(res, bundle);
  } catch (e) {
    try { await client.query('ROLLBACK'); } catch (_) {}
    bad(res, 500, e.message || 'Génération du tableau final impossible');
  } finally {
    client.release();
  }
});

app.post('/admin/tournaments/:id/matches/:matchId/result', auth, adminOnly, async (req, res) => {
  const tournamentId = Number(req.params.id);
  const matchId = Number(req.params.matchId);
  if (!Number.isInteger(tournamentId) || tournamentId <= 0) return bad(res, 400, 'id tournoi invalide');
  if (!Number.isInteger(matchId) || matchId <= 0) return bad(res, 400, 'id match invalide');

  const score1 = parseScoreValue(req.body?.score_p1);
  const score2 = parseScoreValue(req.body?.score_p2);
  if (score1 === null || score2 === null) return bad(res, 400, 'Scores invalides');

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const t = await client.query(`SELECT id, status, format FROM tournaments WHERE id=$1 FOR UPDATE`, [tournamentId]);
    if (!t.rowCount) {
      await client.query('ROLLBACK');
      return bad(res, 404, 'Tournoi introuvable');
    }
    if (t.rows[0].status === 'archived') {
      await client.query('ROLLBACK');
      return bad(res, 400, 'Tournoi archivé');
    }
    const format = t.rows[0].format;

    const m = await client.query(`
      SELECT id, tournament_id, status, p1_participant_id, p2_participant_id,
             winner_participant_id, next_match_id, next_match_slot,
             bracket_side, loser_next_match_id, loser_next_match_slot, group_no
      FROM tournament_matches
      WHERE id=$1 AND tournament_id=$2
      FOR UPDATE
    `, [matchId, tournamentId]);
    if (!m.rowCount) {
      await client.query('ROLLBACK');
      return bad(res, 404, 'Match introuvable');
    }
    const match = m.rows[0];
    if (!match.p1_participant_id || !match.p2_participant_id) {
      await client.query('ROLLBACK');
      return bad(res, 400, 'Le match n\'a pas encore 2 participants');
    }

    const isReedit = match.status === 'completed';
    const isGroupMatch = match.group_no !== null && match.group_no !== undefined;
    // Pour SE/DE : bloquer seulement si le match suivant a déjÃ  été joué
    // Pas de blocage pour la ré-édition : le cascade reset gÃ¨re les matchs aval

    if (format === 'round_robin' || isGroupMatch) {
      // Match nul autorisé en round robin / phase de groupes
      const winnerRR = score1 > score2 ? match.p1_participant_id : (score2 > score1 ? match.p2_participant_id : null);
      await client.query(`
        UPDATE tournament_matches
        SET score_p1=$1, score_p2=$2, winner_participant_id=$3, status='completed',
            walkover=false, finished_at=COALESCE(finished_at, now()), updated_at=now()
        WHERE id=$4
      `, [score1, score2, winnerRR, match.id]);
      if (format === 'round_robin') {
        await checkRoundRobinCompletion(client, tournamentId);
      } else {
        // Phase de groupes : s'assurer que le tournoi est live
        await client.query(`UPDATE tournaments SET status='live', updated_at=now() WHERE id=$1 AND status='draft'`, [tournamentId]);
      }
    } else {
      // Ã‰limination : match nul interdit
      if (score1 === score2) {
        await client.query('ROLLBACK');
        return bad(res, 400, 'Match nul interdit en élimination directe');
      }
      const newWinner = score1 > score2 ? match.p1_participant_id : match.p2_participant_id;
      const newLoser  = score1 > score2 ? match.p2_participant_id : match.p1_participant_id;
      const oldWinner = match.winner_participant_id;
      const oldLoser = oldWinner
        ? (oldWinner === match.p1_participant_id ? match.p2_participant_id : match.p1_participant_id)
        : null;
      await client.query(`
        UPDATE tournament_matches
        SET score_p1=$1, score_p2=$2, winner_participant_id=$3, status='completed',
            walkover=false, finished_at=COALESCE(finished_at, now()), updated_at=now()
        WHERE id=$4
      `, [score1, score2, newWinner, match.id]);
      // Mise Ã  jour de la progression dans le bracket
      if (!isReedit || newWinner !== oldWinner) {
        if (isReedit && oldWinner && newWinner !== oldWinner) {
          // Cascade reset : annuler tous les matchs aval qui dépendaient de l'ancien vainqueur
          await cascadeResetWinner(client, tournamentId, match.next_match_id, oldWinner);
        }
        await assignWinnerToNextMatch(client, tournamentId, match, newWinner);
      }
      const loserRoute = format === 'double_elimination'
        ? await resolveLoserRoute(client, tournamentId, match)
        : null;
      if (format === 'double_elimination' && loserRoute?.targetMatchId && newLoser) {
        if (isReedit && oldLoser && newLoser !== oldLoser) {
          await cascadeResetWinner(client, tournamentId, loserRoute.targetMatchId, oldLoser);
        }
        if (!isReedit || newLoser !== oldLoser) {
          await assignLoserToNextMatch(client, tournamentId, match, newLoser, loserRoute);
        }
      }
      await autoAdvanceWalkovers(client, tournamentId);
      await client.query(`
        UPDATE tournaments
        SET status = CASE WHEN status='draft' THEN 'live' ELSE status END, updated_at=now()
        WHERE id=$1
      `, [tournamentId]);
    }

    await client.query('COMMIT');
    const bundle = await getTournamentBundle(tournamentId);
    emitTournamentRealtime(bundle, 'score');
    if (bundle?.tournament?.member_tournament && bundle?.tournament?.status === 'completed') {
      io.emit('season:changed');
    }
    ok(res, bundle);
  } catch (e) {
    try { await client.query('ROLLBACK'); } catch (_) {}
    bad(res, 500, e.message || 'Validation du match impossible');
  } finally {
    client.release();
  }
});

/* ====== Players ====== */
function markOnlineField(rows){
  const now=Date.now();
  return rows.map(p=>{
    const ts = presence.players.get(p.player_id);
    const online = ts && (now - ts < PRESENCE_TTL_MS);
    return { ...p, online: !!online };
  });
}
app.get('/players', auth, async (_req,res)=>{
  const r = await q(`
    SELECT p.player_id, p.name, p.role, p.profile_pic_url, u.email AS user_email
    FROM players p
    LEFT JOIN users u ON u.player_id = p.player_id
    ORDER BY p.name ASC
  `);
  ok(res,{ players: markOnlineField(r.rows) });
});
app.get('/players/search', auth, async (req,res)=>{
  const qv=(req.query.q||'').trim();
  if(!qv) return ok(res,{ players:[] });
  const r=await q(`
    SELECT p.player_id, p.name, p.role, p.profile_pic_url, u.email AS user_email
    FROM players p
    LEFT JOIN users u ON u.player_id = p.player_id
    WHERE p.player_id ILIKE $1 OR p.name ILIKE $1
    ORDER BY p.name ASC
    LIMIT 20
  `, ['%'+qv+'%']);
  ok(res,{ players: markOnlineField(r.rows) });
});
app.get('/players/:pid', auth, async (req,res)=>{
  const r=await q(`SELECT player_id,name,role,profile_pic_url FROM players WHERE player_id=$1`,[req.params.pid]);
  if(!r.rowCount) return bad(res,404,'not found');
  const row = r.rows[0];
  const ts = presence.players.get(row.player_id);
  const online = ts && (Date.now()-ts < PRESENCE_TTL_MS);
  ok(res,{ player:{...row, online: !!online} });
});

// Mettre Ã  jour un joueur (admin seulement)
app.put('/admin/players/:oldId', auth, adminOnly, async (req, res) => {
  const oldId = req.params.oldId;
  const { player_id: newId, name, role } = req.body || {};

  // Vérifier que le joueur existe
  const existing = await q(`SELECT player_id, name, role FROM players WHERE player_id = $1`, [oldId]);
  if (!existing.rowCount) return bad(res, 404, 'Joueur introuvable');

  const player = existing.rows[0];
  const updatedName = name !== undefined ? name : player.name;
  const updatedRole = role !== undefined ? role : player.role;

  // Si l'ID change
  if (newId && newId !== oldId) {
    // Vérifier que le nouvel ID n'existe pas déjÃ 
    const conflict = await q(`SELECT player_id FROM players WHERE player_id = $1`, [newId]);
    if (conflict.rowCount) return bad(res, 409, 'Ce nouvel ID existe déjÃ ');

    // Fonction helper pour mettre Ã  jour les player_id dans un JSONB
    function updatePlayerIdInPayload(payload, oldId, newId) {
      if (!payload) return payload;
      let updated = false;

      // Mettre Ã  jour d1 et d2 (matchs)
      for (const div of ['d1', 'd2']) {
        if (Array.isArray(payload[div])) {
          payload[div].forEach(match => {
            if (match.p1 === oldId) { match.p1 = newId; updated = true; }
            if (match.p2 === oldId) { match.p2 = newId; updated = true; }
          });
        }
      }

      // Mettre Ã  jour champions
      if (payload.champions) {
        if (payload.champions.d1?.id === oldId) {
          payload.champions.d1.id = newId;
          updated = true;
        }
        if (payload.champions.d2?.id === oldId) {
          payload.champions.d2.id = newId;
          updated = true;
        }
      }

      // Mettre Ã  jour barrage
      if (payload.barrage?.winner === oldId) {
        payload.barrage.winner = newId;
        updated = true;
      }

      return updated ? payload : null;
    }

    // Mettre Ã  jour les matchdays
    const matchdays = await q(`SELECT day, payload FROM matchday ORDER BY day ASC`);
    for (const row of matchdays.rows) {
      const updatedPayload = updatePlayerIdInPayload(JSON.parse(JSON.stringify(row.payload)), oldId, newId);
      if (updatedPayload) {
        await q(`UPDATE matchday SET payload = $1 WHERE day = $2`, [JSON.stringify(updatedPayload), row.day]);
      }
    }

    // Mettre Ã  jour les drafts
    const drafts = await q(`SELECT day, payload FROM draft ORDER BY day ASC`);
    for (const row of drafts.rows) {
      const updatedPayload = updatePlayerIdInPayload(JSON.parse(JSON.stringify(row.payload)), oldId, newId);
      if (updatedPayload) {
        await q(`UPDATE draft SET payload = $1 WHERE day = $2`, [JSON.stringify(updatedPayload), row.day]);
      }
    }

    // Mettre Ã  jour la table players (CASCADE vers users et champion_result)
    await q(`UPDATE players SET player_id = $1, name = $2, role = $3 WHERE player_id = $4`,
      [newId, updatedName, updatedRole, oldId]);

    // Mettre Ã  jour la présence
    if (presence.players.has(oldId)) {
      const ts = presence.players.get(oldId);
      presence.players.delete(oldId);
      presence.players.set(newId, ts);
    }

    ok(res, { player: { player_id: newId, name: updatedName, role: updatedRole } });
  } else {
    // Mise Ã  jour simple sans changement d'ID
    await q(`UPDATE players SET name = $1, role = $2 WHERE player_id = $3`,
      [updatedName, updatedRole, oldId]);
    ok(res, { player: { player_id: oldId, name: updatedName, role: updatedRole } });
  }
});

// POST /admin/players - Créer un nouveau joueur
app.post('/admin/players', auth, adminOnly, async (req, res) => {
  try {
    const { player_id, name, role } = req.body || {};

    if (!player_id || !player_id.trim()) {
      return bad(res, 400, 'player_id requis');
    }

    if (!name || !name.trim()) {
      return bad(res, 400, 'name requis');
    }

    const trimmedId = player_id.trim();
    const trimmedName = name.trim();
    const playerRole = (role || 'MEMBRE').toUpperCase();

    // Vérifier que le player_id n'existe pas déjÃ 
    const existing = await q(`SELECT player_id FROM players WHERE player_id = $1`, [trimmedId]);
    if (existing.rowCount > 0) {
      return bad(res, 409, 'Ce player_id existe déjÃ ');
    }

    // Créer le joueur
    const result = await q(
      `INSERT INTO players (player_id, name, role) VALUES ($1, $2, $3) RETURNING *`,
      [trimmedId, trimmedName, playerRole]
    );

    ok(res, {
      message: 'Joueur créé',
      player: result.rows[0]
    });
  } catch (error) {
    console.error('Error creating player:', error);
    bad(res, 500, error.message || 'Erreur serveur');
  }
});

// POST /admin/players/:playerId/attach_user - Lier/créer un compte utilisateur
app.post('/admin/players/:playerId/attach_user', auth, adminOnly, async (req, res) => {
  try {
    const { playerId } = req.params;
    const { email, password } = req.body || {};

    if (!email || !email.trim()) {
      return bad(res, 400, 'Email requis');
    }

    // Vérifier que le joueur existe
    const playerCheck = await q(`SELECT player_id, name FROM players WHERE player_id = $1`, [playerId]);
    if (!playerCheck.rowCount) {
      return bad(res, 404, 'Joueur introuvable');
    }

    // Vérifier si un utilisateur existe déjÃ  avec cet email
    const existingUser = await q(`SELECT id, email, player_id FROM users WHERE email = $1`, [email.trim()]);

    let userId;
    if (existingUser.rowCount > 0) {
      // Utilisateur existe, le lier au joueur
      userId = existingUser.rows[0].id;

      // Vérifier si déjÃ  lié Ã  un autre joueur
      if (existingUser.rows[0].player_id && existingUser.rows[0].player_id !== playerId) {
        return bad(res, 409, `Cet email est déjÃ  lié au joueur ${existingUser.rows[0].player_id}`);
      }

      // Lier le joueur
      await q(`UPDATE users SET player_id = $1 WHERE id = $2`, [playerId, userId]);
    } else {
      // Créer un nouveau compte utilisateur
      if (!password || !password.trim()) {
        return bad(res, 400, 'Mot de passe requis pour créer un nouveau compte');
      }

      const hash = await bcrypt.hash(password.trim(), 10);
      const newUser = await q(
        `INSERT INTO users (email, password_hash, role, player_id) VALUES ($1, $2, 'member', $3) RETURNING id, email`,
        [email.trim(), hash, playerId]
      );
      userId = newUser.rows[0].id;
    }

    ok(res, {
      message: 'Compte lié avec succÃ¨s',
      user: { id: userId, email: email.trim() },
      player_id: playerId
    });
  } catch (error) {
    console.error('Error attaching user:', error);
    bad(res, 500, error.message || 'Erreur serveur');
  }
});

// DELETE /admin/players/:playerId - Supprimer un joueur
app.delete('/admin/players/:playerId', auth, adminOnly, async (req, res) => {
  try {
    const { playerId } = req.params;

    // Vérifier que le joueur existe
    const playerCheck = await q(`SELECT player_id, name, role FROM players WHERE player_id = $1`, [playerId]);
    if (!playerCheck.rowCount) {
      return bad(res, 404, 'Joueur introuvable');
    }

    const player = playerCheck.rows[0];

    // Supprimer le joueur (CASCADE supprimera les dépendances)
    // ATTENTION: Supprime toutes les références dans matchdays, stats, tournois, etc.
    await q(`DELETE FROM players WHERE player_id = $1`, [playerId]);

    // Retirer de la présence
    if (presence.players.has(playerId)) {
      presence.players.delete(playerId);
    }

    ok(res, {
      message: 'Joueur supprimé',
      player_id: playerId,
      name: player.name
    });
  } catch (error) {
    console.error('Error deleting player:', error);
    if (error && error.code === '23503') {
      return bad(res, 409, 'Impossible de supprimer ce joueur: il est utilise dans un tournoi');
    }
    bad(res, 500, error.message || 'Erreur serveur');
  }
});

/* ====== Standings helpers ====== */
async function currentSeasonId(){
  const r=await q(`SELECT id FROM seasons WHERE is_closed=false ORDER BY id DESC LIMIT 1`);
  return r.rows[0]?.id;
}
async function previousSeasonId(){
  const r=await q(`SELECT id FROM seasons WHERE is_closed=true ORDER BY id DESC LIMIT 1`);
  return r.rows[0]?.id || null;
}
async function resolveSeasonId(qv){
  if(!qv || String(qv).toLowerCase()==='current') return await currentSeasonId();
  if(String(qv).toLowerCase()==='previous') {
    const p = await previousSeasonId(); return p || await currentSeasonId();
  }
  if(/^\d+$/.test(String(qv))){
    const sid = +qv;
    const r=await q(`SELECT id FROM seasons WHERE id=$1`,[sid]);
    return r.rowCount ? sid : await currentSeasonId();
  }
  const r=await q(`SELECT id FROM seasons WHERE name ILIKE $1 ORDER BY id DESC LIMIT 1`, ['%'+qv+'%']);
  return r.rowCount ? r.rows[0].id : await currentSeasonId();
}
async function getPlayersRoles(){
  const r=await q(`SELECT player_id,role FROM players`);
  const map=new Map(); r.rows.forEach(p=>map.set(p.player_id,(p.role||'MEMBRE').toUpperCase())); return map;
}
function collectInviteIdsFromPayload(payload){
  const ids = new Set();
  const p = payload || {};
  for (const g of (p.tempGuests || [])) {
    const id = String(g?.player_id || '').trim();
    if (id) ids.add(id);
  }
  const scan = (matches=[]) => {
    for (const m of matches) {
      const p1 = String(m?.p1 || '').trim();
      const p2 = String(m?.p2 || '').trim();
      if (p1.startsWith('G_')) ids.add(p1);
      if (p2.startsWith('G_')) ids.add(p2);
    }
  };
  scan(p.d1 || []);
  scan(p.d2 || []);
  return ids;
}
function isEligibleMember(id, roles, inviteIds){
  const pid = String(id || '').trim();
  if (!pid || pid === '-' || pid === 'â€”') return false;
  if (inviteIds?.has(pid)) return false;
  if (pid.startsWith('G_')) return false;
  if (!roles.has(pid)) return false; // inconnu => considÃ¨re comme invité/éphémÃ¨re
  return (roles.get(pid) || 'MEMBRE') !== 'INVITE';
}
function computeStandings(matches){
  const agg={};
  function add(A,B,ga,gb){
    if(ga==null||gb==null) return;
    if(!agg[A]) agg[A]={J:0,V:0,N:0,D:0,BP:0,BC:0};
    if(!agg[B]) agg[B]={J:0,V:0,N:0,D:0,BP:0,BC:0};
    agg[A].J++; agg[B].J++;
    agg[A].BP+=ga; agg[A].BC+=gb;
    agg[B].BP+=gb; agg[B].BC+=ga;
    if(ga>gb){ agg[A].V++; agg[B].D++; }
    else if(ga<gb){ agg[B].V++; agg[A].D++; }
    else { agg[A].N++; agg[B].N++; }
  }
  for(const m of matches||[]){
    if(!m.p1||!m.p2) continue;
    if(m.a1!=null&&m.a2!=null) add(m.p1,m.p2,m.a1,m.a2);
    if(m.r1!=null&&m.r2!=null) add(m.p2,m.p1,m.r2,m.r1); // retour inversé
  }
  const arr = Object.entries(agg).map(([id,x])=>({id,...x,PTS:x.V*3+x.N,DIFF:x.BP-x.BC}));
  arr.sort((a,b)=>b.PTS-a.PTS||b.DIFF-a.DIFF||b.BP-a.BP||a.id.localeCompare(b.id));
  return arr;
}
const BONUS_D1_CHAMPION = 1;
function pointsD1(nPlayers, rank){
  if(rank<1||rank>nPlayers) return 0;
  const basePoints = 15;
  if(rank === 1) return basePoints;
  return basePoints - rank;
}
function pointsD2(rank){ const table=[10,8,7,6,5,4,3,2,1,1,1]; return rank>0 && rank<=table.length ? table[rank-1] : 1; }
function normalizeTournamentBracketSide(raw, format, roundNo){
  const side = String(raw || '').trim().toUpperCase();
  if (side === 'W' || side === 'WB') return 'W';
  if (side === 'L' || side === 'LB') return 'L';
  if (side === 'GF' || side === 'FINAL' || side === 'GRAND_FINAL') return 'GF';
  if (side === 'G' || side === 'GROUP') return 'G';
  if (format === 'double_elimination') {
    if (Number(roundNo) >= 20) return 'GF';
    if (Number(roundNo) >= 10) return 'L';
    return 'W';
  }
  if (format === 'groups_knockout') {
    if (Number(roundNo) >= 100) return 'W';
    return 'G';
  }
  return 'W';
}
function isEligibleTournamentMember(playerId, roles){
  const pid = String(playerId || '').trim();
  if (!pid || pid.startsWith('G_')) return false;
  if (!roles.has(pid)) return false;
  return (roles.get(pid) || 'MEMBRE') !== 'INVITE';
}
function rankTournamentParticipants(tournament, participants, matches){
  const rrWinsOnly = tournament?.format === 'round_robin' && String(tournament?.rr_standings_mode || 'goals') === 'wins';
  const stats = new Map();
  for (const p of (participants || [])) {
    const pid = Number(p?.id);
    if (!Number.isInteger(pid)) continue;
    const seedNum = Number(p?.seed);
    stats.set(pid, {
      participant_id: pid,
      player_id: p?.player_id || null,
      display_name: String(p?.display_name || p?.name || '').trim() || String(pid),
      seed: Number.isInteger(seedNum) ? seedNum : null,
      points: 0,
      wins: 0,
      draws: 0,
      losses: 0,
      gf: 0,
      ga: 0,
      played: 0,
    });
  }

  const completed = [];
  for (const m of (matches || [])) {
    const p1 = Number(m?.p1_participant_id);
    const p2 = Number(m?.p2_participant_id);
    if (!Number.isInteger(p1) || !Number.isInteger(p2)) continue;
    const s1 = Number(m?.score_p1);
    const s2 = Number(m?.score_p2);
    const status = String(m?.status || '').toLowerCase();
    if (!(status === 'completed' || status === 'done')) continue;
    if (!Number.isFinite(s1) || !Number.isFinite(s2)) continue;
    if (!stats.has(p1) || !stats.has(p2)) continue;

    const a = stats.get(p1);
    const b = stats.get(p2);
    a.played += 1; b.played += 1;
    a.gf += s1; a.ga += s2;
    b.gf += s2; b.ga += s1;
    if (s1 > s2) {
      a.points += rrWinsOnly ? 1 : 3; a.wins += 1; b.losses += 1;
    } else if (s2 > s1) {
      b.points += rrWinsOnly ? 1 : 3; b.wins += 1; a.losses += 1;
    } else {
      a.points += rrWinsOnly ? 0 : 1; b.points += rrWinsOnly ? 0 : 1; a.draws += 1; b.draws += 1;
    }
    completed.push(m);
  }

  // For round_robin, rank is purely standings-based — no bracket finals detection
  if (tournament?.format === 'round_robin') {
    const rows = [...stats.values()];
    rows.sort((a, b) => {
      const diffA = a.gf - a.ga;
      const diffB = b.gf - b.ga;
      const seedA = Number.isInteger(a.seed) ? a.seed : Number.MAX_SAFE_INTEGER;
      const seedB = Number.isInteger(b.seed) ? b.seed : Number.MAX_SAFE_INTEGER;
      if (rrWinsOnly) {
        return b.wins - a.wins
          || a.played - b.played
          || seedA - seedB
          || String(a.display_name).localeCompare(String(b.display_name), 'fr');
      }
      return b.points - a.points
        || b.wins - a.wins
        || diffB - diffA
        || b.gf - a.gf
        || b.played - a.played
        || seedA - seedB
        || String(a.display_name).localeCompare(String(b.display_name), 'fr');
    });
    return rows.map((row, idx) => ({ ...row, rank: idx + 1 }));
  }

  let championId = null;
  let runnerId = null;
  const finals = completed
    .filter((m) => {
      const side = normalizeTournamentBracketSide(m?.bracket_side, tournament?.format, m?.round_no);
      const winner = Number(m?.winner_participant_id);
      return side !== 'G' && Number.isInteger(winner) && !m?.next_match_id;
    })
    .sort((a, b) => {
      const p = (mm) => {
        const s = normalizeTournamentBracketSide(mm?.bracket_side, tournament?.format, mm?.round_no);
        if (s === 'GF') return 3;
        if (s === 'W') return 2;
        if (s === 'L') return 1;
        return 0;
      };
      return p(b) - p(a) || Number(b?.round_no || 0) - Number(a?.round_no || 0) || Number(b?.id || 0) - Number(a?.id || 0);
    });

  if (finals.length) {
    const fm = finals[0];
    const w = Number(fm?.winner_participant_id);
    const p1 = Number(fm?.p1_participant_id);
    const p2 = Number(fm?.p2_participant_id);
    if (Number.isInteger(w)) championId = w;
    if (Number.isInteger(championId)) runnerId = championId === p1 ? p2 : p1;
  } else if (tournament?.winner_name) {
    const byName = String(tournament.winner_name).trim().toLowerCase();
    for (const row of stats.values()) {
      if (String(row.display_name || '').trim().toLowerCase() === byName) {
        championId = row.participant_id;
        break;
      }
    }
  }

  const rows = [...stats.values()];
  rows.sort((a, b) => {
    const tier = (x) => {
      if (Number.isInteger(championId) && x.participant_id === championId) return 0;
      if (Number.isInteger(runnerId) && x.participant_id === runnerId) return 1;
      return 2;
    };
    const t = tier(a) - tier(b);
    if (t !== 0) return t;
    const diffA = a.gf - a.ga;
    const diffB = b.gf - b.ga;
    const seedA = Number.isInteger(a.seed) ? a.seed : Number.MAX_SAFE_INTEGER;
    const seedB = Number.isInteger(b.seed) ? b.seed : Number.MAX_SAFE_INTEGER;
    return b.points - a.points
      || b.wins - a.wins
      || diffB - diffA
      || b.gf - a.gf
      || b.played - a.played
      || seedA - seedB
      || String(a.display_name).localeCompare(String(b.display_name), 'fr');
  });
  return rows.map((row, idx) => ({ ...row, rank: idx + 1 }));
}
async function attachPlayerIdsByDisplayName(rows){
  const keys = [...new Set(
    (rows || [])
      .filter((r) => !r?.player_id)
      .map((r) => String(r?.display_name || '').trim().toLowerCase())
      .filter(Boolean)
  )];
  if (!keys.length) return rows;

  const found = await q(`
    SELECT player_id, name
    FROM players
    WHERE lower(name)=ANY($1::text[])
  `, [keys]);

  const byName = new Map();
  for (const row of found.rows) {
    const key = String(row?.name || '').trim().toLowerCase();
    if (!key) continue;
    if (!byName.has(key)) byName.set(key, []);
    byName.get(key).push(row);
  }

  return (rows || []).map((row) => {
    if (row?.player_id) return row;
    const key = String(row?.display_name || '').trim().toLowerCase();
    const candidates = byName.get(key) || [];
    if (candidates.length === 1) {
      return { ...row, player_id: candidates[0].player_id };
    }
    return row;
  });
}
async function computeSeasonStandings(seasonId){
  const days = await q(`SELECT day,payload FROM matchday WHERE season_id=$1 ORDER BY day ASC`,[seasonId]);
  const roles = await getPlayersRoles();
  const totals = new Map(); // id -> {id,total,participations,won_d1,won_d2,teams:Set}
  const ensure = id=>{ if(!totals.has(id)) totals.set(id,{id,total:0,participations:0,won_d1:0,won_d2:0,teams:new Set()}); return totals.get(id); };

  for(const row of days.rows){
    const p=row.payload||{};
    const inviteIds = collectInviteIdsFromPayload(p);
    const st1Full=computeStandings(p.d1||[]);
    const st2Full=computeStandings(p.d2||[]);

    const st1 = st1Full.filter(r => isEligibleMember(r.id, roles, inviteIds));
    const st2 = st2Full.filter(r => isEligibleMember(r.id, roles, inviteIds));

    const n1=st1.length, n2=st2.length;

    st1.forEach((r,idx)=>{ const o=ensure(r.id); o.total += pointsD1(n1, idx+1); o.participations+=1; });
    st2.forEach((r,idx)=>{ const o=ensure(r.id); o.total += pointsD2(idx+1);   o.participations+=1; });

    const champD1=p?.champions?.d1?.id||null;
    if(champD1 && isEligibleMember(champD1, roles, inviteIds)){ ensure(champD1).total += BONUS_D1_CHAMPION; ensure(champD1).won_d1++; }
    const champD2=p?.champions?.d2?.id||null;
    if(champD2 && isEligibleMember(champD2, roles, inviteIds)){ ensure(champD2).won_d2++; }

    const teamD1 = p?.champions?.d1?.team;
    if (champD1 && teamD1 && isEligibleMember(champD1, roles, inviteIds)){ const k = teamKey(teamD1); if (k) ensure(champD1).teams.add(k); }
    // D2 teams intentionally excluded from teams_used count
  }

  // Tournois membres terminés:
  // - ajout de points selon le barème D1
  // - impact sur TOTAL, PARTICIP. et donc MOYENNE
  const tournaments = await q(`
    SELECT id, format, winner_name, rr_standings_mode
    FROM tournaments
    WHERE season_id=$1
      AND status='completed'
      AND member_tournament=true
      AND counts_for_title=true
    ORDER BY COALESCE(ended_at, updated_at, created_at) ASC, id ASC
  `, [seasonId]);

  for (const t of tournaments.rows) {
    const parts = await q(`
      SELECT id, player_id, display_name, seed
      FROM tournament_participants
      WHERE tournament_id=$1
      ORDER BY seed ASC NULLS LAST, id ASC
    `, [t.id]);
    if (!parts.rowCount) continue;

    const matches = await q(`
      SELECT
        id, round_no, bracket_side, group_no, status, next_match_id,
        p1_participant_id, p2_participant_id, winner_participant_id,
        score_p1, score_p2
      FROM tournament_matches
      WHERE tournament_id=$1
      ORDER BY round_no ASC, slot_no ASC
    `, [t.id]);

    let ranking = rankTournamentParticipants(t, parts.rows, matches.rows);
    ranking = await attachPlayerIdsByDisplayName(ranking);
    const eligible = ranking.filter((row) => isEligibleTournamentMember(row.player_id, roles));
    const n = eligible.length;
    if (!n) continue;

    eligible.forEach((row, idx) => {
      const pts = pointsD1(n, idx + 1);
      const o = ensure(row.player_id);
      o.total += pts;
      o.participations += 1;
    });
  }

  const allIds=[...totals.keys()];
  if(allIds.length){
    const r=await q(`SELECT player_id,name FROM players WHERE player_id=ANY($1::text[])`,[allIds]);
    const nameById=new Map(r.rows.map(x=>[x.player_id,x.name]));
    for(const o of totals.values()){
      o.name = nameById.get(o.id)||o.id;
      o.moyenne = o.participations>0 ? +(o.total/o.participations).toFixed(2) : 0;
    }
  }
  const arr=[...totals.values()].map(o=>({
    id:o.id, name:o.name, total:o.total, participations:o.participations,
    moyenne:o.moyenne, won_d1:o.won_d1, won_d2:o.won_d2,
    teams_used: o.teams ? o.teams.size : 0
  }));
  arr.sort((a,b)=> b.moyenne-a.moyenne || b.total-a.total || a.name.localeCompare(b.name));
  return arr;
}

/* ====== /leaderboard (alias pour tes pages) ====== */
app.get('/leaderboard', auth, async (req,res)=>{
  const sid = await resolveSeasonId(req.query.season);
  const list = await computeSeasonStandings(sid);
  // adapte aux besoins front : name, player_id, points (=total), games (=participations)
  const leaderboard = list.map(x=>({
    player_id: x.id,
    name: x.name,
    points: x.total,
    games: x.participations,
    wins: undefined, draws: undefined, losses: undefined, // non calculés au niveau saison (optionnel)
    gf: undefined, ga: undefined, gd: undefined
  }));
  ok(res,{ season_id:sid, leaderboard });
});

/* ====== Member panel (/me*) ====== */
async function loadDaysForSeason(seasonId){
  const r = await q(`SELECT day,payload FROM matchday WHERE season_id=$1 ORDER BY day ASC`, [seasonId]);
  return { season_id: seasonId, rows: r.rows };
}
function rowsForPlayer(payload, pid, date){
  const out=[];
  for(const div of ['d1','d2']){
    for(const m of (payload?.[div]||[])){
      if(!m?.p1 || !m?.p2) continue;
      if(m.p1!==pid && m.p2!==pid) continue;
      const home=(m.p1===pid), opp=home?m.p2:m.p1;
      const aller =(m.a1!=null&&m.a2!=null)?{gf:home?m.a1:m.a2,ga:home?m.a2:m.a1}:null;
      const retour=(m.r1!=null&&m.r2!=null)?{gf:home?m.r1:m.r2,ga:home?m.r2:m.r1}:null;
      out.push({date, division:div.toUpperCase(), opponent:opp, aller, retour});
    }
  }
  return out;
}
app.get('/me/player', auth, async (req,res)=>{
  const r=await q(`SELECT id,email,role,player_id FROM users WHERE id=$1`,[req.user.uid]);
  const user = r.rows[0];
  if(!user?.player_id) return bad(res,404,'Aucun joueur lié');
  const p = await q(`SELECT player_id,name,role,profile_pic_url FROM players WHERE player_id=$1`,[user.player_id]);
  ok(res,{ player:p.rows[0]||null });
});
app.get('/me/matches', auth, async (req,res)=>{
  const pid = await getLinkedPlayerId(req.user.uid);
  if(!pid) return bad(res,404,'Aucun joueur lié');
  const sid = await resolveSeasonId(req.query.season);
  const { rows } = await loadDaysForSeason(sid);
  const out=[];
  for(const d of rows) out.push(...rowsForPlayer(d.payload, pid, d.day));
  const uniq=[...new Set(out.map(x=>x.opponent))];
  if(uniq.length){
    const r=await q(`SELECT player_id,name FROM players WHERE player_id=ANY($1::text[])`,[uniq]);
    const map=new Map(r.rows.map(x=>[x.player_id,x.name]));
    out.forEach(x=> x.opponent_name = map.get(x.opponent)||x.opponent);
  }
  ok(res,{ season_id:sid, matches: out });
});
app.get('/me/stats', auth, async (req,res)=>{
  const pid = await getLinkedPlayerId(req.user.uid);
  if(!pid) return bad(res,404,'player not linked');
  const sid = await resolveSeasonId(req.query.season);
  const { rows } = await loadDaysForSeason(sid);

  let played=0, GF=0, GA=0;
  let best={gf:0,ga:0,date:null,opp:null,leg:null,division:null};
  for(const d of rows){
    const R = rowsForPlayer(d.payload, pid, d.day);
    for(const r of R){
      if(r.aller){ played++; GF+=r.aller.gf; GA+=r.aller.ga;
        if(r.aller.gf>best.gf) best={gf:r.aller.gf,ga:r.aller.ga,date:r.date,opp:r.opponent,leg:'Aller',division:r.division}; }
      if(r.retour){ played++; GF+=r.retour.gf; GA+=r.retour.ga;
        if(r.retour.gf>best.gf) best={gf:r.retour.gf,ga:r.retour.ga,date:r.date,opp:r.opponent,leg:'Retour',division:r.division}; }
    }
  }

  let rank=null, points=null, moyenne=null;
  try{
    const st=await computeSeasonStandings(sid);
    const ix=st.findIndex(x=>x.id===pid);
    if(ix>=0){ rank=ix+1; points=st[ix].total; moyenne=st[ix].moyenne; }
  }catch(_){}

  if(best.opp){
    const r=await q(`SELECT name FROM players WHERE player_id=$1`,[best.opp]);
    best.opp_name = r.rows[0]?.name || best.opp;
  }
  ok(res,{ season_id:sid, played_legs:played, goals_for:GF, goals_against:GA, best_single:best, season_rank:rank, season_points:points, season_average:moyenne });
});
app.put('/me/name', auth, async (req,res)=>{
  const { name } = req.body||{};
  if(!name || name.trim().length<2) return bad(res,400,'nom invalide');
  const pid = await getLinkedPlayerId(req.user.uid);
  if(!pid) return bad(res,404,'player not linked');
  const r = await q(`UPDATE players SET name=$2 WHERE player_id=$1 RETURNING player_id,name,role,profile_pic_url`, [pid, name.trim()]);
  ok(res,{ player:r.rows[0] });
});
app.put('/me/password', auth, async (req,res)=>{
  const { currentPassword, newPassword } = req.body||{};
  if(!newPassword || newPassword.length<6) return bad(res,400,'mot de passe trop court');
  const u = await q(`SELECT id,password_hash FROM users WHERE id=$1`,[req.user.uid]);
  if(!u.rowCount) return bad(res,404,'user not found');
  if(currentPassword){
    const okc = await bcrypt.compare(currentPassword, u.rows[0].password_hash);
    if(!okc) return bad(res,403,'mot de passe actuel incorrect');
  }
  const newHash = await bcrypt.hash(newPassword,10);
  await q(`UPDATE users SET password_hash=$2 WHERE id=$1`,[req.user.uid,newHash]);
  ok(res,{ ok:true });
});
app.post('/me/photo', auth, upload.single('photo'), async (req,res)=>{
  const pid = await getLinkedPlayerId(req.user.uid);
  if(!pid) return bad(res,404,'player not linked');
  if(!req.file) return bad(res,400,'fichier requis');
  const url = `/uploads/players/${req.file.filename}`;
  const r = await q(`UPDATE players SET profile_pic_url=$2 WHERE player_id=$1 RETURNING player_id,name,role,profile_pic_url`, [pid, url]);
  ok(res,{ player:r.rows[0] });
});

/* ====== Presence (beat & list) ====== */
app.post('/presence/beat', auth, async (req,res)=>{
  const r = await q(`SELECT player_id FROM users WHERE id=$1`,[req.user.uid]);
  const pid = r.rows[0]?.player_id;
  if(pid){ presence.players.set(pid, Date.now()); }
  ok(res,{ ok:true });
});
app.get('/presence/players', auth, async (_req,res)=>{
  const now=Date.now(), TTL=PRESENCE_TTL_MS;
  const online=[];
  for(const [pid,ts] of presence.players.entries()){
    if(now - ts <= TTL) online.push(pid);
  }
  ok(res,{ online });
});

/* ====== Matchdays ====== */
app.get('/matchdays', auth, async (req,res)=>{
  const sid = await resolveSeasonId(req.query.season);
  const r = await q(
    `SELECT day FROM matchday
     WHERE season_id=$1
     ORDER BY day ASC`,
    [sid]
  );
  ok(res, { season_id: sid, days: r.rows.map(x=>dayjs(x.day).format('YYYY-MM-DD')) });
});
app.get('/matchdays/:date', auth, async (req,res)=>{
  const d = req.params.date;
  const r = await q(`SELECT payload FROM matchday WHERE day=$1`,[d]);
  if (!r.rowCount) return bad(res,404,'introuvable');
  res.json(r.rows[0].payload);
});

/* ====== Drafts temps réel ====== */
app.get('/matchdays/draft/:date', auth, async (req,res)=>{
  const d = req.params.date;
  try{
    const r = await q('SELECT payload FROM draft WHERE day=$1',[d]);
    if(!r.rowCount) return bad(res,404,'no draft');
    ok(res,{ payload: r.rows[0].payload });
  }catch(e){ bad(res,500,'draft get error'); }
});
app.put('/matchdays/draft/:date', auth, async (req,res)=>{
  const d = req.params.date;
  // âœ… FIX: Validation de la date et du payload
  if(!/^\d{4}-\d{2}-\d{2}$/.test(d)) return bad(res,400,'Invalid date format (YYYY-MM-DD expected)');
  if(!req.body || typeof req.body !== 'object') return bad(res,400,'Invalid payload');

  const payload = req.body;
  try{
    await q(`INSERT INTO draft(day,payload,updated_at,author_user_id)
         VALUES ($1,$2,now(),$3)
         ON CONFLICT (day) DO UPDATE
         SET payload=EXCLUDED.payload, updated_at=now(), author_user_id=EXCLUDED.author_user_id`,
       [d, payload, req.user?.uid || null]);

    io.to(`draft:${d}`).emit('draft:update', { date:d });
    io.to(`day:${d}`).emit('day:updated', { date:d, source:'draft' });
    ok(res,{ ok:true });
  }catch(e){ bad(res,500,'draft save error'); }
});
app.delete('/matchdays/draft/:date', auth, async (req,res)=>{
  try{
    await q('DELETE FROM draft WHERE day=$1',[req.params.date]);
    ok(res,{ ok:true });
  }catch(e){ bad(res,500,'draft delete error'); }
});

app.put('/matchdays/:day/season', auth, adminOnly, async (req,res)=>{
  const day = req.params.day;
  const { season_id } = req.body||{};
  if(!season_id) return bad(res,400,'season_id requis');
  const chk = await q(`SELECT 1 FROM seasons WHERE id=$1`,[+season_id]);
  if(!chk.rowCount) return bad(res,404,'saison inconnue');
  await q(`UPDATE matchday SET season_id=$2 WHERE day=$1`,[day,+season_id]);
  ok(res,{ ok:true });
});
app.post('/matchdays/confirm', auth, adminOnly, async (req,res)=>{
  const { date, d1=[], d2=[], barrage={}, champions={}, season_id } = req.body||{};
  if(!date) return bad(res,400,'date requise');

  // âœ… FIX: Utiliser une transaction pour garantir l'atomicité
  try{
    await q('BEGIN');

    const sid = season_id ? +season_id : await currentSeasonId();
    const payload = { d1, d2, barrage, champions };

    await q(`INSERT INTO matchday(day,season_id,payload,created_at)
             VALUES ($1,$2,$3,now())
             ON CONFLICT (day) DO UPDATE SET season_id=EXCLUDED.season_id, payload=EXCLUDED.payload`,
             [date, sid, payload]);

    await q('DELETE FROM draft WHERE day=$1',[date]);

    await q('COMMIT');

    io.to(`draft:${date}`).emit('day:confirmed', { date });
    io.to(`day:${date}`).emit('day:updated', { date, source:'confirmed' });
    io.emit('season:changed');
    ok(res,{ ok:true });
  }catch(e){
    await q('ROLLBACK');
    console.error('[matchdays/confirm] Error:', e);
    bad(res,500,'Failed to confirm matchday');
  }
});
app.delete('/matchdays/:date', auth, async (req,res)=>{
  await q(`DELETE FROM matchday WHERE day=$1`,[req.params.date]);
  io.to(`day:${req.params.date}`).emit('day:updated', { date:req.params.date, source:'deleted' });
  io.emit('season:changed');
  ok(res,{ ok:true });
});

/* ====== Standings exposés ====== */
app.get('/standings', auth, async (req,res)=>{
  const sid = await resolveSeasonId(req.query.season);
  const list = await computeSeasonStandings(sid);
  ok(res,{ season_id:sid, standings:list });
});
app.get('/season/standings', auth, async (req,res)=>{
  const sid = await resolveSeasonId(req.query.season);
  const list = await computeSeasonStandings(sid);
  ok(res,{ season_id:sid, standings:list });
});
app.get('/seasons/:id/standings', auth, async (req,res)=>{
  const sid = +req.params.id;
  const chk = await q(`SELECT 1 FROM seasons WHERE id=$1`,[sid]);
  if(!chk.rowCount) return bad(res,404,'saison inconnue');
  const list = await computeSeasonStandings(sid);
  ok(res,{ season_id:sid, standings:list });
});

/* ====== Saisons (CRUD & helpers) ====== */
app.get('/seasons', auth, async (_req,res)=>{
  const r=await q(`SELECT id,name,is_closed,started_at,ended_at FROM seasons ORDER BY id DESC`);
  ok(res,{ seasons:r.rows });
});
app.get('/season/list', auth, async (_req,res)=>{
  const r=await q(`SELECT id,name FROM seasons ORDER BY id DESC`);
  ok(res,{ seasons:r.rows });
});
app.get('/season/ids', auth, async (_req,res)=>{
  const r=await q(`SELECT id FROM seasons ORDER BY id DESC`);
  // âœ… FIX: Retourner un objet JSON cohérent avec les autres endpoints
  ok(res, { ids: r.rows.map(x=>x.id) });
});
app.post('/seasons', auth, adminOnly, async (req,res)=>{
  const { name } = req.body||{};
  if(!name || !name.trim()) return bad(res,400,'nom requis');
  const r=await q(`INSERT INTO seasons(name,is_closed) VALUES ($1,false) RETURNING id,name,is_closed,started_at,ended_at`,[name.trim()]);
  ok(res,{ season:r.rows[0] });
});
app.get('/season/current', auth, async (_req,res)=>{
  const r=await q(`SELECT id,name FROM seasons WHERE is_closed=false ORDER BY id DESC LIMIT 1`);
  if(!r.rowCount) return bad(res,404,'aucune saison en cours');
  ok(res, r.rows[0]);
});
app.get('/seasons/:id/matchdays', auth, async (req,res)=>{
  const sid = +req.params.id;
  const chk = await q(`SELECT 1 FROM seasons WHERE id=$1`,[sid]);
  if(!chk.rowCount) return bad(res,404,'saison inconnue');
  const r = await q(`SELECT day FROM matchday WHERE season_id=$1 ORDER BY day ASC`,[sid]);
  ok(res,{ days: r.rows.map(x=>dayjs(x.day).format('YYYY-MM-DD')) });
});

/* ====== Face-Ã -face ====== */
app.get('/faceoff/:oppId', auth, async (req,res)=>{
  const mePid = await getLinkedPlayerId(req.user.uid);
  const oppId = req.params.oppId;
  if(!mePid) return bad(res,404,'Aucun joueur lié');
  if(!oppId) return bad(res,400,'oppId requis');

  const sid = await resolveSeasonId(req.query.season);
  const days = await q(`SELECT day,payload FROM matchday WHERE season_id=$1 ORDER BY day ASC`,[sid]);

  const legs=[];
  let totals={legs:0,wins:0,draws:0,losses:0,gf:0,ga:0};
  let best_me=null, best_opp=null;

  function pushLeg(date, division, leg, gf, ga){
    const result = gf>ga?'W':(gf<ga?'L':'D');
    legs.push({date,division,leg,gf,ga,result});
    totals.legs++; totals.gf+=gf; totals.ga+=ga;
    if(result==='W') totals.wins++; else if(result==='L') totals.losses++; else totals.draws++;
  }

  for(const d of days.rows){
    const P=d.payload||{};
    for(const div of ['d1','d2']){
      for(const m of (P[div]||[])){
        if(!m?.p1 || !m?.p2) continue;
        const a = m.p1, b = m.p2;
        const matchAB = (a===mePid && b===oppId);
        const matchBA = (a===oppId && b===mePid);
        if(!matchAB && !matchBA) continue;

        const homeIsMe = matchAB;
        if(m.a1!=null && m.a2!=null){
          const gf = homeIsMe? m.a1 : m.a2;
          const ga = homeIsMe? m.a2 : m.a1;
          pushLeg(d.day, div.toUpperCase(), 'Aller', gf, ga);
          if(!best_me || gf>best_me.gf){ best_me={gf,ga,leg:'Aller',division:div.toUpperCase(),date:d.day}; }
          if(!best_opp || ga>best_opp.gf){ best_opp={gf:ga,ga:gf,leg:'Aller',division:div.toUpperCase(),date:d.day}; }
        }
        if(m.r1!=null && m.r2!=null){
          const gf = homeIsMe? m.r1 : m.r2;
          const ga = homeIsMe? m.r2 : m.r1;
          pushLeg(d.day, div.toUpperCase(), 'Retour', gf, ga);
          if(!best_me || gf>best_me.gf){ best_me={gf,ga,leg:'Retour',division:div.toUpperCase(),date:d.day}; }
          if(!best_opp || ga>best_opp.gf){ best_opp={gf:ga,ga:gf,leg:'Retour',division:div.toUpperCase(),date:d.day}; }
        }
      }
    }
  }

  const meName  = (await q(`SELECT name FROM players WHERE player_id=$1`,[mePid])).rows[0]?.name || mePid;
  const oppName = (await q(`SELECT name FROM players WHERE player_id=$1`,[oppId])).rows[0]?.name || oppId;

  let leader='draw';
  if(totals.wins>totals.losses) leader='me';
  else if(totals.losses>totals.wins) leader='opponent';

  ok(res,{
    me:{ id:mePid, name:meName },
    opponent:{ id:oppId, name:oppName },
    totals, legs, best_me, best_opp, leader
  });
});

/* ====== Duels (additive) ====== */
function normalizeDuelBody(body){
  const src = body && typeof body==='object' ? (body.duel && typeof body.duel==='object' ? body.duel : body) : {};
  const val = (v)=> (v===undefined || v===null ? undefined : (typeof v==='string' ? v.trim() : v));
  const pick = (o, ...keys)=>{ for(const k of keys){ const v = val(o[k]); if(v!==undefined && v!=='') return v; } return undefined; };
  const p1 = pick(src, 'p1','player_a','A','a','p1_id','id1','idA','id_a','joueur1','player1');
  const p2 = pick(src, 'p2','player_b','B','b','p2_id','id2','idB','id_b','joueur2','player2');
  let sa = pick(src, 'score_a','score1','but1','sA','sa','a_score','goals1');
  let sb = pick(src, 'score_b','score2','but2','sB','sb','b_score','goals2');
  const when = pick(src, 'played_at','date','when','playedAt','match_date');
  const n = (x)=>{ const i = parseInt(x,10); return Number.isFinite(i) ? i : NaN; };
  return { p1, p2, score_a: n(sa), score_b: n(sb), played_at: when };
}
/* Create duel */
app.post('/duels', auth, async (req,res)=>{
  try{
    const { p1, p2, score_a, score_b, played_at } = normalizeDuelBody(req.body);
    if(!p1 || !p2 || !Number.isFinite(score_a) || !Number.isFinite(score_b)){
      return bad(res,400,'Missing fields: p1, p2, score_a, score_b');
    }
    const dt = played_at ? new Date(played_at) : null;
    const r = await q(
      'INSERT INTO duels(p1_id,p2_id,score_a,score_b,played_at) VALUES($1,$2,$3,$4,COALESCE($5, now())) RETURNING id',
      [String(p1), String(p2), score_a, score_b, (dt && !isNaN(dt)) ? dt : null]
    );
    ok(res,{ ok:true, id: r.rows[0].id });
  }catch(e){
    console.error('POST /duels error', e);
    bad(res,500,'Server error');
  }
});
function appendDuelDateFilters(query, cond, vals) {
  const fromRaw = query?.from ? String(query.from).trim() : '';
  const toRaw = query?.to ? String(query.to).trim() : '';
  const dateOnlyRe = /^\d{4}-\d{2}-\d{2}$/;

  if (fromRaw) {
    if (dateOnlyRe.test(fromRaw)) {
      cond.push(`played_at >= $${vals.length + 1}::date`);
      vals.push(fromRaw);
    } else {
      const fromDate = new Date(fromRaw);
      if (!Number.isNaN(fromDate.getTime())) {
        cond.push(`played_at >= $${vals.length + 1}`);
        vals.push(fromDate);
      }
    }
  }

  if (toRaw) {
    if (dateOnlyRe.test(toRaw)) {
      cond.push(`played_at < ($${vals.length + 1}::date + INTERVAL '1 day')`);
      vals.push(toRaw);
    } else {
      const toDate = new Date(toRaw);
      if (!Number.isNaN(toDate.getTime())) {
        cond.push(`played_at <= $${vals.length + 1}`);
        vals.push(toDate);
      }
    }
  }
}

function csvEscape(v) {
  if (v === null || v === undefined) return '';
  const s = String(v);
  if (!/[",\r\n]/.test(s)) return s;
  return `"${s.replace(/"/g, '""')}"`;
}

function htmlEscape(v) {
  if (v === null || v === undefined) return '';
  return String(v)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

/* Recent duels */
app.get('/duels/recent', auth, async (req,res)=>{
  try{
    const player = req.query.player || req.query.p;
    const { limit } = req.query;
    const lim = Math.max(1, Math.min(parseInt(limit||'20',10), 200));
    const cond = []; const vals = [];
    if(player){ cond.push('(p1_id = $'+(vals.length+1)+' OR p2_id = $'+(vals.length+1)+')'); vals.push(String(player)); }
    appendDuelDateFilters(req.query, cond, vals);
    const where = cond.length ? ('WHERE '+cond.join(' AND ')) : '';

    const limitParam = '$'+(vals.push(lim));

    const sql = `SELECT d.id, d.p1_id, d.p2_id, d.score_a, d.score_b, d.played_at,
                        p1.name AS p1_name, p2.name AS p2_name
                 FROM duels d
                 LEFT JOIN players p1 ON p1.player_id = d.p1_id
                 LEFT JOIN players p2 ON p2.player_id = d.p2_id
                 ${where}
                 ORDER BY d.played_at DESC, d.id DESC
                 LIMIT ${limitParam}`;
    const r = await q(sql, vals);
    ok(res,{ duels: r.rows });
  }catch(e){
    console.error('GET /duels/recent error', e);
    bad(res,500,'Server error');
  }
});

/* Export duels CSV */
app.get('/duels/export.csv', auth, async (req,res)=>{
  try{
    const player = req.query.player || req.query.p;
    const lim = Math.max(1, Math.min(parseInt(req.query.limit || '2000', 10), 5000));
    const cond = []; const vals = [];
    if (player) {
      cond.push('(d.p1_id = $'+(vals.length+1)+' OR d.p2_id = $'+(vals.length+1)+')');
      vals.push(String(player));
    }
    appendDuelDateFilters(req.query, cond, vals);
    const where = cond.length ? ('WHERE '+cond.join(' AND ')) : '';
    const limitParam = '$'+(vals.push(lim));

    const sql = `SELECT d.id, d.p1_id, d.p2_id, d.score_a, d.score_b, d.played_at,
                        p1.name AS p1_name, p2.name AS p2_name
                 FROM duels d
                 LEFT JOIN players p1 ON p1.player_id = d.p1_id
                 LEFT JOIN players p2 ON p2.player_id = d.p2_id
                 ${where}
                 ORDER BY d.played_at DESC, d.id DESC
                 LIMIT ${limitParam}`;
    const r = await q(sql, vals);
    const rows = r.rows || [];

    const header = ['id','played_at','p1_id','p1_name','score_a','score_b','p2_id','p2_name','leader','result'];
    const lines = [header.join(',')];
    for (const d of rows) {
      const a = Number(d.score_a || 0);
      const b = Number(d.score_b || 0);
      const leader = a > b ? (d.p1_name || d.p1_id) : a < b ? (d.p2_name || d.p2_id) : 'Egalite';
      const result = a > b ? 'A gagne' : a < b ? 'B gagne' : 'Nul';
      const row = [
        d.id,
        d.played_at ? new Date(d.played_at).toISOString() : '',
        d.p1_id,
        d.p1_name || '',
        a,
        b,
        d.p2_id,
        d.p2_name || '',
        leader,
        result,
      ];
      lines.push(row.map(csvEscape).join(','));
    }

    const nowIso = new Date().toISOString().replace(/[:.]/g, '-');
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', `attachment; filename="duels_${nowIso}.csv"`);
    return res.status(200).send(lines.join('\n'));
  }catch(e){
    console.error('GET /duels/export.csv error', e);
    bad(res,500,'Server error');
  }
});

/* Export duels HTML (print/PDF) */
app.get('/duels/export.html', auth, async (req,res)=>{
  try{
    const player = req.query.player || req.query.p;
    const lim = Math.max(1, Math.min(parseInt(req.query.limit || '2000', 10), 5000));
    const cond = []; const vals = [];
    if (player) {
      cond.push('(d.p1_id = $'+(vals.length+1)+' OR d.p2_id = $'+(vals.length+1)+')');
      vals.push(String(player));
    }
    appendDuelDateFilters(req.query, cond, vals);
    const where = cond.length ? ('WHERE '+cond.join(' AND ')) : '';
    const limitParam = '$'+(vals.push(lim));

    const sql = `SELECT d.id, d.p1_id, d.p2_id, d.score_a, d.score_b, d.played_at,
                        p1.name AS p1_name, p2.name AS p2_name
                 FROM duels d
                 LEFT JOIN players p1 ON p1.player_id = d.p1_id
                 LEFT JOIN players p2 ON p2.player_id = d.p2_id
                 ${where}
                 ORDER BY d.played_at DESC, d.id DESC
                 LIMIT ${limitParam}`;
    const r = await q(sql, vals);
    const rows = r.rows || [];

    const periodLabel = [
      req.query.from ? `du ${htmlEscape(req.query.from)}` : null,
      req.query.to ? `au ${htmlEscape(req.query.to)}` : null,
    ].filter(Boolean).join(' ');
    const title = `Historique des duels${periodLabel ? ' (' + periodLabel + ')' : ''}`;

    const htmlRows = rows.map((d, idx) => {
      const a = Number(d.score_a || 0);
      const b = Number(d.score_b || 0);
      const leader = a > b ? (d.p1_name || d.p1_id) : a < b ? (d.p2_name || d.p2_id) : 'Egalite';
      const result = a > b ? 'A gagne' : a < b ? 'B gagne' : 'Nul';
      return `<tr>
        <td>${idx + 1}</td>
        <td>${htmlEscape(d.played_at ? new Date(d.played_at).toLocaleString('fr-FR') : '')}</td>
        <td>${htmlEscape(d.p1_name || d.p1_id || '')}</td>
        <td>${a}</td>
        <td>${b}</td>
        <td>${htmlEscape(d.p2_name || d.p2_id || '')}</td>
        <td>${htmlEscape(result)}</td>
        <td>${htmlEscape(leader)}</td>
      </tr>`;
    }).join('\n');

    const html = `<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8" />
  <title>${title}</title>
  <style>
    body{font-family:Arial,Helvetica,sans-serif;margin:20px;color:#111}
    h1{margin:0 0 6px;font-size:20px}
    .meta{margin:0 0 16px;color:#555;font-size:12px}
    table{width:100%;border-collapse:collapse;font-size:12px}
    th,td{border:1px solid #d1d5db;padding:6px 8px;text-align:left}
    th{background:#f3f4f6}
    @media print{body{margin:10mm}}
  </style>
</head>
<body>
  <h1>${title}</h1>
  <p class="meta">Genere le ${htmlEscape(new Date().toLocaleString('fr-FR'))}</p>
  <table>
    <thead>
      <tr><th>#</th><th>Date</th><th>Joueur A</th><th>SA</th><th>SB</th><th>Joueur B</th><th>Resultat</th><th>Leader</th></tr>
    </thead>
    <tbody>
      ${htmlRows}
    </tbody>
  </table>
</body>
</html>`;

    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    return res.status(200).send(html);
  }catch(e){
    console.error('GET /duels/export.html error', e);
    bad(res,500,'Server error');
  }
});
/* Head-to-head */
app.get('/duels/compare', auth, async (req,res)=>{
  try{
    const p1 = req.query.p1 || req.query.A || req.query.a || req.query.player_a;
    const p2 = req.query.p2 || req.query.B || req.query.b || req.query.player_b;
    if(!p1 || !p2) return bad(res,400,'p1 and p2 required');

    const names = await q(
      `SELECT 
         (SELECT name FROM players WHERE player_id=$1) AS p1_name,
         (SELECT name FROM players WHERE player_id=$2) AS p2_name`,
      [String(p1), String(p2)]
    );
    const n = names.rows[0] || {};

    const cond = ['((p1_id=$1 AND p2_id=$2) OR (p1_id=$2 AND p2_id=$1))'];
    const vals = [String(p1), String(p2)];
    appendDuelDateFilters(req.query, cond, vals);

    const stats = await q(
      `SELECT
         SUM(CASE WHEN p1_id=$1 AND score_a>score_b THEN 1 WHEN p2_id=$1 AND score_b>score_a THEN 1 ELSE 0 END) AS wins_p1,
         SUM(CASE WHEN score_a=score_b THEN 1 ELSE 0 END) AS draws,
         SUM(CASE WHEN p1_id=$2 AND score_a>score_b THEN 1 WHEN p2_id=$2 AND score_b>score_a THEN 1 ELSE 0 END) AS wins_p2,
         SUM(score_a) FILTER (WHERE p1_id=$1) + SUM(score_b) FILTER (WHERE p2_id=$1) AS gf_p1,
         SUM(score_b) FILTER (WHERE p1_id=$1) + SUM(score_a) FILTER (WHERE p2_id=$1) AS ga_p1,
         COUNT(*) AS legs
       FROM duels
       WHERE ${cond.join(' AND ')}`,
      vals
    );
    const s = stats.rows[0] || {};
    const wins = Number(s.wins_p1||0);
    const draws = Number(s.draws||0);
    const losses = Number(s.wins_p2||0);
    const gf = Number(s.gf_p1||0);
    const ga = Number(s.ga_p1||0);
    const legs = Number(s.legs||0);

    ok(res,{
      p1: { id:String(p1), name: n.p1_name || null },
      p2: { id:String(p2), name: n.p2_name || null },
      totals: { wins, draws, losses, gf, ga, legs }
    });
  }catch(e){
    console.error('GET /duels/compare error', e);
    bad(res,500,'Server error');
  }
});
/* Delete duel (admin) */
app.delete('/duels/:id', auth, adminOnly, async (req,res)=>{
  try{
    const id = parseInt(req.params.id, 10);
    if(!id) return bad(res,400,'Invalid id');
    await q('DELETE FROM duels WHERE id=$1', [id]);
    ok(res,{ ok:true });
  }catch(e){
    console.error('DELETE /duels/:id error', e);
    bad(res,500,'Server error');
  }
});

/* ====== WebSockets (no handoff) ====== */
io.on('connection', (socket)=>{
  socket.on('join', ({room} = {})=>{
    if(room && typeof room === 'string') socket.join(room);
  });
  socket.on('leave', ({room} = {})=>{
    if(room && typeof room === 'string') socket.leave(room);
  });
  socket.on('draft:update', ({date} = {})=>{
    if(!date) return;
    io.to(`draft:${date}`).emit('draft:update', { date });
  });
});

/* ====== Start ====== */
(async ()=>{
  try{
    await ensureSchema();
    server.listen(PORT, HOST, ()=> {
      console.log(`API OK on ${HOST}:${PORT}`);
      if (AUTO_BACKUP_ENABLED) {
        const nextRun = nextAutoBackupDate();
        console.log(`[backup] auto backup active (samedi 23:00). Prochaine execution: ${nextRun.toString()}`);
      } else {
        console.log('[backup] auto backup desactive');
      }

      // Afficher l'IP locale pour les connexions réseau
      if (HOST === '0.0.0.0') {
        const networkInterfaces = os.networkInterfaces();
        const localIPs = [];

        Object.keys(networkInterfaces).forEach(interfaceName => {
          networkInterfaces[interfaceName].forEach(iface => {
            if (iface.family === 'IPv4' && !iface.internal) {
              localIPs.push(iface.address);
            }
          });
        });

        if (localIPs.length > 0) {
          console.log('\n[RESEAU] Serveur accessible depuis le réseau local :');
          localIPs.forEach(ip => {
            console.log(`   http://${ip}:${PORT}`);
          });
          console.log('\n[INFO] Les autres appareils peuvent se connecter avec ces URLs\n');
        }
      }
    });
  }catch(e){
    console.error('Schema init error', e);
    process.exit(1);
  }
})();

/* ====== Auto backup scheduler ====== */
setInterval(()=>{
  runAutoBackupTick().catch((e)=> console.error('[backup] tick error', e));
}, BACKUP_TICK_MS);

/* ====== Janitor ====== */
const JANITOR_EVERY_MS = 60*1000;
setInterval(async ()=>{
  try{
    await q(`UPDATE sessions
             SET is_active=false, revoked_at=now()
             WHERE is_active=true AND last_seen < now() - interval '24 hours'`);

    const uids = await q(`
      SELECT DISTINCT user_id
      FROM sessions
      WHERE logout_at IS NOT NULL
        AND cleaned_after_logout = false
        AND logout_at < now() - interval '5 minutes'
    `);

    for(const row of uids.rows){
      await q(`DELETE FROM draft WHERE author_user_id=$1`, [row.user_id]);
      await q(`UPDATE sessions
               SET cleaned_after_logout=true
               WHERE user_id=$1
                 AND logout_at IS NOT NULL
                 AND logout_at < now() - interval '5 minutes'`,
              [row.user_id]);
    }
  }catch(e){ console.error('janitor error', e); }
}, JANITOR_EVERY_MS);

