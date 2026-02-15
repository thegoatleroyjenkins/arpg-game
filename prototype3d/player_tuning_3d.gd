extends Resource
class_name PlayerTuning3D

@export var move_speed: float = 6.5
@export var sprint_multiplier: float = 1.6
@export var jump_velocity: float = 4.5
@export var gravity: float = 12.0
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12
@export var jump_release_gravity_multiplier: float = 2.2
@export var max_fall_speed: float = 18.0

@export_group("Movement Feel")
@export var ground_acceleration: float = 40.0
@export var ground_deceleration: float = 48.0
@export_range(0.0, 1.0, 0.01) var air_control: float = 0.5

@export_group("Sprint Feel")
@export var sprint_ramp_up_per_second: float = 8.0
@export var sprint_ramp_down_per_second: float = 10.0

@export_group("Facing")
@export var turn_speed_degrees_per_second: float = 720.0
@export var min_turn_speed_threshold: float = 0.1

@export_group("Stamina")
@export var max_stamina: float = 100.0
@export var sprint_stamina_per_second: float = 28.0
@export var dash_stamina_cost: float = 35.0
@export var jump_stamina_cost: float = 12.0
@export var stamina_regen_idle_per_second: float = 28.0
@export var stamina_regen_moving_per_second: float = 16.0
@export var stamina_regen_delay: float = 0.7

@export_group("Dash")
@export var dash_speed: float = 18.0
@export var dash_duration: float = 0.18
@export var dash_cooldown: float = 0.65
@export var dash_input_buffer_time: float = 0.15

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
