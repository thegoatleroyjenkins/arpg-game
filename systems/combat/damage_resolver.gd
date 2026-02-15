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

	# Optional payload knobs keep damage math data-driven across skills/items:
	# - armor_penetration_flat: subtracts flat mitigation before damage
	# - armor_penetration_ratio: ignores a % of mitigation (0.0 - 1.0)
	# - minimum_damage: absolute final-damage floor
	# - minimum_damage_ratio: floor based on requested damage (0.0 - 1.0)
	var armor_penetration_flat: float = max(0.0, float(payload.get("armor_penetration_flat", 0.0)))
	var armor_penetration_ratio: float = clamp(float(payload.get("armor_penetration_ratio", 0.0)), 0.0, 1.0)
	var effective_mitigation: float = mitigation
	effective_mitigation *= max(0.0, 1.0 - armor_penetration_ratio)
	effective_mitigation = max(0.0, effective_mitigation - armor_penetration_flat)

	var minimum_damage: float = max(0.0, float(payload.get("minimum_damage", 0.0)))
	var minimum_damage_ratio: float = clamp(float(payload.get("minimum_damage_ratio", 0.0)), 0.0, 1.0)
	minimum_damage = max(minimum_damage, requested_damage * minimum_damage_ratio)

	var damage_multiplier: float = 1.0
	if target.has_method("get_damage_multiplier_for"):
		damage_multiplier = max(0.0, float(target.get_damage_multiplier_for(payload)))

	var final_damage_before_multiplier: float = max(minimum_damage, requested_damage - effective_mitigation)
	var final_damage: float = final_damage_before_multiplier * damage_multiplier
	var result := {
		"source": payload.get("source", null),
		"target": target,
		"damage_type": payload.get("damage_type", "physical"),
		"tags": payload.get("tags", PackedStringArray()),
		"requested_damage": requested_damage,
		"mitigated_damage": effective_mitigation,
		"raw_mitigation": mitigation,
		"armor_penetration_flat": armor_penetration_flat,
		"armor_penetration_ratio": armor_penetration_ratio,
		"minimum_damage": minimum_damage,
		"damage_multiplier": damage_multiplier,
		"final_damage_before_multiplier": final_damage_before_multiplier,
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
