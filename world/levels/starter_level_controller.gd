extends Node
class_name StarterLevelController

@export_file("*.json") var layout_json_path: String = "res://data/levels/starter_village_layout.json"
@export var spawn_markers_root: NodePath = NodePath("../SpawnMarkers")

var level_layout: Dictionary = {}
var _zone_data_by_id: Dictionary = {}
var _zone_markers_by_id: Dictionary = {}

func _ready() -> void:
	level_layout = _load_layout(layout_json_path)
	if level_layout.is_empty():
		push_warning("StarterLevelController: layout JSON failed to load: %s" % layout_json_path)
		return
	var level_name: String = str(level_layout.get("display_name", "Unknown Level"))
	print("StarterLevelController loaded: %s" % level_name)

	# Validation + cache pass so gameplay systems can query zone marker groups.
	_rebuild_zone_caches()

func _load_layout(path: String) -> Dictionary:
	if path.is_empty() or not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var text: String = file.get_as_text()
	var parsed := JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed

func _rebuild_zone_caches() -> void:
	_zone_data_by_id.clear()
	_zone_markers_by_id.clear()

	var markers_root := get_node_or_null(spawn_markers_root)
	if markers_root == null:
		push_warning("StarterLevelController: SpawnMarkers root missing at %s" % spawn_markers_root)
		return

	var zones: Array = level_layout.get("zones", [])
	for zone_data in zones:
		if typeof(zone_data) != TYPE_DICTIONARY:
			continue
		var zone_id: String = str(zone_data.get("id", "")).strip_edges()
		if zone_id.is_empty():
			push_warning("StarterLevelController: Zone entry missing id")
			continue

		_zone_data_by_id[zone_id] = zone_data
		var prefix: String = str(zone_data.get("scene_marker_prefix", ""))
		var marker_nodes: Array[Node3D] = _find_markers_by_prefix(markers_root, prefix)
		_zone_markers_by_id[zone_id] = marker_nodes.duplicate()
		if marker_nodes.is_empty():
			push_warning("StarterLevelController: No markers found for zone '%s' prefix '%s'" % [zone_id, prefix])

func _find_markers_by_prefix(markers_root: Node, prefix: String) -> Array[Node3D]:
	var nodes: Array[Node3D] = []
	if prefix.is_empty():
		return nodes

	_collect_markers_by_prefix_recursive(markers_root, prefix, nodes)
	return nodes

func _collect_markers_by_prefix_recursive(root: Node, prefix: String, out_nodes: Array[Node3D]) -> void:
	for child in root.get_children():
		if child is Node3D and child.name.begins_with(prefix):
			out_nodes.append(child as Node3D)
		_collect_markers_by_prefix_recursive(child, prefix, out_nodes)

func get_zone_data(zone_id: String) -> Dictionary:
	var normalized_id := zone_id.strip_edges()
	if normalized_id.is_empty():
		return {}
	if not _zone_data_by_id.has(normalized_id):
		return {}
	return _zone_data_by_id[normalized_id]

func get_zone_marker_nodes(zone_id: String) -> Array[Node3D]:
	var normalized_id := zone_id.strip_edges()
	var result: Array[Node3D] = []
	if normalized_id.is_empty():
		return result
	if not _zone_markers_by_id.has(normalized_id):
		return result
	var stored_markers: Array = _zone_markers_by_id[normalized_id]
	for marker in stored_markers:
		if marker is Node3D:
			result.append(marker)
	return result

func get_random_zone_marker(zone_id: String, rng: RandomNumberGenerator = null) -> Node3D:
	var markers := get_zone_marker_nodes(zone_id)
	if markers.is_empty():
		return null

	var local_rng := rng
	if local_rng == null:
		local_rng = RandomNumberGenerator.new()
		local_rng.randomize()

	var index := local_rng.randi_range(0, markers.size() - 1)
	return markers[index]
