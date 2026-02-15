class_name RetreatState
extends EnemyState

var retreat_timer: float = 0.0

func enter() -> void:
	retreat_timer = 2.0
	enemy.show_retreat()

func update(delta: float) -> void:
	retreat_timer -= delta
	
	# Stop retreating after timer or if health recovered
	if retreat_timer <= 0 or enemy.current_health > enemy.max_health * 0.5:
		enemy.state_machine.change_state("chase")
		return

func physics_update(delta: float) -> void:
	if enemy.player_ref:
		# Run away from player
		var direction = (enemy.position - enemy.player_ref.position).normalized()
		enemy.velocity = direction * enemy.retreat_speed
		enemy.move_and_slide()
		
		# Face away from player
		if direction.x > 0:
			enemy.sprite.scale.x = 1
		elif direction.x < 0:
			enemy.sprite.scale.x = -1
