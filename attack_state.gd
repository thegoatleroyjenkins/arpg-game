class_name AttackState
extends EnemyState

var attack_timer: float = 0.0

func enter() -> void:
	attack_timer = 0.0

func update(delta: float) -> void:
	if not enemy.player_ref:
		enemy.state_machine.change_state("idle")
		return
	
	var dist = enemy.position.distance_to(enemy.player_ref.position)
	
	# Player moved out of attack range
	if dist > enemy.attack_range + 10:
		enemy.state_machine.change_state("chase")
		return
	
	# Attack cooldown
	if attack_timer > 0:
		attack_timer -= delta
		return
	
	# Perform attack
	if enemy.attack_cooldown <= 0:
		enemy.perform_attack()
		attack_timer = enemy.attack_cooldown_time

func physics_update(delta: float) -> void:
	# Stay in place while attacking, maybe circle slightly
	enemy.velocity = enemy.velocity * 0.9
	enemy.move_and_slide()
