extends Area3D

@export var profile: Resource

@export var stamina_restore: float = 24.0
@export var respawn_time: float = 8.0
@export var bob_height: float = 0.2
@export var bob_speed: float = 2.2
@export var spin_speed_degrees: float = 95.0
@export_group("Magnet")
@export var magnet_radius: float = 4.0
@export var magnet_speed: float = 10.0
@export_range(0.0, 1.0, 0.01) var magnet_min_speed_ratio: float = 0.35
@export_range(0.5, 3.0, 0.05) var magnet_speed_curve_power: float = 1.4
@export var magnet_auto_collect_radius: float = 0.75
@export_range(0.0, 1.0, 0.01) var magnet_missing_stamina_ratio: float = 0.2
@export_group("Collection")
@export_range(0.0, 1.0, 0.01) var min_collect_missing_stamina_ratio: float = 0.05

@export_group("Dash Recovery")
@export var dash_recovery_bonus_seconds: float = 0.35
@export_range(0.0, 1.0, 0.01) var min_collect_missing_dash_ratio: float = 0.1
@export_range(0.0, 1.0, 0.01) var magnet_missing_dash_ratio: float = 0.2

@export_group("Dash Charge Recovery")
@export var dash_charge_restore_count: int = 1
@export_range(0.0, 1.0, 0.01) var min_collect_missing_dash_charge_ratio: float = 0.34
@export_range(0.0, 1.0, 0.01) var magnet_missing_dash_charge_ratio: float = 0.5

@export_group("Air Jump Recovery")
@export var air_jump_recovery_count: int = 1
@export_range(0.0, 1.0, 0.01) var min_collect_missing_air_jump_ratio: float = 0.34
@export_range(0.0, 1.0, 0.01) var magnet_missing_air_jump_ratio: float = 0.5

@export_group("Regen Surge")
@export var regen_boost_duration: float = 1.6
@export_range(1.0, 4.0, 0.05) var regen_boost_multiplier: float = 1.35

@export_group("Sprint Efficiency")
@export var sprint_efficiency_boost_duration: float = 2.4
@export_range(1.0, 4.0, 0.05) var sprint_efficiency_boost_multiplier: float = 1.5

@export_group("Momentum Boost")
@export var move_speed_boost_duration: float = 1.75
@export_range(1.0, 3.0, 0.05) var move_speed_boost_multiplier: float = 1.2

@export_group("Dash Defense Boost")
@export var dash_invulnerability_boost_duration: float = 2.0
@export_range(0.0, 0.5, 0.01) var dash_invulnerability_boost_bonus_seconds: float = 0.05

@export_group("Dash Charge Recovery Boost")
@export var dash_charge_recovery_boost_duration: float = 1.8
@export_range(1.0, 3.0, 0.05) var dash_charge_recovery_boost_multiplier: float = 1.35

@export_group("Line of Sight")
@export var magnet_requires_line_of_sight: bool = true
@export_flags_3d_physics var magnet_line_of_sight_collision_mask: int = 1
@export var magnet_line_of_sight_height_offset: float = 0.5

@export_group("Spawn Recovery")
@export var return_to_spawn_speed: float = 3.5
@export var return_to_spawn_snap_distance: float = 0.05

@export_group("Respawn Telegraph")
@export var show_respawn_telegraph: bool = true
@export var respawn_telegraph_duration: float = 1.1
@export_range(0.0, 1.0, 0.01) var respawn_telegraph_min_alpha: float = 0.2
@export_range(0.0, 1.0, 0.01) var respawn_telegraph_max_alpha: float = 0.8
@export var respawn_telegraph_pulse_speed: float = 8.0

@export_group("Visual")
@export var visual_albedo_color: Color = Color(0.5, 0.95, 1.0, 1.0)
@export var visual_emission_color: Color = Color(0.35, 0.8, 1.0, 1.0)
@export_range(0.0, 4.0, 0.05) var visual_emission_energy: float = 1.15

@export_group("Contextual Visuals")
@export var contextual_visual_feedback_enabled: bool = true
@export var contextual_stamina_tint: Color = Color(0.5, 0.95, 1.0, 1.0)
@export var contextual_dash_tint: Color = Color(1.0, 0.78, 0.36, 1.0)
@export var contextual_air_jump_tint: Color = Color(0.86, 0.66, 1.0, 1.0)
@export var contextual_mixed_tint: Color = Color(0.68, 0.92, 0.74, 1.0)
@export_range(0.0, 1.0, 0.01) var contextual_tint_blend: float = 0.7

