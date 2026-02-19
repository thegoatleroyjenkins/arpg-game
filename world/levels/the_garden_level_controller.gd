extends Node
class_name TheGardenLevelController

## City hub controller for The Garden.
## Handles NPC spawning, district activation, and travel gateway wiring.
## The Garden is always a safe zone — no enemy encounters.

@export_file("*.json") var layout_json_path: String = "res://data/levels/the_garden_layout.json"
@export var npc_root_path: NodePath = NodePath("../NPCs")
@export var interactables_root_path: NodePath = NodePath("../Interactables")

var level_layout: Dictionary = {}
var _district_data_by_id: Dictionary = {}
var _npc_data_by_id: Dictionary = {}
var _travel_connections_by_id: Dictionary = {}

# Emitted when the player interacts with the Gnome NPC.
signal gnome_interaction_requested(npc_data: Dictionary)
# Emitted when the player activates a travel gate.
signal travel_requested(connection_id: String, target_level: String, target_marker: String)

func _ready() -> void:
	level_layout = _load_layout(layout_json_path)
	if level_layout.is_empty():
		push_warning("TheGardenLevelController: layout JSON failed to load: %s" % layout_json_path)
		return

	var city_name: String = str(level_layout.get("display_name", "The Garden"))
	print("TheGardenLevelController loaded: %s" % city_name)

	_cache_district_data()
	_cache_npc_data()
	_cache_travel_connections()
	_spawn_npcs()

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

func _cache_district_data() -> void:
	_district_data_by_id.clear()
	for district_variant in level_layout.get("districts", []):
		if typeof(district_variant) != TYPE_DICTIONARY:
			continue
		var district: Dictionary = district_variant
		var district_id: String = str(district.get("id", "")).strip_edges()
		if district_id.is_empty():
			continue
		_district_data_by_id[district_id] = district

func _cache_npc_data() -> void:
	_npc_data_by_id.clear()
	for npc_variant in level_layout.get("npcs", []):
		if typeof(npc_variant) != TYPE_DICTIONARY:
			continue
		var npc: Dictionary = npc_variant
		var npc_id: String = str(npc.get("id", "")).strip_edges()
		if npc_id.is_empty():
			continue
		_npc_data_by_id[npc_id] = npc

func _cache_travel_connections() -> void:
	_travel_connections_by_id.clear()
	for conn_variant in level_layout.get("travel_connections", []):
		if typeof(conn_variant) != TYPE_DICTIONARY:
			continue
		var conn: Dictionary = conn_variant
		var conn_id: String = str(conn.get("id", "")).strip_edges()
		if conn_id.is_empty():
			continue
		_travel_connections_by_id[conn_id] = conn

func _spawn_npcs() -> void:
	var npc_root := get_node_or_null(npc_root_path) as Node3D
	if npc_root == null:
		push_warning("TheGardenLevelController: NPCs root missing at %s" % npc_root_path)
		return

	for npc_id in _npc_data_by_id:
		var npc_data: Dictionary = _npc_data_by_id[npc_id]
		var marker_name: String = str(npc_data.get("scene_marker", ""))
		if marker_name.is_empty():
			continue

		var marker := _find_marker_in_scene(marker_name)
		if marker == null:
			push_warning("TheGardenLevelController: NPC spawn marker '%s' not found for NPC '%s'" % [marker_name, npc_id])
			continue

		var npc_node := _build_npc_node(npc_id, npc_data)
		if npc_node != null:
			npc_node.global_position = marker.global_position
			npc_root.add_child(npc_node)
			print("TheGardenLevelController: Spawned NPC '%s' at %s" % [npc_id, marker.global_position])

func _build_npc_node(npc_id: String, npc_data: Dictionary) -> Node3D:
	# Placeholder NPC: CharacterBody3D with a CollisionShape3D + MeshInstance3D.
	# Replace with a proper NPC scene instance when character assets are ready.
	var body := CharacterBody3D.new()
	body.name = "NPC_" + npc_id

	var col_shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.8
	col_shape.shape = capsule
	col_shape.position = Vector3(0, 0.9, 0)
	body.add_child(col_shape)

	var mesh_inst := MeshInstance3D.new()
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = 0.4
	capsule_mesh.height = 1.8
	mesh_inst.mesh = capsule_mesh
	mesh_inst.position = Vector3(0, 0.9, 0)
	body.add_child(mesh_inst)

	# Attach NPC script if available.
	var npc_script: GDScript = load("res://systems/npc/npc_gnome.gd") if npc_id == "gnome" else null
	if npc_script != null:
		body.set_script(npc_script)
		body.set_meta("npc_data", npc_data)
		body.set_meta("level_controller", self)
	else:
		body.set_meta("npc_data", npc_data)

	return body

func _find_marker_in_scene(marker_name: String) -> Marker3D:
	return _find_marker_recursive(get_parent(), marker_name)

func _find_marker_recursive(node: Node, marker_name: String) -> Marker3D:
	if node is Marker3D and node.name == marker_name:
		return node as Marker3D
	for child in node.get_children():
		var result := _find_marker_recursive(child, marker_name)
		if result != null:
			return result
	return null

## Returns data dictionary for a named district, or empty if not found.
func get_district_data(district_id: String) -> Dictionary:
	return _district_data_by_id.get(district_id.strip_edges(), {})

## Returns data for a named NPC, or empty if not found.
func get_npc_data(npc_id: String) -> Dictionary:
	return _npc_data_by_id.get(npc_id.strip_edges(), {})

## Returns travel connection data by id.
func get_travel_connection(connection_id: String) -> Dictionary:
	return _travel_connections_by_id.get(connection_id.strip_edges(), {})

## Called by interaction system when player activates a travel gate.
func request_travel(connection_id: String) -> void:
	var conn: Dictionary = get_travel_connection(connection_id)
	if conn.is_empty():
		push_warning("TheGardenLevelController: Unknown travel connection '%s'" % connection_id)
		return
	travel_requested.emit(
		connection_id,
		str(conn.get("target_level", "")),
		str(conn.get("target_marker", ""))
	)

## Called by interaction system when player talks to the Gnome NPC.
func request_gnome_interaction() -> void:
	var gnome_data := get_npc_data("gnome")
	if gnome_data.is_empty():
		push_warning("TheGardenLevelController: Gnome NPC data not found")
		return
	gnome_interaction_requested.emit(gnome_data)
