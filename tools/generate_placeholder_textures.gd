extends SceneTree

const OUT_DIR := "res://assets/placeholders"
const SIZE := 64

func _init() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	_save_enemy_texture()
	_save_player_texture()
	_save_item_health_texture()
	_save_item_xp_texture()
	_save_equipment_weapon_texture()
	_save_equipment_armor_texture()
	_save_equipment_accessory_texture()
	print("[placeholder-art] Generated placeholder textures in %s" % OUT_DIR)
	quit()

func _new_image() -> Image:
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	return img

func _draw_circle(img: Image, cx: int, cy: int, radius: int, color: Color) -> void:
	for y in range(cy - radius, cy + radius + 1):
		if y < 0 or y >= SIZE:
			continue
		for x in range(cx - radius, cx + radius + 1):
			if x < 0 or x >= SIZE:
				continue
			var dx := x - cx
			var dy := y - cy
			if dx * dx + dy * dy <= radius * radius:
				img.set_pixel(x, y, color)

func _draw_rect(img: Image, x0: int, y0: int, x1: int, y1: int, color: Color) -> void:
	for y in range(max(0, y0), min(SIZE, y1)):
		for x in range(max(0, x0), min(SIZE, x1)):
			img.set_pixel(x, y, color)

func _save(img: Image, filename: String) -> void:
	img.save_png("%s/%s" % [OUT_DIR, filename])

func _save_enemy_texture() -> void:
	var img := _new_image()
	_draw_circle(img, 32, 34, 19, Color("#5A6B5E"))
	_draw_circle(img, 25, 29, 3, Color.BLACK)
	_draw_circle(img, 39, 29, 3, Color.BLACK)
	_draw_rect(img, 22, 41, 42, 45, Color("#2A322C"))
	_save(img, "enemy_goblin.png")

func _save_player_texture() -> void:
	var img := _new_image()
	_draw_circle(img, 32, 22, 9, Color("#F1D0B3"))
	_draw_rect(img, 20, 29, 44, 52, Color("#4A6EA8"))
	_draw_rect(img, 16, 33, 20, 50, Color("#2B3E5F"))
	_draw_rect(img, 44, 33, 48, 50, Color("#2B3E5F"))
	_draw_rect(img, 28, 52, 36, 62, Color("#2B3E5F"))
	_save(img, "player_knight.png")

func _save_item_health_texture() -> void:
	var img := _new_image()
	_draw_circle(img, 32, 36, 14, Color("#C0392B"))
	_draw_rect(img, 28, 18, 36, 27, Color("#EAECEE"))
	_draw_rect(img, 23, 31, 41, 41, Color("#FFFFFF"))
	_save(img, "item_health_potion.png")

func _save_item_xp_texture() -> void:
	var img := _new_image()
	_draw_circle(img, 32, 34, 16, Color("#4FC3F7"))
	_draw_circle(img, 32, 34, 8, Color("#B3E5FC"))
	_save(img, "item_xp_orb.png")

func _save_equipment_weapon_texture() -> void:
	var img := _new_image()
	_draw_rect(img, 30, 10, 34, 46, Color("#C8CCD1"))
	_draw_rect(img, 24, 40, 40, 44, Color("#8B5E3C"))
	_draw_rect(img, 29, 44, 35, 58, Color("#6E4B2F"))
	_save(img, "equipment_weapon.png")

func _save_equipment_armor_texture() -> void:
	var img := _new_image()
	_draw_rect(img, 18, 18, 46, 50, Color("#7F8C8D"))
	_draw_rect(img, 24, 24, 40, 44, Color("#AAB7B8"))
	_save(img, "equipment_armor.png")

func _save_equipment_accessory_texture() -> void:
	var img := _new_image()
	_draw_circle(img, 32, 32, 15, Color("#D4AF37"))
	_draw_circle(img, 32, 32, 9, Color(0, 0, 0, 0))
	_draw_circle(img, 32, 32, 5, Color("#7AB7FF"))
	_save(img, "equipment_accessory.png")
