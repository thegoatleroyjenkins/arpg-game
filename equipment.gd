class_name Equipment

extends Area2D

enum EquipmentType { WEAPON, ARMOR, ACCESSORY }

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
