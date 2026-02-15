extends CharacterBody3D

const ACTION_JUMP := "jump"
const ACTION_CAMERA_RECENTER := "camera_recenter"

@export var tuning: PlayerTuning3D = preload("res://prototype3d/default_player_tuning_3d.tres")

@onready var pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var body_mesh: MeshInstance3D = $MeshInstance3D

signal stamina_changed(current: float, max_value: float)
signal dash_cooldown_changed(remaining: float, max_value: float)
signal dash_buffer_changed(remaining: float, max_value: float)
signal dash_charges_changed(current: int, max_value: int)
signal dash_charge_recharge_changed(remaining: float, max_value: float)
signal air_jumps_changed(current: int, max_value: int)
signal sprint_state_changed(is_sprinting: bool, is_exhausted: bool)
signal landing_recovery_changed(remaining: float, max_value: float)
signal stamina_regen_delay_changed(remaining: float, max_value: float)
signal stamina_action_failed(reason: String, remaining: float)
signal dash_invulnerability_changed(remaining: float, max_value: float)
signal stamina_regen_boost_changed(remaining: float, max_value: float, multiplier: float)
signal sprint_efficiency_boost_changed(remaining: float, max_value: float, multiplier: float)
signal move_speed_boost_changed(remaining: float, max_value: float, multiplier: float)
signal dash_invulnerability_boost_changed(remaining: float, max_value: float, bonus_seconds: float)
signal dash_charge_recovery_boost_changed(remaining: float, max_value: float, multiplier: float)

var look_target: Vector3
var respawn_position: Vector3
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
var camera_impulse_offset: Vector3 = Vector3.ZERO
var landing_recovery_left: float = 0.0
var recent_move_direction: Vector3 = Vector3.ZERO
var recent_move_direction_left: float = 0.0
var stamina_action_warning_cooldown_left: float = 0.0
var dash_invulnerability_left: float = 0.0
var stamina_regen_boost_left: float = 0.0
var stamina_regen_boost_max: float = 0.0
var stamina_regen_boost_multiplier: float = 1.0
var sprint_efficiency_boost_left: float = 0.0
var sprint_efficiency_boost_max: float = 0.0
var sprint_efficiency_boost_multiplier: float = 1.0
var move_speed_boost_left: float = 0.0
var move_speed_boost_max: float = 0.0
var move_speed_boost_multiplier: float = 1.0
var dash_invulnerability_boost_left: float = 0.0
var dash_invulnerability_boost_max: float = 0.0
var dash_invulnerability_boost_bonus_seconds: float = 0.0
var dash_charge_recovery_boost_left: float = 0.0
var dash_charge_recovery_boost_max: float = 0.0
var dash_charge_recovery_boost_multiplier: float = 1.0
var dash_trail_spawn_left: float = 0.0
var sprinting_now: bool = false
var camera_orbit_yaw: float = 0.0
var camera_orbit_pitch: float = 0.0
var camera_follow_assist_lock_left: float = 0.0
var _last_emitted_sprinting: bool = false
var _last_emitted_sprint_exhausted: bool = false
var _body_visual_blend: float = 0.0
var _body_material: StandardMaterial3D = null
var _body_base_albedo: Color = Color(1.0, 1.0, 1.0, 1.0)

