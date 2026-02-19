## InventoryData — central inventory state, registered as autoload "Inventory".
## Manages:
##   • 24-slot main grid  (items + consumables)
##   • 3 equipment slots  (weapon / armor / accessory)
##   • stacking, overflow, equip/unequip logic
##   • JSON save / load  (user://inventory.json)
extends Node

const SAVE_PATH   := "user://inventory.json"
const GRID_SLOTS  := 24
const NULL_SLOT   := -1

signal inventory_changed()
signal equipment_changed(slot: String)
signal item_used(item: InventoryItem, slot_index: int)
signal item_picked_up(item: InventoryItem)
signal overflow_dropped(item: InventoryItem)

# ── state ─────────────────────────────────────────────────────────────────────

# grid[i] is null or an InventoryItem
var grid: Array = []           # size = GRID_SLOTS

# equipment slots
var equipped_weapon:    InventoryItem = null
var equipped_armor:     InventoryItem = null
var equipped_accessory: InventoryItem = null

# ── lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	grid.resize(GRID_SLOTS)
	grid.fill(null)
	load_from_disk()
	# auto-save on quit
	get_tree().connect("tree_exiting", save_to_disk)

# ── public API ────────────────────────────────────────────────────────────────

## Returns true if at least one slot can accept the item (after stacking).
func can_add(item: InventoryItem) -> bool:
	if item == null:
		return false
	var remaining := item.quantity
	if item.is_stackable():
		for slot in grid:
			if slot != null and slot.item_id == item.item_id and slot.quantity < slot.max_stack:
				remaining -= (slot.max_stack - slot.quantity)
				if remaining <= 0:
					return true
	# check for an empty slot
	for slot in grid:
		if slot == null:
			return true
	return false

## Add item to grid; stacks if possible, splits across empty slots.
## Returns true if fully added, false if partial / overflow.
func add_item(item: InventoryItem) -> bool:
	if item == null:
		return false
	var remaining := item.quantity

	# --- fill existing stacks first ---
	if item.is_stackable():
		for i in range(GRID_SLOTS):
			if grid[i] != null and grid[i].item_id == item.item_id and grid[i].quantity < grid[i].max_stack:
				var space := grid[i].max_stack - grid[i].quantity
				var take  := min(space, remaining)
				grid[i].quantity += take
				remaining        -= take
				if remaining == 0:
					break

	# --- fill empty slots ---
	var i := 0
	while remaining > 0 and i < GRID_SLOTS:
		if grid[i] == null:
			var placed  := InventoryItem.from_dict(item.to_dict())
			placed.quantity  = min(remaining, item.max_stack)
			grid[i]          = placed
			remaining        -= placed.quantity
		i += 1

	inventory_changed.emit()
	item_picked_up.emit(item)

	if remaining > 0:
		var leftover := InventoryItem.from_dict(item.to_dict())
		leftover.quantity = remaining
		overflow_dropped.emit(leftover)
		return false
	return true

## Remove qty from slot_index. Returns true on success.
func remove_at(slot_index: int, qty: int = 1) -> bool:
	if not _valid_slot(slot_index) or grid[slot_index] == null:
		return false
	var item := grid[slot_index] as InventoryItem
	item.quantity = max(0, item.quantity - qty)
	if item.quantity == 0:
		grid[slot_index] = null
	inventory_changed.emit()
	return true

## Use a consumable from slot_index (heals player if reachable).
## Returns true if consumed.
func use_item(slot_index: int) -> bool:
	if not _valid_slot(slot_index) or grid[slot_index] == null:
		return false
	var item := grid[slot_index] as InventoryItem
	if not item.is_consumable():
		# try equipping instead
		return equip_from_slot(slot_index)
	item_used.emit(item, slot_index)
	return remove_at(slot_index, 1)

