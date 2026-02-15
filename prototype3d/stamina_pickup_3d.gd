extends Area3D

@export var stamina_restore: float = 24.0
@export var respawn_time: float = 8.0
@export var bob_height: float = 0.2
@export var bob_speed: float = 2.2
@export var spin_speed_degrees: float = 95.0

@onready var mesh: Node3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D

var _active: bool = true
var _base_y: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_base_y = global_position.y

func _process(delta: float) -> void:
	_time += delta
	if _active and is_instance_valid(mesh):
		mesh.rotation_degrees.y += spin_speed_degrees * delta
		mesh.position.y = sin(_time * bob_speed) * bob_height

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
	monitoring = true
	monitorable = true
	if is_instance_valid(collision):
		collision.disabled = false
	if is_instance_valid(mesh):
		mesh.visible = true
		mesh.position.y = 0.0
