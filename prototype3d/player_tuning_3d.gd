extends Resource
class_name PlayerTuning3D

@export var move_speed: float = 6.5
@export var sprint_multiplier: float = 1.6
@export var jump_velocity: float = 4.5
@export var gravity: float = 12.0
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12
@export var jump_buffer_dash_bonus_time: float = 0.1
@export var max_air_jumps: int = 1

@export_group("Air Jump Feel")
@export var air_jump_horizontal_boost: float = 2.2
@export var air_jump_horizontal_speed_cap: float = 8.8

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

@export_group("Movement Controls")
@export var movement_relative_to_camera: bool = true
@export_range(0.0, 0.4, 0.01) var movement_input_deadzone: float = 0.15

@export_group("Sprint Feel")
@export var sprint_ramp_up_per_second: float = 8.0
@export var sprint_ramp_down_per_second: float = 10.0
@export var sprint_exhaustion_threshold: float = 5.0
@export var sprint_resume_threshold: float = 18.0

@export_group("Facing")
@export var turn_speed_degrees_per_second: float = 720.0
@export_range(0.25, 2.5, 0.01) var sprint_turn_speed_multiplier: float = 0.82
@export var min_turn_speed_threshold: float = 0.1

@export_group("Landing Feel")
@export var hard_landing_speed_threshold: float = 12.0
@export var hard_landing_max_penalty_speed: float = 24.0
@export_range(0.1, 1.0, 0.01) var hard_landing_min_penalty_multiplier: float = 0.35
@export var hard_landing_recovery_time: float = 0.18
@export var hard_landing_stamina_cost: float = 14.0
@export var hard_landing_dash_cancel_window: float = 0.07
@export var hard_landing_dash_input_buffer_window: float = 0.12

@export_group("Safety")
@export var fall_reset_height: float = -12.0
@export var fall_reset_stamina_cost: float = 18.0
@export var fall_reset_recovery_time: float = 0.2

@export_group("Stamina")
@export var max_stamina: float = 100.0
@export var sprint_stamina_per_second: float = 28.0
@export var dash_stamina_cost: float = 35.0
@export var light_attack_stamina_cost: float = 10.0
@export_range(1.0, 3.0, 0.01) var dash_airborne_stamina_multiplier: float = 1.2
@export var jump_stamina_cost: float = 12.0
@export_range(1.0, 3.0, 0.01) var air_jump_stamina_multiplier: float = 1.25
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

@export_group("Attack Feel")
@export var light_attack_input_buffer_time: float = 0.14
@export var light_attack_allow_whiff_swing: bool = true
@export_range(0.0, 1.0, 0.01) var light_attack_whiff_cooldown_multiplier: float = 0.55
@export_range(0.0, 1.0, 0.01) var light_attack_whiff_stamina_multiplier: float = 0.35
@export_range(0.0, 1.0, 0.01) var light_attack_whiff_lunge_multiplier: float = 0.45
@export var light_attack_lunge_enabled: bool = true
@export var light_attack_lunge_duration: float = 0.1
@export var light_attack_lunge_speed: float = 7.5
@export_range(0.0, 1.0, 0.01) var light_attack_lunge_control_multiplier: float = 0.35
@export_range(0.0, 1.0, 0.01) var light_attack_cleave_falloff_per_target: float = 0.2
@export_range(0.1, 1.0, 0.01) var light_attack_cleave_min_multiplier: float = 0.5
@export var light_attack_backstab_enabled: bool = true
@export_range(0.0, 1.0, 0.01) var light_attack_backstab_dot_threshold: float = 0.35
@export_range(1.0, 3.0, 0.01) var light_attack_backstab_damage_multiplier: float = 1.25
@export var light_attack_hit_camera_impulse_strength: float = 0.045
@export var light_attack_hit_camera_impulse_vertical: float = 0.07
@export var light_attack_crit_camera_impulse_strength_bonus: float = 0.12
@export var light_attack_crit_camera_impulse_vertical_bonus: float = 0.15
@export var light_attack_require_line_of_sight: bool = true
@export_flags_3d_physics var light_attack_line_of_sight_mask: int = 1
@export var light_attack_line_of_sight_height: float = 1.0
@export var light_attack_auto_face_enabled: bool = true
@export_range(0.0, 180.0, 0.5) var light_attack_auto_face_max_angle_degrees: float = 70.0
@export_range(0.0, 180.0, 0.5) var light_attack_auto_face_max_turn_per_attack_degrees: float = 55.0
@export_range(0.0, 3.0, 0.05) var light_attack_targeting_distance_weight: float = 1.0
@export_range(0.0, 3.0, 0.05) var light_attack_targeting_alignment_weight: float = 0.7
@export var light_attack_execute_enabled: bool = true
@export_range(0.0, 1.0, 0.01) var light_attack_execute_health_ratio_threshold: float = 0.25
@export_range(1.0, 3.0, 0.01) var light_attack_execute_damage_multiplier: float = 1.35
@export var light_attack_combo_enabled: bool = true
@export var light_attack_combo_reset_time: float = 1.2
@export_range(0.0, 1.0, 0.01) var light_attack_combo_damage_per_stack: float = 0.08
@export_range(1, 8, 1) var light_attack_combo_max_stacks: int = 4

