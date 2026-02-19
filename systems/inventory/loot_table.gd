## LootTable — loads item_definitions.json and generates random InventoryItems.
## Usage:
##   var item = LootTable.random_item()
##   var item = LootTable.item_by_id("flame_sword")
##   Pickup3D.spawn_at(parent, pos, item.item_id, item.item_name, item.item_type, item.rarity)
class_name LootTable
extends RefCounted

const DEFS_PATH := "res://data/items/item_definitions.json"

static var _defs: Array = []
static var _loaded: bool = false

static func _ensure_loaded() -> void:
	if _loaded:
		return
	if not FileAccess.file_exists(DEFS_PATH):
		push_error("LootTable: item_definitions.json not found at " + DEFS_PATH)
		return
	var file := FileAccess.open(DEFS_PATH, FileAccess.READ)
	if not file:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary and parsed.has("items"):
		_defs = parsed["items"]
	_loaded = true

static func item_by_id(id: String) -> InventoryItem:
	_ensure_loaded()
	for d in _defs:
		if d.get("item_id", "") == id:
			return InventoryItem.from_dict(d)
	return null

## Returns a random InventoryItem, optionally filtered by rarity (0-4, -1 = any).
static func random_item(rarity_filter: int = -1) -> InventoryItem:
	_ensure_loaded()
	if _defs.is_empty():
		return null
	var pool: Array = _defs if rarity_filter < 0 else _defs.filter(func(d): return d.get("rarity", 0) == rarity_filter)
	if pool.is_empty():
		pool = _defs
	var d := pool[randi() % pool.size()]
	return InventoryItem.from_dict(d)

## Weighted random drop: 50% common, 30% uncommon, 15% rare, 4% epic, 1% legendary.
static func weighted_random_drop() -> InventoryItem:
	var roll := randf()
	var rar: int
	if   roll < 0.50: rar = 0   # common
	elif roll < 0.80: rar = 1   # uncommon
	elif roll < 0.95: rar = 2   # rare
	elif roll < 0.99: rar = 3   # epic
	else:             rar = 4   # legendary
	return random_item(rar)

## All item IDs in the definitions file.
static func all_ids() -> Array[String]:
	_ensure_loaded()
	var ids: Array[String] = []
	for d in _defs:
		ids.append(d.get("item_id", ""))
	return ids
