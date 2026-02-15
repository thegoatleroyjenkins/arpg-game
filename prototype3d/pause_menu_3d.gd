extends CanvasLayer

@export var player_path: NodePath = NodePath("../Player")
@export var hud_path: NodePath = NodePath("../StaminaHud")

@onready var panel: PanelContainer = $CenterContainer/PanelContainer
@onready var sensitivity_slider: HSlider = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SensitivityRow/SensitivitySlider
@onready var sensitivity_value_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SensitivityRow/SensitivityValue
@onready var fullscreen_toggle: CheckButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/FullscreenToggle
@onready var invert_y_toggle: CheckButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/InvertYToggle
@onready var hud_toggle: CheckButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HudToggle
@onready var mouse_capture_toggle: CheckButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MouseCaptureToggle
@onready var resume_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonRow/ResumeButton
@onready var quit_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonRow/QuitButton

var _player: Node = null
var _hud: CanvasLayer = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = true
	panel.visible = false
	_player = get_node_or_null(player_path)
	_hud = get_node_or_null(hud_path) as CanvasLayer

	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	invert_y_toggle.toggled.connect(_on_invert_y_toggled)
	hud_toggle.toggled.connect(_on_hud_toggled)
	mouse_capture_toggle.toggled.connect(_on_mouse_capture_toggled)

	_sync_from_state()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if get_tree().paused:
		_close_menu()
	else:
		_open_menu()
	get_viewport().set_input_as_handled()

func _open_menu() -> void:
	get_tree().paused = true
	panel.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_sync_from_state()

func _close_menu() -> void:
	get_tree().paused = false
	panel.visible = false
	if mouse_capture_toggle.button_pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _sync_from_state() -> void:
	if _player != null:
		var tuning: Resource = _player.get("tuning")
		if tuning != null and tuning.has_method("get"):
			var sensitivity: float = float(tuning.get("camera_orbit_sensitivity"))
			sensitivity_slider.value = clamp(sensitivity, sensitivity_slider.min_value, sensitivity_slider.max_value)
			_update_sensitivity_label(sensitivity_slider.value)
			invert_y_toggle.button_pressed = bool(tuning.get("camera_orbit_invert_y"))
	else:
		_update_sensitivity_label(sensitivity_slider.value)

	fullscreen_toggle.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	if _hud != null:
		hud_toggle.button_pressed = _hud.visible
	mouse_capture_toggle.button_pressed = Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED

func _on_resume_pressed() -> void:
	_close_menu()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_sensitivity_changed(value: float) -> void:
	_update_sensitivity_label(value)
	if _player == null:
		return
	var tuning: Resource = _player.get("tuning")
	if tuning != null:
		tuning.set("camera_orbit_sensitivity", value)

func _update_sensitivity_label(value: float) -> void:
	sensitivity_value_label.text = "%.2f" % value

func _on_fullscreen_toggled(enabled: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)

func _on_invert_y_toggled(enabled: bool) -> void:
	if _player == null:
		return
	var tuning: Resource = _player.get("tuning")
	if tuning != null:
		tuning.set("camera_orbit_invert_y", enabled)

func _on_hud_toggled(enabled: bool) -> void:
	if _hud != null:
		_hud.visible = enabled

func _on_mouse_capture_toggled(enabled: bool) -> void:
	if not get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if enabled else Input.MOUSE_MODE_VISIBLE)
