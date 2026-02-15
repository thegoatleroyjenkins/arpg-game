extends Node
class_name DamageResolver

signal damage_requested(payload: Dictionary)
signal damage_resolved(result: Dictionary)
signal damage_applied(result: Dictionary)

func _ready() -> void:
	add_to_group("damage_resolver")

func request_damage(payload: Dictionary) -> Dictionary:
	damage_requested.emit(payload)
	var target: Node = payload.get("target", null)
	if target == null:
		return {}

	var requested_damage: float = max(0.0, float(payload.get("base_damage", 0.0)))
	var crit_chance: float = clamp(float(payload.get("crit_chance", 0.0)), 0.0, 1.0)
	var crit_multiplier: float = max(1.0, float(payload.get("crit_multiplier", 1.5)))
	var is_critical: bool = crit_chance > 0.0 and randf() <= crit_chance
	if is_critical:
		requested_damage *= crit_multiplier
	var mitigation: float = 0.0
	if target.has_method("get_mitigation_for"):
		mitigation = max(0.0, float(target.get_mitigation_for(payload)))

	var final_damage: float = max(0.0, requested_damage - mitigation)
	var result := {
		"source": payload.get("source", null),
		"target": target,
		"damage_type": payload.get("damage_type", "physical"),
		"tags": payload.get("tags", PackedStringArray()),
		"requested_damage": requested_damage,
		"mitigated_damage": mitigation,
		"final_damage": final_damage,
		"is_critical": is_critical,
		"critical_multiplier": crit_multiplier if is_critical else 1.0,
		"is_lethal": false,
	}
	damage_resolved.emit(result)

	if target.has_method("apply_damage_result"):
		result = target.apply_damage_result(result)

	damage_applied.emit(result)
	return result
