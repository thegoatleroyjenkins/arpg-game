extends Node2D

@onready var player = $Player
@onready var camera = $Camera2D
@onready var ui = $UI
@onready var stats_panel = $UI/StatsPanel
@onready var objective_panel = $UI/ObjectivePanel
@onready var controls_panel = $UI/ControlsPanel
@onready var minimap_panel = $UI/MinimapPanel
@onready var stats_label = $UI/StatsPanel/StatsLabel
@onready var minimap = $UI/MinimapPanel/MiniMap
@onready var objective_label = $UI/ObjectivePanel/ObjectiveLabel
@onready var objective_progress = $UI/ObjectivePanel/ObjectiveProgress
@onready var controls_hint = $UI/ControlsPanel/ControlsHint
@onready var minimap_legend = $UI/MinimapPanel/MinimapLegend

var world_size = Vector2(2000, 2000)
var enemies_remaining: int = 0
var total_enemies: int = 0

# Loot drop chances
var loot_chance_common: float = 0.4
var loot_chance_uncommon: float = 0.25
var loot_chance_rare: float = 0.1

func _ready():
	# Setup camera
	camera.position = player.position
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = world_size.x
	camera.limit_bottom = world_size.y
	
	if minimap:
		minimap.world_size = world_size

	# Generate world
	_generate_floor()
	_generate_enemies(20)  # More enemies for variety
	_generate_items(10)
	_generate_equipment(5)
	
	if player.has_signal("stats_changed"):
		player.stats_changed.connect(update_stats)
	
	_apply_ui_style()
	update_stats()

func _process(_delta):
	camera.position = camera.position.lerp(player.position, 0.1)

func _generate_floor():
	# Simple floor placeholder (avoids editor-only tile setup requirements)
	var floor = ColorRect.new()
	floor.name = "Floor"
	floor.color = Color(0.08, 0.08, 0.1)
	floor.size = world_size
	floor.position = Vector2.ZERO
	floor.z_index = -10
	add_child(floor)

func _generate_enemies(count):
	enemies_remaining = count
	total_enemies = count
	
	for i in range(count):
		var enemy = preload("res://enemy.tscn").instantiate()
		
		# Random enemy type with weighted distribution
		var rand = randf()
		if rand < 0.35:
			enemy.enemy_type = Enemy.EnemyType.GRUNT
		elif rand < 0.58:
			enemy.enemy_type = Enemy.EnemyType.FAST
		elif rand < 0.74:
			enemy.enemy_type = Enemy.EnemyType.TANK
		elif rand < 0.86:
			enemy.enemy_type = Enemy.EnemyType.RANGED
		elif rand < 0.94:
			enemy.enemy_type = Enemy.EnemyType.BRUISER
		else:
			enemy.enemy_type = Enemy.EnemyType.ASSASSIN
		
		# Position away from player start
		var valid_position = false
		var pos = Vector2.ZERO
		var attempts = 0
		
		while not valid_position and attempts < 50:
			pos = Vector2(
				randf_range(200, world_size.x - 200),
				randf_range(200, world_size.y - 200)
			)
			# Don't spawn too close to player
			if pos.distance_to(player.position) > 300:
				valid_position = true
			attempts += 1
		
		enemy.position = pos
		enemy.set_player(player)
		enemy.connect("died", _on_enemy_died)
		add_child(enemy)

func _generate_items(count):
	for i in range(count):
		var item = preload("res://item.tscn").instantiate()
		
		# Mix of health and XP items
		if randf() < 0.7:
			item.item_type = "health_potion"
			item.value = randi_range(15, 40)
		else:
			item.item_type = "xp_orb"
			item.value = randi_range(10, 30)
		
		item.position = Vector2(
			randf_range(100, world_size.x - 100),
			randf_range(100, world_size.y - 100)
		)
		add_child(item)

