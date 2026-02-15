extends CanvasLayer

@export var player_path: NodePath = NodePath("../Player")

@onready var stamina_bar: ProgressBar = $MarginContainer/VBoxContainer/StaminaBar
@onready var stamina_label: Label = $MarginContainer/VBoxContainer/StaminaLabel
@onready var dash_cooldown_bar: ProgressBar = $MarginContainer/VBoxContainer/DashCooldownBar
@onready var dash_cooldown_label: Label = $MarginContainer/VBoxContainer/DashCooldownLabel
@onready var dash_charge_recharge_bar: ProgressBar = $MarginContainer/VBoxContainer/DashChargeRechargeBar
@onready var dash_charge_recharge_label: Label = $MarginContainer/VBoxContainer/DashChargeRechargeLabel
@onready var dash_buffer_label: Label = $MarginContainer/VBoxContainer/DashBufferLabel
@onready var jump_buffer_label: Label = get_node_or_null("MarginContainer/VBoxContainer/JumpBufferLabel") as Label
@onready var attack_buffer_label: Label = get_node_or_null("MarginContainer/VBoxContainer/AttackBufferLabel") as Label
@onready var attack_cooldown_bar: ProgressBar = get_node_or_null("MarginContainer/VBoxContainer/AttackCooldownBar") as ProgressBar
@onready var attack_cooldown_label: Label = get_node_or_null("MarginContainer/VBoxContainer/AttackCooldownLabel") as Label
@onready var air_jump_label: Label = $MarginContainer/VBoxContainer/AirJumpLabel
@onready var sprint_state_label: Label = $MarginContainer/VBoxContainer/SprintStateLabel
@onready var landing_recovery_bar: ProgressBar = $MarginContainer/VBoxContainer/LandingRecoveryBar
@onready var landing_recovery_label: Label = $MarginContainer/VBoxContainer/LandingRecoveryLabel
@onready var stamina_regen_delay_bar: ProgressBar = $MarginContainer/VBoxContainer/StaminaRegenDelayBar
@onready var stamina_regen_delay_label: Label = $MarginContainer/VBoxContainer/StaminaRegenDelayLabel
@onready var stamina_regen_boost_label: Label = $MarginContainer/VBoxContainer/StaminaRegenBoostLabel
@onready var sprint_efficiency_boost_label: Label = $MarginContainer/VBoxContainer/SprintEfficiencyBoostLabel
@onready var move_speed_boost_label: Label = get_node_or_null("MarginContainer/VBoxContainer/MoveSpeedBoostLabel") as Label
@onready var dash_invulnerability_boost_label: Label = get_node_or_null("MarginContainer/VBoxContainer/DashInvulnerabilityBoostLabel") as Label
@onready var dash_charge_recovery_boost_label: Label = get_node_or_null("MarginContainer/VBoxContainer/DashChargeRecoveryBoostLabel") as Label
@onready var dash_invulnerability_bar: ProgressBar = $MarginContainer/VBoxContainer/DashInvulnerabilityBar
@onready var dash_invulnerability_label: Label = $MarginContainer/VBoxContainer/DashInvulnerabilityLabel
@onready var stamina_warning_label: Label = $MarginContainer/VBoxContainer/StaminaWarningLabel

