extends Node3D

@export_file("*.json") var world_layout_json: String = "res://data/world/world_map_layout.json"
@export var chunk_root_path: NodePath = NodePath("../ChunkRoot")
@export var world_streamer_path: NodePath = NodePath("../WorldStreamer")

var _chunk_nodes: Dictionary = {}

func _ready() -> void:
	var chunk_root := get_node_or_null(chunk_root_path) as Node3D
	if chunk_root == null:
		push_warning("OpenWorldLevelController: ChunkRoot not found.")
		return
	
	var layout := _load_layout(world_layout_json)
	if layout.is_empty():
		push_warning("OpenWorldLevelController: layout missing/invalid: %s" % world_layout_json)
		return
	
	var chunk_size: float = float(layout.get("chunk_size_meters", 256.0))
	var biome_color_by_id := _build_biome_color_map(layout)
	
	for chunk_variant in layout.get("chunks", []):
		if typeof(chunk_variant) != TYPE_DICTIONARY:
			continue
		var chunk: Dictionary = chunk_variant
		var chunk_id: String = str(chunk.get("id", "")).strip_edges()
		if chunk_id.is_empty():
			continue
		var grid_x := int(chunk.get("grid_x", 0))
		var grid_y := int(chunk.get("grid_y", 0))
		var biome_id := str(chunk.get("biome", ""))
		var biome_color: Color = biome_color_by_id.get(biome_id, Color(0.2, 0.25, 0.2))
		
		var chunk_node := _create_chunk_node(chunk_id, grid_x, grid_y, chunk_size, biome_color)
		chunk_root.add_child(chunk_node)
		_chunk_nodes[chunk_id] = chunk_node
	
	_wire_streaming_signals()

func _load_layout(path: String) -> Dictionary:
	if path.is_empty() or not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed

func _build_biome_color_map(layout: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for biome_variant in layout.get("biomes", []):
		if typeof(biome_variant) != TYPE_DICTIONARY:
			continue
		var biome: Dictionary = biome_variant
		var biome_id: String = str(biome.get("id", "")).strip_edges()
		if biome_id.is_empty():
			continue
		var color_hint: String = str(biome.get("color_hint", "#445566"))
		result[biome_id] = Color(color_hint)
	return result

func _create_chunk_node(chunk_id: String, grid_x: int, grid_y: int, chunk_size: float, biome_color: Color) -> Node3D:
	var chunk_node := Node3D.new()
	chunk_node.name = chunk_id
	chunk_node.position = Vector3(float(grid_x) * chunk_size, 0.0, float(grid_y) * chunk_size)
	
	var ground_body := StaticBody3D.new()
	ground_body.name = "Ground"
	chunk_node.add_child(ground_body)
	
	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(chunk_size, 1.0, chunk_size)
	collision.shape = box_shape
	collision.position = Vector3(chunk_size * 0.5, -0.5, chunk_size * 0.5)
	ground_body.add_child(collision)
	
	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(chunk_size, 1.0, chunk_size)
	mesh_instance.mesh = box_mesh
	mesh_instance.position = Vector3(chunk_size * 0.5, -0.5, chunk_size * 0.5)
	
	var mat := StandardMaterial3D.new()
	mat.albedo_color = biome_color.darkened(0.15)
	mat.roughness = 0.95
	mesh_instance.material_override = mat
	ground_body.add_child(mesh_instance)
	
	_add_chunk_props(chunk_node, chunk_id, chunk_size)
	return chunk_node

func _add_chunk_props(chunk_node: Node3D, chunk_id: String, chunk_size: float) -> void:
	var prop_paths := [
		"res://generated_assets/props/crate_oak.tscn",
		"res://generated_assets/props/crate_reinforced.tscn",
		"res://generated_assets/props/pillar_stone.tscn",
		"res://generated_assets/props/rock_small.tscn",
		"res://generated_assets/props/rock_large.tscn"
	]
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = abs(hash(chunk_id))
	var count: int = 8
	for i in count:
		var path: String = prop_paths[rng.randi_range(0, prop_paths.size() - 1)]
		var scene: PackedScene = load(path) as PackedScene
		if scene == null:
			continue
		var prop: Node3D = scene.instantiate() as Node3D
		if prop == null:
			continue
		prop.position = Vector3(
			rng.randf_range(10.0, chunk_size - 10.0),
			0.0,
			rng.randf_range(10.0, chunk_size - 10.0)
		)
		prop.rotation.y = rng.randf_range(0.0, TAU)
		var scale_jitter: float = rng.randf_range(0.85, 1.35)
		prop.scale = Vector3.ONE * scale_jitter
		chunk_node.add_child(prop)

func _wire_streaming_signals() -> void:
	var streamer: Node = get_node_or_null(world_streamer_path)
	if streamer == null:
		return
	if streamer.has_signal("chunk_should_load"):
		streamer.chunk_should_load.connect(_on_chunk_should_load)
	if streamer.has_signal("chunk_should_unload"):
		streamer.chunk_should_unload.connect(_on_chunk_should_unload)

func _on_chunk_should_load(chunk_id: String) -> void:
	var chunk: Variant = _chunk_nodes.get(chunk_id)
	if chunk is Node3D:
		chunk.visible = true

func _on_chunk_should_unload(chunk_id: String) -> void:
	var chunk: Variant = _chunk_nodes.get(chunk_id)
	if chunk is Node3D:
		chunk.visible = false
