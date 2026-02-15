-- Open World Schema: Emberfall Marches

CREATE TABLE IF NOT EXISTS biome (
  id TEXT PRIMARY KEY,
  display_name TEXT NOT NULL,
  danger_min INTEGER NOT NULL,
  danger_max INTEGER NOT NULL,
  climate_tags TEXT NOT NULL DEFAULT '[]'
);

CREATE TABLE IF NOT EXISTS world_chunk (
  id TEXT PRIMARY KEY,
  biome_id TEXT NOT NULL,
  grid_x INTEGER NOT NULL,
  grid_y INTEGER NOT NULL,
  scene_path TEXT NOT NULL,
  lod_scene_path TEXT DEFAULT '',
  is_discovered INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (biome_id) REFERENCES biome(id)
);

CREATE TABLE IF NOT EXISTS poi (
  id TEXT PRIMARY KEY,
  chunk_id TEXT NOT NULL,
  biome_id TEXT NOT NULL,
  poi_type TEXT NOT NULL,
  display_name TEXT NOT NULL,
  x REAL NOT NULL,
  y REAL NOT NULL,
  z REAL NOT NULL,
  landmark_score REAL NOT NULL DEFAULT 0,
  discovery_state TEXT NOT NULL DEFAULT 'hidden',
  tags_json TEXT NOT NULL DEFAULT '[]',
  FOREIGN KEY (chunk_id) REFERENCES world_chunk(id),
  FOREIGN KEY (biome_id) REFERENCES biome(id)
);

CREATE TABLE IF NOT EXISTS faction (
  id TEXT PRIMARY KEY,
  display_name TEXT NOT NULL,
  summary TEXT NOT NULL DEFAULT ''
);

CREATE TABLE IF NOT EXISTS faction_relation (
  faction_a TEXT NOT NULL,
  faction_b TEXT NOT NULL,
  relation_value REAL NOT NULL DEFAULT 0,
  PRIMARY KEY (faction_a, faction_b),
  FOREIGN KEY (faction_a) REFERENCES faction(id),
  FOREIGN KEY (faction_b) REFERENCES faction(id)
);

CREATE TABLE IF NOT EXISTS npc (
  id TEXT PRIMARY KEY,
  display_name TEXT NOT NULL,
  faction_id TEXT NOT NULL,
  home_poi_id TEXT NOT NULL,
  role TEXT NOT NULL,
  disposition REAL NOT NULL DEFAULT 0,
  flags_json TEXT NOT NULL DEFAULT '[]',
  FOREIGN KEY (faction_id) REFERENCES faction(id),
  FOREIGN KEY (home_poi_id) REFERENCES poi(id)
);

CREATE TABLE IF NOT EXISTS npc_routine (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  npc_id TEXT NOT NULL,
  day_mask TEXT NOT NULL DEFAULT 'all',
  start_hour INTEGER NOT NULL,
  end_hour INTEGER NOT NULL,
  activity TEXT NOT NULL,
  target_poi_id TEXT NOT NULL,
  priority INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (npc_id) REFERENCES npc(id),
  FOREIGN KEY (target_poi_id) REFERENCES poi(id)
);

CREATE TABLE IF NOT EXISTS spawn_table (
  id TEXT PRIMARY KEY,
  biome_id TEXT NOT NULL,
  encounter_type TEXT NOT NULL,
  enemy_archetype_id TEXT NOT NULL,
  weight INTEGER NOT NULL,
  min_level INTEGER NOT NULL,
  max_level INTEGER NOT NULL,
  FOREIGN KEY (biome_id) REFERENCES biome(id)
);

CREATE TABLE IF NOT EXISTS radiant_template (
  id TEXT PRIMARY KEY,
  display_name TEXT NOT NULL,
  trigger_type TEXT NOT NULL,
  objective_json TEXT NOT NULL,
  constraints_json TEXT NOT NULL,
  reward_json TEXT NOT NULL,
  cooldown_minutes INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS world_event (
  id TEXT PRIMARY KEY,
  chunk_id TEXT NOT NULL,
  template_id TEXT NOT NULL,
  state TEXT NOT NULL,
  started_at_unix INTEGER NOT NULL,
  expires_at_unix INTEGER NOT NULL,
  payload_json TEXT NOT NULL DEFAULT '{}',
  FOREIGN KEY (chunk_id) REFERENCES world_chunk(id),
  FOREIGN KEY (template_id) REFERENCES radiant_template(id)
);

CREATE INDEX IF NOT EXISTS idx_chunk_grid ON world_chunk(grid_x, grid_y);
CREATE INDEX IF NOT EXISTS idx_poi_chunk ON poi(chunk_id);
CREATE INDEX IF NOT EXISTS idx_npc_faction ON npc(faction_id);
CREATE INDEX IF NOT EXISTS idx_routine_npc ON npc_routine(npc_id);
CREATE INDEX IF NOT EXISTS idx_spawn_biome ON spawn_table(biome_id, encounter_type);
CREATE INDEX IF NOT EXISTS idx_event_chunk_state ON world_event(chunk_id, state);