var dash_charges_current: int = 0
var dash_charges_max: int = 1
var low_stamina_warning_ratio: float = 0.25
var low_stamina_pulse_speed: float = 7.0
var hard_landing_dash_cancel_window: float = 0.0
var low_stamina_active: bool = false
var stamina_warning_left: float = 0.0
var base_stamina_modulate: Color = Color(1.0, 1.0, 1.0)
var ui_outline_color: Color = Color(0.02, 0.03, 0.04, 0.95)
var bar_background_color: Color = Color(0.08, 0.11, 0.14, 0.95)
var stamina_color_high: Color = Color(0.35, 0.9, 0.5)
var stamina_color_mid: Color = Color(0.92, 0.82, 0.34)
var stamina_color_low: Color = Color(0.95, 0.36, 0.34)
var ready_color: Color = Color(0.44, 0.84, 1.0)
var active_color: Color = Color(0.98, 0.74, 0.34)

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
	if not player.has_signal("jump_buffer_changed"):
		push_warning("StaminaHud3D target does not expose jump_buffer_changed signal")
		return
	if not player.has_signal("attack_buffer_changed"):
		push_warning("StaminaHud3D target does not expose attack_buffer_changed signal")
		return
	if not player.has_signal("light_attack_cooldown_changed"):
		push_warning("StaminaHud3D target does not expose light_attack_cooldown_changed signal")
		return
	if not player.has_signal("dash_charges_changed"):
		push_warning("StaminaHud3D target does not expose dash_charges_changed signal")
		return
	if not player.has_signal("dash_charge_recharge_changed"):
		push_warning("StaminaHud3D target does not expose dash_charge_recharge_changed signal")
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
	if not player.has_signal("stamina_regen_delay_changed"):
		push_warning("StaminaHud3D target does not expose stamina_regen_delay_changed signal")
		return
	if not player.has_signal("stamina_action_failed"):
		push_warning("StaminaHud3D target does not expose stamina_action_failed signal")
		return
	if not player.has_signal("dash_invulnerability_changed"):
		push_warning("StaminaHud3D target does not expose dash_invulnerability_changed signal")
		return
	if not player.has_signal("stamina_regen_boost_changed"):
		push_warning("StaminaHud3D target does not expose stamina_regen_boost_changed signal")
		return
	if not player.has_signal("sprint_efficiency_boost_changed"):
		push_warning("StaminaHud3D target does not expose sprint_efficiency_boost_changed signal")
		return
	if not player.has_signal("move_speed_boost_changed"):
		push_warning("StaminaHud3D target does not expose move_speed_boost_changed signal")
		return
	if not player.has_signal("dash_invulnerability_boost_changed"):
		push_warning("StaminaHud3D target does not expose dash_invulnerability_boost_changed signal")
		return
	if not player.has_signal("dash_charge_recovery_boost_changed"):
		push_warning("StaminaHud3D target does not expose dash_charge_recovery_boost_changed signal")
		return

	player.stamina_changed.connect(_on_stamina_changed)
	player.dash_cooldown_changed.connect(_on_dash_cooldown_changed)
	player.dash_charge_recharge_changed.connect(_on_dash_charge_recharge_changed)
	player.dash_buffer_changed.connect(_on_dash_buffer_changed)
	player.jump_buffer_changed.connect(_on_jump_buffer_changed)
	player.attack_buffer_changed.connect(_on_attack_buffer_changed)
	player.light_attack_cooldown_changed.connect(_on_light_attack_cooldown_changed)
	player.dash_charges_changed.connect(_on_dash_charges_changed)
	player.air_jumps_changed.connect(_on_air_jumps_changed)
	player.sprint_state_changed.connect(_on_sprint_state_changed)
	player.landing_recovery_changed.connect(_on_landing_recovery_changed)
	player.stamina_regen_delay_changed.connect(_on_stamina_regen_delay_changed)
	player.stamina_action_failed.connect(_on_stamina_action_failed)
	player.dash_invulnerability_changed.connect(_on_dash_invulnerability_changed)
	player.stamina_regen_boost_changed.connect(_on_stamina_regen_boost_changed)
	player.sprint_efficiency_boost_changed.connect(_on_sprint_efficiency_boost_changed)
	player.move_speed_boost_changed.connect(_on_move_speed_boost_changed)
	player.dash_invulnerability_boost_changed.connect(_on_dash_invulnerability_boost_changed)
	player.dash_charge_recovery_boost_changed.connect(_on_dash_charge_recovery_boost_changed)
	var current_stamina := float(player.get("stamina"))
	var current_dash_cooldown := float(player.call("_next_dash_ready_remaining"))
	var current_dash_charge_recharge := float(player.get("dash_charge_recharge_left"))
	var current_dash_buffer := float(player.get("dash_buffer_left"))
	var current_jump_buffer := float(player.get("jump_buffer_left"))
	var current_attack_buffer := float(player.get("light_attack_buffer_left"))
	var current_attack_cooldown := float(player.get("light_attack_cooldown_left"))
	var current_dash_charges := int(player.get("dash_charges"))
	var current_air_jumps := int(player.get("air_jumps_left"))
	var current_landing_recovery := float(player.get("landing_recovery_left"))
	var current_stamina_regen_delay := float(player.get("stamina_regen_delay_left"))
	var current_dash_invulnerability := float(player.get("dash_invulnerability_left"))
	var current_stamina_regen_boost := float(player.get("stamina_regen_boost_left"))
	var current_stamina_regen_boost_max := float(player.get("stamina_regen_boost_max"))
	var current_stamina_regen_boost_multiplier := float(player.get("stamina_regen_boost_multiplier"))
	var current_sprint_efficiency_boost := float(player.get("sprint_efficiency_boost_left"))
	var current_sprint_efficiency_boost_max := float(player.get("sprint_efficiency_boost_max"))
	var current_sprint_efficiency_boost_multiplier := float(player.get("sprint_efficiency_boost_multiplier"))
	var current_move_speed_boost := float(player.get("move_speed_boost_left"))
	var current_move_speed_boost_max := float(player.get("move_speed_boost_max"))
	var current_move_speed_boost_multiplier := float(player.get("move_speed_boost_multiplier"))
	var current_dash_invulnerability_boost := float(player.get("dash_invulnerability_boost_left"))
	var current_dash_invulnerability_boost_max := float(player.get("dash_invulnerability_boost_max"))
	var current_dash_invulnerability_boost_bonus := float(player.get("dash_invulnerability_boost_bonus_seconds"))
	var current_dash_charge_recovery_boost := float(player.get("dash_charge_recovery_boost_left"))
	var current_dash_charge_recovery_boost_max := float(player.get("dash_charge_recovery_boost_max"))
	var current_dash_charge_recovery_boost_multiplier := float(player.get("dash_charge_recovery_boost_multiplier"))
	var tuning_resource: Resource = player.get("tuning")
	var max_stamina := 100.0
	var max_dash_cooldown := 1.0
	var max_dash_charge_recharge := 1.25
	var max_dash_buffer := 0.15
	var max_jump_buffer := 0.12
	var max_attack_buffer := 0.14
	var max_attack_cooldown := 0.35
	var max_dash_charges := 1
	var max_air_jumps := 0
	var max_landing_recovery := 0.18
	var max_stamina_regen_delay := 0.7
	var max_dash_invulnerability := 0.12
	if tuning_resource != null:
		max_stamina = float(tuning_resource.get("max_stamina"))
		max_dash_cooldown = max(0.01, float(player.call("_next_dash_ready_max")))
		max_dash_charge_recharge = max(0.01, float(tuning_resource.get("dash_charge_recovery_time")))
		max_dash_buffer = max(0.01, float(tuning_resource.get("dash_input_buffer_time")))
		max_jump_buffer = max(0.01, float(tuning_resource.get("jump_buffer_time")) + max(0.0, float(tuning_resource.get("jump_buffer_dash_bonus_time"))))
		max_attack_buffer = max(0.01, float(tuning_resource.get("light_attack_input_buffer_time")))
		max_attack_cooldown = max(0.01, float(player.call("_light_attack_cooldown_max")))
		max_dash_charges = max(1, int(tuning_resource.get("dash_max_charges")))
		max_air_jumps = max(0, int(tuning_resource.get("max_air_jumps")))
		max_landing_recovery = max(0.01, float(tuning_resource.get("hard_landing_recovery_time")))
		max_stamina_regen_delay = max(0.01, float(tuning_resource.get("stamina_regen_delay")))
		max_dash_invulnerability = max(0.01, float(tuning_resource.get("dash_invulnerability_duration")))
		if tuning_resource.has_method("get"):
			low_stamina_warning_ratio = clamp(float(tuning_resource.get("low_stamina_warning_ratio")), 0.0, 1.0)
			low_stamina_pulse_speed = max(0.01, float(tuning_resource.get("low_stamina_pulse_speed")))
			hard_landing_dash_cancel_window = max(0.0, float(tuning_resource.get("hard_landing_dash_cancel_window")))
	if move_speed_boost_label == null:
		var vbox: VBoxContainer = $MarginContainer/VBoxContainer
		move_speed_boost_label = Label.new()
		move_speed_boost_label.name = "MoveSpeedBoostLabel"
		move_speed_boost_label.text = "Momentum Boost Ready"
		vbox.add_child(move_speed_boost_label)
		vbox.move_child(move_speed_boost_label, sprint_efficiency_boost_label.get_index() + 1)
	if dash_invulnerability_boost_label == null:
		var vbox: VBoxContainer = $MarginContainer/VBoxContainer
		dash_invulnerability_boost_label = Label.new()
		dash_invulnerability_boost_label.name = "DashInvulnerabilityBoostLabel"
		dash_invulnerability_boost_label.text = "Dash I-Frame Boost Ready"
		vbox.add_child(dash_invulnerability_boost_label)
		vbox.move_child(dash_invulnerability_boost_label, move_speed_boost_label.get_index() + 1)
	if dash_charge_recovery_boost_label == null:
		var vbox: VBoxContainer = $MarginContainer/VBoxContainer
		dash_charge_recovery_boost_label = Label.new()
		dash_charge_recovery_boost_label.name = "DashChargeRecoveryBoostLabel"
		dash_charge_recovery_boost_label.text = "Dash Recharge Boost Ready"
		vbox.add_child(dash_charge_recovery_boost_label)
		vbox.move_child(dash_charge_recovery_boost_label, dash_invulnerability_boost_label.get_index() + 1)
	if jump_buffer_label == null:
		var vbox: VBoxContainer = $MarginContainer/VBoxContainer
		jump_buffer_label = Label.new()
		jump_buffer_label.name = "JumpBufferLabel"
		jump_buffer_label.text = "Jump Queue Empty"
		vbox.add_child(jump_buffer_label)
		vbox.move_child(jump_buffer_label, dash_buffer_label.get_index() + 1)
	if attack_buffer_label == null:
		var vbox: VBoxContainer = $MarginContainer/VBoxContainer
		attack_buffer_label = Label.new()
		attack_buffer_label.name = "AttackBufferLabel"
		attack_buffer_label.text = "Attack Queue Empty"
		vbox.add_child(attack_buffer_label)
		vbox.move_child(attack_buffer_label, jump_buffer_label.get_index() + 1)
	if attack_cooldown_bar == null:
		var vbox: VBoxContainer = $MarginContainer/VBoxContainer
		attack_cooldown_bar = ProgressBar.new()
		attack_cooldown_bar.name = "AttackCooldownBar"
		attack_cooldown_bar.show_percentage = false
		attack_cooldown_bar.max_value = 1.0
		attack_cooldown_bar.value = 0.0
		vbox.add_child(attack_cooldown_bar)
		vbox.move_child(attack_cooldown_bar, attack_buffer_label.get_index() + 1)
	if attack_cooldown_label == null:
		var vbox: VBoxContainer = $MarginContainer/VBoxContainer
		attack_cooldown_label = Label.new()
		attack_cooldown_label.name = "AttackCooldownLabel"
		attack_cooldown_label.text = "Attack Ready"
		vbox.add_child(attack_cooldown_label)
		vbox.move_child(attack_cooldown_label, attack_cooldown_bar.get_index() + 1)
	stamina_warning_label.visible = false
	stamina_warning_label.modulate = Color(1.0, 0.45, 0.35)
	_apply_readability_theme()
	set_process(true)
	_on_stamina_changed(current_stamina, max_stamina)
	_on_dash_charges_changed(current_dash_charges, max_dash_charges)
	_on_dash_cooldown_changed(current_dash_cooldown, max_dash_cooldown)
	_on_dash_charge_recharge_changed(current_dash_charge_recharge, max_dash_charge_recharge)
	_on_dash_buffer_changed(current_dash_buffer, max_dash_buffer)
	_on_jump_buffer_changed(current_jump_buffer, max_jump_buffer)
	_on_attack_buffer_changed(current_attack_buffer, max_attack_buffer)
	_on_light_attack_cooldown_changed(current_attack_cooldown, max_attack_cooldown)
	_on_air_jumps_changed(current_air_jumps, max_air_jumps)
	_on_sprint_state_changed(bool(player.get("sprinting_now")), bool(player.get("sprint_exhausted")))
	_on_landing_recovery_changed(current_landing_recovery, max_landing_recovery)
	_on_stamina_regen_delay_changed(current_stamina_regen_delay, max_stamina_regen_delay)
	_on_stamina_regen_boost_changed(current_stamina_regen_boost, max(0.01, current_stamina_regen_boost_max), max(1.0, current_stamina_regen_boost_multiplier))
	_on_sprint_efficiency_boost_changed(current_sprint_efficiency_boost, max(0.01, current_sprint_efficiency_boost_max), max(1.0, current_sprint_efficiency_boost_multiplier))
	_on_move_speed_boost_changed(current_move_speed_boost, max(0.01, current_move_speed_boost_max), max(1.0, current_move_speed_boost_multiplier))
	_on_dash_invulnerability_boost_changed(current_dash_invulnerability_boost, max(0.01, current_dash_invulnerability_boost_max), max(0.0, current_dash_invulnerability_boost_bonus))
	_on_dash_charge_recovery_boost_changed(current_dash_charge_recovery_boost, max(0.01, current_dash_charge_recovery_boost_max), max(1.0, current_dash_charge_recovery_boost_multiplier))
	_on_dash_invulnerability_changed(current_dash_invulnerability, max_dash_invulnerability)

