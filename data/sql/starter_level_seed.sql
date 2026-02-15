-- Seed data for Ashfall Outskirts starter level

INSERT OR REPLACE INTO enemy_archetype
(id, display_name, tier, hp, damage, move_speed, xp_reward, posture_max, aggro_radius, attack_range, notes)
VALUES
('corrupted_villager', 'Corrupted Villager', 'T1', 45, 6, 2.8, 12, 0, 7.5, 1.6, 'Slow melee opener'),
('blight_archer', 'Blight Archer', 'T2', 36, 5, 3.2, 16, 0, 10.0, 8.5, 'Ranged poison support'),
('corrupted_brute_elite', 'Corrupted Brute', 'Elite', 140, 14, 2.4, 48, 40, 8.0, 2.2, 'Staggerable heavy melee'),
('rotbound_warden', 'The Rotbound Warden', 'Boss', 420, 18, 2.6, 180, 80, 12.0, 2.5, 'Mini-boss arena controller');

INSERT OR REPLACE INTO enemy_ability
(id, enemy_id, ability_name, damage, cooldown, telegraph_ms, area_radius, dot_damage, dot_duration, phase_gate_hp_ratio)
VALUES
('villager_swipe', 'corrupted_villager', 'Rusty Swipe', 6, 1.4, 300, 1.8, 0, 0, 1.0),
('archer_blight_shot', 'blight_archer', 'Blight Shot', 5, 1.8, 450, 0.0, 2, 3.0, 1.0),
('brute_crush', 'corrupted_brute_elite', 'Crushing Blow', 14, 2.1, 700, 2.0, 0, 0, 1.0),
('warden_ground_slam', 'rotbound_warden', 'Ground Slam', 24, 4.2, 950, 3.5, 0, 0, 1.0),
('warden_poison_puddle', 'rotbound_warden', 'Poison Puddle', 0, 5.4, 800, 3.2, 4, 5.0, 1.0),
('warden_enraged_combo', 'rotbound_warden', 'Enraged Combo', 20, 2.0, 500, 2.6, 0, 0, 0.3);

INSERT OR REPLACE INTO loot_table
(id, source_id, source_kind, common_weight, magic_weight, rare_weight, gold_min, gold_max, guaranteed_rarity)
VALUES
('loot_villager', 'corrupted_villager', 'enemy', 72, 25, 3, 4, 9, NULL),
('loot_archer', 'blight_archer', 'enemy', 65, 30, 5, 5, 11, NULL),
('loot_brute', 'corrupted_brute_elite', 'enemy', 30, 55, 15, 14, 24, NULL),
('loot_mid_chest', 'starter_mid_chest', 'chest', 0, 100, 0, 12, 18, 'Magic'),
('loot_warden', 'rotbound_warden', 'boss', 0, 20, 80, 30, 55, 'Rare');

INSERT OR REPLACE INTO encounter_zone
(id, level_id, sequence_index, zone_name, zone_type, completion_rule, min_spawn, max_spawn, spawn_budget, allow_variation, tutorial_prompt_key)
VALUES
('starter_zone_1', 'ashfall_outskirts', 1, 'Entry Lane', 'tutorial', 'defeat_all', 2, 3, 3, 1, 'prompt_move_attack'),
('starter_zone_2', 'ashfall_outskirts', 2, 'Village Split', 'mixed', 'defeat_all', 4, 6, 6, 1, 'prompt_potion'),
('starter_zone_3', 'ashfall_outskirts', 3, 'Corrupted Square', 'elite', 'defeat_all', 1, 3, 5, 1, NULL),
('starter_zone_4_boss', 'ashfall_outskirts', 4, 'Warden Arena', 'boss', 'defeat_boss', 1, 1, 8, 0, NULL),
('starter_zone_optional_chest', 'ashfall_outskirts', 5, 'Collapsed Shed', 'optional', 'open_chest', 0, 0, 0, 0, NULL);

INSERT INTO encounter_spawn_entry (zone_id, enemy_id, weight, min_count, max_count) VALUES
('starter_zone_1', 'corrupted_villager', 100, 2, 3),
('starter_zone_2', 'corrupted_villager', 70, 2, 4),
('starter_zone_2', 'blight_archer', 55, 1, 2),
('starter_zone_3', 'corrupted_villager', 40, 1, 2),
('starter_zone_3', 'corrupted_brute_elite', 100, 1, 1),
('starter_zone_4_boss', 'rotbound_warden', 100, 1, 1);

INSERT OR REPLACE INTO xp_curve (level, xp_to_next) VALUES
(1, 120),
(2, 180),
(3, 260),
(4, 360);

INSERT OR REPLACE INTO level_reward
(id, level_id, trigger_key, reward_type, reward_payload)
VALUES
('reward_mid_magic', 'ashfall_outskirts', 'starter_mid_chest_opened', 'item', '{"rarity":"Magic","table":"loot_mid_chest"}'),
('reward_boss_rare', 'ashfall_outskirts', 'rotbound_warden_killed', 'item', '{"rarity":"Rare","table":"loot_warden"}'),
('reward_boss_passive', 'ashfall_outskirts', 'rotbound_warden_killed', 'passive_point', '{"points":1}');