@export_group("Proximity Feedback")
@export var proximity_feedback_enabled: bool = true
@export var proximity_feedback_radius: float = 5.5
@export_range(0.0, 1.0, 0.01) var proximity_scale_boost: float = 0.22
@export_range(0.0, 2.0, 0.01) var proximity_emission_boost: float = 0.7
@export_range(0.5, 20.0, 0.1) var proximity_response_speed: float = 8.0

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D

var _active: bool = true
var _base_y: float = 0.0
var _time: float = 0.0
var _spawn_origin: Vector3 = Vector3.ZERO
var _respawn_remaining: float = 0.0
var _runtime_albedo_tint: Color = Color(1.0, 1.0, 1.0, 1.0)
var _runtime_emission_tint: Color = Color(1.0, 1.0, 1.0, 1.0)
var _base_mesh_scale: Vector3 = Vector3.ONE
var _proximity_feedback_weight: float = 0.0

func _ready() -> void:
	_apply_profile_overrides()
	body_entered.connect(_on_body_entered)
	_base_y = global_position.y
	_spawn_origin = global_position
	if is_instance_valid(mesh):
		_base_mesh_scale = mesh.scale

func _apply_profile_overrides() -> void:
	if profile == null:
		return
	var settable_properties: Dictionary = {}
	for property_info in get_property_list():
		var property_name: StringName = StringName(property_info.name)
		settable_properties[property_name] = true
	var ignored_properties := {
		&"resource_local_to_scene": true,
		&"resource_name": true,
		&"resource_path": true,
		&"script": true
	}
	for property_info in profile.get_property_list():
		var property_name: StringName = StringName(property_info.name)
		if ignored_properties.has(property_name):
			continue
		var usage: int = int(property_info.usage)
		if (usage & PROPERTY_USAGE_STORAGE) == 0:
			continue
		if not settable_properties.has(property_name):
			continue
		set(property_name, profile.get(property_name))

func _process(delta: float) -> void:
	_time += delta
	if _active:
		if is_instance_valid(mesh):
			mesh.rotation_degrees.y += spin_speed_degrees * delta
			mesh.position.y = sin(_time * bob_speed) * bob_height
			_update_contextual_visual_tint()
			_update_proximity_feedback(delta)
			_set_mesh_alpha(1.0)
		_update_magnet_motion(delta)
		return

	_update_proximity_feedback(delta, true)
	_update_respawn(delta)

func _on_body_entered(body: Node) -> void:
	_try_collect(body)

