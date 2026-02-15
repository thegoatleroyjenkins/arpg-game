extends CanvasLayer

@export var player_path: NodePath = NodePath("../Player")

@onready var stamina_bar: ProgressBar = $MarginContainer/VBoxContainer/StaminaBar
@onready var stamina_label: Label = $MarginContainer/VBoxContainer/StaminaLabel
@onready var dash_cooldown_bar: ProgressBar = $MarginContainer/VBoxContainer/DashCooldownBar
@onready var dash_cooldown_label: Label = $MarginContainer/VBoxContainer/DashCooldownLabel
@onready var air_jump_label: Label = $MarginContainer/VBoxContainer/AirJumpLabel

var dash_charges_current: int = 0
var dash_charges_max: int = 1

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
	if not player.has_signal("dash_charges_changed"):
		push_warning("StaminaHud3D target does not expose dash_charges_changed signal")
		return
	if not player.has_signal("air_jumps_changed"):
		push_warning("StaminaHud3D target does not expose air_jumps_changed signal")
		return

	player.stamina_changed.connect(_on_stamina_changed)
	player.dash_cooldown_changed.connect(_on_dash_cooldown_changed)
	player.dash_charges_changed.connect(_on_dash_charges_changed)
	player.air_jumps_changed.connect(_on_air_jumps_changed)
	var current_stamina := float(player.get("stamina"))
	var current_dash_cooldown := float(player.call("_next_dash_ready_remaining"))
	var current_dash_charges := int(player.get("dash_charges"))
	var current_air_jumps := int(player.get("air_jumps_left"))
	var tuning_resource: Resource = player.get("tuning")
	var max_stamina := 100.0
	var max_dash_cooldown := 1.0
	var max_dash_charges := 1
	var max_air_jumps := 0
	if tuning_resource != null:
		max_stamina = float(tuning_resource.get("max_stamina"))
		max_dash_cooldown = max(0.01, float(player.call("_next_dash_ready_max")))
		max_dash_charges = max(1, int(tuning_resource.get("dash_max_charges")))
		max_air_jumps = max(0, int(tuning_resource.get("max_air_jumps")))
	_on_stamina_changed(current_stamina, max_stamina)
	_on_dash_charges_changed(current_dash_charges, max_dash_charges)
	_on_dash_cooldown_changed(current_dash_cooldown, max_dash_cooldown)
	_on_air_jumps_changed(current_air_jumps, max_air_jumps)

func _on_stamina_changed(current: float, max_value: float) -> void:
	stamina_bar.max_value = max(1.0, max_value)
	stamina_bar.value = clamp(current, 0.0, stamina_bar.max_value)
	stamina_label.text = "Stamina %d / %d" % [roundi(current), roundi(max_value)]

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

func _on_air_jumps_changed(current: int, max_value: int) -> void:
	var clamped_max := max(0, max_value)
	var clamped_current := clampi(current, 0, clamped_max)
	air_jump_label.text = "Air Jumps %d / %d" % [clamped_current, clamped_max]