func _ready() -> void:
	add_to_group("player_3d")
	look_target = global_position
	respawn_position = global_position
	target_camera_distance = clamp(tuning.camera_distance, tuning.camera_min_distance, tuning.camera_max_distance)
	camera_orbit_yaw = 0.0
	camera_orbit_pitch = deg_to_rad(clamp(0.0, tuning.camera_orbit_pitch_min_degrees, tuning.camera_orbit_pitch_max_degrees))
	stamina = tuning.max_stamina
	dash_charges = max(1, tuning.dash_max_charges)
	air_jumps_left = max(0, tuning.max_air_jumps)
	camera.fov = tuning.camera_base_fov
	_ensure_body_material()
	_emit_stamina_changed()
	_emit_dash_charges_changed()
	_emit_dash_charge_recharge_changed()
	_emit_dash_cooldown_changed()
	_emit_dash_buffer_changed()
	_emit_air_jumps_changed()
	_emit_sprint_state_changed(true)
	_emit_landing_recovery_changed()
	_emit_stamina_regen_delay_changed()
	_emit_dash_invulnerability_changed()
	_emit_stamina_regen_boost_changed()
	_emit_sprint_efficiency_boost_changed()
	_emit_move_speed_boost_changed()
	_emit_dash_invulnerability_boost_changed()
	_emit_dash_charge_recovery_boost_changed()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_adjust_camera_orbit(event.relative)
	if event is InputEventMouseButton and event.pressed:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_adjust_camera_zoom(-tuning.camera_zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_adjust_camera_zoom(tuning.camera_zoom_step)
	if event.is_action_pressed(ACTION_CAMERA_RECENTER):
		_recenter_camera_orbit(1.0)

func _physics_process(delta: float) -> void:
	var was_on_floor := is_on_floor()
	if stamina_action_warning_cooldown_left > 0.0:
		stamina_action_warning_cooldown_left = max(0.0, stamina_action_warning_cooldown_left - delta)
	if camera_follow_assist_lock_left > 0.0:
		camera_follow_assist_lock_left = max(0.0, camera_follow_assist_lock_left - delta)

	if dash_invulnerability_left > 0.0:
		dash_invulnerability_left = max(0.0, dash_invulnerability_left - delta)
		_emit_dash_invulnerability_changed()
	if stamina_regen_boost_left > 0.0:
		stamina_regen_boost_left = max(0.0, stamina_regen_boost_left - delta)
		if stamina_regen_boost_left <= 0.0:
			stamina_regen_boost_multiplier = 1.0
			stamina_regen_boost_max = 0.0
		_emit_stamina_regen_boost_changed()
	if sprint_efficiency_boost_left > 0.0:
		sprint_efficiency_boost_left = max(0.0, sprint_efficiency_boost_left - delta)
		if sprint_efficiency_boost_left <= 0.0:
			sprint_efficiency_boost_multiplier = 1.0
			sprint_efficiency_boost_max = 0.0
		_emit_sprint_efficiency_boost_changed()
	if move_speed_boost_left > 0.0:
		move_speed_boost_left = max(0.0, move_speed_boost_left - delta)
		if move_speed_boost_left <= 0.0:
			move_speed_boost_multiplier = 1.0
			move_speed_boost_max = 0.0
		_emit_move_speed_boost_changed()
	if dash_invulnerability_boost_left > 0.0:
		dash_invulnerability_boost_left = max(0.0, dash_invulnerability_boost_left - delta)
		if dash_invulnerability_boost_left <= 0.0:
			dash_invulnerability_boost_bonus_seconds = 0.0
			dash_invulnerability_boost_max = 0.0
		_emit_dash_invulnerability_boost_changed()
	if dash_charge_recovery_boost_left > 0.0:
		dash_charge_recovery_boost_left = max(0.0, dash_charge_recovery_boost_left - delta)
		if dash_charge_recovery_boost_left <= 0.0:
			dash_charge_recovery_boost_multiplier = 1.0
			dash_charge_recovery_boost_max = 0.0
		_emit_dash_charge_recovery_boost_changed()
	_update_dash_invulnerability_visual(delta)

	_handle_fall_reset_if_needed()

	# Jump buffering gives more forgiving timing before landing.
	if _is_jump_just_pressed():
		var jump_buffer_window: float = max(0.0, tuning.jump_buffer_time)
		if dash_time_left > 0.0:
			jump_buffer_window += min(dash_time_left, max(0.0, tuning.jump_buffer_dash_bonus_time))
		jump_buffer_left = jump_buffer_window
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
	var jump_stamina_cost: float = max(0.0, tuning.jump_stamina_cost)
	if can_air_jump and not can_ground_jump:
		jump_stamina_cost *= max(1.0, tuning.air_jump_stamina_multiplier)
	if jump_buffer_left > 0.0 and (can_ground_jump or can_air_jump) and _try_spend_stamina(jump_stamina_cost, "Jump"):
		velocity.y = tuning.jump_velocity
		_apply_sprint_jump_momentum_boost()
		jump_buffer_left = 0.0
		if can_ground_jump:
			coyote_time_left = 0.0
		elif can_air_jump:
			_apply_air_jump_horizontal_boost()
			air_jumps_left -= 1
			_emit_air_jumps_changed()

	if landing_recovery_left > 0.0:
		landing_recovery_left = max(0.0, landing_recovery_left - delta)
		_emit_landing_recovery_changed()

	# Movement input
	var input_vec := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	var move_dir := _resolve_move_direction(input_vec)
	_update_recent_move_direction(move_dir, delta)
	if landing_recovery_left > 0.0:
		move_dir = Vector3.ZERO

	var dash_state_changed := false
	if dash_cooldown_left > 0.0:
		dash_cooldown_left = max(0.0, dash_cooldown_left - delta)
		dash_state_changed = true

	if dash_charge_recharge_left > 0.0:
		var recharge_speed_multiplier: float = dash_charge_recovery_boost_multiplier if dash_charge_recovery_boost_left > 0.0 else 1.0
		dash_charge_recharge_left = max(0.0, dash_charge_recharge_left - (delta * max(1.0, recharge_speed_multiplier)))
		dash_state_changed = true
		_emit_dash_charge_recharge_changed()
		if dash_charge_recharge_left <= 0.0 and dash_charges < max(1, tuning.dash_max_charges):
			dash_charges += 1
			_emit_dash_charges_changed()
			if dash_charges < max(1, tuning.dash_max_charges):
				dash_charge_recharge_left = max(0.01, tuning.dash_charge_recovery_time)
				dash_state_changed = true
			_emit_dash_charge_recharge_changed()

	if dash_buffer_left > 0.0:
		dash_buffer_left = max(0.0, dash_buffer_left - delta)
		_emit_dash_buffer_changed()

	if dash_state_changed:
		_emit_dash_cooldown_changed()

	var dash_stamina_cost := _current_dash_stamina_cost()
	if Input.is_action_just_pressed("dash"):
		if _can_dash_now() and _can_start_dash() and _try_spend_stamina(dash_stamina_cost, "Dash"):
			_start_dash(move_dir)
		else:
			var should_buffer_dash: bool = false
			if _can_dash_now() and _dash_ready_within(tuning.dash_input_buffer_time):
				should_buffer_dash = true
			elif _can_start_dash() and _dash_recovery_ready_within(tuning.hard_landing_dash_input_buffer_window):
				should_buffer_dash = true
			if should_buffer_dash:
				dash_buffer_left = max(dash_buffer_left, tuning.dash_input_buffer_time)
				buffered_dash_direction = move_dir
				_emit_dash_buffer_changed()

	if _can_dash_now() and dash_buffer_left > 0.0 and _can_start_dash() and _try_spend_stamina(dash_stamina_cost, "Dash"):
		_start_dash(buffered_dash_direction)
		dash_buffer_left = 0.0
		buffered_dash_direction = Vector3.ZERO
		_emit_dash_buffer_changed()

	if dash_time_left > 0.0:
		dash_time_left = max(0.0, dash_time_left - delta)
		dash_trail_spawn_left = max(0.0, dash_trail_spawn_left - delta)
		if tuning.dash_trail_enabled and dash_trail_spawn_left <= 0.0:
			_spawn_dash_trail()
			dash_trail_spawn_left = max(0.01, tuning.dash_trail_spawn_interval)
		_update_dash_direction(move_dir, delta)
		velocity.x = dash_direction.x * tuning.dash_speed
		velocity.z = dash_direction.z * tuning.dash_speed
		if sprinting_now:
			sprinting_now = false
			_emit_sprint_state_changed()
	else:
		dash_trail_spawn_left = 0.0
		var is_recovering := landing_recovery_left > 0.0
		var is_moving := move_dir.length() > 0.01
		var is_trying_to_sprint := Input.is_action_pressed("sprint") and is_moving and not is_recovering
		var is_sprinting := false
		var sprint_exhaust_threshold: float = max(0.0, tuning.sprint_exhaustion_threshold)
		var sprint_resume_threshold: float = max(sprint_exhaust_threshold, tuning.sprint_resume_threshold)
		if sprint_exhausted and stamina >= sprint_resume_threshold:
			sprint_exhausted = false
		var sprint_stamina_drain: float = tuning.sprint_stamina_per_second * delta
		if sprint_efficiency_boost_left > 0.0:
			sprint_stamina_drain /= max(1.0, sprint_efficiency_boost_multiplier)
		if is_trying_to_sprint and not sprint_exhausted and _can_pay_stamina(sprint_stamina_drain):
			is_sprinting = true
			_use_stamina(sprint_stamina_drain)
			if stamina <= sprint_exhaust_threshold:
				sprint_exhausted = true
		else:
			_regen_stamina(delta, is_moving and not is_recovering)

		sprinting_now = is_sprinting
		_emit_sprint_state_changed()

		var ramp_up: float = max(0.01, tuning.sprint_ramp_up_per_second)
		var ramp_down: float = max(0.01, tuning.sprint_ramp_down_per_second)
		if is_sprinting:
			sprint_blend = min(1.0, sprint_blend + ramp_up * delta)
		else:
			sprint_blend = max(0.0, sprint_blend - ramp_down * delta)

		var sprint_multiplier := lerpf(1.0, tuning.sprint_multiplier, sprint_blend)
		var stamina_ratio: float = 1.0
		if tuning.max_stamina > 0.01:
			stamina_ratio = clamp(stamina / tuning.max_stamina, 0.0, 1.0)
		var low_stamina_threshold: float = clamp(tuning.low_stamina_movement_threshold_ratio, 0.0, 1.0)
		var low_stamina_min_multiplier: float = clamp(tuning.low_stamina_movement_min_multiplier, 0.1, 1.0)
		var low_stamina_move_multiplier: float = 1.0
		if low_stamina_threshold > 0.0 and stamina_ratio < low_stamina_threshold and not is_sprinting:
			var fatigue_t: float = (low_stamina_threshold - stamina_ratio) / low_stamina_threshold
			low_stamina_move_multiplier = lerpf(1.0, low_stamina_min_multiplier, clamp(fatigue_t, 0.0, 1.0))
		var move_speed_multiplier: float = move_speed_boost_multiplier if move_speed_boost_left > 0.0 else 1.0
		var speed := tuning.move_speed * sprint_multiplier * low_stamina_move_multiplier * move_speed_multiplier
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
	_handle_dash_wall_collision()

	if not was_on_floor and is_on_floor() and pre_move_vertical_velocity <= -absf(tuning.hard_landing_speed_threshold):
		var landing_speed: float = absf(pre_move_vertical_velocity)
		var threshold_speed: float = absf(tuning.hard_landing_speed_threshold)
		var max_penalty_speed: float = max(threshold_speed + 0.01, absf(tuning.hard_landing_max_penalty_speed))
		var landing_impact_t: float = clamp((landing_speed - threshold_speed) / (max_penalty_speed - threshold_speed), 0.0, 1.0)
		var min_penalty_multiplier: float = clamp(tuning.hard_landing_min_penalty_multiplier, 0.1, 1.0)
		var landing_penalty_multiplier: float = lerpf(min_penalty_multiplier, 1.0, landing_impact_t)
		landing_recovery_left = max(
			landing_recovery_left,
			max(0.0, tuning.hard_landing_recovery_time) * landing_penalty_multiplier
		)
		_use_stamina(max(0.0, tuning.hard_landing_stamina_cost) * landing_penalty_multiplier)
		_add_camera_impulse(Vector3(0.0, -1.0, 0.0), tuning.camera_landing_impulse_strength * landing_penalty_multiplier)
		_emit_landing_recovery_changed()

	# Face movement direction with data-driven turn speed smoothing.
	var horizontal_vel := Vector3(velocity.x, 0.0, velocity.z)
	if horizontal_vel.length() > tuning.min_turn_speed_threshold:
		look_target = global_position + horizontal_vel.normalized()
		var desired_yaw := atan2(-horizontal_vel.x, -horizontal_vel.z)
		var turn_speed_multiplier: float = tuning.sprint_turn_speed_multiplier if sprinting_now else 1.0
		rotation.y = lerp_angle(
			rotation.y,
			desired_yaw,
			deg_to_rad(tuning.turn_speed_degrees_per_second * max(0.01, turn_speed_multiplier)) * delta
		)

	# Follow camera smoothly with scroll-wheel zoom and movement-aware look-ahead.
	if Input.is_action_pressed(ACTION_CAMERA_RECENTER):
		_recenter_camera_orbit(delta)
	else:
		_update_camera_follow_assist(horizontal_vel.length(), delta)
	_update_camera_impulse(delta)
	var target_cam_pos := _resolve_camera_pivot_target()
	var camera_follow_smooth: float = tuning.camera_smooth
	if tuning.camera_collision_enabled:
		camera_follow_smooth = max(camera_follow_smooth, tuning.camera_collision_smooth)
	pivot.global_position = pivot.global_position.lerp(target_cam_pos, delta * camera_follow_smooth)
	_update_camera_look_ahead(delta)
	camera.look_at(global_position + Vector3(0, 1.0, 0) + camera_look_ahead, Vector3.UP)
	_update_camera_fov(delta)

func _resolve_move_direction(input_vec: Vector2) -> Vector3:
	if input_vec.length() > 1.0:
		input_vec = input_vec.normalized()
	var deadzone: float = clamp(tuning.movement_input_deadzone, 0.0, 0.95)
	var input_strength: float = input_vec.length()
	if input_strength <= deadzone:
		return Vector3.ZERO
	if input_strength > 0.001:
		var remapped_strength: float = clamp((input_strength - deadzone) / max(0.001, 1.0 - deadzone), 0.0, 1.0)
		input_vec = input_vec.normalized() * remapped_strength
	if not tuning.movement_relative_to_camera or not is_instance_valid(camera):
		return Vector3(input_vec.x, 0.0, -input_vec.y)

	var camera_forward := -camera.global_transform.basis.z
	camera_forward.y = 0.0
	if camera_forward.length() <= 0.001:
		camera_forward = Vector3.FORWARD
	camera_forward = camera_forward.normalized()

	var camera_right := camera.global_transform.basis.x
	camera_right.y = 0.0
	if camera_right.length() <= 0.001:
		camera_right = Vector3.RIGHT
	camera_right = camera_right.normalized()

	var direction := (camera_right * input_vec.x) - (camera_forward * input_vec.y)
	if direction.length() > 1.0:
		direction = direction.normalized()
	return direction

func _update_recent_move_direction(move_dir: Vector3, delta: float) -> void:
	recent_move_direction_left = max(0.0, recent_move_direction_left - delta)
	if move_dir.length() <= 0.01:
		return
	recent_move_direction = move_dir.normalized()
	recent_move_direction.y = 0.0
	recent_move_direction_left = max(0.0, tuning.dash_recent_input_memory_time)

func _resolve_dash_start_direction(move_dir: Vector3) -> Vector3:
	if move_dir.length() > 0.01:
		return move_dir.normalized()
	if tuning.dash_use_recent_input_direction and recent_move_direction_left > 0.0 and recent_move_direction.length() > 0.01:
		return recent_move_direction.normalized()
	return _resolve_neutral_dash_direction()

func _resolve_neutral_dash_direction() -> Vector3:
	if tuning.dash_neutral_uses_camera_forward and is_instance_valid(camera):
		var camera_forward: Vector3 = -camera.global_transform.basis.z
		camera_forward.y = 0.0
		if camera_forward.length() > 0.01:
			return camera_forward.normalized()
	var facing_forward: Vector3 = -global_transform.basis.z
	facing_forward.y = 0.0
	if facing_forward.length() > 0.01:
		return facing_forward.normalized()
	return Vector3.ZERO

func _is_jump_just_pressed() -> bool:
	if InputMap.has_action(ACTION_JUMP):
		return Input.is_action_just_pressed(ACTION_JUMP)
	return Input.is_action_just_pressed("ui_accept")

func _is_jump_pressed() -> bool:
	if InputMap.has_action(ACTION_JUMP):
		return Input.is_action_pressed(ACTION_JUMP)
	return Input.is_action_pressed("ui_accept")

func _apply_sprint_jump_momentum_boost() -> void:
	if not Input.is_action_pressed("sprint"):
		return
	var boost_multiplier: float = max(1.0, tuning.sprint_jump_momentum_multiplier)
	if boost_multiplier <= 1.0:
		return
	var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
	var horizontal_speed := horizontal_velocity.length()
	if horizontal_speed <= 0.01:
		return
	var speed_cap: float = tuning.move_speed * max(1.0, tuning.sprint_multiplier) * max(1.0, tuning.sprint_jump_speed_cap_multiplier)
	var boosted_speed: float = min(horizontal_speed * boost_multiplier, speed_cap)
	var boosted_velocity: Vector3 = horizontal_velocity.normalized() * boosted_speed
	velocity.x = boosted_velocity.x
	velocity.z = boosted_velocity.z

func _apply_air_jump_horizontal_boost() -> void:
	var boost: float = max(0.0, tuning.air_jump_horizontal_boost)
	if boost <= 0.0:
		return
	var boost_direction: Vector3 = _resolve_air_jump_boost_direction()
	if boost_direction.length() <= 0.01:
		return
	var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
	var speed_cap: float = max(tuning.move_speed, tuning.air_jump_horizontal_speed_cap)
	var boosted_velocity: Vector3 = horizontal_velocity + boost_direction * boost
	if boosted_velocity.length() > speed_cap:
		boosted_velocity = boosted_velocity.normalized() * speed_cap
	velocity.x = boosted_velocity.x
	velocity.z = boosted_velocity.z

func _resolve_air_jump_boost_direction() -> Vector3:
	if recent_move_direction_left > 0.0 and recent_move_direction.length() > 0.01:
		return recent_move_direction.normalized()
	var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
	if horizontal_velocity.length() > 0.01:
		return horizontal_velocity.normalized()
	var forward := -global_transform.basis.z
	forward.y = 0.0
	if forward.length() <= 0.01:
		return Vector3.ZERO
	return forward.normalized()

func _start_dash(move_dir: Vector3) -> void:
	if landing_recovery_left > 0.0:
		landing_recovery_left = 0.0
		_emit_landing_recovery_changed()
	dash_direction = _resolve_dash_start_direction(move_dir)
	if dash_direction.length() <= 0.01:
		dash_direction = _resolve_neutral_dash_direction()
	if dash_direction.length() <= 0.01:
		dash_direction = Vector3.FORWARD
	dash_direction.y = 0.0
	dash_direction = dash_direction.normalized()
	dash_time_left = tuning.dash_duration
	dash_trail_spawn_left = 0.0
	dash_cooldown_left = tuning.dash_cooldown
	var dash_invulnerability_duration: float = max(0.0, tuning.dash_invulnerability_duration)
	if dash_invulnerability_boost_left > 0.0:
		dash_invulnerability_duration += max(0.0, dash_invulnerability_boost_bonus_seconds)
	dash_invulnerability_left = max(dash_invulnerability_left, dash_invulnerability_duration)
	_emit_dash_invulnerability_changed()
	dash_charges = max(0, dash_charges - 1)
	if dash_charges < max(1, tuning.dash_max_charges) and dash_charge_recharge_left <= 0.0:
		dash_charge_recharge_left = max(0.01, tuning.dash_charge_recovery_time)
	dash_buffer_left = 0.0
	buffered_dash_direction = Vector3.ZERO
	var dash_impulse_direction := Vector3(-dash_direction.x, tuning.camera_dash_impulse_vertical, -dash_direction.z)
	_add_camera_impulse(dash_impulse_direction, tuning.camera_dash_impulse_strength)
	_emit_dash_charges_changed()
	_emit_dash_charge_recharge_changed()
	_emit_dash_cooldown_changed()
	_emit_dash_buffer_changed()

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

func _spawn_dash_trail() -> void:
	if not tuning.dash_trail_enabled:
		return
	if not is_instance_valid(body_mesh) or body_mesh.mesh == null:
		return
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return
	var trail := MeshInstance3D.new()
	trail.mesh = body_mesh.mesh
	trail.global_transform = body_mesh.global_transform
	trail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var trail_material := StandardMaterial3D.new()
	trail_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	trail_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var trail_color: Color = tuning.dash_trail_color
	trail_color.a = clamp(tuning.dash_trail_start_alpha, 0.0, 1.0)
	trail_material.albedo_color = trail_color
	trail_material.emission_enabled = true
	trail_material.emission = tuning.dash_trail_color
	trail_material.emission_energy_multiplier = max(0.0, tuning.dash_trail_emission_energy)
	trail.material_override = trail_material
	current_scene.add_child(trail)
	var tween := create_tween()
	tween.tween_property(trail_material, "albedo_color:a", clamp(tuning.dash_trail_end_alpha, 0.0, 1.0), max(0.01, tuning.dash_trail_lifetime))
	tween.tween_callback(trail.queue_free)

func _handle_dash_wall_collision() -> void:
	if dash_time_left <= 0.0 or not tuning.dash_cancel_on_wall_collision:
		return
	var threshold: float = clamp(tuning.dash_wall_collision_dot_threshold, 0.0, 1.0)
	var dash_heading: Vector3 = Vector3(dash_direction.x, 0.0, dash_direction.z)
	if dash_heading.length() <= 0.01:
		return
	dash_heading = dash_heading.normalized()
	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision3D = get_slide_collision(i)
		if collision == null:
			continue
		var wall_normal: Vector3 = collision.get_normal()
		wall_normal.y = 0.0
		if wall_normal.length() <= 0.01:
			continue
		wall_normal = wall_normal.normalized()
		var impact_alignment: float = dash_heading.dot(-wall_normal)
		if impact_alignment < threshold:
			continue
		dash_time_left = 0.0
		velocity.x = 0.0
		velocity.z = 0.0
		dash_trail_spawn_left = 0.0
		break

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

func _update_camera_impulse(delta: float) -> void:
	var decay: float = max(0.01, tuning.camera_impulse_decay_per_second)
	camera_impulse_offset = camera_impulse_offset.move_toward(Vector3.ZERO, decay * delta)

func _resolve_camera_pivot_target() -> Vector3:
	var orbit_distance: float = max(0.0, target_camera_distance)
	var orbit_offset := Vector3(0.0, 0.0, orbit_distance)
	if tuning.camera_orbit_enabled:
		var orbit_basis := Basis(Vector3.UP, camera_orbit_yaw)
		orbit_offset = orbit_basis * orbit_offset
		if absf(camera_orbit_pitch) > 0.0001:
			var horizontal_distance: float = orbit_distance * cos(camera_orbit_pitch)
			orbit_offset = orbit_offset.normalized() * horizontal_distance
			orbit_offset.y = sin(camera_orbit_pitch) * orbit_distance
	var desired_pivot_position := global_position + Vector3(0.0, tuning.camera_height, 0.0) + orbit_offset + camera_impulse_offset
	if not tuning.camera_collision_enabled:
		return desired_pivot_position

	var focus_point := global_position + Vector3(0.0, 1.0, 0.0)
	var ray_query := PhysicsRayQueryParameters3D.create(focus_point, desired_pivot_position)
	ray_query.exclude = [self]
	ray_query.collide_with_areas = false
	ray_query.collide_with_bodies = true
	ray_query.collision_mask = max(1, tuning.camera_collision_mask)
	var hit := get_world_3d().direct_space_state.intersect_ray(ray_query)
	if hit.is_empty():
		return desired_pivot_position

	var hit_position: Vector3 = hit.position
	var hit_normal: Vector3 = hit.normal
	if hit_normal.length() <= 0.001:
		hit_normal = (focus_point - desired_pivot_position).normalized()
	var safe_padding: float = max(0.0, tuning.camera_collision_padding)
	return hit_position + (hit_normal.normalized() * safe_padding)

func _add_camera_impulse(direction: Vector3, strength: float) -> void:
	if strength <= 0.0:
		return
	var impulse_direction := direction
	if impulse_direction.length() <= 0.001:
		return
	impulse_direction = impulse_direction.normalized()
	camera_impulse_offset += impulse_direction * strength
	var max_offset: float = max(0.0, tuning.camera_impulse_max_offset)
	if camera_impulse_offset.length() > max_offset and max_offset > 0.0:
		camera_impulse_offset = camera_impulse_offset.normalized() * max_offset

func _update_camera_follow_assist(horizontal_speed: float, delta: float) -> void:
	if not tuning.camera_follow_assist_enabled:
		return
	if camera_follow_assist_lock_left > 0.0:
		return
	var min_speed: float = max(0.0, tuning.camera_follow_assist_min_move_speed)
	if horizontal_speed < min_speed:
		return
	var assist_speed_degrees: float = max(0.0, tuning.camera_follow_assist_speed_degrees_per_second)
	if dash_time_left > 0.0:
		assist_speed_degrees *= max(0.5, tuning.camera_follow_assist_dash_multiplier)
	var assist_speed_rad: float = deg_to_rad(assist_speed_degrees)
	if assist_speed_rad <= 0.0:
		return
	var yaw_difference: float = wrapf(rotation.y - camera_orbit_yaw, -PI, PI)
	var yaw_step: float = assist_speed_rad * max(0.0, delta)
	camera_orbit_yaw += clamp(yaw_difference, -yaw_step, yaw_step)

func _adjust_camera_orbit(relative_motion: Vector2) -> void:
	if not tuning.camera_orbit_enabled:
		return
	var sensitivity: float = max(0.0, tuning.camera_orbit_sensitivity)
	if sensitivity <= 0.0:
		return
	camera_follow_assist_lock_left = max(camera_follow_assist_lock_left, max(0.0, tuning.camera_follow_assist_input_lock_time))
	camera_orbit_yaw -= relative_motion.x * sensitivity * 0.01
	var pitch_input: float = -relative_motion.y
	if tuning.camera_orbit_invert_y:
		pitch_input = -pitch_input
	camera_orbit_pitch += pitch_input * sensitivity * 0.01
	var min_pitch_rad: float = deg_to_rad(min(tuning.camera_orbit_pitch_min_degrees, tuning.camera_orbit_pitch_max_degrees))
	var max_pitch_rad: float = deg_to_rad(max(tuning.camera_orbit_pitch_min_degrees, tuning.camera_orbit_pitch_max_degrees))
	camera_orbit_pitch = clamp(camera_orbit_pitch, min_pitch_rad, max_pitch_rad)

func _recenter_camera_orbit(delta: float) -> void:
	if not tuning.camera_orbit_enabled or not tuning.camera_recenter_enabled:
		return
	var desired_yaw: float = rotation.y
	var difference: float = wrapf(desired_yaw - camera_orbit_yaw, -PI, PI)
	var snap_threshold: float = deg_to_rad(max(0.0, tuning.camera_recenter_snap_angle_degrees))
	if absf(difference) <= snap_threshold:
		camera_orbit_yaw = desired_yaw
		return
	var recenter_step: float = deg_to_rad(max(0.0, tuning.camera_recenter_speed_degrees_per_second)) * max(0.0, delta)
	if recenter_step <= 0.0:
		return
	camera_orbit_yaw += clamp(difference, -recenter_step, recenter_step)

func _adjust_camera_zoom(amount: float) -> void:
	target_camera_distance = clamp(
		target_camera_distance + amount,
		tuning.camera_min_distance,
		tuning.camera_max_distance
	)

func _handle_fall_reset_if_needed() -> void:
	if global_position.y >= tuning.fall_reset_height:
		return
	global_position = respawn_position
	velocity = Vector3.ZERO
	dash_time_left = 0.0
	dash_cooldown_left = max(dash_cooldown_left, tuning.dash_cooldown * 0.25)
	dash_buffer_left = 0.0
	buffered_dash_direction = Vector3.ZERO
	landing_recovery_left = max(landing_recovery_left, max(0.0, tuning.fall_reset_recovery_time))
	_use_stamina(max(0.0, tuning.fall_reset_stamina_cost))
	_emit_dash_cooldown_changed()
	_emit_dash_buffer_changed()
	_emit_landing_recovery_changed()

func _can_dash_now() -> bool:
	if landing_recovery_left <= 0.0:
		return true
	var cancel_window: float = max(0.0, tuning.hard_landing_dash_cancel_window)
	if cancel_window <= 0.0:
		return false
	return landing_recovery_left <= cancel_window

func _can_start_dash() -> bool:
	if dash_time_left > 0.0 or dash_charges <= 0:
		return false
	if tuning.dash_allow_charge_bypass_cooldown:
		return true
	return dash_cooldown_left <= 0.0

func _dash_ready_within(window: float) -> bool:
	if window <= 0.0:
		return false
	var remaining := _next_dash_ready_remaining()
	return remaining > 0.0 and remaining <= window

func _dash_recovery_ready_within(window: float) -> bool:
	if window <= 0.0:
		return false
	return landing_recovery_left > 0.0 and landing_recovery_left <= window

func _next_dash_ready_remaining() -> float:
	if dash_charges > 0:
		if tuning.dash_allow_charge_bypass_cooldown:
			return 0.0
		return dash_cooldown_left
	return max(dash_cooldown_left, dash_charge_recharge_left)

func _next_dash_ready_max() -> float:
	if dash_charges > 0:
		if tuning.dash_allow_charge_bypass_cooldown:
			return max(0.01, tuning.dash_charge_recovery_time)
		return max(0.01, tuning.dash_cooldown)
	return max(0.01, max(tuning.dash_cooldown, tuning.dash_charge_recovery_time))

func _current_dash_stamina_cost() -> float:
	var base_cost: float = max(0.0, tuning.dash_stamina_cost)
	if is_on_floor():
		return base_cost
	return base_cost * max(1.0, tuning.dash_airborne_stamina_multiplier)

func _try_spend_stamina(cost: float, reason: String) -> bool:
	var clamped_cost: float = max(0.0, cost)
	if _can_pay_stamina(clamped_cost):
		_use_stamina(clamped_cost)
		return true
	_report_stamina_action_failed(reason)
	return false

func _can_pay_stamina(cost: float) -> bool:
	return stamina >= max(0.0, cost)

func _use_stamina(cost: float) -> void:
	if cost <= 0.0:
		return
	stamina = max(0.0, stamina - cost)
	stamina_regen_delay_left = tuning.stamina_regen_delay
	_emit_stamina_changed()
	_emit_stamina_regen_delay_changed()

func _regen_stamina(delta: float, is_moving: bool) -> void:
	if stamina_regen_delay_left > 0.0:
		var previous_delay := stamina_regen_delay_left
		stamina_regen_delay_left = max(0.0, stamina_regen_delay_left - delta)
		if absf(previous_delay - stamina_regen_delay_left) > 0.0001:
			_emit_stamina_regen_delay_changed()
		return
	if stamina >= tuning.max_stamina:
		return
	var regen_rate := tuning.stamina_regen_idle_per_second
	if not is_on_floor():
		regen_rate = tuning.stamina_regen_airborne_per_second
	elif is_moving:
		regen_rate = tuning.stamina_regen_moving_per_second
	if stamina_regen_boost_left > 0.0:
		regen_rate *= max(1.0, stamina_regen_boost_multiplier)
	stamina = min(tuning.max_stamina, stamina + regen_rate * delta)
	_emit_stamina_changed()

func _ensure_body_material() -> void:
	if not is_instance_valid(body_mesh) or body_mesh.mesh == null:
		return
	var source_material: Material = body_mesh.get_active_material(0)
	if source_material is StandardMaterial3D:
		_body_material = (source_material as StandardMaterial3D).duplicate()
	else:
		_body_material = StandardMaterial3D.new()
		_body_material.albedo_color = Color(0.8, 0.8, 0.9, 1.0)
	_body_material.resource_local_to_scene = true
	_body_material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	body_mesh.material_override = _body_material
	_body_base_albedo = _body_material.albedo_color

func _update_dash_invulnerability_visual(delta: float) -> void:
	if not tuning.dash_invulnerability_flash_enabled:
		_reset_dash_invulnerability_visual(delta)
		return
	if _body_material == null:
		_ensure_body_material()
		if _body_material == null:
			return
	var max_duration: float = max(0.001, tuning.dash_invulnerability_duration)
	var active_ratio: float = clamp(dash_invulnerability_left / max_duration, 0.0, 1.0)
	var target_blend: float = active_ratio
	var blend_speed: float = max(0.01, tuning.dash_invulnerability_flash_blend_speed)
	_body_visual_blend = move_toward(_body_visual_blend, target_blend, blend_speed * delta)
	if _body_visual_blend <= 0.001:
		_reset_dash_invulnerability_visual(delta)
		return
	var pulse := 0.5 + (0.5 * sin(Time.get_ticks_msec() * 0.001 * max(0.01, tuning.dash_invulnerability_flash_pulse_speed)))
	var flash_weight: float = clamp(_body_visual_blend * pulse, 0.0, 1.0)
	var flash_color: Color = _body_base_albedo.lerp(tuning.dash_invulnerability_flash_color, flash_weight)
	_body_material.albedo_color = flash_color
	_body_material.emission_enabled = true
	_body_material.emission = tuning.dash_invulnerability_flash_color
	_body_material.emission_energy_multiplier = tuning.dash_invulnerability_flash_emission_energy * flash_weight

func _reset_dash_invulnerability_visual(delta: float) -> void:
	if _body_material == null:
		return
	if _body_visual_blend > 0.0:
		var blend_speed: float = max(0.01, tuning.dash_invulnerability_flash_blend_speed)
		_body_visual_blend = max(0.0, _body_visual_blend - blend_speed * delta)
	_body_material.albedo_color = _body_base_albedo
	_body_material.emission_enabled = false
	_body_material.emission_energy_multiplier = 0.0

func _emit_stamina_changed() -> void:
	stamina_changed.emit(stamina, tuning.max_stamina)

func restore_stamina(amount: float) -> float:
	var clamped_amount: float = max(0.0, amount)
	if clamped_amount <= 0.0:
		return 0.0
	var previous_stamina: float = stamina
	stamina = min(tuning.max_stamina, stamina + clamped_amount)
	if stamina > previous_stamina:
		_emit_stamina_changed()
		return stamina - previous_stamina
	return 0.0

func apply_stamina_regen_boost(duration: float, multiplier: float) -> float:
	var clamped_duration: float = max(0.0, duration)
	var clamped_multiplier: float = max(1.0, multiplier)
	if clamped_duration <= 0.0 or clamped_multiplier <= 1.0:
		return 0.0
	var previous_remaining: float = stamina_regen_boost_left
	stamina_regen_boost_left = max(stamina_regen_boost_left, clamped_duration)
	stamina_regen_boost_max = max(stamina_regen_boost_max, stamina_regen_boost_left)
	stamina_regen_boost_multiplier = max(stamina_regen_boost_multiplier, clamped_multiplier)
	_emit_stamina_regen_boost_changed()
	return max(0.0, stamina_regen_boost_left - previous_remaining)

func apply_sprint_efficiency_boost(duration: float, multiplier: float) -> float:
	var clamped_duration: float = max(0.0, duration)
	var clamped_multiplier: float = max(1.0, multiplier)
	if clamped_duration <= 0.0 or clamped_multiplier <= 1.0:
		return 0.0
	var previous_remaining: float = sprint_efficiency_boost_left
	sprint_efficiency_boost_left = max(sprint_efficiency_boost_left, clamped_duration)
	sprint_efficiency_boost_max = max(sprint_efficiency_boost_max, sprint_efficiency_boost_left)
	sprint_efficiency_boost_multiplier = max(sprint_efficiency_boost_multiplier, clamped_multiplier)
	_emit_sprint_efficiency_boost_changed()
	return max(0.0, sprint_efficiency_boost_left - previous_remaining)

func apply_move_speed_boost(duration: float, multiplier: float) -> float:
	var clamped_duration: float = max(0.0, duration)
	var clamped_multiplier: float = max(1.0, multiplier)
	if clamped_duration <= 0.0 or clamped_multiplier <= 1.0:
		return 0.0
	var previous_remaining: float = move_speed_boost_left
	move_speed_boost_left = max(move_speed_boost_left, clamped_duration)
	move_speed_boost_max = max(move_speed_boost_max, move_speed_boost_left)
	move_speed_boost_multiplier = max(move_speed_boost_multiplier, clamped_multiplier)
	_emit_move_speed_boost_changed()
	return max(0.0, move_speed_boost_left - previous_remaining)

func apply_dash_invulnerability_boost(duration: float, bonus_seconds: float) -> float:
	var clamped_duration: float = max(0.0, duration)
	var clamped_bonus_seconds: float = max(0.0, bonus_seconds)
	if clamped_duration <= 0.0 or clamped_bonus_seconds <= 0.0:
		return 0.0
	var previous_remaining: float = dash_invulnerability_boost_left
	dash_invulnerability_boost_left = max(dash_invulnerability_boost_left, clamped_duration)
	dash_invulnerability_boost_max = max(dash_invulnerability_boost_max, dash_invulnerability_boost_left)
	dash_invulnerability_boost_bonus_seconds = max(dash_invulnerability_boost_bonus_seconds, clamped_bonus_seconds)
	_emit_dash_invulnerability_boost_changed()
	return max(0.0, dash_invulnerability_boost_left - previous_remaining)

func apply_dash_charge_recovery_boost(duration: float, multiplier: float) -> float:
	var clamped_duration: float = max(0.0, duration)
	var clamped_multiplier: float = max(1.0, multiplier)
	if clamped_duration <= 0.0 or clamped_multiplier <= 1.0:
		return 0.0
	var previous_remaining: float = dash_charge_recovery_boost_left
	dash_charge_recovery_boost_left = max(dash_charge_recovery_boost_left, clamped_duration)
	dash_charge_recovery_boost_max = max(dash_charge_recovery_boost_max, dash_charge_recovery_boost_left)
	dash_charge_recovery_boost_multiplier = max(dash_charge_recovery_boost_multiplier, clamped_multiplier)
	_emit_dash_charge_recovery_boost_changed()
	return max(0.0, dash_charge_recovery_boost_left - previous_remaining)

func restore_dash_charges(count: int) -> int:
	var grant_count: int = max(0, count)
	if grant_count <= 0:
		return 0
	var max_dash_charges: int = max(1, tuning.dash_max_charges)
	if dash_charges >= max_dash_charges:
		return 0
	var previous_charges: int = dash_charges
	dash_charges = min(max_dash_charges, dash_charges + grant_count)
	if dash_charges >= max_dash_charges:
		dash_charge_recharge_left = 0.0
	else:
		if dash_charge_recharge_left <= 0.0:
			dash_charge_recharge_left = max(0.01, tuning.dash_charge_recovery_time)
		else:
			dash_charge_recharge_left = min(dash_charge_recharge_left, max(0.01, tuning.dash_charge_recovery_time))
	_emit_dash_charges_changed()
	_emit_dash_charge_recharge_changed()
	_emit_dash_cooldown_changed()
	return dash_charges - previous_charges

func restore_air_jumps(count: int) -> int:
	var grant_count: int = max(0, count)
	if grant_count <= 0:
		return 0
	var max_air_jumps: int = max(0, tuning.max_air_jumps)
	if max_air_jumps <= 0:
		return 0
	var previous_air_jumps: int = air_jumps_left
	air_jumps_left = min(max_air_jumps, air_jumps_left + grant_count)
	var restored: int = air_jumps_left - previous_air_jumps
	if restored > 0:
		_emit_air_jumps_changed()
	return restored

func refund_dash_recovery(seconds: float) -> float:
	var reduction: float = max(0.0, seconds)
	if reduction <= 0.0:
		return 0.0
	var applied: float = 0.0
	if dash_cooldown_left > 0.0:
		var cooldown_reduction: float = min(dash_cooldown_left, reduction)
		dash_cooldown_left -= cooldown_reduction
		applied += cooldown_reduction
	if dash_charge_recharge_left > 0.0:
		var charge_reduction: float = min(dash_charge_recharge_left, reduction)
		dash_charge_recharge_left -= charge_reduction
		applied += charge_reduction
	if applied > 0.0:
		_emit_dash_cooldown_changed()
		_emit_dash_charge_recharge_changed()
	return applied

func _report_stamina_action_failed(reason: String) -> void:
	if stamina_action_warning_cooldown_left > 0.0:
		return
	stamina_action_warning_cooldown_left = max(0.0, tuning.low_stamina_action_warning_cooldown)
	stamina_action_failed.emit(reason, max(0.0, tuning.low_stamina_action_warning_time))

func _emit_dash_charges_changed() -> void:
	dash_charges_changed.emit(dash_charges, max(1, tuning.dash_max_charges))

func _dash_charge_recharge_max() -> float:
	return max(0.01, tuning.dash_charge_recovery_time)

func _emit_dash_charge_recharge_changed() -> void:
	dash_charge_recharge_changed.emit(dash_charge_recharge_left, _dash_charge_recharge_max())

func _emit_dash_cooldown_changed() -> void:
	dash_cooldown_changed.emit(_next_dash_ready_remaining(), _next_dash_ready_max())

func _emit_dash_buffer_changed() -> void:
	dash_buffer_changed.emit(dash_buffer_left, max(0.01, tuning.dash_input_buffer_time))

func _emit_air_jumps_changed() -> void:
	air_jumps_changed.emit(air_jumps_left, max(0, tuning.max_air_jumps))

func _emit_sprint_state_changed(force: bool = false) -> void:
	if not force and sprinting_now == _last_emitted_sprinting and sprint_exhausted == _last_emitted_sprint_exhausted:
		return
	_last_emitted_sprinting = sprinting_now
	_last_emitted_sprint_exhausted = sprint_exhausted
	sprint_state_changed.emit(sprinting_now, sprint_exhausted)

func _landing_recovery_max() -> float:
	return max(0.01, tuning.hard_landing_recovery_time)

func _stamina_regen_delay_max() -> float:
	return max(0.01, tuning.stamina_regen_delay)

func _emit_stamina_regen_delay_changed() -> void:
	stamina_regen_delay_changed.emit(stamina_regen_delay_left, _stamina_regen_delay_max())

func _emit_landing_recovery_changed() -> void:
	landing_recovery_changed.emit(landing_recovery_left, _landing_recovery_max())

func _dash_invulnerability_max() -> float:
	return max(0.01, tuning.dash_invulnerability_duration)

func has_dash_invulnerability() -> bool:
	return dash_invulnerability_left > 0.0

func _emit_dash_invulnerability_changed() -> void:
	dash_invulnerability_changed.emit(dash_invulnerability_left, _dash_invulnerability_max())

func _emit_stamina_regen_boost_changed() -> void:
	stamina_regen_boost_changed.emit(stamina_regen_boost_left, max(0.01, stamina_regen_boost_max), max(1.0, stamina_regen_boost_multiplier))

func _emit_sprint_efficiency_boost_changed() -> void:
	sprint_efficiency_boost_changed.emit(sprint_efficiency_boost_left, max(0.01, sprint_efficiency_boost_max), max(1.0, sprint_efficiency_boost_multiplier))

func _emit_move_speed_boost_changed() -> void:
	move_speed_boost_changed.emit(move_speed_boost_left, max(0.01, move_speed_boost_max), max(1.0, move_speed_boost_multiplier))

func _emit_dash_invulnerability_boost_changed() -> void:
	dash_invulnerability_boost_changed.emit(dash_invulnerability_boost_left, max(0.01, dash_invulnerability_boost_max), max(0.0, dash_invulnerability_boost_bonus_seconds))

func _emit_dash_charge_recovery_boost_changed() -> void:
	dash_charge_recovery_boost_changed.emit(dash_charge_recovery_boost_left, max(0.01, dash_charge_recovery_boost_max), max(1.0, dash_charge_recovery_boost_multiplier))
