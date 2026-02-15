extends Control
class_name Minimap

@export var world_size: Vector2 = Vector2(2000, 2000)
@export var player_path: NodePath
@export var enemy_color: Color = Color(1.0, 0.35, 0.35, 0.95)
@export var player_color: Color = Color(0.45, 0.95, 0.6, 1.0)
@export var pickup_color: Color = Color(0.45, 0.75, 1.0, 0.8)
@export var show_grid: bool = true
@export var grid_spacing: float = 48.0
@export var grid_color: Color = Color(1, 1, 1, 0.08)
@export var center_axis_color: Color = Color(1, 1, 1, 0.16)
@export var highlight_color: Color = Color(1, 1, 1, 0.05)
@export var player_direction_color: Color = Color(0.8, 0.97, 0.85, 0.95)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var bg := Rect2(Vector2.ZERO, size)
	draw_rect(bg, Color(0.04, 0.05, 0.07, 0.85), true)
	draw_rect(bg, Color(0.75, 0.82, 0.95, 0.5), false, 2.0)

	_draw_background_glow()
	if show_grid:
		_draw_grid()
	_draw_center_axes()

	_draw_pickups()
	_draw_enemies()
	_draw_player()

func _draw_background_glow() -> void:
	var center = size * 0.5
	var radius = min(size.x, size.y) * 0.45
	draw_circle(center, radius, highlight_color)

func _draw_grid() -> void:
	if grid_spacing <= 0.0:
		return
	var x = grid_spacing
	while x < size.x:
		draw_line(Vector2(x, 0), Vector2(x, size.y), grid_color, 1.0)
		x += grid_spacing
	var y = grid_spacing
	while y < size.y:
		draw_line(Vector2(0, y), Vector2(size.x, y), grid_color, 1.0)
		y += grid_spacing

func _draw_center_axes() -> void:
	var center = size * 0.5
	draw_line(Vector2(center.x, 0), Vector2(center.x, size.y), center_axis_color, 1.0)
	draw_line(Vector2(0, center.y), Vector2(size.x, center.y), center_axis_color, 1.0)

func _draw_player() -> void:
	var player = get_node_or_null(player_path) as CharacterBody2D
	if player == null:
		return
	var p = _to_minimap(player.global_position)
	_draw_player_direction(player, p)
	draw_circle(p, 3.5, player_color)

func _draw_player_direction(player: CharacterBody2D, origin: Vector2) -> void:
	var direction = player.velocity
	if direction.length_squared() < 0.01:
		var sprite = player.get_node_or_null("Sprite2D") as Node2D
		if sprite:
			direction = Vector2(sprite.scale.x, 0)
	if direction.length_squared() < 0.01:
		return
	direction = direction.normalized()
	var length = min(size.x, size.y) * 0.18
	var tip = origin + direction * length
	draw_line(origin, tip, player_direction_color, 2.0)
	draw_circle(tip, 2.4, player_direction_color)

func _draw_enemies() -> void:
	for n in get_tree().get_nodes_in_group("enemies"):
		if n is Node2D:
			var p = _to_minimap((n as Node2D).global_position)
			draw_circle(p, 2.2, enemy_color)

func _draw_pickups() -> void:
	for n in get_tree().get_nodes_in_group("pickups"):
		if n is Node2D:
			var p = _to_minimap((n as Node2D).global_position)
			draw_circle(p, 1.8, pickup_color)

func _to_minimap(pos: Vector2) -> Vector2:
	if world_size.x <= 0.0 or world_size.y <= 0.0:
		return Vector2.ZERO
	var nx := clamp(pos.x / world_size.x, 0.0, 1.0)
	var ny := clamp(pos.y / world_size.y, 0.0, 1.0)
	return Vector2(nx * size.x, ny * size.y)
