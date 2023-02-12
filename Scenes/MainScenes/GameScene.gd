extends Node2D


var map_node
var map_towers_node
var ui_node

var build_mode = false
var build_valid = false
var build_location = null
var build_type = null


func init_build_mode(tower_type):
	build_type = tower_type
	build_mode = true
	ui_node.set_tower_preview(tower_type, get_global_mouse_position())


func update_tower_preview():
	var map_tower_exclusion_node = map_node.get_node("TowerExclusion")

	var mouse_position = get_global_mouse_position()
	var current_tile = map_tower_exclusion_node.world_to_map(mouse_position)

	build_location = map_tower_exclusion_node.map_to_world(current_tile)
	build_valid = map_tower_exclusion_node.get_cellv(current_tile) == -1

	ui_node.update_tower_preview(build_location, build_valid)


func verify_and_build():
	if build_valid:
		var new_tower = load("res://Scenes/Turrets/" + build_type + ".tscn").instance()
		new_tower.position = build_location
		map_towers_node.add_child(new_tower, true)


func cancel_build():
	build_mode = false
	build_valid = false
	build_location = null
	build_type = null
	ui_node.clear_tower_preview()


func _ready():
	map_node = get_node("Map1")
	map_towers_node = map_node.get_node("Towers")
	ui_node = get_node("UI")

	for build_btn in get_tree().get_nodes_in_group("build_buttons"):
		build_btn.connect("pressed", self, "init_build_mode", [build_btn.get_name()])


func _process(delta):
	if build_mode:
		update_tower_preview()


func _unhandled_input(event):
	if build_mode:
		if event.is_action_released("ui_accept"):
			verify_and_build()
			cancel_build()
		if event.is_action_released("ui_cancel"):
			cancel_build()