func _try_collect(body: Node) -> void:
	if not _active:
		return
	if not body.has_method("restore_stamina"):
		return
	if not (body is Node3D):
		return
	var target: Node3D = body as Node3D
	var wants_stamina: bool = _target_needs_stamina_for_collection(target)
	var wants_dash_recovery: bool = _target_needs_dash_recovery(target, min_collect_missing_dash_ratio)
	var wants_dash_charge_recovery: bool = _target_needs_dash_charge_recovery(target, min_collect_missing_dash_charge_ratio)
	var wants_air_jump_recovery: bool = _target_needs_air_jump_recovery(target, min_collect_missing_air_jump_ratio)
	var wants_sprint_efficiency_boost: bool = _target_needs_sprint_efficiency_boost(target)
	var wants_move_speed_boost: bool = _target_needs_move_speed_boost(target)
	var wants_dash_invulnerability_boost: bool = _target_needs_dash_invulnerability_boost(target)
	var wants_dash_charge_recovery_boost: bool = _target_needs_dash_charge_recovery_boost(target)
	if not wants_stamina and not wants_dash_recovery and not wants_dash_charge_recovery and not wants_air_jump_recovery and not wants_sprint_efficiency_boost and not wants_move_speed_boost and not wants_dash_invulnerability_boost and not wants_dash_charge_recovery_boost:
		return

	var restored: float = 0.0
	if wants_stamina:
		restored = float(target.call("restore_stamina", stamina_restore))

	var dash_recovered: float = 0.0
	if dash_recovery_bonus_seconds > 0.0 and target.has_method("refund_dash_recovery") and wants_dash_recovery:
		dash_recovered = float(target.call("refund_dash_recovery", dash_recovery_bonus_seconds))

	var dash_charges_recovered: int = 0
	if dash_charge_restore_count > 0 and target.has_method("restore_dash_charges") and wants_dash_charge_recovery:
		dash_charges_recovered = int(target.call("restore_dash_charges", dash_charge_restore_count))

	var air_jumps_recovered: int = 0
	if air_jump_recovery_count > 0 and target.has_method("restore_air_jumps") and wants_air_jump_recovery:
		air_jumps_recovered = int(target.call("restore_air_jumps", air_jump_recovery_count))

	var regen_boost_applied: float = 0.0
	if regen_boost_duration > 0.0 and regen_boost_multiplier > 1.0 and target.has_method("apply_stamina_regen_boost"):
		regen_boost_applied = float(target.call("apply_stamina_regen_boost", regen_boost_duration, regen_boost_multiplier))

	var sprint_efficiency_boost_applied: float = 0.0
	if wants_sprint_efficiency_boost and sprint_efficiency_boost_duration > 0.0 and sprint_efficiency_boost_multiplier > 1.0 and target.has_method("apply_sprint_efficiency_boost"):
		sprint_efficiency_boost_applied = float(target.call("apply_sprint_efficiency_boost", sprint_efficiency_boost_duration, sprint_efficiency_boost_multiplier))

	var move_speed_boost_applied: float = 0.0
	if wants_move_speed_boost and move_speed_boost_duration > 0.0 and move_speed_boost_multiplier > 1.0 and target.has_method("apply_move_speed_boost"):
		move_speed_boost_applied = float(target.call("apply_move_speed_boost", move_speed_boost_duration, move_speed_boost_multiplier))

	var dash_invulnerability_boost_applied: float = 0.0
	if wants_dash_invulnerability_boost and dash_invulnerability_boost_duration > 0.0 and dash_invulnerability_boost_bonus_seconds > 0.0 and target.has_method("apply_dash_invulnerability_boost"):
		dash_invulnerability_boost_applied = float(target.call("apply_dash_invulnerability_boost", dash_invulnerability_boost_duration, dash_invulnerability_boost_bonus_seconds))

	var dash_charge_recovery_boost_applied: float = 0.0
	if wants_dash_charge_recovery_boost and dash_charge_recovery_boost_duration > 0.0 and dash_charge_recovery_boost_multiplier > 1.0 and target.has_method("apply_dash_charge_recovery_boost"):
		dash_charge_recovery_boost_applied = float(target.call("apply_dash_charge_recovery_boost", dash_charge_recovery_boost_duration, dash_charge_recovery_boost_multiplier))

	if restored <= 0.0 and dash_recovered <= 0.0 and dash_charges_recovered <= 0 and air_jumps_recovered <= 0 and regen_boost_applied <= 0.0 and sprint_efficiency_boost_applied <= 0.0 and move_speed_boost_applied <= 0.0 and dash_invulnerability_boost_applied <= 0.0 and dash_charge_recovery_boost_applied <= 0.0:
		return
	_deactivate()

func _deactivate() -> void:
	_active = false
	_respawn_remaining = max(0.1, respawn_time)
	monitoring = false
	monitorable = false
	if is_instance_valid(collision):
		collision.disabled = true
	if is_instance_valid(mesh):
		if show_respawn_telegraph:
			mesh.visible = true
			mesh.position.y = 0.0
			_set_mesh_alpha(clamp(respawn_telegraph_min_alpha, 0.0, 1.0))
		else:
			mesh.visible = false

func _activate() -> void:
	_active = true
	_respawn_remaining = 0.0
	global_position = _spawn_origin
	monitoring = true
	monitorable = true
	if is_instance_valid(collision):
		collision.disabled = false
	if is_instance_valid(mesh):
		mesh.visible = true
		mesh.position.y = 0.0
		_set_mesh_alpha(1.0)

