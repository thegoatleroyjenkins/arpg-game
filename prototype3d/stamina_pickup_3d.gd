extends Area3D

@export var stamina_restore: float = 24.0
@export var respawn_time: float = 8.0
@export var bob_height: float = 0.2
@export var bob_speed: float = 2.2
@export var spin_speed_degrees: float = 95.0
@export_group("Magnet")
@export var magnet_radius: float = 4.0
@export var magnet_speed: float = 10.0
@export_range(0.0, 1.0, 0.01) var magnet_missing_stamina_ratio: float = 0.2

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
	if not _active:
		return
	if not body.has_method("restore_stamina"):
		return
	var restored: float = float(body.call("restore_stamina", stamina_restore))
	if restored <= 0.0:
		return
	_deactivate()
	await get_tree().create_timer(max(0.1, respawn_time)).timeout
	_activate()

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
		return
	var player := _get_magnet_target()
	if player == null:
		return
	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0.0
	var distance: float = to_player.length()
	if distance <= 0.01 or distance > magnet_radius:
		return
	if not _target_needs_stamina(player):
		return
	var direction: Vector3 = to_player / distance
	global_position += direction * magnet_speed * delta

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