func _process(delta: float) -> void:
	if low_stamina_active:
		var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.001 * low_stamina_pulse_speed)
		var warning_color := Color(1.0, 0.35, 0.35)
		var pulse_strength := lerpf(0.35, 0.85, pulse)
		stamina_label.modulate = base_stamina_modulate.lerp(warning_color, pulse_strength)
		stamina_bar.modulate = base_stamina_modulate.lerp(warning_color, pulse_strength * 0.9)
	if stamina_warning_left > 0.0:
		stamina_warning_left = max(0.0, stamina_warning_left - delta)
		stamina_warning_label.visible = stamina_warning_left > 0.0

func _apply_readability_theme() -> void:
	var labels: Array[Label] = [
		stamina_label,
		dash_cooldown_label,
		dash_charge_recharge_label,
		dash_buffer_label,
		jump_buffer_label,
		attack_buffer_label,
		attack_cooldown_label,
		air_jump_label,
		sprint_state_label,
		landing_recovery_label,
		stamina_regen_delay_label,
		stamina_regen_boost_label,
		sprint_efficiency_boost_label,
		dash_invulnerability_label,
		stamina_warning_label,
	]
	if move_speed_boost_label != null:
		labels.append(move_speed_boost_label)
	if dash_invulnerability_boost_label != null:
		labels.append(dash_invulnerability_boost_label)
	if dash_charge_recovery_boost_label != null:
		labels.append(dash_charge_recovery_boost_label)
	for ui_label in labels:
		ui_label.add_theme_constant_override("outline_size", 3)
		ui_label.add_theme_color_override("font_outline_color", ui_outline_color)

	var bars: Array[ProgressBar] = [
		stamina_bar,
		dash_cooldown_bar,
		dash_charge_recharge_bar,
		attack_cooldown_bar,
		landing_recovery_bar,
		stamina_regen_delay_bar,
		dash_invulnerability_bar,
	]
	for bar in bars:
		bar.custom_minimum_size = Vector2(0.0, 14.0)

	stamina_bar.custom_minimum_size = Vector2(0.0, 18.0)
	for bar in bars:
		_set_bar_background_color(bar, bar_background_color)


