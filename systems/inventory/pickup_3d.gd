## Pickup3D — a world item the 3D player can walk over to collect.
## Adds itself to the Inventory autoload; handles overflow feedback.
class_name Pickup3D
extends Area3D

@export var item_id:      String                = "health_potion"
@export var item_name:    String                = "Health Potion"
@export var item_type:    InventoryItem.ItemType = InventoryItem.ItemType.CONSUMABLE
@export var rarity:       InventoryItem.Rarity   = InventoryItem.Rarity.COMMON
@export var quantity:     int = 1
@export var max_stack:    int = 10
@export var heal_amount:  int = 0
@export var damage_bonus:  int = 0
@export var defense_bonus: int = 0
@export var health_bonus:  int = 0
@export var description:  String = ""

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var label_3d:      Label3D        = $Label3D if has_node("Label3D") else null

var _bob_offset: float = 0.0
var _collected: bool   = false

func _ready() -> void:
	add_to_group("pickups_3d")
	body_entered.connect(_on_body_entered)
	_apply_rarity_color()
	_start_bob()

func _process(delta: float) -> void:
	if _collected:
		return
	# gentle bob
	_bob_offset += delta * 1.8
	if is_instance_valid(mesh_instance):
		mesh_instance.position.y = sin(_bob_offset) * 0.08
	# gentle spin
	if is_instance_valid(mesh_instance):
		mesh_instance.rotation.y += delta * 1.2

func _on_body_entered(body: Node3D) -> void:
	if _collected:
		return
	if not body.is_in_group("player_3d"):
		return
	_collected = true

	var inv: Node = get_node_or_null("/root/Inventory")
	if inv == null:
		push_warning("Pickup3D: Inventory autoload not found — item lost.")
		queue_free()
		return

	var item := _build_item()
	var ok    := inv.add_item(item) as bool
	if not ok:
		# inventory full — drop back on ground (re-enable for next pass)
		_collected = false
		# show brief "full" indicator
		if is_instance_valid(label_3d):
			label_3d.text = "Bag full!"
			await get_tree().create_timer(1.5).timeout
			if is_instance_valid(label_3d):
				label_3d.text = item_name
		return

	queue_free()

func _build_item() -> InventoryItem:
	var item            := InventoryItem.new()
	item.item_id        = item_id
	item.item_name      = item_name
	item.item_type      = item_type
	item.rarity         = rarity
	item.quantity       = quantity
	item.max_stack      = max_stack
	item.heal_amount    = heal_amount
	item.damage_bonus   = damage_bonus
	item.defense_bonus  = defense_bonus
	item.health_bonus   = health_bonus
	item.description    = description
	return item

func _apply_rarity_color() -> void:
	if not is_instance_valid(mesh_instance):
		return
	var col: Color
	match rarity:
		InventoryItem.Rarity.COMMON:    col = Color(0.85, 0.85, 0.85)
		InventoryItem.Rarity.UNCOMMON:  col = Color(0.3,  0.9,  0.3)
		InventoryItem.Rarity.RARE:      col = Color(0.3,  0.5,  1.0)
		InventoryItem.Rarity.EPIC:      col = Color(0.7,  0.2,  1.0)
		InventoryItem.Rarity.LEGENDARY: col = Color(1.0,  0.65, 0.1)
		_: col = Color.WHITE
	mesh_instance.modulate = col

func _start_bob() -> void:
	if not is_instance_valid(mesh_instance):
		return
	var tween := create_tween().set_loops()
	tween.tween_property(mesh_instance, "position:y",  0.12, 0.9).set_trans(Tween.TRANS_SINE)
	tween.tween_property(mesh_instance, "position:y", -0.12, 0.9).set_trans(Tween.TRANS_SINE)

## Convenience factory to spawn a pickup at a world position.
static func spawn_at(
		parent: Node,
		pos: Vector3,
		id: String,
		name: String,
		type: InventoryItem.ItemType,
		rar: InventoryItem.Rarity = InventoryItem.Rarity.COMMON,
		qty: int = 1) -> Pickup3D:
	var scene := preload("res://systems/inventory/pickup_3d.tscn")
	var pickup := scene.instantiate() as Pickup3D
	pickup.item_id   = id
	pickup.item_name = name
	pickup.item_type = type
	pickup.rarity    = rar
	pickup.quantity  = qty
	parent.add_child(pickup)
	pickup.global_position = pos
	return pickup