func _generate_equipment(count):
	var equipment_scene = preload("res://equipment.tscn")
	
	# Predefined equipment templates with rarity
	var equipment_templates = [
		# Common (white/gray)
		{"type": 0, "name": "Rusty Sword", "dmg": 5, "def": 0, "hp": 0, "rarity": 0, "color": Color.GRAY},
		{"type": 1, "name": "Tattered Cloth", "dmg": 0, "def": 5, "hp": 10, "rarity": 0, "color": Color.GRAY},
		{"type": 2, "name": "Wooden Ring", "dmg": 0, "def": 2, "hp": 5, "rarity": 0, "color": Color.GRAY},
		
		# Uncommon (green)
		{"type": 0, "name": "Iron Sword", "dmg": 10, "def": 0, "hp": 0, "rarity": 1, "color": Color.LIME_GREEN},
		{"type": 0, "name": "Steel Blade", "dmg": 20, "def": 0, "hp": 0, "rarity": 1, "color": Color.LIME_GREEN},
		{"type": 1, "name": "Leather Armor", "dmg": 0, "def": 10, "hp": 20, "rarity": 1, "color": Color.LIME_GREEN},
		{"type": 1, "name": "Chain Mail", "dmg": 0, "def": 25, "hp": 30, "rarity": 1, "color": Color.LIME_GREEN},
		{"type": 2, "name": "Ring of Health", "dmg": 0, "def": 5, "hp": 40, "rarity": 1, "color": Color.LIME_GREEN},
		{"type": 2, "name": "Amulet of Power", "dmg": 15, "def": 0, "hp": 10, "rarity": 1, "color": Color.LIME_GREEN},
		
		# Rare (blue/purple)
		{"type": 0, "name": "Flame Sword", "dmg": 35, "def": 0, "hp": 10, "rarity": 2, "color": Color.ORANGE_RED},
		{"type": 0, "name": "Shadow Dagger", "dmg": 45, "def": 5, "hp": 5, "rarity": 2, "color": Color.PURPLE},
		{"type": 1, "name": "Dragon Plate", "dmg": 5, "def": 50, "hp": 50, "rarity": 2, "color": Color.GOLD},
		{"type": 1, "name": "Mithril Armor", "dmg": 10, "def": 40, "hp": 60, "rarity": 2, "color": Color.CYAN},
		{"type": 2, "name": "Lucky Charm", "dmg": 5, "def": 5, "hp": 25, "rarity": 2, "color": Color.GOLD},
		{"type": 2, "name": "Ring of the Gods", "dmg": 25, "def": 15, "hp": 30, "rarity": 2, "color": Color.PURPLE},
	]
	
	for i in range(count):
		var eq = equipment_scene.instantiate()
		
		# Pick based on rarity weighting
		var rand = randf()
		var rarity_filter = 0
		if rand < loot_chance_common:
			rarity_filter = 0  # Common
		elif rand < loot_chance_common + loot_chance_uncommon:
			rarity_filter = 1  # Uncommon
		elif rand < loot_chance_common + loot_chance_uncommon + loot_chance_rare:
			rarity_filter = 2  # Rare
		else:
			rarity_filter = 0  # Fallback to common
		
		# Filter templates by rarity
		var valid_templates = []
		for template in equipment_templates:
			if template["rarity"] == rarity_filter:
				valid_templates.append(template)
		
		# Pick random from valid templates
		var template = equipment_templates[randi() % equipment_templates.size()]
		if valid_templates.size() > 0:
			template = valid_templates[randi() % valid_templates.size()]
		
		eq.equipment_type = template["type"]
		eq.item_name = template["name"]
		eq.damage_bonus = template["dmg"]
		eq.defense_bonus = template["def"]
		eq.health_bonus = template["hp"]
		
		# Color sprite by rarity
		if eq.has_node("Sprite2D"):
			eq.get_node("Sprite2D").modulate = template["color"]
		
		eq.position = Vector2(
			randf_range(100, world_size.x - 100),
			randf_range(100, world_size.y - 100)
		)
		add_child(eq)