func _set_bar_background_color(bar: ProgressBar, color: Color) -> void:
	if bar == null:
		return
	var background := StyleBoxFlat.new()
	background.bg_color = color
	background.corner_radius_top_left = 3
	background.corner_radius_top_right = 3
	background.corner_radius_bottom_left = 3
	background.corner_radius_bottom_right = 3
	bar.add_theme_stylebox_override("background", background)


func _set_bar_fill_color(bar: ProgressBar, color: Color) -> void:
	if bar == null:
		return
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.corner_radius_top_left = 3
	fill.corner_radius_top_right = 3
	fill.corner_radius_bottom_left = 3
	fill.corner_radius_bottom_right = 3
	bar.add_theme_stylebox_override("fill", fill)


func _on_stamina_changed(current: float, max_value: float) -> void:
	stamina_bar.max_value = max(1.0, max_value)
	stamina_bar.value = clamp(current, 0.0, stamina_bar.max_value)
	stamina_label.text = "Stamina %d / %d" % [roundi(current), roundi(max_value)]
	var stamina_ratio := 0.0
	if stamina_bar.max_value > 0.0:
		stamina_ratio = stamina_bar.value / stamina_bar.max_value
	var stamina_fill_color: Color = stamina_color_high
	if stamina_ratio <= low_stamina_warning_ratio:
		stamina_fill_color = stamina_color_low
	elif stamina_ratio <= 0.55:
		stamina_fill_color = stamina_color_mid
	_set_bar_fill_color(stamina_bar, stamina_fill_color)
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
		_set_bar_fill_color(dash_cooldown_bar, ready_color)
	else:
		dash_cooldown_label.text = "Dash %.2fs (%d/%d)" % [remaining, dash_charges_current, dash_charges_max]
		_set_bar_fill_color(dash_cooldown_bar, active_color)

