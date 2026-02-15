extends Node
class_name SpawnDirector

signal spawn_wave_requested(chunk_id: String, entries: Array)

@export_file("*.json") var spawn_profiles_path: String = "res://data/world/spawn_profiles.json"
@export var default_enemy_archetype_id: String = "blight_husk"

var _profile_data: Dictionary = {}

func _ready() -> void:
	_profile_data = _load_profile_data(spawn_profiles_path)

func request_wilderness_wave(chunk_id: String, biome_id: String, danger_level: int) -> void:
	var entries: Array = _build_wave_from_profile(biome_id, danger_level)
	spawn_wave_requested.emit(chunk_id, entries)

func _build_wave_from_profile(biome_id: String, danger_level: int) -> Array:
	var base_count: int = clampi(1 + int(danger_level / 2), 1, 8)
	var selected_archetype_id: String = _roll_enemy_archetype_id(biome_id)
	return [
		{
			"enemy_archetype_id": selected_archetype_id,
			"count": base_count,
			"weight_context": {
				"biome": biome_id,
				"danger": danger_level,
				"spawn_profile": spawn_profiles_path,
			}
		}
	]

func _roll_enemy_archetype_id(biome_id: String) -> String:
	var biome_profiles: Dictionary = _profile_data.get("biomes", {})
	var entries_variant: Variant = biome_profiles.get(biome_id, [])
	if typeof(entries_variant) != TYPE_ARRAY:
		entries_variant = []
	var entries: Array = entries_variant as Array
	if entries.is_empty():
		entries = _profile_data.get("fallback", []) as Array
	if entries.is_empty():
		return default_enemy_archetype_id

	var total_weight: float = 0.0
	for entry_variant in entries:
		if typeof(entry_variant) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = entry_variant
		total_weight += max(0.0, float(entry.get("weight", 0.0)))
	if total_weight <= 0.0:
		return default_enemy_archetype_id

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	var roll: float = rng.randf_range(0.0, total_weight)
	var cumulative: float = 0.0
	for entry_variant in entries:
		if typeof(entry_variant) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = entry_variant
		var weight: float = max(0.0, float(entry.get("weight", 0.0)))
		if weight <= 0.0:
			continue
		cumulative += weight
		if roll <= cumulative:
			var enemy_archetype_id: String = str(entry.get("enemy_archetype_id", "")).strip_edges()
			if not enemy_archetype_id.is_empty():
				return enemy_archetype_id
	return default_enemy_archetype_id

func _load_profile_data(path: String) -> Dictionary:
	if path.is_empty() or not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed as Dictionary