func _update_respawn(delta: float) -> void:
	if _respawn_remaining <= 0.0:
		_activate()
		return
	_respawn_remaining = max(0.0, _respawn_remaining - delta)
	if not is_instance_valid(mesh):
		return
	if not show_respawn_telegraph:
		mesh.visible = false
		return

	var telegraph_duration: float = min(max(0.05, respawn_telegraph_duration), max(0.05, respawn_time))
	var telegraph_active: bool = _respawn_remaining <= telegraph_duration
	mesh.visible = telegraph_active
	if not telegraph_active:
		return

	mesh.rotation_degrees.y += spin_speed_degrees * delta * 0.75
	mesh.position.y = sin(_time * bob_speed) * (bob_height * 0.4)
	var pulse: float = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.001 * max(0.01, respawn_telegraph_pulse_speed))
	var min_alpha: float = clamp(respawn_telegraph_min_alpha, 0.0, 1.0)
	var max_alpha: float = clamp(respawn_telegraph_max_alpha, min_alpha, 1.0)
	_set_mesh_alpha(lerpf(min_alpha, max_alpha, pulse))

func _update_magnet_motion(delta: float) -> void:
	if magnet_radius <= 0.0 or magnet_speed <= 0.0:
		_move_toward_spawn(delta)
		return
	var player := _get_magnet_target()
	if player == null:
		_move_toward_spawn(delta)
		return
	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0.0
	var distance: float = to_player.length()
	if distance <= 0.01 or distance > magnet_radius:
		_move_toward_spawn(delta)
		return
	if magnet_requires_line_of_sight and not _has_line_of_sight_to_target(player):
		_move_toward_spawn(delta)
		return
	if distance <= max(0.05, magnet_auto_collect_radius):
		_try_collect(player)
		return
	var direction: Vector3 = to_player / distance
	var magnet_progress: float = clamp(1.0 - (distance / magnet_radius), 0.0, 1.0)
	var speed_curve: float = pow(magnet_progress, max(0.5, magnet_speed_curve_power))
	var speed_scale: float = lerpf(clamp(magnet_min_speed_ratio, 0.0, 1.0), 1.0, speed_curve)
	global_position += direction * magnet_speed * speed_scale * delta

func _move_toward_spawn(delta: float) -> void:
	var speed: float = max(0.0, return_to_spawn_speed)
	if speed <= 0.0:
		return
	var target_position := _spawn_origin
	var horizontal_delta := target_position - global_position
	horizontal_delta.y = 0.0
	var distance: float = horizontal_delta.length()
	if distance <= max(0.0, return_to_spawn_snap_distance):
		global_position = Vector3(target_position.x, global_position.y, target_position.z)
		return
	var step: float = min(distance, speed * delta)
	global_position += horizontal_delta.normalized() * step

func _get_magnet_target() -> Node3D:
	var players: Array[Node] = get_tree().get_nodes_in_group("player_3d")
	var best_target: Node3D = null
	var best_distance_sq: float = INF
	for node in players:
		if not (node is Node3D):
			continue
		var player: Node3D = node as Node3D
		if player == null:
			continue
		if not _target_needs_any_recovery(player, magnet_missing_stamina_ratio, magnet_missing_dash_ratio, magnet_missing_air_jump_ratio):
			continue
		var horizontal_delta: Vector3 = player.global_position - global_position
		horizontal_delta.y = 0.0
		var distance_sq: float = horizontal_delta.length_squared()
		if distance_sq < best_distance_sq:
			best_distance_sq = distance_sq
			best_target = player
	return best_target

func _target_needs_any_recovery(player: Node3D, stamina_threshold: float, dash_threshold: float, air_jump_threshold: float) -> bool:
	return _target_needs_stamina_with_threshold(player, stamina_threshold) \
		or _target_needs_dash_recovery(player, dash_threshold) \
		or _target_needs_dash_charge_recovery(player, magnet_missing_dash_charge_ratio) \
		or _target_needs_air_jump_recovery(player, air_jump_threshold) \
		or _target_needs_sprint_efficiency_boost(player) \
		or _target_needs_move_speed_boost(player) \
		or _target_needs_dash_invulnerability_boost(player) \
		or _target_needs_dash_charge_recovery_boost(player)