func _on_dash_charge_recharge_changed(remaining: float, max_value: float) -> void:
	dash_charge_recharge_bar.max_value = max(0.01, max_value)
	dash_charge_recharge_bar.value = clamp(remaining, 0.0, dash_charge_recharge_bar.max_value)
	if remaining > 0.01 and dash_charges_current < dash_charges_max:
		dash_charge_recharge_label.text = "Dash Charge +1 in %.2fs" % remaining
		dash_charge_recharge_label.modulate = Color(0.92, 0.87, 0.55)
		_set_bar_fill_color(dash_charge_recharge_bar, active_color)
	else:
		dash_charge_recharge_label.text = "Dash Charges Full"
		dash_charge_recharge_label.modulate = Color(0.75, 0.9, 1.0)
		_set_bar_fill_color(dash_charge_recharge_bar, ready_color)

func _on_dash_buffer_changed(remaining: float, max_value: float) -> void:
	var clamped_max: float = max(0.01, max_value)
	var clamped_remaining: float = clamp(remaining, 0.0, clamped_max)
	if clamped_remaining > 0.0:
		dash_buffer_label.text = "Dash Queue %.2fs" % clamped_remaining
		dash_buffer_label.modulate = Color(0.95, 0.9, 0.5)
	else:
		dash_buffer_label.text = "Dash Queue Empty"
		dash_buffer_label.modulate = Color(0.75, 0.8, 0.9)

