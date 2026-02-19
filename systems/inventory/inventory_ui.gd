## InventoryUI — full inventory panel controller.
## Handles:  grid display, equipment slots, tooltip, drag/drop, keyboard dismiss.
extends Control

const SLOT_SCENE    := preload("res://systems/inventory/item_slot_ui.tscn")
const TOOLTIP_SCENE := preload("res://systems/inventory/item_tooltip_ui.tscn")

@onready var grid_container:     GridContainer = $BG/HBox/Left/GridContainer
@onready var eq_weapon_slot:     Control       = $BG/HBox/Right/EquipSection/WeaponSlot
@onready var eq_armor_slot:      Control       = $BG/HBox/Right/EquipSection/ArmorSlot
@onready var eq_accessory_slot:  Control       = $BG/HBox/Right/EquipSection/AccessorySlot
@onready var info_name:          Label         = $BG/HBox/Right/InfoBox/InfoName
@onready var info_stats:         Label         = $BG/HBox/Right/InfoBox/InfoStats
@onready var info_desc:          Label         = $BG/HBox/Right/InfoBox/InfoDesc
@onready var close_btn:          Button        = $BG/TitleRow/CloseBtn
@onready var hint_label:         Label         = $BG/HintLabel

var tooltip: PanelContainer = null

var _grid_slots: Array[ItemSlotUI] = []
var _eq_slots:   Dictionary = {}    # "weapon"/"armor"/"accessory" → ItemSlotUI
var _drag_from_index:  int  = -1
var _selected_index:   int  = -1

# Called from open_world_3d or the level controller to inject reference to Inventory autoload
var inventory: Node = null

func _ready() -> void:
	hide()
	_build_grid()
	_build_equipment_slots()
	_build_tooltip()
	close_btn.pressed.connect(hide_panel)
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_open"):
		toggle()
	elif event.is_action_pressed("ui_cancel") and visible:
		hide_panel()

func toggle() -> void:
	if visible:
		hide_panel()
	else:
		show_panel()

func show_panel() -> void:
	_connect_inventory()
	refresh_all()
	show()
	# release mouse so UI can be interacted with
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_panel() -> void:
	hide()
	tooltip.hide()
	# recapture mouse if we're in 3D mode
	if get_tree().get_first_node_in_group("player_3d") != null:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# ── inventory connection ───────────────────────────────────────────────────────

func _connect_inventory() -> void:
	if inventory == null:
		inventory = get_node_or_null("/root/Inventory")
	if inventory == null:
		push_warning("InventoryUI: No Inventory autoload found.")
		return
	if not inventory.inventory_changed.is_connected(_on_inventory_changed):
		inventory.inventory_changed.connect(_on_inventory_changed)
	if not inventory.equipment_changed.is_connected(_on_equipment_changed):
		inventory.equipment_changed.connect(_on_equipment_changed)
	if not inventory.item_used.is_connected(_on_item_used):
		inventory.item_used.connect(_on_item_used)

# ── grid build ─────────────────────────────────────────────────────────────────

func _build_grid() -> void:
	for i in range(24):
		var slot: ItemSlotUI = SLOT_SCENE.instantiate() as ItemSlotUI
		slot.slot_index = i
		slot.slot_clicked.connect(_on_slot_clicked)
		slot.slot_right_clicked.connect(_on_slot_right_clicked)
		slot.drag_started.connect(_on_drag_started)
		slot.tooltip_requested.connect(_on_tooltip_requested)
		slot.tooltip_hide_requested.connect(_on_tooltip_hide)
		grid_container.add_child(slot)
		_grid_slots.append(slot)

