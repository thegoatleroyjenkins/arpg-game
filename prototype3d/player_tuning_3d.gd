extends Resource
class_name PlayerTuning3D

@export var move_speed: float = 6.5
@export var sprint_multiplier: float = 1.6
@export var jump_velocity: float = 4.5
@export var gravity: float = 12.0
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12
@export var max_air_jumps: int = 1
@export var jump_release_gravity_multiplier: float = 2.2
@export var jump_apex_gravity_multiplier: float = 0.7
@export var jump_apex_vertical_speed_threshold: float = 1.0
@export var max_fall_speed: float = 18.0
@export var sprint_jump_momentum_multiplier: float = 1.12
@export var sprint_jump_speed_cap_multiplier: float = 1.2

@export_group("Movement Feel")
@export var ground_acceleration: float = 40.0
@export var ground_deceleration: float = 48.0
@export_range(0.0, 1.0, 0.01) var air_control: float = 0.5

@export_group("Sprint Feel")
@export var sprint_ramp_up_per_second: float = 8.0
@export var sprint_ramp_down_per_second: float = 10.0
@export var sprint_exhaustion_threshold: float = 5.0
@export var sprint_resume_threshold: float = 18.0

@export_group("Facing")
@export var turn_speed_degrees_per_second: float = 720.0
@export var min_turn_speed_threshold: float = 0.1

@export_group("Landing Feel")
@export var hard_landing_speed_threshold: float = 12.0
@export var hard_landing_max_penalty_speed: float = 24.0
@export_range(0.1, 1.0, 0.01) var hard_landing_min_penalty_multiplier: float = 0.35
@export var hard_landing_recovery_time: float = 0.18
@export var hard_landing_stamina_cost: float = 14.0
@export var hard_landing_dash_cancel_window: float = 0.07

@export_group("Stamina")
@export var max_stamina: float = 100.0
@export var sprint_stamina_per_second: float = 28.0
@export var dash_stamina_cost: float = 35.0
@export_range(1.0, 3.0, 0.01) var dash_airborne_stamina_multiplier: float = 1.2
@export var jump_stamina_cost: float = 12.0
@export_range(0.0, 1.0, 0.01) var low_stamina_movement_threshold_ratio: float = 0.2
@export_range(0.1, 1.0, 0.01) var low_stamina_movement_min_multiplier: float = 0.82
@export var stamina_regen_idle_per_second: float = 28.0
@export var stamina_regen_moving_per_second: float = 16.0
@export var stamina_regen_airborne_per_second: float = 10.0
@export var stamina_regen_delay: float = 0.7

@export_group("HUD Feedback")
@export_range(0.0, 1.0, 0.01) var low_stamina_warning_ratio: float = 0.25
@export var low_stamina_pulse_speed: float = 7.0
@export var low_stamina_action_warning_time: float = 0.65
@export var low_stamina_action_warning_cooldown: float = 0.25

@export_group("Dash")
@export var dash_speed: float = 18.0
@export var dash_duration: float = 0.18
@export var dash_cooldown: float = 0.65
@export var dash_max_charges: int = 1
@export var dash_charge_recovery_time: float = 1.25
@export var dash_input_buffer_time: float = 0.15
@export var dash_allow_charge_bypass_cooldown: bool = true
@export_range(0.0, 1.0, 0.01) var dash_steer_control: float = 0.35
@export var dash_steer_responsiveness: float = 14.0

@export_group("Camera")
@export var camera_smooth: float = 8.0
@export var camera_height: float = 7.0
@export var camera_distance: float = 8.5
@export var camera_min_distance: float = 5.5
@export var camera_max_distance: float = 12.0
@export var camera_zoom_step: float = 1.0
@export var camera_base_fov: float = 75.0
@export var camera_fov_speed_bonus: float = 5.5
@export var camera_fov_dash_bonus: float = 3.0
@export var camera_fov_smooth: float = 10.0
@export var camera_look_ahead_distance: float = 2.25
@export var camera_look_ahead_smooth: float = 8.0

@export_group("Camera Impulse Feel")
@export var camera_impulse_decay_per_second: float = 14.0
@export var camera_impulse_max_offset: float = 0.85
@export var camera_dash_impulse_strength: float = 0.3
@export var camera_dash_impulse_vertical: float = 0.12
@export var camera_landing_impulse_strength: float = 0.38