func _on_jump_buffer_changed(remaining: float, max_value: float) -> void:
	if jump_buffer_label == null:
		return
	var clamped_max: float = max(0.01, max_value)
	var clamped_remaining: float = clamp(remaining, 0.0, clamped_max)
	if clamped_remaining > 0.0:
		jump_buffer_label.text = "Jump Queue %.2fs" % clamped_remaining
		jump_buffer_label.modulate = Color(0.8, 0.92, 1.0)
	else:
		jump_buffer_label.text = "Jump Queue Empty"
		jump_buffer_label.modulate = Color(0.72, 0.82, 0.94)

func _on_attack_buffer_changed(remaining: float, max_value: float) -> void:
	if attack_buffer_label == null:
		return
	var clamped_max: float = max(0.01, max_value)
	var clamped_remaining: float = clamp(remaining, 0.0, clamped_max)
	if clamped_remaining > 0.0:
		attack_buffer_label.text = "Attack Queue %.2fs" % clamped_remaining
		attack_buffer_label.modulate = Color(1.0, 0.84, 0.62)
	else:
		attack_buffer_label.text = "Attack Queue Empty"
		attack_buffer_label.modulate = Color(0.9, 0.82, 0.78)

func _on_light_attack_cooldown_changed(remaining: float, max_value: float) -> void:
	if attack_cooldown_bar == null or attack_cooldown_label == null:
		return
	attack_cooldown_bar.max_value = max(0.01, max_value)
	attack_cooldown_bar.value = clamp(remaining, 0.0, attack_cooldown_bar.max_value)
	if remaining > 0.01:
		attack_cooldown_label.text = "Attack Cooldown %.2fs" % remaining
		attack_cooldown_label.modulate = Color(1.0, 0.72, 0.55)
		_set_bar_fill_color(attack_cooldown_bar, active_color)
	else:
		attack_cooldown_label.text = "Attack Ready"
		attack_cooldown_label.modulate = Color(0.88, 0.96, 0.88)
		_set_bar_fill_color(attack_cooldown_bar, ready_color)

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
		_set_bar_fill_color(landing_recovery_bar, active_color)
		if hard_landing_dash_cancel_window > 0.0 and remaining <= hard_landing_dash_cancel_window:
			landing_recovery_label.text = "Landing Recovery %.2fs (Dash Cancel Ready)" % remaining
			landing_recovery_label.modulate = Color(0.85, 0.95, 1.0)
		else:
			landing_recovery_label.text = "Landing Recovery %.2fs" % remaining
			landing_recovery_label.modulate = Color(1.0, 0.82, 0.45)
	else:
		landing_recovery_label.text = "Landing Recovery Ready"
		landing_recovery_label.modulate = Color(0.8, 1.0, 0.8)
		_set_bar_fill_color(landing_recovery_bar, ready_color)

