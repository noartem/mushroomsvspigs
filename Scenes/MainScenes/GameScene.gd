extends Node2D


var map_node
var map_towers_node
var map_tower_exclusion_node
var map_path_node
var map_base_node

var build_mode = false
var build_valid = false
var build_tile
var build_location
var build_type

var waves_count = 0
var current_wave = 0
var waves_finished = false
var enemies_spawned = 0
var enemies_died = 0

@onready var ui = $UI
@onready var play_pause_button = $UI/MarginContainer/HUD/PlayPause
@onready var progress_bar = $UI/MarginContainer/HUD/ProgressBar
@onready var pause_screen = $PauseScreen
@onready var loose_screen = $LooseScreen
@onready var win_screen = $WinScreen


func init_build_mode(tower_type):
	if build_mode:
		cancel_build()

	build_type = tower_type
	build_mode = true
	ui.set_tower_preview(tower_type, get_global_mouse_position())


func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	build_tile = map_tower_exclusion_node.local_to_map(mouse_position)
	build_location = map_tower_exclusion_node.map_to_local(build_tile)
	build_valid = map_tower_exclusion_node.get_cell_source_id(0, build_tile) == -1
	ui.update_tower_preview(build_location, build_valid)


func verify_and_build():
	if build_valid:
		var new_tower = load("res://Scenes/Towers/" + build_type + ".tscn").instantiate()
		new_tower.position = build_location
		new_tower.built = true
		new_tower.type = build_type
		new_tower.data = GameData.towers[build_type]
		map_towers_node.add_child(new_tower, true)
		map_tower_exclusion_node.set_cell(0, build_tile, 5)


func cancel_build():
	build_mode = false
	build_valid = false
	build_location = null
	build_type = null
	ui.clear_tower_preview()


func sleep(time):
	return get_tree().create_timer(time).timeout


func get_waves_data():
	return GameData.maps[0]


func make_enemy(enemy_type):
	return load("res://Scenes/Enemies/" + enemy_type + ".tscn").instantiate()


func spawn_enemy(enemy):
	map_path_node.add_child(enemy, true)
	enemies_spawned += 1


func _on_enemy_dies():
	enemies_died += 1

	await sleep(5.0)
	if enemies_spawned == enemies_died and waves_finished:
		on_won()


func start_waves():
	var random = RandomNumberGenerator.new()
	random.randomize()

	var waves_data = get_waves_data()
	waves_count = waves_data.waves.size()

	current_wave = 0
	enemies_spawned = 0
	enemies_died = 0

	for wave in waves_data.waves:
		await sleep(waves_data.waves_delay)

		current_wave += 1

		for enemy_type in wave.receipe:
			for i in wave.receipe[enemy_type]:
				var enemy = make_enemy(enemy_type)
				spawn_enemy(enemy)
				enemy.dies.connect(_on_enemy_dies)

				var enemy_delay_min = wave.get("enemy_delay_min", 0.0)
				var enemy_delay_mean = wave.get("enemy_delay_mean", 0.0)
				var enemy_delay_deviation = wave.get("enemy_delay_deviation", 1.0)
				var enemy_delay = random.randfn(enemy_delay_mean, enemy_delay_deviation)
				await sleep(max(enemy_delay_min, enemy_delay))

		progress_bar.value = float(current_wave) / float(waves_count) * 100

	waves_finished = true


func on_won():
	ui.set_pause(false)
	get_tree().paused = true
	play_pause_button.button_pressed = false
	win_screen.visible = true


func on_loose():
	ui.set_pause(false)
	get_tree().paused = true
	play_pause_button.button_pressed = false
	loose_screen.visible = true


func _ready():
	map_node = get_node("Map")
	map_towers_node = map_node.get_node("Towers")
	map_tower_exclusion_node = map_node.get_node("TowerExclusion")
	map_path_node = map_node.get_node("Path3D")
	map_base_node = map_node.get_node("Base")

	for build_btn in get_tree().get_nodes_in_group("build_buttons"):
		var build_btn_name = build_btn.get_name()
		build_btn.connect("pressed", Callable(self,"init_build_mode").bind(build_btn_name))
		
	map_base_node.body_entered.connect(_on_Base_body_entered)

	start_waves()

func _process(delta):
	if build_mode:
		update_tower_preview()


func _unhandled_input(event):
	if build_mode:
		if event.is_action_released("ui_accept"):
			verify_and_build()
			cancel_build()
		elif event.is_action_released("ui_cancel"):
			cancel_build()


func _on_Base_body_entered(body):
	on_loose()
