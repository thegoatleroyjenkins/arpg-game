extends Node
class_name StarterLevelController

@export_file("*.json") var layout_json_path: String = "res://data/levels/starter_village_layout.json"
@export var spawn_markers_root: NodePath = NodePath("../SpawnMarkers")

var level_layout: Dictionary = {}

func _ready() -> void:
	level_layout = _load_layout(layout_json_path)
	if level_layout.is_empty():
		push_warning("StarterLevelController: layout JSON failed to load: %s" % layout_json_path)
		return
	var level_name: String = str(level_layout.get("display_name", "Unknown Level"))
	print("StarterLevelController loaded: %s" % level_name)

	# Validation pass: ensure marker prefixes map to at least one marker node.
	_validate_zone_markers()

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

func _validate_zone_markers() -> void:
	var markers_root := get_node_or_null(spawn_markers_root)
	if markers_root == null:
		push_warning("StarterLevelController: SpawnMarkers root missing at %s" % spawn_markers_root)
		return

	var zones: Array = level_layout.get("zones", [])
	for zone_data in zones:
		if typeof(zone_data) != TYPE_DICTIONARY:
			continue
		var prefix: String = str(zone_data.get("scene_marker_prefix", ""))
		if prefix.is_empty():
			continue
		var found: int = 0
		for child in markers_root.get_children():
			if child is Node3D and child.name.begins_with(prefix):
				found += 1
		if found == 0:
			push_warning("StarterLevelController: No markers found for prefix '%s'" % prefix)
