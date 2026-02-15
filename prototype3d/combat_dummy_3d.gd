extends CombatActor3D

@onready var mesh: MeshInstance3D = $MeshInstance3D

var _base_scale: Vector3 = Vector3.ONE
var _hit_flash_left: float = 0.0

func _ready() -> void:
	super._ready()
	if mesh != null:
		_base_scale = mesh.scale
	damage_taken.connect(_on_damage_taken)

func _process(delta: float) -> void:
	if _hit_flash_left > 0.0:
		_hit_flash_left = max(0.0, _hit_flash_left - delta)
		if mesh != null:
			var pulse: float = 1.0 + (_hit_flash_left * 0.35)
			mesh.scale = _base_scale * pulse
	elif mesh != null and mesh.scale != _base_scale:
		mesh.scale = _base_scale

func _on_damage_taken(_amount: float, _current: float, _max_value: float) -> void:
	_hit_flash_left = 0.12
