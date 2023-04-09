extends CanvasLayer


var drag_tower
var drag_tower_range_texture
var drag_control

var color_valid = Color("00753daa")
var color_invalid = Color("a63430aa")


func set_tower_preview(tower_type, mouse_position):
	drag_tower = load("res://Scenes/Towers/" + tower_type + ".tscn").instantiate()
	drag_tower.set_name("DragTower")
	drag_tower.modulate = color_valid
	
	drag_tower_range_texture = Sprite2D.new()
	drag_tower_range_texture.position = Vector2(32, 32)
	var range_scale = GameData.towers[tower_type].range / 600.0
	drag_tower_range_texture.scale = Vector2(range_scale, range_scale)
	drag_tower_range_texture.texture = load("res://Assets/UI/range_overlay.png")
	drag_tower_range_texture.modulate = color_valid

	drag_control = Control.new()
	drag_control.add_child(drag_tower, true)
	drag_control.add_child(drag_tower_range_texture, true)
	drag_control.position = mouse_position
	drag_control.set_name("TowerPreview")
	add_child(drag_control, true)
	move_child(drag_control, 0)


func update_tower_preview(new_position, valid):
	var new_tower_color = color_valid if valid else color_invalid

	if drag_tower.modulate != new_tower_color:
		drag_tower.modulate = new_tower_color

	if drag_tower_range_texture.modulate != new_tower_color:
		drag_tower_range_texture.modulate = new_tower_color

	drag_control.position = new_position


func clear_tower_preview():
	drag_control.free()
	drag_tower = null
	drag_control = null


func toggle_pause():
	if get_parent().build_mode:
		get_parent().cancel_build()

	var is_paused = get_tree().is_paused()
	get_tree().paused = not is_paused
	get_node("MarginContainer/HUD/PlayPause").button_pressed = not is_paused
	get_parent().get_node("PauseScreen").visible = not is_paused


func _on_play_pause_pressed():
	toggle_pause()


func _on_continue_pressed():
	toggle_pause()


func _on_quit_pressed():
	get_tree().quit()