func _on_enemy_died(enemy, position):
	enemies_remaining -= 1
	player.gain_xp(enemy.xp_value)
	
	# Drop loot from enemy
	_spawn_loot_drop(position, enemy.enemy_type)
	
	update_stats()
	
	# Check win condition
	if enemies_remaining <= 0:
		_show_victory_message()

func _spawn_loot_drop(pos: Vector2, enemy_type: Enemy.EnemyType):
	var rand = randf()
	
	# Higher chance for loot from better enemies
	var drop_chance = 0.3
	match enemy_type:
		Enemy.EnemyType.FAST: drop_chance = 0.4
		Enemy.EnemyType.TANK: drop_chance = 0.5
		Enemy.EnemyType.RANGED: drop_chance = 0.45
		Enemy.EnemyType.BRUISER: drop_chance = 0.55
		Enemy.EnemyType.ASSASSIN: drop_chance = 0.5
	
	if rand > drop_chance:
		return  # No drop
	
	# Determine what type of drop
	var drop_type = randf()
	
	if drop_type < 0.5:
		# Health potion
		var item = preload("res://item.tscn").instantiate()
		item.item_type = "health_potion"
		item.value = randi_range(10, 30)
		item.position = pos + Vector2(randi_range(-20, 20), randi_range(-20, 20))
		add_child(item)
	else:
		# Equipment drop (rare from enemies)
		var equipment_scene = preload("res://equipment.tscn")
		var eq = equipment_scene.instantiate()
		
		# Generate scaled equipment based on enemy type
		var rarity_boost = 0
		match enemy_type:
			Enemy.EnemyType.TANK: rarity_boost = 1
			Enemy.EnemyType.RANGED: rarity_boost = 1
		
		var templates = [
			{"type": 0, "name": "Iron Sword", "dmg": 10, "def": 0, "hp": 0},
			{"type": 1, "name": "Leather Armor", "dmg": 0, "def": 10, "hp": 20},
			{"type": 2, "name": "Health Ring", "dmg": 0, "def": 3, "hp": 25},
		]
		
		var template = templates[randi() % templates.size()]
		eq.equipment_type = template["type"]
		eq.item_name = template["name"]
		eq.damage_bonus = template["dmg"]
		eq.defense_bonus = template["def"]
		eq.health_bonus = template["hp"]
		eq.position = pos + Vector2(randi_range(-20, 20), randi_range(-20, 20))
		add_child(eq)

func _show_victory_message():
	var victory_label = Label.new()
	victory_label.text = "VICTORY!\nAll Enemies Defeated!"
	victory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	victory_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	victory_label.anchors_preset = Control.PRESET_CENTER
	victory_label.offset_left = -260
	victory_label.offset_top = -70
	victory_label.offset_right = 260
	victory_label.offset_bottom = 70
	victory_label.add_theme_font_size_override("font_size", 32)
	victory_label.modulate = Color.GOLD
	ui.add_child(victory_label)

func _apply_ui_style():
	_style_panel(stats_panel, Color(0.38, 0.62, 0.9, 0.9))
	_style_panel(objective_panel, Color(0.7, 0.9, 1.0, 0.9))
	_style_panel(controls_panel, Color(0.6, 0.8, 1.0, 0.9))
	_style_panel(minimap_panel, Color(0.55, 0.75, 0.9, 0.9))
	_tint_label(stats_label, Color(0.94, 0.97, 1.0, 1.0))
	_tint_label(objective_label, Color(0.78, 0.94, 1.0, 1.0), 18)
	_tint_label(controls_hint, Color(0.88, 0.92, 1.0, 1.0))
	_tint_label(minimap_legend, Color(0.8, 0.9, 1.0, 1.0))
	_style_objective_progress()

func _style_panel(panel: Panel, border_color: Color) -> void:
	if panel == null:
		return
	panel.add_theme_stylebox_override("panel", _build_panel_style(border_color))

