-- Starter Level SQLite schema (Stage 0)
-- Designed for data-driven encounter + loot tuning.

CREATE TABLE IF NOT EXISTS enemy_archetype (
  id TEXT PRIMARY KEY,
  display_name TEXT NOT NULL,
  tier TEXT NOT NULL,
  hp REAL NOT NULL,
  damage REAL NOT NULL,
  move_speed REAL NOT NULL,
  xp_reward INTEGER NOT NULL,
  posture_max REAL DEFAULT 0,
  aggro_radius REAL DEFAULT 8,
  attack_range REAL DEFAULT 1.6,
  notes TEXT DEFAULT ''
);

CREATE TABLE IF NOT EXISTS enemy_ability (
  id TEXT PRIMARY KEY,
  enemy_id TEXT NOT NULL,
  ability_name TEXT NOT NULL,
  damage REAL NOT NULL,
  cooldown REAL NOT NULL,
  telegraph_ms INTEGER DEFAULT 0,
  area_radius REAL DEFAULT 0,
  dot_damage REAL DEFAULT 0,
  dot_duration REAL DEFAULT 0,
  phase_gate_hp_ratio REAL DEFAULT 1.0,
  FOREIGN KEY (enemy_id) REFERENCES enemy_archetype(id)
);

CREATE TABLE IF NOT EXISTS loot_table (
  id TEXT PRIMARY KEY,
  source_id TEXT NOT NULL,
  source_kind TEXT NOT NULL, -- enemy|chest|boss
  common_weight INTEGER NOT NULL,
  magic_weight INTEGER NOT NULL,
  rare_weight INTEGER NOT NULL,
  gold_min INTEGER NOT NULL,
  gold_max INTEGER NOT NULL,
  guaranteed_rarity TEXT DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS encounter_zone (
  id TEXT PRIMARY KEY,
  level_id TEXT NOT NULL,
  sequence_index INTEGER NOT NULL,
  zone_name TEXT NOT NULL,
  zone_type TEXT NOT NULL, -- tutorial|mixed|elite|boss|optional
  completion_rule TEXT NOT NULL,
  min_spawn INTEGER NOT NULL,
  max_spawn INTEGER NOT NULL,
  spawn_budget INTEGER NOT NULL,
  allow_variation INTEGER NOT NULL DEFAULT 1,
  tutorial_prompt_key TEXT DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS encounter_spawn_entry (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  zone_id TEXT NOT NULL,
  enemy_id TEXT NOT NULL,
  weight INTEGER NOT NULL,
  min_count INTEGER NOT NULL,
  max_count INTEGER NOT NULL,
  FOREIGN KEY (zone_id) REFERENCES encounter_zone(id),
  FOREIGN KEY (enemy_id) REFERENCES enemy_archetype(id)
);

CREATE TABLE IF NOT EXISTS xp_curve (
  level INTEGER PRIMARY KEY,
  xp_to_next INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS level_reward (
  id TEXT PRIMARY KEY,
  level_id TEXT NOT NULL,
  trigger_key TEXT NOT NULL,
  reward_type TEXT NOT NULL, -- passive_point|skill_unlock|item
  reward_payload TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_enemy_ability_enemy ON enemy_ability(enemy_id);
CREATE INDEX IF NOT EXISTS idx_zone_level ON encounter_zone(level_id, sequence_index);
CREATE INDEX IF NOT EXISTS idx_spawn_zone ON encounter_spawn_entry(zone_id);
