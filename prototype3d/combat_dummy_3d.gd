extends CombatActor3D

@onready var mesh: MeshInstance3D = $MeshInstance3D

@export_group("Dummy Feedback")
@export var hit_flash_duration: float = 0.12
@export var hit_flash_scale_bonus: float = 0.35

@export_group("Health Readout")
@export var health_label_height: float = 1.6
@export var health_label_visible_time_on_hit: float = 1.5
@export var health_label_show_when_full: bool = false
@export var health_label_text_size: int = 28
@export var health_label_color_high: Color = Color(0.45, 0.95, 0.55, 1.0)
@export var health_label_color_mid: Color = Color(0.95, 0.85, 0.35, 1.0)
@export var health_label_color_low: Color = Color(1.0, 0.38, 0.34, 1.0)

@export_group("Damage Readout")
@export var damage_popup_enabled: bool = true
@export var damage_popup_height: float = 1.2
@export var damage_popup_rise_distance: float = 0.45
@export var damage_popup_duration: float = 0.5
@export var damage_popup_pixel_size: float = 0.006
@export var damage_popup_text_size: int = 30
@export var damage_popup_color: Color = Color(1.0, 0.52, 0.3, 1.0)

var _base_scale: Vector3 = Vector3.ONE
var _hit_flash_left: float = 0.0
var _health_label_visible_left: float = 0.0
var _health_label: Label3D = null
var _damage_popups: Array[Dictionary] = []

func _ready() -> void:
	super._ready()
	if mesh != null:
		_base_scale = mesh.scale
	_create_health_label()
	damage_taken.connect(_on_damage_taken)
	health_changed.connect(_on_health_changed)
	_update_health_label(current_health, max_health)

func _process(delta: float) -> void:
	_update_hit_flash(delta)
	_update_health_label_visibility(delta)
	_face_health_label_to_camera()
	_update_damage_popups(delta)

func _update_hit_flash(delta: float) -> void:
	if _hit_flash_left > 0.0:
		_hit_flash_left = max(0.0, _hit_flash_left - delta)
		if mesh != null:
			var normalized: float = 0.0
			if hit_flash_duration > 0.0:
				normalized = _hit_flash_left / hit_flash_duration
			var pulse: float = 1.0 + (normalized * max(0.0, hit_flash_scale_bonus))
			mesh.scale = _base_scale * pulse
	elif mesh != null and mesh.scale != _base_scale:
		mesh.scale = _base_scale

func _update_health_label_visibility(delta: float) -> void:
	if _health_label == null:
		return
	if _health_label_visible_left > 0.0:
		_health_label_visible_left = max(0.0, _health_label_visible_left - delta)
		_health_label.visible = true
		return
	if health_label_show_when_full:
		_health_label.visible = true
		return
	var full_health: bool = current_health >= max_health - 0.001
	_health_label.visible = not full_health

func _create_health_label() -> void:
	if _health_label != null:
		return
	_health_label = Label3D.new()
	_health_label.name = "HealthLabel3D"
	_health_label.position = Vector3(0.0, health_label_height, 0.0)
	_health_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_health_label.font_size = max(12, health_label_text_size)
	_health_label.modulate = health_label_color_high
	_health_label.pixel_size = 0.0055
	_health_label.outline_size = 6
	_health_label.no_depth_test = true
	_health_label.visible = health_label_show_when_full
	add_child(_health_label)

func _face_health_label_to_camera() -> void:
	if _health_label == null or not _health_label.visible:
		return
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return
	_health_label.look_at(camera.global_position, Vector3.UP, true)

func _on_damage_taken(amount: float, _current: float, _max_value: float) -> void:
	_hit_flash_left = max(0.0, hit_flash_duration)
	_health_label_visible_left = max(_health_label_visible_left, health_label_visible_time_on_hit)
	_spawn_damage_popup(amount)

func _on_health_changed(current: float, max_value: float) -> void:
	_update_health_label(current, max_value)

func _update_health_label(current: float, max_value: float) -> void:
	if _health_label == null:
		return
	var safe_max: float = max(1.0, max_value)
	var ratio: float = clamp(current / safe_max, 0.0, 1.0)
	_health_label.text = "Dummy HP %d%%" % int(round(ratio * 100.0))
	if ratio <= 0.3:
		_health_label.modulate = health_label_color_low
	elif ratio <= 0.65:
		_health_label.modulate = health_label_color_mid
	else:
		_health_label.modulate = health_label_color_high

func _spawn_damage_popup(amount: float) -> void:
	if not damage_popup_enabled:
		return
	if damage_popup_duration <= 0.0:
		return
	var popup: Label3D = Label3D.new()
	popup.name = "DamagePopup3D"
	popup.text = "-%d" % int(round(max(0.0, amount)))
	popup.position = Vector3(0.0, damage_popup_height, 0.0)
	popup.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	popup.font_size = max(12, damage_popup_text_size)
	popup.pixel_size = max(0.001, damage_popup_pixel_size)
	popup.outline_size = 6
	popup.no_depth_test = true
	popup.modulate = damage_popup_color
	add_child(popup)
	_damage_popups.append({
		"node": popup,
		"time_left": damage_popup_duration,
		"start_y": popup.position.y,
	})

func _update_damage_popups(delta: float) -> void:
	if _damage_popups.is_empty():
		return
	var camera: Camera3D = get_viewport().get_camera_3d()
	for i in range(_damage_popups.size() - 1, -1, -1):
		var entry: Dictionary = _damage_popups[i]
		var popup: Label3D = entry.get("node") as Label3D
		if popup == null or not is_instance_valid(popup):
			_damage_popups.remove_at(i)
			continue
		var time_left: float = max(0.0, float(entry.get("time_left", 0.0)) - delta)
		entry["time_left"] = time_left
		var normalized: float = 1.0
		if damage_popup_duration > 0.0:
			normalized = clamp(1.0 - (time_left / damage_popup_duration), 0.0, 1.0)
		var start_y: float = float(entry.get("start_y", damage_popup_height))
		popup.position.y = start_y + (damage_popup_rise_distance * normalized)
		var alpha: float = 1.0 - normalized
		var tint: Color = damage_popup_color
		tint.a *= alpha
		popup.modulate = tint
		if camera != null:
			popup.look_at(camera.global_position, Vector3.UP, true)
		if time_left <= 0.0:
			popup.queue_free()
			_damage_popups.remove_at(i)
		else:
			_damage_popups[i] = entry
