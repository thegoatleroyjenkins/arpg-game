extends Control
class_name Minimap

@export var world_size: Vector2 = Vector2(2000, 2000)
@export var player_path: NodePath
@export var enemy_color: Color = Color(1.0, 0.35, 0.35, 0.95)
@export var player_color: Color = Color(0.45, 0.95, 0.6, 1.0)
@export var pickup_color: Color = Color(0.45, 0.75, 1.0, 0.8)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var bg := Rect2(Vector2.ZERO, size)
	draw_rect(bg, Color(0.04, 0.05, 0.07, 0.85), true)
	draw_rect(bg, Color(0.75, 0.82, 0.95, 0.5), false, 2.0)

	_draw_pickups()
	_draw_enemies()
	_draw_player()

func _to_minimap(pos: Vector2) -> Vector2:
	if world_size.x <= 0.0 or world_size.y <= 0.0:
		return Vector2.ZERO
	var nx := clamp(pos.x / world_size.x, 0.0, 1.0)
	var ny := clamp(pos.y / world_size.y, 0.0, 1.0)
	return Vector2(nx * size.x, ny * size.y)

func _draw_player() -> void:
	var player := get_node_or_null(player_path) as Node2D
	if player == null:
		return
	var p := _to_minimap(player.global_position)
	draw_circle(p, 3.5, player_color)

func _draw_enemies() -> void:
	for n in get_tree().get_nodes_in_group("enemies"):
		if n is Node2D:
			var p := _to_minimap((n as Node2D).global_position)
			draw_circle(p, 2.2, enemy_color)

func _draw_pickups() -> void:
	for n in get_tree().get_nodes_in_group("pickups"):
		if n is Node2D:
			var p := _to_minimap((n as Node2D).global_position)
			draw_circle(p, 1.8, pickup_color)
