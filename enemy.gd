class_name Enemy
extends CharacterBody2D

# Enemy types with different behaviors
enum EnemyType { GRUNT, FAST, TANK, RANGED, BRUISER, ASSASSIN }

# Base stats (will be modified by type)
@export var enemy_type: EnemyType = EnemyType.GRUNT
@export var max_health: int = 50
@export var damage: int = 10
@export var xp_value: int = 25

# Speed modifiers
var wander_speed: float = 30.0
var chase_speed: float = 80.0
var retreat_speed: float = 100.0

# AI Ranges
@export var detection_range: float = 200.0
@export var attack_range: float = 45.0
@export var attack_cooldown_time: float = 1.0

# State
var current_health: int
var attack_cooldown: float = 0.0
var player_ref: Node2D = null
var state_machine: StateMachine = null

# Visual feedback
var alert_indicator: Label = null

@onready var sprite = $Sprite2D
@onready var health_bar = $HealthBar
@onready var detection_area = $DetectionArea

signal died(enemy, position)
signal damaged(amount)

func _ready():
	_setup_by_type()
	current_health = max_health
	_update_health_bar()
	
	# Initialize state machine
	state_machine = StateMachine.new(self)
	state_machine.add_state("idle", IdleState.new(self))
	state_machine.add_state("chase", ChaseState.new(self))
	state_machine.add_state("attack", AttackState.new(self))
	state_machine.add_state("retreat", RetreatState.new(self))
	state_machine.change_state("idle")
	
	# Create alert indicator
	_setup_alert_indicator()
	
	# Setup detection area if not present
	if not detection_area:
		_setup_detection_area()

func _setup_by_type():
	match enemy_type:
		EnemyType.GRUNT:
			# Balanced stats (default)
			max_health = 50
			damage = 10
			xp_value = 25
			wander_speed = 30.0
			chase_speed = 80.0
			detection_range = 200.0
			attack_range = 45.0
			sprite.modulate = Color(1, 0.3, 0.3)  # Red
		
		EnemyType.FAST:
			# Fast but fragile
			max_health = 30
			damage = 8
			xp_value = 30
			wander_speed = 50.0
			chase_speed = 140.0  # Very fast
			retreat_speed = 160.0
			detection_range = 250.0
			attack_range = 40.0
			attack_cooldown_time = 0.6  # Faster attacks
			sprite.modulate = Color(0.3, 1, 0.3)  # Green
		
		EnemyType.TANK:
			# Slow but tough
			max_health = 120
			damage = 20
			xp_value = 50
			wander_speed = 15.0
			chase_speed = 50.0  # Slow
			retreat_speed = 60.0  # Doesn't retreat much
			detection_range = 180.0
			attack_range = 55.0  # Longer reach
			attack_cooldown_time = 1.5  # Slower attacks
			sprite.modulate = Color(0.4, 0.4, 0.4)  # Dark gray
		
		EnemyType.RANGED:
			# Keeps distance, higher detection
			max_health = 35
			damage = 12
			xp_value = 35
			wander_speed = 35.0
			chase_speed = 70.0
			retreat_speed = 110.0
			detection_range = 320.0  # High detection
			attack_range = 100.0  # Attacks from distance
			attack_cooldown_time = 1.2
			sprite.modulate = Color(0.8, 0.3, 1)  # Purple

		EnemyType.BRUISER:
			# Mid-speed frontline with heavy hits
			max_health = 90
			damage = 18
			xp_value = 45
			wander_speed = 24.0
			chase_speed = 95.0
			retreat_speed = 85.0
			detection_range = 220.0
			attack_range = 50.0
			attack_cooldown_time = 1.1
			sprite.modulate = Color(1.0, 0.55, 0.2)  # Orange

		EnemyType.ASSASSIN:
			# Fragile but very high pressure
			max_health = 25
			damage = 16
			xp_value = 40
			wander_speed = 55.0
			chase_speed = 165.0
			retreat_speed = 190.0
			detection_range = 280.0
			attack_range = 35.0
			attack_cooldown_time = 0.55
			sprite.modulate = Color(0.95, 0.95, 0.2)  # Yellow

