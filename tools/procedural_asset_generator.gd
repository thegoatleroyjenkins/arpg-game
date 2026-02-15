extends SceneTree

const OUTPUT_ROOT := "res://generated_assets"
const WEAPON_DIR := OUTPUT_ROOT + "/weapons"
const PROP_DIR := OUTPUT_ROOT + "/props"
const PICKUP_DIR := OUTPUT_ROOT + "/pickups"
const CHARACTER_DIR := OUTPUT_ROOT + "/characters"

const RARITY_STYLE := {
	"common": {
		"albedo": Color("#9AA3AD"),
		"emission": Color("#000000"),
		"emission_energy": 0.0
	},
	"uncommon": {
		"albedo": Color("#6ECF7A"),
		"emission": Color("#2E7D32"),
		"emission_energy": 0.2
	},
	"rare": {
		"albedo": Color("#7AB7FF"),
		"emission": Color("#2A6BFF"),
		"emission_energy": 0.45
	}
}

func _init() -> void:
	print("[procgen] Starting procedural asset generation...")
	_ensure_dir(OUTPUT_ROOT)
	_ensure_dir(WEAPON_DIR)
	_ensure_dir(PROP_DIR)
	_ensure_dir(PICKUP_DIR)
	_ensure_dir(CHARACTER_DIR)

	_generate_weapons()
	_generate_props()
	_generate_pickups()
	_generate_characters()

	print("[procgen] Done.")
	quit()

func _generate_weapons() -> void:
	var weapon_defs := [
		{"name": "sword_short", "rarity": "common", "blade_len": 1.2, "blade_w": 0.12, "guard_w": 0.34, "handle_len": 0.52},
		{"name": "sword_knight", "rarity": "uncommon", "blade_len": 1.45, "blade_w": 0.13, "guard_w": 0.42, "handle_len": 0.58},
		{"name": "sword_arc", "rarity": "rare", "blade_len": 1.55, "blade_w": 0.10, "guard_w": 0.46, "handle_len": 0.62},
		{"name": "axe_raider", "rarity": "common", "blade_len": 0.95, "blade_w": 0.55, "guard_w": 0.18, "handle_len": 0.82},
		{"name": "axe_war", "rarity": "uncommon", "blade_len": 1.05, "blade_w": 0.62, "guard_w": 0.2, "handle_len": 0.9},
		{"name": "axe_storm", "rarity": "rare", "blade_len": 1.15, "blade_w": 0.68, "guard_w": 0.22, "handle_len": 1.0}
	]

	for def in weapon_defs:
		var root := Node3D.new()
		root.name = _pascal(def["name"])

		var style: Dictionary = RARITY_STYLE[def["rarity"]]
		var metal := _make_material(style["albedo"], style["emission"], style["emission_energy"], 0.2)
		var leather := _make_material(Color("#5E4631"), Color.BLACK, 0.0, 0.65)

		var handle := MeshInstance3D.new()
		handle.name = "Handle"
		var handle_mesh := CylinderMesh.new()
		handle_mesh.top_radius = 0.04
		handle_mesh.bottom_radius = 0.045
		handle_mesh.height = float(def["handle_len"])
		handle.mesh = handle_mesh
		handle.material_override = leather
		handle.position = Vector3(0.0, 0.0, 0.0)
		root.add_child(handle)

		var guard := MeshInstance3D.new()
		guard.name = "Guard"
		var guard_mesh := BoxMesh.new()
		guard_mesh.size = Vector3(float(def["guard_w"]), 0.05, 0.1)
		guard.mesh = guard_mesh
		guard.material_override = metal
		guard.position = Vector3(0.0, float(def["handle_len"]) * 0.5 - 0.05, 0.0)
		root.add_child(guard)

		var blade := MeshInstance3D.new()
		blade.name = "Blade"
		if String(def["name"]).begins_with("axe"):
			var axe_mesh := BoxMesh.new()
			axe_mesh.size = Vector3(float(def["blade_w"]), float(def["blade_len"]) * 0.45, 0.08)
			blade.mesh = axe_mesh
			blade.position = Vector3(float(def["blade_w"]) * 0.45, float(def["handle_len"]) * 0.45, 0.0)
		else:
			var blade_mesh := BoxMesh.new()
			blade_mesh.size = Vector3(float(def["blade_w"]), float(def["blade_len"]), 0.06)
			blade.mesh = blade_mesh
			blade.position = Vector3(0.0, float(def["handle_len"]) * 0.5 + float(def["blade_len"]) * 0.5 - 0.03, 0.0)
		blade.material_override = metal
		root.add_child(blade)

		_assign_owners(root, root)
		_save_scene(root, "%s/%s.tscn" % [WEAPON_DIR, def["name"]])

