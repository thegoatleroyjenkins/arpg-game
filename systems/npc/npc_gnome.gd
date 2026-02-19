extends CharacterBody3D
class_name NpcGnome

## Gnome — The Garden's keeper and quest-giver.
## Stands in the Market Square and initiates the first quest chain
## for new players arriving from the Ashfall Outskirts.
##
## Usage: set_meta("npc_data", <dict>) and set_meta("level_controller", <TheGardenLevelController>)
## before _ready() fires (done automatically by TheGardenLevelController._build_npc_node).

const INTERACTION_RADIUS: float = 2.5
const IDLE_BOB_SPEED: float = 0.8
const IDLE_BOB_AMPLITUDE: float = 0.04

var _npc_data: Dictionary = {}
var _level_controller: Node = null
var _base_y: float = 0.0
var _time_acc: float = 0.0
var _player_in_range: bool = false

# Interaction area — triggers when player enters.
var _interaction_area: Area3D = null

func _ready() -> void:
	if has_meta("npc_data"):
		_npc_data = get_meta("npc_data")
	if has_meta("level_controller"):
		_level_controller = get_meta("level_controller")

	_base_y = position.y
	_setup_interaction_area()
	print("NpcGnome: ready at %s" % global_position)

func _setup_interaction_area() -> void:
	_interaction_area = Area3D.new()
	_interaction_area.name = "InteractionArea"
	add_child(_interaction_area)

	var col := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = INTERACTION_RADIUS
	col.shape = sphere
	col.position = Vector3(0, 0.9, 0)
	_interaction_area.add_child(col)

	_interaction_area.body_entered.connect(_on_body_entered)
	_interaction_area.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	# Gentle idle bob so Gnome doesn't look completely static.
	_time_acc += delta * IDLE_BOB_SPEED
	position.y = _base_y + sin(_time_acc) * IDLE_BOB_AMPLITUDE

func _input(event: InputEvent) -> void:
	if not _player_in_range:
		return
	# "ui_accept" (default: Enter/Space) triggers dialogue.
	if event.is_action_pressed("ui_accept"):
		_interact()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		# TODO: show interaction prompt UI here.
		print("NpcGnome: player entered interaction radius")

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		print("NpcGnome: player left interaction radius")

func _interact() -> void:
	if _level_controller != null and _level_controller.has_method("request_gnome_interaction"):
		_level_controller.request_gnome_interaction()
	else:
		# Fallback: print dialogue snippet if no level controller is wired.
		_play_fallback_dialogue()

func _play_fallback_dialogue() -> void:
	var dialogue_lines: Array = [
		"Gnome: 'You've found The Garden. Few do by accident.'",
		"Gnome: 'There are tasks for the willing. Return when you're ready.'",
		"Gnome: 'The Marches remember those who act — and those who hesitate.'",
	]
	print(dialogue_lines[randi() % dialogue_lines.size()])

## Returns this NPC's id string.
func get_npc_id() -> String:
	return str(_npc_data.get("id", "gnome"))

## Returns display name.
func get_display_name() -> String:
	return str(_npc_data.get("display_name", "Gnome"))