func _build_equipment_slots() -> void:
	var keys := ["weapon", "armor", "accessory"]
	var nodes := [eq_weapon_slot, eq_armor_slot, eq_accessory_slot]
	for i in range(keys.size()):
		var slot: ItemSlotUI = SLOT_SCENE.instantiate() as ItemSlotUI
		slot.slot_index       = -(i + 1)   # negative = equipment
		slot.is_equipment_slot = true
		slot.equipment_key     = keys[i]
		slot.slot_clicked.connect(_on_eq_slot_clicked.bind(keys[i]))
		slot.slot_right_clicked.connect(_on_eq_slot_right_clicked.bind(keys[i]))
		slot.tooltip_requested.connect(_on_tooltip_requested)
		slot.tooltip_hide_requested.connect(_on_tooltip_hide)
		nodes[i].add_child(slot)
		_eq_slots[keys[i]] = slot

func _build_tooltip() -> void:
	tooltip = TOOLTIP_SCENE.instantiate() as PanelContainer
	add_child(tooltip)
	tooltip.z_index = 100

# ── refresh ───────────────────────────────────────────────────────────────────

func refresh_all() -> void:
	if inventory == null:
		_connect_inventory()
	if inventory == null:
		return
	for i in range(_grid_slots.size()):
		_grid_slots[i].refresh(inventory.get_slot(i))
	for key in _eq_slots.keys():
		(_eq_slots[key] as ItemSlotUI).refresh(inventory._get_equipped(key))

func _on_inventory_changed() -> void:
	if visible:
		refresh_all()

func _on_equipment_changed(_slot_key: String) -> void:
	if visible:
		refresh_all()

func _on_item_used(item: InventoryItem, _index: int) -> void:
	# Apply consumable effects to 3D player
	var player: Node = get_tree().get_first_node_in_group("player_3d")
	if player == null:
		return
	if item.heal_amount > 0 and player.has_method("receive_healing"):
		player.receive_healing(item.heal_amount)

# ── slot interaction ───────────────────────────────────────────────────────────

func _on_slot_clicked(index: int) -> void:
	if _drag_from_index >= 0:
		# Complete drag
		if inventory != null:
			inventory.move_slot(_drag_from_index, index)
		_drag_from_index = -1
		return
	_select_slot(index)

func _on_slot_right_clicked(index: int) -> void:
	if inventory != null:
		inventory.use_item(index)

func _on_drag_started(index: int) -> void:
	_drag_from_index = index

func _on_eq_slot_clicked(key: String) -> void:
	if _drag_from_index >= 0:
		_drag_from_index = -1
		return
	if inventory != null:
		inventory.unequip_slot(key)

func _on_eq_slot_right_clicked(key: String) -> void:
	if inventory != null:
		inventory.unequip_slot(key)

func _select_slot(index: int) -> void:
	_selected_index = index
	if inventory == null:
		return
	var item := inventory.get_slot(index)
	if item == null:
		info_name.text  = ""
		info_stats.text = ""
		info_desc.text  = ""
		return
	info_name.text = item.item_name
	info_name.add_theme_color_override("font_color", item.rarity_color())
	info_stats.text = "\n".join(item.stat_lines()) if item.stat_lines().size() > 0 else "(no stats)"
	info_desc.text  = item.description if item.description != "" else ""

# ── tooltip ───────────────────────────────────────────────────────────────────

func _on_tooltip_requested(item: InventoryItem, slot_rect: Rect2) -> void:
	if inventory == null or item == null:
		return
	# find compare item from equipment slot
	var compare_item: InventoryItem = null
	if item.is_equipment():
		match item.item_type:
			InventoryItem.ItemType.WEAPON:    compare_item = inventory.equipped_weapon
			InventoryItem.ItemType.ARMOR:     compare_item = inventory.equipped_armor
			InventoryItem.ItemType.ACCESSORY: compare_item = inventory.equipped_accessory
	tooltip.show_item(item, compare_item)
	# Position tooltip to the right or above the slot
	var tip_pos := Vector2(slot_rect.end.x + 8, slot_rect.position.y)
	tooltip.global_position = tip_pos

func _on_tooltip_hide() -> void:
	tooltip.hide_tooltip()
