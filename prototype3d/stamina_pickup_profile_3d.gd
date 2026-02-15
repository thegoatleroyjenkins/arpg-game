extends Resource
class_name StaminaPickupProfile3D

@export_group("Core")
@export var stamina_restore: float = 24.0
@export var respawn_time: float = 8.0
@export var bob_height: float = 0.2
@export var bob_speed: float = 2.2
@export var spin_speed_degrees: float = 95.0

@export_group("Magnet")
@export var magnet_radius: float = 4.0
@export var magnet_speed: float = 10.0
@export_range(0.0, 1.0, 0.01) var magnet_min_speed_ratio: float = 0.35
@export_range(0.5, 3.0, 0.05) var magnet_speed_curve_power: float = 1.4
@export var magnet_auto_collect_radius: float = 0.75
@export_range(0.0, 1.0, 0.01) var magnet_missing_stamina_ratio: float = 0.2

@export_group("Collection")
@export_range(0.0, 1.0, 0.01) var min_collect_missing_stamina_ratio: float = 0.05

@export_group("Dash Recovery")
@export var dash_recovery_bonus_seconds: float = 0.35
@export_range(0.0, 1.0, 0.01) var min_collect_missing_dash_ratio: float = 0.1
@export_range(0.0, 1.0, 0.01) var magnet_missing_dash_ratio: float = 0.2

@export_group("Dash Charge Recovery")
@export var dash_charge_restore_count: int = 1
@export_range(0.0, 1.0, 0.01) var min_collect_missing_dash_charge_ratio: float = 0.34
@export_range(0.0, 1.0, 0.01) var magnet_missing_dash_charge_ratio: float = 0.5

@export_group("Air Jump Recovery")
@export var air_jump_recovery_count: int = 1
@export_range(0.0, 1.0, 0.01) var min_collect_missing_air_jump_ratio: float = 0.34
@export_range(0.0, 1.0, 0.01) var magnet_missing_air_jump_ratio: float = 0.5

@export_group("Regen Surge")
@export var regen_boost_duration: float = 1.6
@export_range(1.0, 4.0, 0.05) var regen_boost_multiplier: float = 1.35

@export_group("Sprint Efficiency")
@export var sprint_efficiency_boost_duration: float = 2.4
@export_range(1.0, 4.0, 0.05) var sprint_efficiency_boost_multiplier: float = 1.5

@export_group("Momentum Boost")
@export var move_speed_boost_duration: float = 1.75
@export_range(1.0, 3.0, 0.05) var move_speed_boost_multiplier: float = 1.2

@export_group("Dash Defense Boost")
@export var dash_invulnerability_boost_duration: float = 2.0
@export_range(0.0, 0.5, 0.01) var dash_invulnerability_boost_bonus_seconds: float = 0.05

@export_group("Line of Sight")
@export var magnet_requires_line_of_sight: bool = true
@export_flags_3d_physics var magnet_line_of_sight_collision_mask: int = 1
@export var magnet_line_of_sight_height_offset: float = 0.5

@export_group("Spawn Recovery")
@export var return_to_spawn_speed: float = 3.5
@export var return_to_spawn_snap_distance: float = 0.05

@export_group("Respawn Telegraph")
@export var show_respawn_telegraph: bool = true
@export var respawn_telegraph_duration: float = 1.1
@export_range(0.0, 1.0, 0.01) var respawn_telegraph_min_alpha: float = 0.2
@export_range(0.0, 1.0, 0.01) var respawn_telegraph_max_alpha: float = 0.8
@export var respawn_telegraph_pulse_speed: float = 8.0

@export_group("Visual")
@export var visual_albedo_color: Color = Color(0.5, 0.95, 1.0, 1.0)
@export var visual_emission_color: Color = Color(0.35, 0.8, 1.0, 1.0)
@export_range(0.0, 4.0, 0.05) var visual_emission_energy: float = 1.15

@export_group("Contextual Visuals")
@export var contextual_visual_feedback_enabled: bool = true
@export var contextual_stamina_tint: Color = Color(0.5, 0.95, 1.0, 1.0)
@export var contextual_dash_tint: Color = Color(1.0, 0.78, 0.36, 1.0)
@export var contextual_air_jump_tint: Color = Color(0.86, 0.66, 1.0, 1.0)
@export var contextual_mixed_tint: Color = Color(0.68, 0.92, 0.74, 1.0)
@export_range(0.0, 1.0, 0.01) var contextual_tint_blend: float = 0.7
