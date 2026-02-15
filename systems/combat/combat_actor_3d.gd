extends Node3D
class_name CombatActor3D

signal health_changed(current: float, max_value: float)
signal damage_taken(amount: float, current: float, max_value: float)
signal died()

@export var max_health: float = 100.0
@export var armor: float = 0.0
@export var damage_type_multipliers: Dictionary = {}

var current_health: float = 0.0
var is_dead: bool = false

func _ready() -> void:
	current_health = max(0.0, max_health)
	add_to_group("combat_actor_3d")
	health_changed.emit(current_health, max_health)

func get_mitigation_for(_payload: Dictionary) -> float:
	return max(0.0, armor)

func get_damage_multiplier_for(payload: Dictionary) -> float:
	var damage_type: String = String(payload.get("damage_type", "physical"))
	if damage_type_multipliers.has(damage_type):
		return max(0.0, float(damage_type_multipliers[damage_type]))
	return 1.0

func apply_damage_result(result: Dictionary) -> Dictionary:
	if is_dead:
		result["final_damage"] = 0.0
		result["is_lethal"] = true
		return result

	var incoming_damage: float = max(0.0, float(result.get("final_damage", 0.0)))
	if incoming_damage <= 0.0:
		return result

	current_health = max(0.0, current_health - incoming_damage)
	var lethal := current_health <= 0.0
	result["is_lethal"] = lethal
	result["health_after"] = current_health
	health_changed.emit(current_health, max_health)
	damage_taken.emit(incoming_damage, current_health, max_health)
	if lethal:
		is_dead = true
		died.emit()
		queue_free()
	return result