func _build_panel_style(border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.05, 0.08, 0.9)
	style.border_color = border_color
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 12
	style.content_margin_top = 10
	style.content_margin_right = 12
	style.content_margin_bottom = 10
	return style

func _tint_label(label: Label, color: Color, font_size: int = 0) -> void:
	if label == null:
		return
	label.add_theme_color_override("font_color", color)
	if font_size > 0:
		label.add_theme_font_size_override("font_size", font_size)

func _style_objective_progress() -> void:
	if objective_progress == null:
		return
	var fg := StyleBoxFlat.new()
	fg.bg_color = Color(0.41, 0.75, 0.99, 0.95)
	fg.corner_radius_top_left = 6
	fg.corner_radius_top_right = 6
	fg.corner_radius_bottom_left = 6
	fg.corner_radius_bottom_right = 6
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.12, 0.16, 0.2, 0.9)
	bg.corner_radius_top_left = 6
	bg.corner_radius_top_right = 6
	bg.corner_radius_bottom_left = 6
	bg.corner_radius_bottom_right = 6
	objective_progress.add_theme_stylebox_override("fg", fg)
	objective_progress.add_theme_stylebox_override("fg_disabled", fg)
	objective_progress.add_theme_stylebox_override("bg", bg)
	objective_progress.add_theme_stylebox_override("bg_disabled", bg)
	objective_progress.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))

func update_stats():
	# Show equipment in stats
	var weapon_name = "None"
	var armor_name = "None"
	var accessory_name = "None"
	
	var weapon_damage = 0
	var armor_defense = 0
	var accessory_health = 0
	
	if player.weapon:
		weapon_name = player.weapon.item_name
		weapon_damage = player.weapon.damage_bonus
	if player.armor:
		armor_name = player.armor.item_name
		armor_defense = player.armor.defense_bonus
	if player.accessory:
		accessory_name = player.accessory.item_name
		accessory_health = player.accessory.health_bonus
	
	var health_ratio = 0.0
	if player.total_max_health > 0:
		health_ratio = float(player.current_health) / float(player.total_max_health)
	
	var health_color = "#7CFF6B"
	if health_ratio < 0.6:
		health_color = "#FFD166"
	if health_ratio < 0.3:
		health_color = "#FF6B6B"

	var objective_ratio = 0.0
	if total_enemies > 0:
		objective_ratio = float(max(total_enemies - enemies_remaining, 0)) / float(total_enemies)
	var objective_status = "Clear all hostiles"
	if objective_ratio >= 0.5:
		objective_status = "Keep pressure on the remaining enemies"
	if objective_ratio >= 0.85:
		objective_status = "Final push"
	
	stats_label.text = "[b][color=#F6E27A]Level %d[/color][/b]      [color=#7ED7A5]Objective:[/color] %s\n[color=#A9D6FF]XP:[/color] %d/%d\n[color=%s]Health:[/color] %d/%d\n[color=#FFB26B]Damage:[/color] %d    [color=#8BD3FF]Defense:[/color] %d\n\n[b][color=#DCC7FF]Equipment[/color][/b]\n• Weapon: %s (+%d dmg)\n• Armor: %s (+%d def)\n• Accessory: %s (+%d hp)" % [
		player.level,
		objective_status,
		player.xp,
		player.xp_to_next_level,
		health_color,
		player.current_health,
		player.total_max_health,
		player.total_damage,
		player.defense_bonus,
		weapon_name,
		weapon_damage,
		armor_name,
		armor_defense,
		accessory_name,
		accessory_health
	]

	if objective_label and objective_progress:
		var defeated = max(total_enemies - enemies_remaining, 0)
		objective_label.text = "Objective: Defeat enemies (%d/%d)" % [defeated, total_enemies]
		objective_progress.max_value = max(total_enemies, 1)
		objective_progress.value = defeated
