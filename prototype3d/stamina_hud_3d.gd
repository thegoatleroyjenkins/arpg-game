extends CanvasLayer

@export var player_path: NodePath = NodePath("../Player")

@onready var stamina_bar: ProgressBar = $MarginContainer/VBoxContainer/StaminaBar
@onready var stamina_label: Label = $MarginContainer/VBoxContainer/StaminaLabel

func _ready() -> void:
	var player := get_node_or_null(player_path)
	if player == null:
		push_warning("StaminaHud3D could not find player at path: %s" % player_path)
		return

	if not player.has_signal("stamina_changed"):
		push_warning("StaminaHud3D target does not expose stamina_changed signal")
		return

	player.stamina_changed.connect(_on_stamina_changed)
	var current_stamina := float(player.get("stamina"))
	var tuning_resource: Resource = player.get("tuning")
	var max_stamina := 100.0
	if tuning_resource != null:
		max_stamina = float(tuning_resource.get("max_stamina"))
	_on_stamina_changed(current_stamina, max_stamina)

func _on_stamina_changed(current: float, max_value: float) -> void:
	stamina_bar.max_value = max(1.0, max_value)
	stamina_bar.value = clamp(current, 0.0, stamina_bar.max_value)
	stamina_label.text = "Stamina %d / %d" % [roundi(current), roundi(max_value)]
