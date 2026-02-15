extends Node
class_name WorldSector

@export var chunk_id: String = ""
@export var biome_id: String = ""

var is_loaded: bool = false
var last_activated_unix: int = 0

func activate_sector() -> void:
	is_loaded = true
	last_activated_unix = Time.get_unix_time_from_system()
	set_process(true)

func deactivate_sector() -> void:
	is_loaded = false
	set_process(false)

func get_sector_state() -> Dictionary:
	return {
		"chunk_id": chunk_id,
		"biome_id": biome_id,
		"is_loaded": is_loaded,
		"last_activated_unix": last_activated_unix
	}
