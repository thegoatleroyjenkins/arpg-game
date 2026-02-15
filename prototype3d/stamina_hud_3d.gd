extends CanvasLayer

@export var player_path: NodePath = NodePath("../Player")

@onready var stamina_bar: ProgressBar = $MarginContainer/VBoxContainer/StaminaBar
@onready var stamina_label: Label = $MarginContainer/VBoxContainer/StaminaLabel
@onready var dash_cooldown_bar: ProgressBar = $MarginContainer/VBoxContainer/DashCooldownBar
@onready var dash_cooldown_label: Label = $MarginContainer/VBoxContainer/DashCooldownLabel
@onready var dash_buffer_label: Label = $MarginContainer/VBoxContainer/DashBufferLabel
@onready var air_jump_label: Label = $MarginContainer/VBoxContainer/AirJumpLabel
@onready var sprint_state_label: Label = $MarginContainer/VBoxContainer/SprintStateLabel
@onready var landing_recovery_bar: ProgressBar = $MarginContainer/VBoxContainer/LandingRecoveryBar
@onready var landing_recovery_label: Label = $MarginContainer/VBoxContainer/LandingRecoveryLabel

var dash_charges_current: int = 0
var dash_charges_max: int = 1
var low_stamina_warning_ratio: float = 0.25
var low_stamina_pulse_speed: float = 7.0
var hard_landing_dash_cancel_window: float = 0.0
var low_stamina_active: bool = false
var base_stamina_modulate: Color = Color(1.0, 1.0, 1.0)

func _ready() -> void:
	var player := get_node_or_null(player_path)
	if player == null:
		push_warning("StaminaHud3D could not find player at path: %s" % player_path)
		return

	if not player.has_signal("stamina_changed"):
		push_warning("StaminaHud3D target does not expose stamina_changed signal")
		return
	if not player.has_signal("dash_cooldown_changed"):
		push_warning("StaminaHud3D target does not expose dash_cooldown_changed signal")
		return
	if not player.has_signal("dash_buffer_changed"):
		push_warning("StaminaHud3D target does not expose dash_buffer_changed signal")
		return
	if not player.has_signal("dash_charges_changed"):
		push_warning("StaminaHud3D target does not expose dash_charges_changed signal")
		return
	if not player.has_signal("air_jumps_changed"):
		push_warning("StaminaHud3D target does not expose air_jumps_changed signal")
		return
	if not player.has_signal("sprint_state_changed"):
		push_warning("StaminaHud3D target does not expose sprint_state_changed signal")
		return
	if not player.has_signal("landing_recovery_changed"):
		push_warning("StaminaHud3D target does not expose landing_recovery_changed signal")
		return

	player.stamina_changed.connect(_on_stamina_changed)
	player.dash_cooldown_changed.connect(_on_dash_cooldown_changed)
	player.dash_buffer_changed.connect(_on_dash_buffer_changed)
	player.dash_charges_changed.connect(_on_dash_charges_changed)
	player.air_jumps_changed.connect(_on_air_jumps_changed)
	player.sprint_state_changed.connect(_on_sprint_state_changed)
	player.landing_recovery_changed.connect(_on_landing_recovery_changed)
	var current_stamina := float(player.get("stamina"))
	var current_dash_cooldown := float(player.call("_next_dash_ready_remaining"))
	var current_dash_buffer := float(player.get("dash_buffer_left"))
	var current_dash_charges := int(player.get("dash_charges"))
	var current_air_jumps := int(player.get("air_jumps_left"))
	var current_landing_recovery := float(player.get("landing_recovery_left"))
	var tuning_resource: Resource = player.get("tuning")
	var max_stamina := 100.0
	var max_dash_cooldown := 1.0
	var max_dash_buffer := 0.15
	var max_dash_charges := 1
	var max_air_jumps := 0
	var max_landing_recovery := 0.18
	if tuning_resource != null:
		max_stamina = float(tuning_resource.get("max_stamina"))
		max_dash_cooldown = max(0.01, float(player.call("_next_dash_ready_max")))
		max_dash_buffer = max(0.01, float(tuning_resource.get("dash_input_buffer_time")))
		max_dash_charges = max(1, int(tuning_resource.get("dash_max_charges")))
		max_air_jumps = max(0, int(tuning_resource.get("max_air_jumps")))
		max_landing_recovery = max(0.01, float(tuning_resource.get("hard_landing_recovery_time")))
		if tuning_resource.has_method("get"):
			low_stamina_warning_ratio = clamp(float(tuning_resource.get("low_stamina_warning_ratio")), 0.0, 1.0)
			low_stamina_pulse_speed = max(0.01, float(tuning_resource.get("low_stamina_pulse_speed")))
			hard_landing_dash_cancel_window = max(0.0, float(tuning_resource.get("hard_landing_dash_cancel_window")))
	set_process(true)
	_on_stamina_changed(current_stamina, max_stamina)
	_on_dash_charges_changed(current_dash_charges, max_dash_charges)
	_on_dash_cooldown_changed(current_dash_cooldown, max_dash_cooldown)
	_on_dash_buffer_changed(current_dash_buffer, max_dash_buffer)
	_on_air_jumps_changed(current_air_jumps, max_air_jumps)
	_on_sprint_state_changed(bool(player.get("sprinting_now")), bool(player.get("sprint_exhausted")))
	_on_landing_recovery_changed(current_landing_recovery, max_landing_recovery)

