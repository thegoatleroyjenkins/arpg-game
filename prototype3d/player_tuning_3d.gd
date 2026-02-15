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

@export_group("Stamina")
@export var max_stamina: float = 100.0
@export var sprint_stamina_per_second: float = 28.0
@export var dash_stamina_cost: float = 35.0
@export var jump_stamina_cost: float = 12.0
@export var stamina_regen_per_second: float = 24.0
@export var stamina_regen_delay: float = 0.7

@export_group("Dash")
@export var dash_speed: float = 18.0
@export var dash_duration: float = 0.18
@export var dash_cooldown: float = 0.65

@export_group("Camera")
@export var camera_smooth: float = 8.0
@export var camera_height: float = 7.0
@export var camera_distance: float = 8.5
