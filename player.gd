extends CharacterBody2D

const SPEED = 200.0

@export var max_health: int = 100
@export var attack_damage: int = 25
@export var level: int = 1
@export var xp: int = 0

@export var current_health: int
var attack_cooldown: float = 0.0
var is_attacking: bool = false
var attack_range: float = 60.0

# Equipment slots
var weapon: Equipment = null
var armor: Equipment = null
var accessory: Equipment = null

# Bonus stats from equipment
var damage_bonus: int = 0
var defense_bonus: int = 0
var health_bonus: int = 0

var total_max_health: int:
	get: return max_health + health_bonus

var total_damage: int:
	get: return attack_damage + damage_bonus

@onready var sprite = $Sprite2D
@onready var attack_area = $AttackArea
@onready var health_bar = $HealthBar

signal stats_changed

var xp_to_next_level: int:
	get:
		return level * 100

func _ready():
	current_health = max_health
	_update_health_bar()
	emit_signal("stats_changed")

func _physics_process(delta):
	# Handle attack cooldown
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	# Get movement input
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED
	
	direction = Input.get_axis("move_up", "move_down")
	velocity.y = direction * SPEED
	
	move_and_slide()
	
	# Face direction
	if velocity.x > 0:
		sprite.scale.x = 1
	elif velocity.x < 0:
		sprite.scale.x = -1

func _input(event):
	if event.is_action_pressed("attack"):
		attack()

func attack():
	if attack_cooldown <= 0:
		is_attacking = true
		attack_cooldown = 0.4
		
		# Animate attack
		var tween = create_tween()
		tween.tween_property(sprite, "scale:x", sprite.scale.x * 1.3, 0.1)
		tween.tween_property(sprite, "scale:x", sprite.scale.x, 0.1)
		
		# Deal damage to enemies in range (use total damage with bonuses)
		for area in attack_area.get_overlapping_areas():
			var enemy = area.get_parent()
			if enemy.has_method("take_damage"):
				enemy.take_damage(total_damage)
		
		await get_tree().create_timer(0.2).timeout
		is_attacking = false

func take_damage(amount: int):
	# Apply defense bonus (reduce damage)
	var actual_damage = max(1, amount - defense_bonus)
	current_health -= actual_damage
	_update_health_bar()
	emit_signal("stats_changed")
	
	# Flash red
	var tween = create_tween()
	sprite.modulate = Color.RED
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	
	if current_health <= 0:
		die()

func _update_health_bar():
	var health_percent = float(current_health) / total_max_health
	health_bar.value = health_percent * 100

func gain_xp(amount: int):
	xp += amount
	emit_signal("stats_changed")
	if xp >= xp_to_next_level:
		level_up()

func level_up():
	level += 1
	xp -= xp_to_next_level
	max_health += 20
	current_health = total_max_health
	attack_damage += 5
	
	# Level up effect
	var tween = create_tween()
	sprite.modulate = Color.GOLD
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.5)
	emit_signal("stats_changed")

func die():
	# Simple respawn
	current_health = total_max_health
	position = Vector2(100, 100)
	_update_health_bar()
	emit_signal("stats_changed")

func equip_item(new_equipment: Equipment):
	var slot_name = ""
	
	match new_equipment.equipment_type:
		Equipment.EquipmentType.WEAPON:
			# Unequip current weapon if any
			if weapon:
				_unequip(weapon)
			weapon = new_equipment
			slot_name = "weapon"
		Equipment.EquipmentType.ARMOR:
			if armor:
				_unequip(armor)
			armor = new_equipment
			slot_name = "armor"
		Equipment.EquipmentType.ACCESSORY:
			if accessory:
				_unequip(accessory)
			accessory = new_equipment
			slot_name = "accessory"
	
	# Apply bonuses
	_apply_bonuses()
	
	print("Equipped %s in %s slot" % [new_equipment.item_name, slot_name])

func _unequip(equipment: Equipment):
	damage_bonus -= equipment.damage_bonus
	defense_bonus -= equipment.defense_bonus
	health_bonus -= equipment.health_bonus

func _apply_bonuses():
	# Reset bonuses
	damage_bonus = 0
	defense_bonus = 0
	health_bonus = 0
	
	# Apply from equipped items
	if weapon:
		damage_bonus += weapon.damage_bonus
		defense_bonus += weapon.defense_bonus
		health_bonus += weapon.health_bonus
	
	if armor:
		damage_bonus += armor.damage_bonus
		defense_bonus += armor.defense_bonus
		health_bonus += armor.health_bonus
	
	if accessory:
		damage_bonus += accessory.damage_bonus
		defense_bonus += accessory.defense_bonus
		health_bonus += accessory.health_bonus
	
	# Clamp health if current exceeds new max
	current_health = min(current_health, total_max_health)
	_update_health_bar()
	emit_signal("stats_changed")
