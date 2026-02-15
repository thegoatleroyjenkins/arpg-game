extends CharacterBody3D

@export var tuning: PlayerTuning3D = preload("res://prototype3d/default_player_tuning_3d.tres")

@onready var pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

var look_target: Vector3

func _ready() -> void:
	look_target = global_position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseButton and event.pressed and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= tuning.gravity * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = tuning.jump_velocity

	# Movement input
	var input_vec := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	var move_dir := Vector3(input_vec.x, 0.0, input_vec.y)
	if move_dir.length() > 1.0:
		move_dir = move_dir.normalized()

	var speed := tuning.move_speed
	if Input.is_key_pressed(KEY_SHIFT):
		speed *= tuning.sprint_multiplier

	velocity.x = move_dir.x * speed
	velocity.z = move_dir.z * speed

	move_and_slide()

	# Face movement direction
	var horizontal_vel := Vector3(velocity.x, 0.0, velocity.z)
	if horizontal_vel.length() > 0.1:
		look_target = global_position + horizontal_vel.normalized()
		look_at(look_target, Vector3.UP)

	# Follow camera smoothly
	var target_cam_pos := global_position + Vector3(0.0, tuning.camera_height, tuning.camera_distance)
	pivot.global_position = pivot.global_position.lerp(target_cam_pos, delta * tuning.camera_smooth)
	camera.look_at(global_position + Vector3(0, 1.0, 0), Vector3.UP)
