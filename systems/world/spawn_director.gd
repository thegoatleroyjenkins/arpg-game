extends Node
class_name SpawnDirector

signal spawn_wave_requested(chunk_id: String, entries: Array)

# Stub contract for biome/faction/event driven spawning.
func request_wilderness_wave(chunk_id: String, biome_id: String, danger_level: int) -> void:
	var entries: Array = _build_stub_wave(biome_id, danger_level)
	spawn_wave_requested.emit(chunk_id, entries)

func _build_stub_wave(biome_id: String, danger_level: int) -> Array:
	var base_count: int = clampi(1 + int(danger_level / 2), 1, 6)
	return [
		{
			"enemy_archetype_id": "bandit_raider" if biome_id == "ashwood_frontier" else "blight_husk",
			"count": base_count,
			"weight_context": {"biome": biome_id, "danger": danger_level}
		}
	]