func _on_stamina_regen_delay_changed(remaining: float, max_value: float) -> void:
	stamina_regen_delay_bar.max_value = max(0.01, max_value)
	stamina_regen_delay_bar.value = clamp(remaining, 0.0, stamina_regen_delay_bar.max_value)
	if remaining > 0.01:
		stamina_regen_delay_label.text = "Regen Delay %.2fs" % remaining
		stamina_regen_delay_label.modulate = Color(1.0, 0.72, 0.4)
		_set_bar_fill_color(stamina_regen_delay_bar, active_color)
	else:
		stamina_regen_delay_label.text = "Regen Active"
		stamina_regen_delay_label.modulate = Color(0.72, 1.0, 0.72)
		_set_bar_fill_color(stamina_regen_delay_bar, ready_color)

func _on_stamina_action_failed(reason: String, duration: float) -> void:
	stamina_warning_left = max(0.0, duration)
	if stamina_warning_left <= 0.0:
		stamina_warning_label.visible = false
		return
	stamina_warning_label.text = "%s failed: low stamina" % reason
	stamina_warning_label.visible = true

func _on_stamina_regen_boost_changed(remaining: float, _max_value: float, multiplier: float) -> void:
	var clamped_remaining: float = max(0.0, remaining)
	if clamped_remaining > 0.01:
		stamina_regen_boost_label.text = "Regen Surge x%.2f (%.2fs)" % [max(1.0, multiplier), clamped_remaining]
		stamina_regen_boost_label.modulate = Color(0.62, 1.0, 0.72)
	else:
		stamina_regen_boost_label.text = "Regen Surge Ready"
		stamina_regen_boost_label.modulate = Color(0.7, 0.9, 0.75)

