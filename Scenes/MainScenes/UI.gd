extends CanvasLayer


var drag_tower
var drag_control

var color_valid = Color("ad54ff3c")
var color_invalid = Color("adff4545")


func set_tower_preview(tower_type, mouse_position):
	drag_tower = load("res://Scenes/Turrets/" + tower_type + ".tscn").instance()
	drag_tower.set_name("DragTower")
	drag_tower.modulate = color_valid

	drag_control = Control.new()
	drag_control.add_child(drag_tower, true)
	drag_control.rect_position = mouse_position
	drag_control.set_name("TowerPreview")
	add_child(drag_control, true)
	move_child(drag_control, 0)


func update_tower_preview(new_position, valid):
	var new_tower_color = color_valid if valid else color_invalid
	if drag_tower.modulate != new_tower_color:
		drag_tower.modulate = new_tower_color

	drag_control.rect_position = new_position


func clear_tower_preview():
	drag_control.queue_free()
	drag_tower = null
	drag_control = null