func _process(_delta: float) -> void:
	if not low_stamina_active:
		return
	var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.001 * low_stamina_pulse_speed)
	var warning_color := Color(1.0, 0.35, 0.35)
	var pulse_strength := lerpf(0.35, 0.85, pulse)
	stamina_label.modulate = base_stamina_modulate.lerp(warning_color, pulse_strength)
	stamina_bar.modulate = base_stamina_modulate.lerp(warning_color, pulse_strength * 0.9)

func _on_stamina_changed(current: float, max_value: float) -> void:
	stamina_bar.max_value = max(1.0, max_value)
	stamina_bar.value = clamp(current, 0.0, stamina_bar.max_value)
	stamina_label.text = "Stamina %d / %d" % [roundi(current), roundi(max_value)]
	var stamina_ratio := 0.0
	if stamina_bar.max_value > 0.0:
		stamina_ratio = stamina_bar.value / stamina_bar.max_value
	low_stamina_active = stamina_ratio <= low_stamina_warning_ratio and stamina_bar.value < stamina_bar.max_value
	if not low_stamina_active:
		stamina_label.modulate = base_stamina_modulate
		stamina_bar.modulate = base_stamina_modulate

func _on_dash_charges_changed(current: int, max_value: int) -> void:
	dash_charges_current = max(0, current)
	dash_charges_max = max(1, max_value)

func _on_dash_cooldown_changed(remaining: float, max_value: float) -> void:
	dash_cooldown_bar.max_value = max(0.01, max_value)
	dash_cooldown_bar.value = clamp(remaining, 0.0, dash_cooldown_bar.max_value)
	if remaining <= 0.01 and dash_charges_current > 0:
		dash_cooldown_label.text = "Dash Ready (%d/%d)" % [dash_charges_current, dash_charges_max]
	else:
		dash_cooldown_label.text = "Dash %.2fs (%d/%d)" % [remaining, dash_charges_current, dash_charges_max]

func _on_dash_buffer_changed(remaining: float, max_value: float) -> void:
	var clamped_max := max(0.01, max_value)
	var clamped_remaining := clamp(remaining, 0.0, clamped_max)
	if clamped_remaining > 0.0:
		dash_buffer_label.text = "Dash Queue %.2fs" % clamped_remaining
		dash_buffer_label.modulate = Color(0.95, 0.9, 0.5)
	else:
		dash_buffer_label.text = "Dash Queue Empty"
		dash_buffer_label.modulate = Color(0.75, 0.8, 0.9)

func _on_air_jumps_changed(current: int, max_value: int) -> void:
	var clamped_max: int = max(0, max_value)
	var clamped_current: int = clampi(current, 0, clamped_max)
	air_jump_label.text = "Air Jumps %d / %d" % [clamped_current, clamped_max]

func _on_sprint_state_changed(is_sprinting: bool, is_exhausted: bool) -> void:
	if is_exhausted:
		sprint_state_label.text = "Sprint EXHAUSTED"
		sprint_state_label.modulate = Color(1.0, 0.45, 0.35)
	elif is_sprinting:
		sprint_state_label.text = "Sprint ACTIVE"
		sprint_state_label.modulate = Color(0.7, 1.0, 0.7)
	else:
		sprint_state_label.text = "Sprint READY"
		sprint_state_label.modulate = Color(0.85, 0.9, 1.0)

func _on_landing_recovery_changed(remaining: float, max_value: float) -> void:
	landing_recovery_bar.max_value = max(0.01, max_value)
	landing_recovery_bar.value = clamp(remaining, 0.0, landing_recovery_bar.max_value)
	if remaining > 0.01:
		if hard_landing_dash_cancel_window > 0.0 and remaining <= hard_landing_dash_cancel_window:
			landing_recovery_label.text = "Landing Recovery %.2fs (Dash Cancel Ready)" % remaining
			landing_recovery_label.modulate = Color(0.85, 0.95, 1.0)
		else:
			landing_recovery_label.text = "Landing Recovery %.2fs" % remaining
			landing_recovery_label.modulate = Color(1.0, 0.82, 0.45)
	else:
		landing_recovery_label.text = "Landing Recovery Ready"
		landing_recovery_label.modulate = Color(0.8, 1.0, 0.8)
