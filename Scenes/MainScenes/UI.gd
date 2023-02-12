extends CanvasLayer


var drag_tower
var drag_tower_range_texture
var drag_control

var color_valid = Color("ad54ff3c")
var color_invalid = Color("adff4545")


func set_tower_preview(tower_type, mouse_position):
	drag_tower = load("res://Scenes/Turrets/" + tower_type + ".tscn").instance()
	drag_tower.set_name("DragTower")
	drag_tower.modulate = color_valid
	
	drag_tower_range_texture = Sprite.new()
	drag_tower_range_texture.position = Vector2(32, 32)
	var range_scale = GameData.towers[tower_type].range / 600.0
	drag_tower_range_texture.scale = Vector2(range_scale, range_scale)
	drag_tower_range_texture.texture = load("res://Assets/UI/range_overlay.png")
	drag_tower_range_texture.modulate = color_valid

	drag_control = Control.new()
	drag_control.add_child(drag_tower, true)
	drag_control.add_child(drag_tower_range_texture, true)
	drag_control.rect_position = mouse_position
	drag_control.set_name("TowerPreview")
	add_child(drag_control, true)
	move_child(drag_control, 0)


func update_tower_preview(new_position, valid):
	var new_tower_color = color_valid if valid else color_invalid
	if drag_tower.modulate != new_tower_color:
		drag_tower.modulate = new_tower_color

	if drag_tower_range_texture.modulate != new_tower_color:
		drag_tower_range_texture.modulate = new_tower_color

	drag_control.rect_position = new_position


func clear_tower_preview():
	drag_control.free()
	drag_tower = null
	drag_control = null


func _on_PausePlay_pressed():
	if get_parent().build_mode:
		get_parent().cancel_build()

	if get_parent().current_wave == 0:
		get_parent().start_waves()
	else:
		get_tree().paused = not get_tree().is_paused()


func _on_SpeedUp_pressed():
	if get_parent().build_mode:
		get_parent().cancel_build()

	if Engine.get_time_scale() == 1.0:
		Engine.set_time_scale(2.0)
	else:
		Engine.set_time_scale(1.0)	