func _generate_props() -> void:
	var prop_defs := [
		{"name": "crate_oak", "type": "crate", "size": Vector3(1.0, 1.0, 1.0), "rarity": "common"},
		{"name": "crate_reinforced", "type": "crate", "size": Vector3(1.2, 1.1, 1.0), "rarity": "uncommon"},
		{"name": "pillar_stone", "type": "pillar", "height": 2.1, "radius": 0.28, "rarity": "common"},
		{"name": "pillar_ancient", "type": "pillar", "height": 2.5, "radius": 0.33, "rarity": "rare"},
		{"name": "rock_small", "type": "rock", "scale": Vector3(0.9, 0.7, 1.0), "rarity": "common"},
		{"name": "rock_large", "type": "rock", "scale": Vector3(1.4, 1.0, 1.2), "rarity": "uncommon"}
	]

	for def in prop_defs:
		var root := Node3D.new()
		root.name = _pascal(def["name"])
		var style: Dictionary = RARITY_STYLE[def["rarity"]]
		var mat := _make_material(style["albedo"].darkened(0.25), style["emission"], style["emission_energy"] * 0.2, 0.85)
		var t: String = def["type"]
		if t == "crate":
			var body := MeshInstance3D.new()
			var mesh := BoxMesh.new()
			mesh.size = def["size"]
			body.mesh = mesh
			body.material_override = mat
			root.add_child(body)

			for i in 2:
				var strap := MeshInstance3D.new()
				var strap_mesh := BoxMesh.new()
				strap_mesh.size = Vector3(def["size"].x + 0.02, 0.08, 0.08)
				strap.mesh = strap_mesh
				strap.material_override = _make_material(Color("#3A3F46"), Color.BLACK, 0.0, 0.3)
				strap.position = Vector3(0.0, -def["size"].y * 0.25 + float(i) * (def["size"].y * 0.5), def["size"].z * 0.45)
				root.add_child(strap)
		elif t == "pillar":
			var shaft := MeshInstance3D.new()
			var shaft_mesh := CylinderMesh.new()
			shaft_mesh.top_radius = float(def["radius"])
			shaft_mesh.bottom_radius = float(def["radius"]) * 1.08
			shaft_mesh.height = float(def["height"])
			shaft.mesh = shaft_mesh
			shaft.material_override = mat
			shaft.position = Vector3(0.0, float(def["height"]) * 0.5, 0.0)
			root.add_child(shaft)

			var cap := MeshInstance3D.new()
			var cap_mesh := CylinderMesh.new()
			cap_mesh.top_radius = float(def["radius"]) * 1.2
			cap_mesh.bottom_radius = float(def["radius"]) * 1.2
			cap_mesh.height = 0.16
			cap.mesh = cap_mesh
			cap.material_override = mat
			cap.position = Vector3(0.0, float(def["height"]) + 0.08, 0.0)
			root.add_child(cap)
		else:
			var rock := MeshInstance3D.new()
			var rock_mesh := SphereMesh.new()
			rock_mesh.radius = 0.55
			rock_mesh.height = 1.1
			rock.mesh = rock_mesh
			rock.material_override = mat
			rock.scale = def["scale"]
			root.add_child(rock)

		_assign_owners(root, root)
		_save_scene(root, "%s/%s.tscn" % [PROP_DIR, def["name"]])

func _generate_pickups() -> void:
	var defs := [
		{"name": "orb_common", "rarity": "common", "radius": 0.26},
		{"name": "orb_uncommon", "rarity": "uncommon", "radius": 0.29},
		{"name": "orb_rare", "rarity": "rare", "radius": 0.32}
	]
	for def in defs:
		var root := Node3D.new()
		root.name = _pascal(def["name"])
		var style: Dictionary = RARITY_STYLE[def["rarity"]]
		var core := MeshInstance3D.new()
		var core_mesh := SphereMesh.new()
		core_mesh.radius = float(def["radius"])
		core_mesh.height = float(def["radius"]) * 2.0
		core.mesh = core_mesh
		core.material_override = _make_material(style["albedo"].lightened(0.1), style["emission"], max(0.2, float(style["emission_energy"]) + 0.35), 0.15)
		root.add_child(core)

		var ring := MeshInstance3D.new()
		var ring_mesh := TorusMesh.new()
		ring_mesh.inner_radius = float(def["radius"]) * 0.9
		ring_mesh.outer_radius = float(def["radius"]) * 1.25
		ring.mesh = ring_mesh
		ring.rotation = Vector3(deg_to_rad(90.0), 0.0, 0.0)
		ring.material_override = _make_material(style["albedo"], style["emission"], max(0.2, float(style["emission_energy"]) + 0.2), 0.1)
		root.add_child(ring)

		_assign_owners(root, root)
		_save_scene(root, "%s/%s.tscn" % [PICKUP_DIR, def["name"]])