func _update_contextual_visual_tint() -> void:
	_runtime_albedo_tint = Color(1.0, 1.0, 1.0, 1.0)
	_runtime_emission_tint = Color(1.0, 1.0, 1.0, 1.0)
	if not contextual_visual_feedback_enabled:
		return
	var player := _get_magnet_target()
	if player == null:
		return
	var needs_stamina: bool = _target_needs_stamina_with_threshold(player, min_collect_missing_stamina_ratio)
	var needs_dash: bool = _target_needs_dash_recovery(player, min_collect_missing_dash_ratio) \
		or _target_needs_dash_charge_recovery(player, min_collect_missing_dash_charge_ratio)
	var needs_air_jump: bool = _target_needs_air_jump_recovery(player, min_collect_missing_air_jump_ratio)
	var active_modes: int = int(needs_stamina) + int(needs_dash) + int(needs_air_jump)
	if active_modes <= 0:
		return
	var target_tint: Color = contextual_mixed_tint
	if active_modes == 1:
		if needs_dash:
			target_tint = contextual_dash_tint
		elif needs_air_jump:
			target_tint = contextual_air_jump_tint
		else:
			target_tint = contextual_stamina_tint
	var blend: float = clamp(contextual_tint_blend, 0.0, 1.0)
	_runtime_albedo_tint = Color(1.0, 1.0, 1.0, 1.0).lerp(target_tint, blend)
	_runtime_emission_tint = Color(1.0, 1.0, 1.0, 1.0).lerp(target_tint, blend)

func _update_proximity_feedback(delta: float, force_reset: bool = false) -> void:
	if not is_instance_valid(mesh):
		return
	var target_weight: float = 0.0
	if not force_reset and proximity_feedback_enabled and proximity_feedback_radius > 0.01:
		var player := _get_magnet_target()
		if player != null:
			var to_player: Vector3 = player.global_position - global_position
			to_player.y = 0.0
			var proximity_ratio: float = clamp(1.0 - (to_player.length() / proximity_feedback_radius), 0.0, 1.0)
			target_weight = proximity_ratio
	var response_speed: float = max(0.5, proximity_response_speed)
	_proximity_feedback_weight = move_toward(_proximity_feedback_weight, target_weight, response_speed * delta)
	var scale_multiplier: float = 1.0 + (clamp(proximity_scale_boost, 0.0, 1.0) * _proximity_feedback_weight)
	mesh.scale = _base_mesh_scale * scale_multiplier

func _target_needs_stamina(player: Node3D) -> bool:
	return _target_needs_stamina_with_threshold(player, magnet_missing_stamina_ratio)

func _target_needs_stamina_for_collection(player: Node3D) -> bool:
	return _target_needs_stamina_with_threshold(player, min_collect_missing_stamina_ratio)

func _target_needs_stamina_with_threshold(player: Node3D, threshold_ratio: float) -> bool:
	if not player.has_method("restore_stamina"):
		return false
	var missing_ratio: float = _get_target_missing_stamina_ratio(player)
	return missing_ratio >= clamp(threshold_ratio, 0.0, 1.0)

func _target_needs_dash_recovery(player: Node3D, threshold_ratio: float) -> bool:
	if dash_recovery_bonus_seconds <= 0.0:
		return false
	if not player.has_method("refund_dash_recovery"):
		return false
	if not player.has_method("_next_dash_ready_remaining"):
		return false
	var remaining: float = max(0.0, float(player.call("_next_dash_ready_remaining")))
	if remaining <= 0.0:
		return false
	if not player.has_method("_next_dash_ready_max"):
		return true
	var max_value: float = max(0.01, float(player.call("_next_dash_ready_max")))
	var missing_ratio: float = clamp(remaining / max_value, 0.0, 1.0)
	return missing_ratio >= clamp(threshold_ratio, 0.0, 1.0)

func _target_needs_dash_charge_recovery(player: Node3D, threshold_ratio: float) -> bool:
	if dash_charge_restore_count <= 0:
		return false
	if not player.has_method("restore_dash_charges"):
		return false
	var tuning: Resource = player.get("tuning")
	if tuning == null:
		return false
	var max_dash_charges: int = max(1, int(tuning.get("dash_max_charges")))
	var current_dash_charges: int = clampi(int(player.get("dash_charges")), 0, max_dash_charges)
	var missing_ratio: float = float(max_dash_charges - current_dash_charges) / float(max_dash_charges)
	return missing_ratio >= clamp(threshold_ratio, 0.0, 1.0)

