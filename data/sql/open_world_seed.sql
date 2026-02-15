-- Open World Seed (MVP: small but systemic)

INSERT OR REPLACE INTO biome (id, display_name, danger_min, danger_max, climate_tags) VALUES
('ashwood_frontier', 'Ashwood Frontier', 1, 4, '["forest","ruins","roads"]'),
('frostbreak_tundra', 'Frostbreak Tundra', 3, 6, '["tundra","wind","open"]'),
('mire_of_glass', 'Mire of Glass', 4, 7, '["swamp","poison","fog"]'),
('crownspine_mountains', 'Crownspine Mountains', 5, 8, '["mountain","vertical","fortified"]'),
('sunken_imperium', 'Sunken Imperium', 7, 10, '["ruins","late_game","corruption"]');

INSERT OR REPLACE INTO faction (id, display_name, summary) VALUES
('march_wardens', 'March Wardens', 'Frontier defenders maintaining roads and settlements.'),
('ember_synod', 'Ember Synod', 'Arcane faction researching Ember Scar anomalies.'),
('black_briar_band', 'Black Briar Band', 'Bandit coalition controlling smuggling routes.'),
('verdigris_covenant', 'Verdigris Covenant', 'Corruption cult driving ritual spread.'),
('free_clans', 'Free Clans', 'Independent locals tied to trade and survival.');

INSERT OR REPLACE INTO faction_relation (faction_a, faction_b, relation_value) VALUES
('march_wardens','black_briar_band',-0.9),
('black_briar_band','march_wardens',-0.9),
('march_wardens','ember_synod',0.2),
('ember_synod','march_wardens',0.2),
('ember_synod','verdigris_covenant',-0.7),
('verdigris_covenant','ember_synod',-0.7),
('free_clans','march_wardens',0.4),
('free_clans','black_briar_band',-0.3);

INSERT OR REPLACE INTO world_chunk (id, biome_id, grid_x, grid_y, scene_path, lod_scene_path, is_discovered) VALUES
('chunk_ashwood_00','ashwood_frontier',0,0,'res://world/chunks/chunk_ashwood_00.tscn','',1),
('chunk_ashwood_01','ashwood_frontier',1,0,'res://world/chunks/chunk_ashwood_01.tscn','',0),
('chunk_ashwood_10','ashwood_frontier',0,1,'res://world/chunks/chunk_ashwood_10.tscn','',0),
('chunk_tundra_20','frostbreak_tundra',2,0,'res://world/chunks/chunk_tundra_20.tscn','',0),
('chunk_mire_02','mire_of_glass',0,2,'res://world/chunks/chunk_mire_02.tscn','',0);

INSERT OR REPLACE INTO poi (id, chunk_id, biome_id, poi_type, display_name, x, y, z, landmark_score, discovery_state, tags_json) VALUES
('poi_broken_bell_watch','chunk_ashwood_01','ashwood_frontier','tower','Broken Bell Watch',120,12,40,0.92,'hidden','["landmark","combat"]'),
('poi_hollowmere_chapel','chunk_mire_02','mire_of_glass','shrine','Hollowmere Chapel',40,6,210,0.78,'hidden','["optional","puzzle"]'),
('poi_rimegate_pass_camp','chunk_tundra_20','frostbreak_tundra','camp','Rimegate Pass Camp',240,16,35,0.66,'hidden','["faction","contested"]'),
('poi_charred_mill_hamlet','chunk_ashwood_00','ashwood_frontier','town','Charred Mill Hamlet',22,8,22,0.88,'discovered','["hub","vendors"]'),
('poi_vault_of_thorns','chunk_ashwood_10','ashwood_frontier','dungeon','Vault of Thorns',75,-6,135,0.95,'hidden','["dungeon","boss"]');

INSERT OR REPLACE INTO npc (id, display_name, faction_id, home_poi_id, role, disposition, flags_json) VALUES
('npc_warden_elyra','Warden Elyra','march_wardens','poi_charred_mill_hamlet','captain',0.35,'["quest_giver"]'),
('npc_synod_veren','Adept Veren','ember_synod','poi_charred_mill_hamlet','researcher',0.10,'["vendor_arcane"]'),
('npc_miller_hob','Miller Hob','free_clans','poi_charred_mill_hamlet','civilian',0.25,'[]');

INSERT INTO npc_routine (npc_id, day_mask, start_hour, end_hour, activity, target_poi_id, priority) VALUES
('npc_warden_elyra','all',0,6,'sleep','poi_charred_mill_hamlet',1),
('npc_warden_elyra','all',6,14,'patrol','poi_broken_bell_watch',2),
('npc_warden_elyra','all',14,19,'guard_post','poi_charred_mill_hamlet',2),
('npc_warden_elyra','all',19,24,'social','poi_charred_mill_hamlet',1),
('npc_synod_veren','all',0,7,'sleep','poi_charred_mill_hamlet',1),
('npc_synod_veren','all',7,18,'research','poi_hollowmere_chapel',2),
('npc_synod_veren','all',18,24,'social','poi_charred_mill_hamlet',1),
('npc_miller_hob','all',0,6,'sleep','poi_charred_mill_hamlet',1),
('npc_miller_hob','all',6,17,'work','poi_charred_mill_hamlet',2),
('npc_miller_hob','all',17,24,'social','poi_charred_mill_hamlet',1);

INSERT OR REPLACE INTO spawn_table (id, biome_id, encounter_type, enemy_archetype_id, weight, min_level, max_level) VALUES
('spawn_ashwood_bandit_ambush','ashwood_frontier','wilderness','bandit_raider',60,1,5),
('spawn_ashwood_wolf_pack','ashwood_frontier','wilderness','wolf',45,1,5),
('spawn_tundra_ice_stalker','frostbreak_tundra','wilderness','ice_stalker',50,3,7),
('spawn_mire_blight_husk','mire_of_glass','wilderness','blight_husk',58,4,8);

INSERT OR REPLACE INTO radiant_template (id, display_name, trigger_type, objective_json, constraints_json, reward_json, cooldown_minutes) VALUES
('rad_supply_line_disruption','Supply Line Disruption','faction_tension',
 '{"type":"intercept_or_sabotage","target":"caravan","success":["combat","stealth"]}',
 '{"required_factions":["march_wardens","black_briar_band"],"min_relation_delta":0.5}',
 '{"gold":120,"reputation":{"march_wardens":8}}',
 45),
('rad_missing_scout_network','Missing Scout Network','predator_density_spike',
 '{"type":"track_and_recover","targets":3}',
 '{"biomes":["ashwood_frontier","frostbreak_tundra"]}',
 '{"gold":90,"item":"magic_utility"}',
 30),
('rad_cult_escalation_node','Cult Escalation Node','corruption_growth',
 '{"type":"destroy_anchors_before_timer","anchors":4}',
 '{"faction":"verdigris_covenant","adjacent_chunks":true}',
 '{"gold":150,"reputation":{"ember_synod":6},"item":"rare_component"}',
 60);
