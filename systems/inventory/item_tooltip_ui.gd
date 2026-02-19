## ItemTooltipUI — hovers near the cursor and shows item stats + comparison.
extends PanelContainer

@onready var item_name_label:   Label = $VBox/ItemName
@onready var rarity_label:      Label = $VBox/Rarity
@onready var type_label:        Label = $VBox/ItemType
@onready var desc_label:        Label = $VBox/Description
@onready var stats_label:       Label = $VBox/Stats
@onready var compare_label:     Label = $VBox/Compare

func _ready() -> void:
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func show_item(item: InventoryItem, compare_item: InventoryItem = null) -> void:
	if item == null:
		hide()
		return

	item_name_label.text = item.item_name
	item_name_label.add_theme_color_override("font_color", item.rarity_color())
	rarity_label.text    = "[%s]" % item.rarity_name()
	rarity_label.add_theme_color_override("font_color", item.rarity_color())
	type_label.text      = _type_label(item)
	desc_label.text      = item.description if item.description != "" else ""
	desc_label.visible   = item.description != ""

	var stat_lines := item.stat_lines()
	if stat_lines.is_empty():
		stats_label.text = ""
		stats_label.visible = false
	else:
		stats_label.text    = "\n".join(stat_lines)
		stats_label.visible = true

	# comparison with currently equipped
	if compare_item != null and item.is_equipment():
		var diff_lines: Array[String] = []
		var d_dmg  := item.damage_bonus  - compare_item.damage_bonus
		var d_def  := item.defense_bonus - compare_item.defense_bonus
		var d_hp   := item.health_bonus  - compare_item.health_bonus
		if d_dmg  != 0: diff_lines.append(_delta_str("Damage",  d_dmg))
		if d_def  != 0: diff_lines.append(_delta_str("Defense", d_def))
		if d_hp   != 0: diff_lines.append(_delta_str("Health",  d_hp))
		compare_label.text    = ("vs. equipped:\n" + "\n".join(diff_lines)) if diff_lines.size() > 0 else "Same stats"
		compare_label.visible = true
	else:
		compare_label.text    = ""
		compare_label.visible = false

	show()
	_clamp_to_screen()

func hide_tooltip() -> void:
	hide()

# ── helpers ───────────────────────────────────────────────────────────────────

func _delta_str(stat_name: String, delta: int) -> String:
	var sign := "+" if delta > 0 else ""
	var col  := "#6EFF6E" if delta > 0 else "#FF6E6E"
	return "[color=%s]%s%d %s[/color]" % [col, sign, delta, stat_name]

func _type_label(item: InventoryItem) -> String:
	match item.item_type:
		InventoryItem.ItemType.CONSUMABLE: return "Consumable"
		InventoryItem.ItemType.WEAPON:     return "Weapon"
		InventoryItem.ItemType.ARMOR:      return "Armor"
		InventoryItem.ItemType.ACCESSORY:  return "Accessory"
	return ""

func _clamp_to_screen() -> void:
	await get_tree().process_frame
	var vp := get_viewport().get_visible_rect().size
	var pos := global_position
	pos.x = clamp(pos.x, 0, vp.x - size.x)
	pos.y = clamp(pos.y, 0, vp.y - size.y)
	global_position = pos
