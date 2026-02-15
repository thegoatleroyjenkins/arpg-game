class_name IdleState
extends EnemyState

var wander_timer: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO
var idle_time: float = 0.0

func enter() -> void:
	wander_timer = randf_range(1.0, 3.0)
	idle_time = randf_range(0.5, 2.0)
	enemy.velocity = Vector2.ZERO

func update(delta: float) -> void:
	if idle_time > 0:
		idle_time -= delta
		return
	
	wander_timer -= delta
	
	if wander_timer <= 0:
		wander_timer = randf_range(1.0, 3.0)
		# Pick random direction
		var angle = randf() * TAU
		wander_direction = Vector2(cos(angle), sin(angle))
	
	# Check if player is detected
	if enemy.player_ref and enemy.can_see_player():
		enemy.state_machine.change_state("chase")

func physics_update(delta: float) -> void:
	if idle_time <= 0 and wander_direction != Vector2.ZERO:
		enemy.velocity = wander_direction * enemy.wander_speed
		enemy.move_and_slide()
		
		# Face movement direction
		if enemy.velocity.x > 0:
			enemy.sprite.scale.x = 1
		elif enemy.velocity.x < 0:
			enemy.sprite.scale.x = -1
