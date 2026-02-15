class_name Equipment

extends Area2D

enum EquipmentType { WEAPON, ARMOR, ACCESSORY }

const TEX_WEAPON := preload("res://assets/placeholders/equipment_weapon.png")
const TEX_ARMOR := preload("res://assets/placeholders/equipment_armor.png")
const TEX_ACCESSORY := preload("res://assets/placeholders/equipment_accessory.png")

@export var equipment_type: EquipmentType = EquipmentType.WEAPON
@export var item_name: String = "Iron Sword"
@export var description: String = "A basic sword"
@export var damage_bonus: int = 0
@export var defense_bonus: int = 0
@export var health_bonus: int = 0

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var label = $Label

func _ready():
	match equipment_type:
		EquipmentType.WEAPON:
			sprite.texture = TEX_WEAPON
			if sprite.modulate == Color.WHITE:
				sprite.modulate = Color(0.85, 0.85, 0.95)
		EquipmentType.ARMOR:
			sprite.texture = TEX_ARMOR
			if sprite.modulate == Color.WHITE:
				sprite.modulate = Color(0.75, 0.88, 1.0)
		EquipmentType.ACCESSORY:
			sprite.texture = TEX_ACCESSORY
			if sprite.modulate == Color.WHITE:
				sprite.modulate = Color(1.0, 0.9, 0.45)

	# Add floating animation
	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "position:y", -5, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:y", 0, 1.0).set_trans(Tween.TRANS_SINE)
	
	# Update label
	label.text = item_name

func _on_body_entered(body):
	if body.has_method("equip_item"):
		body.equip_item(self)
		queue_free()
