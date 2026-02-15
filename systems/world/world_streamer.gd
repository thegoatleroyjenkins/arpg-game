extends Node
class_name WorldStreamer

@export var player_path: NodePath
@export_file("*.json") var world_layout_json: String = "res://data/world/world_map_layout.json"
@export var chunk_size_meters: float = 256.0
@export var active_radius_chunks: int = 1
@export var preload_radius_chunks: int = 2
@export var unload_hysteresis_seconds: float = 6.0

signal chunk_should_load(chunk_id: String)
signal chunk_should_unload(chunk_id: String)

var _layout: Dictionary = {}
var _loaded_chunks: Dictionary = {}
var _last_seen_seconds: Dictionary = {}

func _ready() -> void:
	_layout = _load_layout(world_layout_json)
	set_process(true)

func _process(_delta: float) -> void:
	var player := get_node_or_null(player_path) as Node3D
	if player == null:
		return
	var player_chunk := _world_to_chunk(player.global_position)
	var now: float = Time.get_unix_time_from_system()
	for x in range(player_chunk.x - preload_radius_chunks, player_chunk.x + preload_radius_chunks + 1):
		for y in range(player_chunk.y - preload_radius_chunks, player_chunk.y + preload_radius_chunks + 1):
			var chunk_id := _chunk_id_at(x, y)
			if chunk_id.is_empty():
				continue
			_last_seen_seconds[chunk_id] = now
			if not _loaded_chunks.has(chunk_id):
				_loaded_chunks[chunk_id] = true
				chunk_should_load.emit(chunk_id)

	for chunk_id in _loaded_chunks.keys():
		var last_seen: float = float(_last_seen_seconds.get(chunk_id, 0.0))
		if now - last_seen >= unload_hysteresis_seconds:
			_loaded_chunks.erase(chunk_id)
			_last_seen_seconds.erase(chunk_id)
			chunk_should_unload.emit(chunk_id)

func _load_layout(path: String) -> Dictionary:
	if path.is_empty() or not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed := JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	var stream_data: Dictionary = parsed.get("streaming", {})
	if not stream_data.is_empty():
		active_radius_chunks = int(stream_data.get("active_radius_chunks", active_radius_chunks))
		preload_radius_chunks = int(stream_data.get("preload_radius_chunks", preload_radius_chunks))
		unload_hysteresis_seconds = float(stream_data.get("unload_hysteresis_seconds", unload_hysteresis_seconds))
	if parsed.has("chunk_size_meters"):
		chunk_size_meters = float(parsed.get("chunk_size_meters", chunk_size_meters))
	return parsed

func _world_to_chunk(pos: Vector3) -> Vector2i:
	var size := max(1.0, chunk_size_meters)
	return Vector2i(floori(pos.x / size), floori(pos.z / size))

func _chunk_id_at(grid_x: int, grid_y: int) -> String:
	# Placeholder lookup. In production, resolve against DB world_chunk table.
	return "chunk_%d_%d" % [grid_x, grid_y]
