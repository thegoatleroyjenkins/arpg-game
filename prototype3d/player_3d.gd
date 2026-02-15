extends CharacterBody3D

const ACTION_JUMP := "jump"

@export var tuning: PlayerTuning3D = preload("res://prototype3d/default_player_tuning_3d.tres")

@onready var pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

signal stamina_changed(current: float, max_value: float)
signal dash_cooldown_changed(remaining: float, max_value: float)
signal dash_charges_changed(current: int, max_value: int)
signal air_jumps_changed(current: int, max_value: int)

var look_target: Vector3
var target_camera_distance: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO
var dash_time_left: float = 0.0
var dash_cooldown_left: float = 0.0
var dash_charge_recharge_left: float = 0.0
var dash_charges: int = 0
var dash_buffer_left: float = 0.0
var buffered_dash_direction: Vector3 = Vector3.ZERO
var stamina: float = 0.0
var stamina_regen_delay_left: float = 0.0
var sprint_blend: float = 0.0
var sprint_exhausted: bool = false
var coyote_time_left: float = 0.0
var jump_buffer_left: float = 0.0
var air_jumps_left: int = 0
var camera_look_ahead: Vector3 = Vector3.ZERO
var landing_recovery_left: float = 0.0

func _ready() -> void:
	look_target = global_position
	target_camera_distance = clamp(tuning.camera_distance, tuning.camera_min_distance, tuning.camera_max_distance)
	stamina = tuning.max_stamina
	dash_charges = max(1, tuning.dash_max_charges)
	air_jumps_left = max(0, tuning.max_air_jumps)
	camera.fov = tuning.camera_base_fov
	_emit_stamina_changed()
	_emit_dash_charges_changed()
	_emit_dash_cooldown_changed()
	_emit_air_jumps_changed()
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
		var reset_air_jumps: int = max(0, tuning.max_air_jumps)
		if air_jumps_left != reset_air_jumps:
			air_jumps_left = reset_air_jumps
			_emit_air_jumps_changed()
	else:
		coyote_time_left = max(0.0, coyote_time_left - delta)
		var gravity_scale := 1.0
		# Variable jump height: releasing jump early makes ascent fall off faster.
		if velocity.y > 0.0 and not _is_jump_pressed():
			gravity_scale = tuning.jump_release_gravity_multiplier
		# Apex hang: near the top of a jump, reduce gravity for cleaner aerial control.
		elif absf(velocity.y) <= tuning.jump_apex_vertical_speed_threshold:
			gravity_scale = tuning.jump_apex_gravity_multiplier
		velocity.y -= tuning.gravity * gravity_scale * delta
		velocity.y = max(velocity.y, -tuning.max_fall_speed)

	var can_ground_jump := coyote_time_left > 0.0
	var can_air_jump := not was_on_floor and air_jumps_left > 0
	if jump_buffer_left > 0.0 and (can_ground_jump or can_air_jump) and _can_pay_stamina(tuning.jump_stamina_cost):
		_use_stamina(tuning.jump_stamina_cost)
		velocity.y = tuning.jump_velocity
		jump_buffer_left = 0.0
		if can_ground_jump:
			coyote_time_left = 0.0
		elif can_air_jump:
			air_jumps_left -= 1
			_emit_air_jumps_changed()

	if landing_recovery_left > 0.0:
		landing_recovery_left = max(0.0, landing_recovery_left - delta)

	# Movement input
	var input_vec := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	var move_dir := Vector3(input_vec.x, 0.0, input_vec.y)
	if move_dir.length() > 1.0:
		move_dir = move_dir.normalized()
	if landing_recovery_left > 0.0:
		move_dir = Vector3.ZERO

	var dash_state_changed := false
	if dash_cooldown_left > 0.0:
		dash_cooldown_left = max(0.0, dash_cooldown_left - delta)
		dash_state_changed = true

	if dash_charge_recharge_left > 0.0:
		dash_charge_recharge_left = max(0.0, dash_charge_recharge_left - delta)
		dash_state_changed = true
		if dash_charge_recharge_left <= 0.0 and dash_charges < max(1, tuning.dash_max_charges):
			dash_charges += 1
			_emit_dash_charges_changed()
			if dash_charges < max(1, tuning.dash_max_charges):
				dash_charge_recharge_left = max(0.01, tuning.dash_charge_recovery_time)
				dash_state_changed = true

	if dash_buffer_left > 0.0:
		dash_buffer_left = max(0.0, dash_buffer_left - delta)

	if dash_state_changed:
		_emit_dash_cooldown_changed()

	if landing_recovery_left <= 0.0 and Input.is_action_just_pressed("dash"):
		if _can_start_dash() and _can_pay_stamina(tuning.dash_stamina_cost):
			_use_stamina(tuning.dash_stamina_cost)
			_start_dash(move_dir)
		elif _dash_ready_within(tuning.dash_input_buffer_time):
			dash_buffer_left = tuning.dash_input_buffer_time
			buffered_dash_direction = move_dir

	if landing_recovery_left <= 0.0 and dash_buffer_left > 0.0 and _can_start_dash() and _can_pay_stamina(tuning.dash_stamina_cost):
		_use_stamina(tuning.dash_stamina_cost)
		_start_dash(buffered_dash_direction)
		dash_buffer_left = 0.0
		buffered_dash_direction = Vector3.ZERO

	if dash_time_left > 0.0:
		dash_time_left = max(0.0, dash_time_left - delta)
		_update_dash_direction(move_dir, delta)
		velocity.x = dash_direction.x * tuning.dash_speed
		velocity.z = dash_direction.z * tuning.dash_speed
	else:
		var is_recovering := landing_recovery_left > 0.0
		var is_moving := move_dir.length() > 0.01
		var is_trying_to_sprint := Input.is_action_pressed("sprint") and is_moving and not is_recovering
		var is_sprinting := false
		var sprint_exhaust_threshold: float = max(0.0, tuning.sprint_exhaustion_threshold)
		var sprint_resume_threshold: float = max(sprint_exhaust_threshold, tuning.sprint_resume_threshold)
		if sprint_exhausted and stamina >= sprint_resume_threshold:
			sprint_exhausted = false
		if is_trying_to_sprint and not sprint_exhausted and _can_pay_stamina(tuning.sprint_stamina_per_second * delta):
			is_sprinting = true
			_use_stamina(tuning.sprint_stamina_per_second * delta)
			if stamina <= sprint_exhaust_threshold:
				sprint_exhausted = true
		else:
			_regen_stamina(delta, is_moving and not is_recovering)

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
		if is_recovering:
			rate = decel
		horizontal_velocity = horizontal_velocity.move_toward(target_velocity, rate * delta)
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z

	var pre_move_vertical_velocity := velocity.y
	move_and_slide()

	if not was_on_floor and is_on_floor() and pre_move_vertical_velocity <= -absf(tuning.hard_landing_speed_threshold):
		landing_recovery_left = max(landing_recovery_left, max(0.0, tuning.hard_landing_recovery_time))

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
	dash_charges = max(0, dash_charges - 1)
	if dash_charges < max(1, tuning.dash_max_charges) and dash_charge_recharge_left <= 0.0:
		dash_charge_recharge_left = max(0.01, tuning.dash_charge_recovery_time)
	dash_buffer_left = 0.0
	buffered_dash_direction = Vector3.ZERO
	_emit_dash_charges_changed()
	_emit_dash_cooldown_changed()