@export_group("Dash")
@export var dash_speed: float = 18.0
@export var dash_duration: float = 0.18
@export var dash_cooldown: float = 0.65
@export var dash_max_charges: int = 1
@export var dash_charge_recovery_time: float = 1.25
@export var dash_input_buffer_time: float = 0.15
@export var dash_allow_charge_bypass_cooldown: bool = true
@export var dash_use_recent_input_direction: bool = true
@export var dash_recent_input_memory_time: float = 0.2
@export var dash_neutral_uses_camera_forward: bool = true
@export_range(0.0, 1.0, 0.01) var dash_steer_control: float = 0.35
@export var dash_steer_responsiveness: float = 14.0
@export var dash_cancel_on_wall_collision: bool = true
@export_range(0.0, 1.0, 0.01) var dash_wall_collision_dot_threshold: float = 0.45
@export var dash_chain_window: float = 0.9
@export_range(1.0, 3.0, 0.01) var dash_chain_stamina_multiplier: float = 1.2
@export var dash_chain_max_stacks: int = 2

@export_group("Dash VFX")
@export var dash_trail_enabled: bool = true
@export var dash_trail_spawn_interval: float = 0.04
@export var dash_trail_lifetime: float = 0.16
@export var dash_trail_color: Color = Color(0.45, 0.8, 1.0, 1.0)
@export_range(0.0, 8.0, 0.1) var dash_trail_emission_energy: float = 1.2
@export_range(0.0, 1.0, 0.01) var dash_trail_start_alpha: float = 0.4
@export_range(0.0, 1.0, 0.01) var dash_trail_end_alpha: float = 0.0

@export_group("Dash Defense")
@export var dash_invulnerability_duration: float = 0.12

@export_group("Dash Readability")
@export var dash_invulnerability_flash_enabled: bool = true
@export var dash_invulnerability_flash_color: Color = Color(0.45, 0.85, 1.0, 1.0)
@export_range(0.0, 8.0, 0.1) var dash_invulnerability_flash_emission_energy: float = 1.5
@export var dash_invulnerability_flash_pulse_speed: float = 18.0
@export var dash_invulnerability_flash_blend_speed: float = 14.0

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

@export_group("Camera Orbit")
@export var camera_orbit_enabled: bool = true
@export var camera_orbit_sensitivity: float = 0.1
@export var camera_orbit_pitch_min_degrees: float = -20.0
@export var camera_orbit_pitch_max_degrees: float = 35.0
@export var camera_orbit_invert_y: bool = false

@export_group("Camera Recentering")
@export var camera_recenter_enabled: bool = true
@export var camera_recenter_speed_degrees_per_second: float = 420.0
@export_range(0.0, 45.0, 0.1) var camera_recenter_snap_angle_degrees: float = 1.25

@export_group("Camera Follow Assist")
@export var camera_follow_assist_enabled: bool = true
@export var camera_follow_assist_speed_degrees_per_second: float = 95.0
@export var camera_follow_assist_min_move_speed: float = 1.5
@export_range(0.5, 4.0, 0.05) var camera_follow_assist_dash_multiplier: float = 1.5
@export var camera_follow_assist_input_lock_time: float = 0.8

@export_group("Camera Collision")
@export var camera_collision_enabled: bool = true
@export_flags_3d_physics var camera_collision_mask: int = 1
@export var camera_collision_padding: float = 0.35
@export var camera_collision_min_distance: float = 2.5
@export var camera_collision_smooth: float = 18.0

@export_group("Camera Impulse Feel")
@export var camera_impulse_decay_per_second: float = 14.0
@export var camera_impulse_max_offset: float = 0.85
@export var camera_dash_impulse_strength: float = 0.3
@export var camera_dash_impulse_vertical: float = 0.12
@export var camera_landing_impulse_strength: float = 0.38
