extends Area3D

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

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D

var _active: bool = true
var _base_y: float = 0.0
var _time: float = 0.0
var _spawn_origin: Vector3 = Vector3.ZERO
var _respawn_remaining: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_base_y = global_position.y
	_spawn_origin = global_position

func _process(delta: float) -> void:
	_time += delta
	if _active:
		if is_instance_valid(mesh):
			mesh.rotation_degrees.y += spin_speed_degrees * delta
			mesh.position.y = sin(_time * bob_speed) * bob_height
			_set_mesh_alpha(1.0)
		_update_magnet_motion(delta)
		return

	_update_respawn(delta)

func _on_body_entered(body: Node) -> void:
	_try_collect(body)

func _try_collect(body: Node) -> void:
	if not _active:
		return
	if not body.has_method("restore_stamina"):
		return
	if body is Node3D:
		var missing_ratio: float = _get_target_missing_stamina_ratio(body)
		if missing_ratio < clamp(min_collect_missing_stamina_ratio, 0.0, 1.0):
			return
	var restored: float = float(body.call("restore_stamina", stamina_restore))
	if restored <= 0.0:
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
	if not _target_needs_stamina(player):
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
	for node in players:
		if node is Node3D:
			return node
	return null

func _target_needs_stamina(player: Node3D) -> bool:
	if not player.has_method("restore_stamina"):
		return false
	var missing_ratio: float = _get_target_missing_stamina_ratio(player)
	return missing_ratio >= clamp(magnet_missing_stamina_ratio, 0.0, 1.0)

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
		mat.albedo_color = Color(0.5, 0.95, 1.0, clamped_alpha)
		mesh.material_override = mat
	var material := mesh.material_override as StandardMaterial3D
	if material != null:
		material.albedo_color.a = clamped_alpha
