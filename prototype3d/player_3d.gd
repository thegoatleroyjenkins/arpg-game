extends CharacterBody3D

@export var tuning: PlayerTuning3D = preload("res://prototype3d/default_player_tuning_3d.tres")

@onready var pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

signal stamina_changed(current: float, max_value: float)

var look_target: Vector3
var dash_direction: Vector3 = Vector3.ZERO
var dash_time_left: float = 0.0
var dash_cooldown_left: float = 0.0
var stamina: float = 0.0
var stamina_regen_delay_left: float = 0.0

func _ready() -> void:
	look_target = global_position
	stamina = tuning.max_stamina
	_emit_stamina_changed()
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

	if dash_cooldown_left > 0.0:
		dash_cooldown_left = max(0.0, dash_cooldown_left - delta)

	if Input.is_action_just_pressed("dash") and dash_cooldown_left <= 0.0 and _can_pay_stamina(tuning.dash_stamina_cost):
		_use_stamina(tuning.dash_stamina_cost)
		_start_dash(move_dir)

	if dash_time_left > 0.0:
		dash_time_left = max(0.0, dash_time_left - delta)
		velocity.x = dash_direction.x * tuning.dash_speed
		velocity.z = dash_direction.z * tuning.dash_speed
	else:
		var speed := tuning.move_speed
		var is_trying_to_sprint := Input.is_key_pressed(KEY_SHIFT) and move_dir.length() > 0.01
		if is_trying_to_sprint and _can_pay_stamina(tuning.sprint_stamina_per_second * delta):
			speed *= tuning.sprint_multiplier
			_use_stamina(tuning.sprint_stamina_per_second * delta)
		else:
			_regen_stamina(delta)

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

func _start_dash(move_dir: Vector3) -> void:
	dash_direction = move_dir
	if dash_direction.length() <= 0.01:
		dash_direction = -global_transform.basis.z
	dash_direction.y = 0.0
	dash_direction = dash_direction.normalized()
	dash_time_left = tuning.dash_duration
	dash_cooldown_left = tuning.dash_cooldown

func _can_pay_stamina(cost: float) -> bool:
	return stamina >= max(0.0, cost)

func _use_stamina(cost: float) -> void:
	if cost <= 0.0:
		return
	stamina = max(0.0, stamina - cost)
	stamina_regen_delay_left = tuning.stamina_regen_delay
	_emit_stamina_changed()

func _regen_stamina(delta: float) -> void:
	if stamina_regen_delay_left > 0.0:
		stamina_regen_delay_left = max(0.0, stamina_regen_delay_left - delta)
		return
	if stamina >= tuning.max_stamina:
		return
	stamina = min(tuning.max_stamina, stamina + tuning.stamina_regen_per_second * delta)
	_emit_stamina_changed()

func _emit_stamina_changed() -> void:
	stamina_changed.emit(stamina, tuning.max_stamina)
