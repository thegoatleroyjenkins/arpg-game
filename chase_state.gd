class_name ChaseState
extends EnemyState

func enter() -> void:
	# Optional: Show exclamation mark or alert animation
	enemy.show_alert()

func update(delta: float) -> void:
	if not enemy.player_ref:
		enemy.state_machine.change_state("idle")
		return
	
	var dist = enemy.position.distance_to(enemy.player_ref.position)
	
	# Lost sight of player
	if not enemy.can_see_player() and dist > enemy.detection_range * 1.5:
		enemy.state_machine.change_state("idle")
		return
	
	# Within attack range
	if dist <= enemy.attack_range:
		enemy.state_machine.change_state("attack")
		return

func physics_update(delta: float) -> void:
	if enemy.player_ref:
		var direction = (enemy.player_ref.position - enemy.position).normalized()
		enemy.velocity = direction * enemy.chase_speed
		enemy.move_and_slide()
		
		# Face player
		if direction.x > 0:
			enemy.sprite.scale.x = 1
		elif direction.x < 0:
			enemy.sprite.scale.x = -1