func _setup_detection_area():
	detection_area = Area2D.new()
	detection_area.name = "DetectionArea"
	add_child(detection_area)
	
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = detection_range
	collision.shape = shape
	detection_area.add_child(collision)
	
	# Connect signals
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)

func _setup_alert_indicator():
	alert_indicator = Label.new()
	alert_indicator.text = "!"
	alert_indicator.visible = false
	alert_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	alert_indicator.position = Vector2(-10, -40)
	alert_indicator.add_theme_font_size_override("font_size", 20)
	alert_indicator.modulate = Color.YELLOW
	add_child(alert_indicator)

func show_alert():
	alert_indicator.visible = true
	alert_indicator.text = "!"
	alert_indicator.modulate = Color.YELLOW
	await get_tree().create_timer(0.5).timeout
	alert_indicator.visible = false

func show_retreat():
	alert_indicator.visible = true
	alert_indicator.text = "..."
	alert_indicator.modulate = Color.RED

func _physics_process(delta):
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	state_machine.update(delta)
	state_machine.physics_update(delta)
	
	# Check for retreat condition (low health)
	if current_health < max_health * 0.25 and enemy_type != EnemyType.TANK:
		if not (state_machine.current_state is RetreatState):
			state_machine.change_state("retreat")

func can_see_player() -> bool:
	if not player_ref:
		return false
	var dist = position.distance_to(player_ref.position)
	return dist <= detection_range

func perform_attack():
	attack_cooldown = attack_cooldown_time
	
	if player_ref and player_ref.has_method("take_damage"):
		player_ref.take_damage(damage)
	
	# Attack animation
	var tween = create_tween()
	var original_scale = sprite.scale
	tween.tween_property(sprite, "scale", original_scale * 1.4, 0.1)
	tween.tween_property(sprite, "scale", original_scale, 0.1)
	
	# Lunge toward player slightly
	if player_ref:
		var direction = (player_ref.position - position).normalized()
		position += direction * 10

func take_damage(amount: int):
	current_health -= amount
	_update_health_bar()
	emit_signal("damaged", amount)
	
	# Flash red
	var tween = create_tween()
	sprite.modulate = Color.RED
	tween.tween_property(sprite, "modulate", get_type_color(), 0.2)
	
	# Brief stun on heavy hits
	if amount >= 20:
		velocity = Vector2.ZERO
		await get_tree().create_timer(0.1).timeout
	
	if current_health <= 0:
		die()

func get_type_color() -> Color:
	match enemy_type:
		EnemyType.GRUNT: return Color(1, 0.3, 0.3)
		EnemyType.FAST: return Color(0.3, 1, 0.3)
		EnemyType.TANK: return Color(0.4, 0.4, 0.4)
		EnemyType.RANGED: return Color(0.8, 0.3, 1)
		EnemyType.BRUISER: return Color(1.0, 0.55, 0.2)
		EnemyType.ASSASSIN: return Color(0.95, 0.95, 0.2)
	return Color.WHITE

func _update_health_bar():
	var health_percent = float(current_health) / max_health
	health_bar.value = health_percent * 100

func die():
	emit_signal("died", self, position)
	queue_free()

func set_player(player: Node2D):
	player_ref = player

func _on_detection_body_entered(body):
	if body.name == "Player" and not player_ref:
		player_ref = body

func _on_detection_body_exited(body):
	if body.name == "Player":
		# Don't immediately lose player - gives time to re-detect
		pass

func get_type_name() -> String:
	match enemy_type:
		EnemyType.GRUNT: return "Grunt"
		EnemyType.FAST: return "Fast"
		EnemyType.TANK: return "Tank"
		EnemyType.RANGED: return "Ranged"
		EnemyType.BRUISER: return "Bruiser"
		EnemyType.ASSASSIN: return "Assassin"
	return "Unknown"