func _update_dash_direction(move_dir: Vector3, delta: float) -> void:
	if move_dir.length() <= 0.01:
		return
	var steer_control: float = clamp(tuning.dash_steer_control, 0.0, 1.0)
	if steer_control <= 0.0:
		return
	var steering_target: Vector3 = move_dir.normalized()
	var steer_lerp: float = clamp(delta * max(0.01, tuning.dash_steer_responsiveness) * steer_control, 0.0, 1.0)
	dash_direction = dash_direction.slerp(steering_target, steer_lerp)
	dash_direction.y = 0.0
	if dash_direction.length() <= 0.01:
		dash_direction = steering_target
	dash_direction = dash_direction.normalized()

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

func _can_start_dash() -> bool:
	return dash_time_left <= 0.0 and dash_cooldown_left <= 0.0 and dash_charges > 0

func _dash_ready_within(window: float) -> bool:
	if window <= 0.0:
		return false
	var remaining := _next_dash_ready_remaining()
	return remaining > 0.0 and remaining <= window

func _next_dash_ready_remaining() -> float:
	if dash_charges > 0:
		return dash_cooldown_left
	return max(dash_cooldown_left, dash_charge_recharge_left)

func _next_dash_ready_max() -> float:
	if dash_charges > 0:
		return max(0.01, tuning.dash_cooldown)
	return max(0.01, max(tuning.dash_cooldown, tuning.dash_charge_recovery_time))

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

func _emit_dash_charges_changed() -> void:
	dash_charges_changed.emit(dash_charges, max(1, tuning.dash_max_charges))

func _emit_dash_cooldown_changed() -> void:
	dash_cooldown_changed.emit(_next_dash_ready_remaining(), _next_dash_ready_max())

func _emit_air_jumps_changed() -> void:
	air_jumps_changed.emit(air_jumps_left, max(0, tuning.max_air_jumps))
