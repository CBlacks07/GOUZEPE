-- Seed : compte administrateur par défaut
-- Email : admin@gz.local / Mot de passe : Admin123
-- ⚠️ Changer le mot de passe après le premier démarrage
INSERT INTO users (email, password_hash, role)
VALUES (
  'admin@gz.local',
  '$2a$10$rntNsCZcjyTxst2/MivXUe1crPwOUsKkCtk1Aj0hdN9D8REpQ2gd6',
  'admin'
)
ON CONFLICT (email) DO NOTHING;
