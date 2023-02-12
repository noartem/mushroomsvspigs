extends Node2D


var map_node
var map_towers_node
var map_tower_exclusion_node
var map_path_node
var ui_node

var build_mode = false
var build_valid = false
var build_tile
var build_location
var build_type

var current_wave = 0
var enemies_in_wave = 0


func init_build_mode(tower_type):
	if build_mode:
		cancel_build()

	build_type = tower_type
	build_mode = true
	ui_node.set_tower_preview(tower_type, get_global_mouse_position())


func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	build_tile = map_tower_exclusion_node.world_to_map(mouse_position)
	build_location = map_tower_exclusion_node.map_to_world(build_tile)
	build_valid = map_tower_exclusion_node.get_cellv(build_tile) == -1
	ui_node.update_tower_preview(build_location, build_valid)


func verify_and_build():
	if build_valid:
		var new_tower = load("res://Scenes/Turrets/" + build_type + ".tscn").instance()
		new_tower.position = build_location
		new_tower.built = true
		new_tower.type = build_type
		map_towers_node.add_child(new_tower, true)
		map_tower_exclusion_node.set_cellv(build_tile, 5)


func cancel_build():
	build_mode = false
	build_valid = false
	build_location = null
	build_type = null
	ui_node.clear_tower_preview()


func sleep(time):
	yield(get_tree().create_timer(time), "timeout")


func get_wave_data():
	var wave_data = [
		["TankT1", 0.64],
		["TankT1", 0.64],
		["TankT1", 1.28],
		["TankT1", 0.0],
	]
	current_wave += 1
	enemies_in_wave = wave_data.size()
	return wave_data


func spawn_enemies(wave_data):
	for enemy_data in wave_data:
		var new_enemy = load("res://Scenes/Enemies/" + enemy_data[0] + ".tscn").instance()
		map_path_node.add_child(new_enemy, true)
		yield(get_tree().create_timer(enemy_data[1]), "timeout")


func start_next_wave():
	var wave_data = get_wave_data()
	yield(get_tree().create_timer(0.2), "timeout")
	spawn_enemies(wave_data)


func start_waves():
	current_wave = 1
	start_next_wave()


func _ready():
	map_node = get_node("Map1")
	map_towers_node = map_node.get_node("Towers")
	map_tower_exclusion_node = map_node.get_node("TowerExclusion")
	map_path_node = map_node.get_node("Path")
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

