extends CanvasLayer

@export var player_path: NodePath = NodePath("../Player")

@onready var stamina_bar: ProgressBar = $MarginContainer/VBoxContainer/StaminaBar
@onready var stamina_label: Label = $MarginContainer/VBoxContainer/StaminaLabel
@onready var dash_cooldown_bar: ProgressBar = $MarginContainer/VBoxContainer/DashCooldownBar
@onready var dash_cooldown_label: Label = $MarginContainer/VBoxContainer/DashCooldownLabel

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

	player.stamina_changed.connect(_on_stamina_changed)
	player.dash_cooldown_changed.connect(_on_dash_cooldown_changed)
	var current_stamina := float(player.get("stamina"))
	var current_dash_cooldown := float(player.get("dash_cooldown_left"))
	var tuning_resource: Resource = player.get("tuning")
	var max_stamina := 100.0
	var max_dash_cooldown := 1.0
	if tuning_resource != null:
		max_stamina = float(tuning_resource.get("max_stamina"))
		max_dash_cooldown = max(0.01, float(tuning_resource.get("dash_cooldown")))
	_on_stamina_changed(current_stamina, max_stamina)
	_on_dash_cooldown_changed(current_dash_cooldown, max_dash_cooldown)

func _on_stamina_changed(current: float, max_value: float) -> void:
	stamina_bar.max_value = max(1.0, max_value)
	stamina_bar.value = clamp(current, 0.0, stamina_bar.max_value)
	stamina_label.text = "Stamina %d / %d" % [roundi(current), roundi(max_value)]

func _on_dash_cooldown_changed(remaining: float, max_value: float) -> void:
	dash_cooldown_bar.max_value = max(0.01, max_value)
	dash_cooldown_bar.value = clamp(remaining, 0.0, dash_cooldown_bar.max_value)
	if remaining <= 0.01:
		dash_cooldown_label.text = "Dash Ready"
	else:
		dash_cooldown_label.text = "Dash CD %.2fs" % remaining
