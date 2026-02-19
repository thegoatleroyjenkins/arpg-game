## ItemSlotUI — one cell in the inventory grid.
## Emits slot_clicked(index) / slot_right_clicked(index) / drag_started(index).
class_name ItemSlotUI
extends PanelContainer

signal slot_clicked(index: int)
signal slot_right_clicked(index: int)
signal drag_started(index: int)
signal tooltip_requested(item: InventoryItem, rect: Rect2)
signal tooltip_hide_requested()

var slot_index: int = -1
var item: InventoryItem = null
var is_equipment_slot: bool = false
var equipment_key: String = ""

@onready var icon_texture:  TextureRect = $VBox/Icon
@onready var qty_label:     Label       = $VBox/Qty
@onready var empty_label:   Label       = $VBox/Empty

const ICON_DEFAULT := preload("res://assets/placeholders/item_health_potion.png")
const ICON_WEAPON  := preload("res://assets/placeholders/equipment_weapon.png")
const ICON_ARMOR   := preload("res://assets/placeholders/equipment_armor.png")
const ICON_ACCESS  := preload("res://assets/placeholders/equipment_accessory.png")

const STYLE_NORMAL   := StyleBoxFlat.new()
const STYLE_HOVER    := StyleBoxFlat.new()
const STYLE_SELECTED := StyleBoxFlat.new()

var _hovered := false
var _drag_threshold_px := 6.0
var _drag_start_pos: Vector2 = Vector2.ZERO
var _dragging := false

func _ready() -> void:
	_build_styles()
	_apply_style_normal()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func refresh(p_item: InventoryItem) -> void:
	item = p_item
	if item == null:
		icon_texture.texture = null
		qty_label.text       = ""
		qty_label.visible    = false
		empty_label.visible  = not is_equipment_slot
		_apply_style_normal()
		return

	icon_texture.texture = _resolve_icon(item)
	empty_label.visible  = false

	if item.is_stackable() and item.quantity > 1:
		qty_label.text    = str(item.quantity)
		qty_label.visible = true
	else:
		qty_label.text    = ""
		qty_label.visible = false

	# Tint icon by rarity
	icon_texture.modulate = item.rarity_color()
	_apply_style_normal()

# ── input ─────────────────────────────────────────────────────────────────────

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_drag_start_pos = mb.global_position
			_dragging       = false
		elif not mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			if not _dragging:
				slot_clicked.emit(slot_index)
		if mb.pressed and mb.button_index == MOUSE_BUTTON_RIGHT:
			slot_right_clicked.emit(slot_index)

	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not _dragging:
			var dist := (event.global_position - _drag_start_pos).length()
			if dist >= _drag_threshold_px:
				_dragging = true
				drag_started.emit(slot_index)

func _on_mouse_entered() -> void:
	_hovered = true
	_apply_style_hover()
	if item != null:
		tooltip_requested.emit(item, get_global_rect())

func _on_mouse_exited() -> void:
	_hovered = false
	_apply_style_normal()
	tooltip_hide_requested.emit()

# ── styles ─────────────────────────────────────────────────────────────────────

func _build_styles() -> void:
	pass  # built inline in _apply_* to avoid static init issues

func _make_style(bg: Color, border: Color, border_w: int = 1) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color           = bg
	s.border_color       = border
	s.border_width_top    = border_w
	s.border_width_bottom = border_w
	s.border_width_left   = border_w
	s.border_width_right  = border_w
	s.corner_radius_top_left     = 4
	s.corner_radius_top_right    = 4
	s.corner_radius_bottom_left  = 4
	s.corner_radius_bottom_right = 4
	s.content_margin_left   = 4
	s.content_margin_top    = 4
	s.content_margin_right  = 4
	s.content_margin_bottom = 4
	return s

func _apply_style_normal() -> void:
	var bg := Color(0.08, 0.08, 0.12, 0.9) if item == null else Color(0.1, 0.12, 0.16, 0.9)
	var brd := Color(0.3, 0.35, 0.5, 0.8) if not is_equipment_slot else Color(0.6, 0.5, 0.2, 0.9)
	add_theme_stylebox_override("panel", _make_style(bg, brd))

func _apply_style_hover() -> void:
	add_theme_stylebox_override("panel", _make_style(Color(0.15, 0.18, 0.25, 0.95), Color(0.7, 0.75, 1.0, 0.9), 2))

# ── icons ──────────────────────────────────────────────────────────────────────

func _resolve_icon(p_item: InventoryItem) -> Texture2D:
	if p_item.icon_path != "" and ResourceLoader.exists(p_item.icon_path):
		return load(p_item.icon_path) as Texture2D
	match p_item.item_type:
		InventoryItem.ItemType.WEAPON:    return ICON_WEAPON
		InventoryItem.ItemType.ARMOR:     return ICON_ARMOR
		InventoryItem.ItemType.ACCESSORY: return ICON_ACCESS
		_:                                return ICON_DEFAULT