func _target_needs_air_jump_recovery(player: Node3D, threshold_ratio: float) -> bool:
	if air_jump_recovery_count <= 0:
		return false
	if not player.has_method("restore_air_jumps"):
		return false
	var tuning: Resource = player.get("tuning")
	if tuning == null:
		return false
	var max_air_jumps: int = max(0, int(tuning.get("max_air_jumps")))
	if max_air_jumps <= 0:
		return false
	var current_air_jumps: int = clampi(int(player.get("air_jumps_left")), 0, max_air_jumps)
	var missing_ratio: float = float(max_air_jumps - current_air_jumps) / float(max_air_jumps)
	return missing_ratio >= clamp(threshold_ratio, 0.0, 1.0)

func _target_needs_sprint_efficiency_boost(player: Node3D) -> bool:
	if sprint_efficiency_boost_duration <= 0.0 or sprint_efficiency_boost_multiplier <= 1.0:
		return false
	if not player.has_method("apply_sprint_efficiency_boost"):
		return false
	if not player.has_method("get"):
		return true
	var remaining: float = float(player.get("sprint_efficiency_boost_left"))
	return remaining <= 0.01

func _target_needs_move_speed_boost(player: Node3D) -> bool:
	if move_speed_boost_duration <= 0.0 or move_speed_boost_multiplier <= 1.0:
		return false
	if not player.has_method("apply_move_speed_boost"):
		return false
	if not player.has_method("get"):
		return true
	var remaining: float = float(player.get("move_speed_boost_left"))
	return remaining <= 0.01

func _target_needs_dash_invulnerability_boost(player: Node3D) -> bool:
	if dash_invulnerability_boost_duration <= 0.0 or dash_invulnerability_boost_bonus_seconds <= 0.0:
		return false
	if not player.has_method("apply_dash_invulnerability_boost"):
		return false
	if not player.has_method("get"):
		return true
	var remaining: float = float(player.get("dash_invulnerability_boost_left"))
	return remaining <= 0.01

func _target_needs_dash_charge_recovery_boost(player: Node3D) -> bool:
	if dash_charge_recovery_boost_duration <= 0.0 or dash_charge_recovery_boost_multiplier <= 1.0:
		return false
	if not player.has_method("apply_dash_charge_recovery_boost"):
		return false
	if not player.has_method("get"):
		return true
	var remaining: float = float(player.get("dash_charge_recovery_boost_left"))
	return remaining <= 0.01

func _get_target_missing_stamina_ratio(player: Node3D) -> float:
	var current_stamina: float = float(player.get("stamina"))
	var tuning: Resource = player.get("tuning")
	if tuning == null:
		return 1.0
	var max_stamina: float = float(tuning.get("max_stamina"))
	if max_stamina <= 0.01:
		return 0.0
	return clamp((max_stamina - current_stamina) / max_stamina, 0.0, 1.0)

func _has_line_of_sight_to_target(player: Node3D) -> bool:
	var world: World3D = get_world_3d()
	if world == null:
		return true
	var height_offset: Vector3 = Vector3.UP * max(0.0, magnet_line_of_sight_height_offset)
	var from_position: Vector3 = global_position + height_offset
	var to_position: Vector3 = player.global_position + height_offset
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from_position, to_position)
	query.exclude = [self, player]
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = max(1, magnet_line_of_sight_collision_mask)
	var hit: Dictionary = world.direct_space_state.intersect_ray(query)
	return hit.is_empty()

func _set_mesh_alpha(alpha: float) -> void:
	if not is_instance_valid(mesh):
		return
	var clamped_alpha: float = clamp(alpha, 0.0, 1.0)
	if mesh.material_override == null or not (mesh.material_override is StandardMaterial3D):
		var mat := StandardMaterial3D.new()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mesh.material_override = mat
	var material := mesh.material_override as StandardMaterial3D
	if material != null:
		var albedo_color := visual_albedo_color * _runtime_albedo_tint
		albedo_color.a = clamped_alpha
		material.albedo_color = albedo_color
		material.emission_enabled = visual_emission_energy > 0.0
		material.emission = visual_emission_color * _runtime_emission_tint
		var emission_multiplier: float = 1.0 + (max(0.0, proximity_emission_boost) * _proximity_feedback_weight)
		material.emission_energy_multiplier = max(0.0, visual_emission_energy) * emission_multiplier
