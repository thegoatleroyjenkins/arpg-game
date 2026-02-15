extends Area2D

const TEX_HEALTH := preload("res://assets/placeholders/item_health_potion.png")
const TEX_XP := preload("res://assets/placeholders/item_xp_orb.png")

@export var item_type: String = "health_potion"
@export var value: int = 25

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func _ready():
	match item_type:
		"xp_orb":
			sprite.texture = TEX_XP
			sprite.modulate = Color.WHITE
		_:
			sprite.texture = TEX_HEALTH
			sprite.modulate = Color.WHITE

	# Add floating animation
	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "position:y", -5, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:y", 0, 1.0).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body):
	if body.name == "Player":
		apply_effect(body)
		queue_free()

func apply_effect(player):
	match item_type:
		"health_potion":
			player.current_health = min(player.current_health + value, player.total_max_health)
			player._update_health_bar()
			if player.has_signal("stats_changed"):
				player.emit_signal("stats_changed")
		"xp_orb":
			player.gain_xp(value)
