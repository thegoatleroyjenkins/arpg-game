extends CharacterBody3D

const ACTION_JUMP := "jump"

@export var tuning: PlayerTuning3D = preload("res://prototype3d/default_player_tuning_3d.tres")

@onready var pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

signal stamina_changed(current: float, max_value: float)
signal dash_cooldown_changed(remaining: float, max_value: float)

var look_target: Vector3
var target_camera_distance: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO
var dash_time_left: float = 0.0
var dash_cooldown_left: float = 0.0
var dash_buffer_left: float = 0.0
var buffered_dash_direction: Vector3 = Vector3.ZERO
var stamina: float = 0.0
var stamina_regen_delay_left: float = 0.0
var sprint_blend: float = 0.0
var coyote_time_left: float = 0.0
var jump_buffer_left: float = 0.0
var camera_look_ahead: Vector3 = Vector3.ZERO

func _ready() -> void:
	look_target = global_position
	target_camera_distance = clamp(tuning.camera_distance, tuning.camera_min_distance, tuning.camera_max_distance)
	stamina = tuning.max_stamina
	camera.fov = tuning.camera_base_fov
	_emit_stamina_changed()
	_emit_dash_cooldown_changed()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseButton and event.pressed:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_adjust_camera_zoom(-tuning.camera_zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_adjust_camera_zoom(tuning.camera_zoom_step)

func _physics_process(delta: float) -> void:
	var was_on_floor := is_on_floor()

	# Jump buffering gives more forgiving timing before landing.
	if _is_jump_just_pressed():
		jump_buffer_left = tuning.jump_buffer_time
	else:
		jump_buffer_left = max(0.0, jump_buffer_left - delta)

	# Gravity + coyote time for forgiving jumps after stepping off ledges.
	if was_on_floor:
		coyote_time_left = tuning.coyote_time
	else:
		coyote_time_left = max(0.0, coyote_time_left - delta)
		var gravity_scale := 1.0
		# Variable jump height: releasing jump early makes ascent fall off faster.
		if velocity.y > 0.0 and not _is_jump_pressed():
			gravity_scale = tuning.jump_release_gravity_multiplier
		velocity.y -= tuning.gravity * gravity_scale * delta
		velocity.y = max(velocity.y, -tuning.max_fall_speed)

	if jump_buffer_left > 0.0 and coyote_time_left > 0.0 and _can_pay_stamina(tuning.jump_stamina_cost):
		_use_stamina(tuning.jump_stamina_cost)
		velocity.y = tuning.jump_velocity
		jump_buffer_left = 0.0
		coyote_time_left = 0.0

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
		_emit_dash_cooldown_changed()

	if dash_buffer_left > 0.0:
		dash_buffer_left = max(0.0, dash_buffer_left - delta)

	if Input.is_action_just_pressed("dash"):
		if dash_cooldown_left <= 0.0 and _can_pay_stamina(tuning.dash_stamina_cost):
			_use_stamina(tuning.dash_stamina_cost)
			_start_dash(move_dir)
		elif dash_cooldown_left <= tuning.dash_input_buffer_time:
			dash_buffer_left = tuning.dash_input_buffer_time
			buffered_dash_direction = move_dir

	if dash_buffer_left > 0.0 and dash_cooldown_left <= 0.0 and dash_time_left <= 0.0 and _can_pay_stamina(tuning.dash_stamina_cost):
		_use_stamina(tuning.dash_stamina_cost)
		_start_dash(buffered_dash_direction)
		dash_buffer_left = 0.0
		buffered_dash_direction = Vector3.ZERO

	if dash_time_left > 0.0:
		dash_time_left = max(0.0, dash_time_left - delta)
		velocity.x = dash_direction.x * tuning.dash_speed
		velocity.z = dash_direction.z * tuning.dash_speed
	else:
		var is_moving := move_dir.length() > 0.01
		var is_trying_to_sprint := Input.is_action_pressed("sprint") and is_moving
		var is_sprinting := false
		if is_trying_to_sprint and _can_pay_stamina(tuning.sprint_stamina_per_second * delta):
			is_sprinting = true
			_use_stamina(tuning.sprint_stamina_per_second * delta)
		else:
			_regen_stamina(delta, is_moving)

		var ramp_up: float = max(0.01, tuning.sprint_ramp_up_per_second)
		var ramp_down: float = max(0.01, tuning.sprint_ramp_down_per_second)
		if is_sprinting:
			sprint_blend = min(1.0, sprint_blend + ramp_up * delta)
		else:
			sprint_blend = max(0.0, sprint_blend - ramp_down * delta)

		var sprint_multiplier := lerpf(1.0, tuning.sprint_multiplier, sprint_blend)
		var speed := tuning.move_speed * sprint_multiplier
		var target_velocity := move_dir * speed
		var control_scale := 1.0 if is_on_floor() else tuning.air_control
		var accel := tuning.ground_acceleration * control_scale
		var decel := tuning.ground_deceleration * control_scale
		var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
		var rate := accel if move_dir.length() > 0.01 else decel
		horizontal_velocity = horizontal_velocity.move_toward(target_velocity, rate * delta)
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z

	move_and_slide()

	# Face movement direction with data-driven turn speed smoothing.
	var horizontal_vel := Vector3(velocity.x, 0.0, velocity.z)
	if horizontal_vel.length() > tuning.min_turn_speed_threshold:
		look_target = global_position + horizontal_vel.normalized()
		var desired_yaw := atan2(-horizontal_vel.x, -horizontal_vel.z)
		rotation.y = lerp_angle(rotation.y, desired_yaw, deg_to_rad(tuning.turn_speed_degrees_per_second) * delta)

	# Follow camera smoothly with scroll-wheel zoom and movement-aware look-ahead.
	var target_cam_pos := global_position + Vector3(0.0, tuning.camera_height, target_camera_distance)
	pivot.global_position = pivot.global_position.lerp(target_cam_pos, delta * tuning.camera_smooth)
	_update_camera_look_ahead(delta)
	camera.look_at(global_position + Vector3(0, 1.0, 0) + camera_look_ahead, Vector3.UP)
	_update_camera_fov(delta)

func _is_jump_just_pressed() -> bool:
	if InputMap.has_action(ACTION_JUMP):
		return Input.is_action_just_pressed(ACTION_JUMP)
	return Input.is_action_just_pressed("ui_accept")

func _is_jump_pressed() -> bool:
	if InputMap.has_action(ACTION_JUMP):
		return Input.is_action_pressed(ACTION_JUMP)
	return Input.is_action_pressed("ui_accept")

func _start_dash(move_dir: Vector3) -> void:
	dash_direction = move_dir
	if dash_direction.length() <= 0.01:
		dash_direction = -global_transform.basis.z
	dash_direction.y = 0.0
	dash_direction = dash_direction.normalized()
	dash_time_left = tuning.dash_duration
	dash_cooldown_left = tuning.dash_cooldown
	dash_buffer_left = 0.0
	buffered_dash_direction = Vector3.ZERO
	_emit_dash_cooldown_changed()

func _update_camera_fov(delta: float) -> void:
	var horizontal_speed := Vector3(velocity.x, 0.0, velocity.z).length()
	var speed_ratio := 0.0
	if tuning.move_speed > 0.01:
		speed_ratio = clamp(horizontal_speed / (tuning.move_speed * max(1.0, tuning.sprint_multiplier)), 0.0, 1.0)
	var dash_bonus := tuning.camera_fov_dash_bonus if dash_time_left > 0.0 else 0.0
	var target_fov := tuning.camera_base_fov + tuning.camera_fov_speed_bonus * speed_ratio + dash_bonus
	camera.fov = lerpf(camera.fov, target_fov, clamp(delta * tuning.camera_fov_smooth, 0.0, 1.0))

func _update_camera_look_ahead(delta: float) -> void:
	var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
	var target_look_ahead := Vector3.ZERO
	if horizontal_velocity.length() > 0.01 and tuning.camera_look_ahead_distance > 0.0:
		var speed_denominator: float = tuning.move_speed * max(1.0, tuning.sprint_multiplier)
		var speed_ratio: float = 0.0
		if speed_denominator > 0.01:
			speed_ratio = clamp(horizontal_velocity.length() / speed_denominator, 0.0, 1.0)
		target_look_ahead = horizontal_velocity.normalized() * tuning.camera_look_ahead_distance * speed_ratio
	camera_look_ahead = camera_look_ahead.lerp(target_look_ahead, clamp(delta * tuning.camera_look_ahead_smooth, 0.0, 1.0))

func _adjust_camera_zoom(amount: float) -> void:
	target_camera_distance = clamp(
		target_camera_distance + amount,
		tuning.camera_min_distance,
		tuning.camera_max_distance
	)

func _can_pay_stamina(cost: float) -> bool:
	return stamina >= max(0.0, cost)

func _use_stamina(cost: float) -> void:
	if cost <= 0.0:
		return
	stamina = max(0.0, stamina - cost)
	stamina_regen_delay_left = tuning.stamina_regen_delay
	_emit_stamina_changed()

func _regen_stamina(delta: float, is_moving: bool) -> void:
	if stamina_regen_delay_left > 0.0:
		stamina_regen_delay_left = max(0.0, stamina_regen_delay_left - delta)
		return
	if stamina >= tuning.max_stamina:
		return
	var regen_rate := tuning.stamina_regen_idle_per_second
	if is_moving:
		regen_rate = tuning.stamina_regen_moving_per_second
	stamina = min(tuning.max_stamina, stamina + regen_rate * delta)
	_emit_stamina_changed()

func _emit_stamina_changed() -> void:
	stamina_changed.emit(stamina, tuning.max_stamina)

func _emit_dash_cooldown_changed() -> void:
	dash_cooldown_changed.emit(dash_cooldown_left, tuning.dash_cooldown)
