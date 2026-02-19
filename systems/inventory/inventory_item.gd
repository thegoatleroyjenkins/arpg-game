## InventoryItem — data resource for a single item stack in the inventory.
## Serialise to/from Dictionary so it can be saved as JSON.
class_name InventoryItem
extends Resource

enum ItemType { CONSUMABLE, WEAPON, ARMOR, ACCESSORY }
enum Rarity    { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

@export var item_id:       String   = ""
@export var item_name:     String   = "Unknown Item"
@export var description:   String   = ""
@export var item_type:     ItemType = ItemType.CONSUMABLE
@export var rarity:        Rarity   = Rarity.COMMON
@export var icon_path:     String   = ""   # res:// path; blank = default icon

# Quantity / stacking
@export var quantity:   int = 1
@export var max_stack:  int = 1   # 1 = non-stackable

# Stat bonuses (used for equipment; can be extended for skills/affixes later)
@export var damage_bonus:  int = 0
@export var defense_bonus: int = 0
@export var health_bonus:  int = 0
@export var heal_amount:   int = 0  # for consumables

# ── helpers ──────────────────────────────────────────────────────────────────

func is_equipment() -> bool:
	return item_type in [ItemType.WEAPON, ItemType.ARMOR, ItemType.ACCESSORY]

func is_consumable() -> bool:
	return item_type == ItemType.CONSUMABLE

func is_stackable() -> bool:
	return max_stack > 1

func rarity_name() -> String:
	return Rarity.keys()[rarity].capitalize()

func rarity_color() -> Color:
	match rarity:
		Rarity.COMMON:    return Color(0.85, 0.85, 0.85)
		Rarity.UNCOMMON:  return Color(0.3, 0.9, 0.3)
		Rarity.RARE:      return Color(0.3, 0.5, 1.0)
		Rarity.EPIC:      return Color(0.7, 0.2, 1.0)
		Rarity.LEGENDARY: return Color(1.0, 0.65, 0.1)
	return Color.WHITE

func stat_lines() -> Array[String]:
	var lines: Array[String] = []
	if damage_bonus  > 0: lines.append("+%d Damage"  % damage_bonus)
	if defense_bonus > 0: lines.append("+%d Defense" % defense_bonus)
	if health_bonus  > 0: lines.append("+%d Health"  % health_bonus)
	if heal_amount   > 0: lines.append("Restores %d HP" % heal_amount)
	return lines

# ── serialisation ─────────────────────────────────────────────────────────────

func to_dict() -> Dictionary:
	return {
		"item_id":      item_id,
		"item_name":    item_name,
		"description":  description,
		"item_type":    item_type,
		"rarity":       rarity,
		"icon_path":    icon_path,
		"quantity":     quantity,
		"max_stack":    max_stack,
		"damage_bonus":  damage_bonus,
		"defense_bonus": defense_bonus,
		"health_bonus":  health_bonus,
		"heal_amount":   heal_amount,
	}

static func from_dict(d: Dictionary) -> InventoryItem:
	var item := InventoryItem.new()
	item.item_id      = d.get("item_id",      "")
	item.item_name    = d.get("item_name",    "Unknown")
	item.description  = d.get("description",  "")
	item.item_type    = d.get("item_type",    ItemType.CONSUMABLE)
	item.rarity       = d.get("rarity",       Rarity.COMMON)
	item.icon_path    = d.get("icon_path",    "")
	item.quantity     = d.get("quantity",     1)
	item.max_stack    = d.get("max_stack",    1)
	item.damage_bonus  = d.get("damage_bonus",  0)
	item.defense_bonus = d.get("defense_bonus", 0)
	item.health_bonus  = d.get("health_bonus",  0)
	item.heal_amount   = d.get("heal_amount",   0)
	return item

## Convenience constructor used by pickup / loot-drop code.
static func make(
		id: String,
		name: String,
		type: ItemType,
		rar: Rarity = Rarity.COMMON,
		qty: int = 1,
		stk: int = 1) -> InventoryItem:
	var item       := InventoryItem.new()
	item.item_id   = id
	item.item_name = name
	item.item_type = type
	item.rarity    = rar
	item.quantity  = qty
	item.max_stack = stk
	return item
