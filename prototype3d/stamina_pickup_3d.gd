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
@export var magnet_requires_line_of_sight: bool = true
@export_flags_3d_physics var magnet_line_of_sight_collision_mask: int = 1
@export var magnet_line_of_sight_height_offset: float = 0.5

@export_group("Spawn Recovery")
@export var return_to_spawn_speed: float = 3.5
@export var return_to_spawn_snap_distance: float = 0.05

@onready var mesh: Node3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D

var _active: bool = true
var _base_y: float = 0.0
var _time: float = 0.0
var _spawn_origin: Vector3 = Vector3.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_base_y = global_position.y
	_spawn_origin = global_position

func _process(delta: float) -> void:
	_time += delta
	if _active and is_instance_valid(mesh):
		mesh.rotation_degrees.y += spin_speed_degrees * delta
		mesh.position.y = sin(_time * bob_speed) * bob_height
		_update_magnet_motion(delta)

func _on_body_entered(body: Node) -> void:
	_try_collect(body)

func _try_collect(body: Node) -> void:
	if not _active:
		return
	if not body.has_method("restore_stamina"):
		return
	var restored: float = float(body.call("restore_stamina", stamina_restore))
	if restored <= 0.0:
		return
	_deactivate()
	_begin_respawn_timer()

func _begin_respawn_timer() -> void:
	var timer := get_tree().create_timer(max(0.1, respawn_time))
	timer.timeout.connect(_activate, CONNECT_ONE_SHOT)

func _deactivate() -> void:
	_active = false
	monitoring = false
	monitorable = false
	if is_instance_valid(collision):
		collision.disabled = true
	if is_instance_valid(mesh):
		mesh.visible = false

func _activate() -> void:
	_active = true
	global_position = _spawn_origin
	monitoring = true
	monitorable = true
	if is_instance_valid(collision):
		collision.disabled = false
	if is_instance_valid(mesh):
		mesh.visible = true
		mesh.position.y = 0.0

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
	var current_stamina: float = float(player.get("stamina"))
	var tuning: Resource = player.get("tuning")
	if tuning == null:
		return true
	var max_stamina: float = float(tuning.get("max_stamina"))
	if max_stamina <= 0.01:
		return false
	var missing_ratio: float = clamp((max_stamina - current_stamina) / max_stamina, 0.0, 1.0)
	return missing_ratio >= clamp(magnet_missing_stamina_ratio, 0.0, 1.0)

func _has_line_of_sight_to_target(player: Node3D) -> bool:
	var world := get_world_3d()
	if world == null:
		return true
	var offset := Vector3.UP * max(0.0, magnet_line_of_sight_height_offset)
	var from := global_position + offset
	var to := player.global_position + offset
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self, player]
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = max(1, magnet_line_of_sight_collision_mask)
	var hit := world.direct_space_state.intersect_ray(query)
	return hit.is_empty()
