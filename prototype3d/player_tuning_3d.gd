extends Resource
class_name PlayerTuning3D

@export var move_speed: float = 6.5
@export var sprint_multiplier: float = 1.6
@export var jump_velocity: float = 4.5
@export var gravity: float = 12.0

@export_group("Dash")
@export var dash_speed: float = 18.0
@export var dash_duration: float = 0.18
@export var dash_cooldown: float = 0.65

@export_group("Camera")
@export var camera_smooth: float = 8.0
@export var camera_height: float = 7.0
@export var camera_distance: float = 8.5
