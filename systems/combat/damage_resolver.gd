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
		"is_lethal": false,
	}
	damage_resolved.emit(result)

	if target.has_method("apply_damage_result"):
		result = target.apply_damage_result(result)

	damage_applied.emit(result)
	return result