## Equip item in grid slot → equipment slot. Old item returns to grid.
func equip_from_slot(slot_index: int) -> bool:
	if not _valid_slot(slot_index) or grid[slot_index] == null:
		return false
	var item := grid[slot_index] as InventoryItem
	if not item.is_equipment():
		return false

	var slot_key: String
	match item.item_type:
		InventoryItem.ItemType.WEAPON:    slot_key = "weapon"
		InventoryItem.ItemType.ARMOR:     slot_key = "armor"
		InventoryItem.ItemType.ACCESSORY: slot_key = "accessory"
		_: return false

	# Swap old equipped back to grid
	var previously_equipped := _get_equipped(slot_key)
	grid[slot_index] = previously_equipped   # may be null
	_set_equipped(slot_key, item)

	inventory_changed.emit()
	equipment_changed.emit(slot_key)
	return true

## Unequip from equipment slot → first empty grid slot. Returns true on success.
func unequip_slot(slot_key: String) -> bool:
	var item := _get_equipped(slot_key)
	if item == null:
		return false
	if not can_add(item):
		return false   # inventory full
	_set_equipped(slot_key, null)
	add_item(item)
	equipment_changed.emit(slot_key)
	return true

## Move item from one grid slot to another (handles swaps).
func move_slot(from_index: int, to_index: int) -> void:
	if from_index == to_index:
		return
	if not _valid_slot(from_index) or not _valid_slot(to_index):
		return

	var a := grid[from_index]
	var b := grid[to_index]

	# Try to stack if same type
	if a != null and b != null and a.item_id == b.item_id and a.is_stackable():
		var space := b.max_stack - b.quantity
		if space > 0:
			var take := min(space, a.quantity)
			b.quantity += take
			a.quantity -= take
			if a.quantity == 0:
				grid[from_index] = null
			inventory_changed.emit()
			return

	# Simple swap
	grid[from_index] = b
	grid[to_index]   = a
	inventory_changed.emit()

## Get item at grid slot (may be null).
func get_slot(index: int) -> InventoryItem:
	if not _valid_slot(index):
		return null
	return grid[index]

## Aggregate stat bonuses from all equipment slots.
func total_damage_bonus()  -> int: return _eq_bonus("damage_bonus")
func total_defense_bonus() -> int: return _eq_bonus("defense_bonus")
func total_health_bonus()  -> int: return _eq_bonus("health_bonus")

# ── equipment slot accessors ──────────────────────────────────────────────────

func _get_equipped(slot_key: String) -> InventoryItem:
	match slot_key:
		"weapon":    return equipped_weapon
		"armor":     return equipped_armor
		"accessory": return equipped_accessory
	return null

func _set_equipped(slot_key: String, item: InventoryItem) -> void:
	match slot_key:
		"weapon":    equipped_weapon    = item
		"armor":     equipped_armor     = item
		"accessory": equipped_accessory = item

func _eq_bonus(field: String) -> int:
	var total := 0
	for slot_key in ["weapon", "armor", "accessory"]:
		var item := _get_equipped(slot_key)
		if item != null:
			total += item.get(field) as int
	return total

# ── persistence ───────────────────────────────────────────────────────────────

func save_to_disk() -> void:
	var data := {
		"grid": [],
		"equipped": {
			"weapon":    null,
			"armor":     null,
			"accessory": null,
		}
	}
	for slot in grid:
		data["grid"].append(slot.to_dict() if slot != null else null)
	for key in ["weapon", "armor", "accessory"]:
		var eq := _get_equipped(key)
		data["equipped"][key] = eq.to_dict() if eq != null else null

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_from_disk() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var text   := file.get_as_text()
	file.close()

	var parsed := JSON.parse_string(text)
	if parsed == null or not (parsed is Dictionary):
		return

	# grid
	var raw_grid: Array = parsed.get("grid", [])
	for i in range(min(raw_grid.size(), GRID_SLOTS)):
		var d = raw_grid[i]
		grid[i] = InventoryItem.from_dict(d) if d != null else null

	# equipment
	var raw_eq: Dictionary = parsed.get("equipped", {})
	for key in ["weapon", "armor", "accessory"]:
		var d = raw_eq.get(key, null)
		_set_equipped(key, InventoryItem.from_dict(d) if d != null else null)

	inventory_changed.emit()
	for key in ["weapon", "armor", "accessory"]:
		equipment_changed.emit(key)

# ── helpers ───────────────────────────────────────────────────────────────────

func _valid_slot(index: int) -> bool:
	return index >= 0 and index < GRID_SLOTS