func _on_sprint_efficiency_boost_changed(remaining: float, _max_value: float, multiplier: float) -> void:
	var clamped_remaining: float = max(0.0, remaining)
	if clamped_remaining > 0.01:
		sprint_efficiency_boost_label.text = "Sprint Efficiency x%.2f (%.2fs)" % [max(1.0, multiplier), clamped_remaining]
		sprint_efficiency_boost_label.modulate = Color(0.6, 0.92, 1.0)
	else:
		sprint_efficiency_boost_label.text = "Sprint Efficiency Ready"
		sprint_efficiency_boost_label.modulate = Color(0.72, 0.85, 0.95)

func _on_move_speed_boost_changed(remaining: float, _max_value: float, multiplier: float) -> void:
	if move_speed_boost_label == null:
		return
	var clamped_remaining: float = max(0.0, remaining)
	if clamped_remaining > 0.01:
		move_speed_boost_label.text = "Momentum Boost x%.2f (%.2fs)" % [max(1.0, multiplier), clamped_remaining]
		move_speed_boost_label.modulate = Color(1.0, 0.86, 0.52)
	else:
		move_speed_boost_label.text = "Momentum Boost Ready"
		move_speed_boost_label.modulate = Color(0.94, 0.86, 0.72)

func _on_dash_invulnerability_boost_changed(remaining: float, _max_value: float, bonus_seconds: float) -> void:
	if dash_invulnerability_boost_label == null:
		return
	var clamped_remaining: float = max(0.0, remaining)
	if clamped_remaining > 0.01 and bonus_seconds > 0.0:
		dash_invulnerability_boost_label.text = "Dash I-Frame Boost +%.2fs (%.2fs)" % [bonus_seconds, clamped_remaining]
		dash_invulnerability_boost_label.modulate = Color(0.66, 0.95, 1.0)
	else:
		dash_invulnerability_boost_label.text = "Dash I-Frame Boost Ready"
		dash_invulnerability_boost_label.modulate = Color(0.76, 0.88, 0.98)


func _on_dash_charge_recovery_boost_changed(remaining: float, _max_value: float, multiplier: float) -> void:
	if dash_charge_recovery_boost_label == null:
		return
	var clamped_remaining: float = max(0.0, remaining)
	if clamped_remaining > 0.01:
		dash_charge_recovery_boost_label.text = "Dash Recharge Boost x%.2f (%.2fs)" % [max(1.0, multiplier), clamped_remaining]
		dash_charge_recovery_boost_label.modulate = Color(0.95, 0.78, 1.0)
	else:
		dash_charge_recovery_boost_label.text = "Dash Recharge Boost Ready"
		dash_charge_recovery_boost_label.modulate = Color(0.84, 0.78, 0.95)

func _on_dash_invulnerability_changed(remaining: float, max_value: float) -> void:
	dash_invulnerability_bar.max_value = max(0.01, max_value)
	dash_invulnerability_bar.value = clamp(remaining, 0.0, dash_invulnerability_bar.max_value)
	if remaining > 0.01:
		dash_invulnerability_label.text = "Dash I-Frames %.2fs" % remaining
		dash_invulnerability_label.modulate = Color(0.72, 0.95, 1.0)
		_set_bar_fill_color(dash_invulnerability_bar, active_color)
	else:
		dash_invulnerability_label.text = "Dash I-Frames Ready"
		dash_invulnerability_label.modulate = Color(0.78, 0.86, 0.98)
		_set_bar_fill_color(dash_invulnerability_bar, ready_color)