func _generate_characters() -> void:
	# Phase-1 hero placeholder: readable silhouette, simple materials, game-ready scene file.
	var root := Node3D.new()
	root.name = "PlayerKnight"

	var armor_mat := _make_material(Color("#4F5D75"), Color("#223047"), 0.1, 0.5)
	var cloth_mat := _make_material(Color("#9A3E5A"), Color.BLACK, 0.0, 0.75)
	var skin_mat := _make_material(Color("#E6C7A8"), Color.BLACK, 0.0, 0.9)
	var accent_mat := _make_material(Color("#7AB7FF"), Color("#2A6BFF"), 0.25, 0.25)

	var body := MeshInstance3D.new()
	body.name = "Body"
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.33
	body_mesh.height = 1.05
	body.mesh = body_mesh
	body.material_override = armor_mat
	body.position = Vector3(0.0, 1.15, 0.0)
	root.add_child(body)

	var head := MeshInstance3D.new()
	head.name = "Head"
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.24
	head_mesh.height = 0.48
	head.mesh = head_mesh
	head.material_override = skin_mat
	head.position = Vector3(0.0, 1.95, 0.0)
	root.add_child(head)

	var shoulder_left := MeshInstance3D.new()
	shoulder_left.name = "ShoulderLeft"
	var shoulder_mesh := SphereMesh.new()
	shoulder_mesh.radius = 0.17
	shoulder_mesh.height = 0.34
	shoulder_left.mesh = shoulder_mesh
	shoulder_left.material_override = armor_mat
	shoulder_left.position = Vector3(-0.33, 1.45, 0.0)
	root.add_child(shoulder_left)

	var shoulder_right := MeshInstance3D.new()
	shoulder_right.name = "ShoulderRight"
	shoulder_right.mesh = shoulder_mesh.duplicate()
	shoulder_right.material_override = armor_mat
	shoulder_right.position = Vector3(0.33, 1.45, 0.0)
	root.add_child(shoulder_right)

	var cape := MeshInstance3D.new()
	cape.name = "Cape"
	var cape_mesh := BoxMesh.new()
	cape_mesh.size = Vector3(0.62, 0.9, 0.06)
	cape.mesh = cape_mesh
	cape.material_override = cloth_mat
	cape.position = Vector3(0.0, 1.2, 0.24)
	root.add_child(cape)

	var chest_accent := MeshInstance3D.new()
	chest_accent.name = "ChestAccent"
	var accent_mesh := BoxMesh.new()
	accent_mesh.size = Vector3(0.2, 0.22, 0.06)
	chest_accent.mesh = accent_mesh
	chest_accent.material_override = accent_mat
	chest_accent.position = Vector3(0.0, 1.25, -0.22)
	root.add_child(chest_accent)

	_assign_owners(root, root)
	_save_scene(root, "%s/player_knight.tscn" % CHARACTER_DIR)

func _make_material(albedo: Color, emission: Color, emission_energy: float, roughness: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = albedo
	mat.roughness = clamp(roughness, 0.0, 1.0)
	mat.metallic = 0.15
	mat.emission_enabled = emission_energy > 0.001
	mat.emission = emission
	mat.emission_energy_multiplier = max(0.0, emission_energy)
	return mat

func _save_scene(root: Node, path: String) -> void:
	var packed := PackedScene.new()
	var pack_err := packed.pack(root)
	if pack_err != OK:
		push_error("[procgen] Failed to pack scene (%s): %s" % [path, pack_err])
		return
	var err := ResourceSaver.save(packed, path)
	if err != OK:
		push_error("[procgen] Failed to save scene (%s): %s" % [path, err])
	else:
		print("[procgen] Wrote: %s" % path)

func _ensure_dir(path: String) -> void:
	var err := DirAccess.make_dir_recursive_absolute(path)
	if err != OK and err != ERR_ALREADY_EXISTS:
		push_error("[procgen] Could not create directory: %s (%s)" % [path, err])

func _assign_owners(node: Node, owner: Node) -> void:
	for child in node.get_children():
		child.owner = owner
		_assign_owners(child, owner)

func _pascal(value: String) -> String:
	var parts := value.split("_", false)
	for i in parts.size():
		parts[i] = parts[i].capitalize()
	return "".join(parts)
