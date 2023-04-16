extends Node2D


var map_i = 0
var map_data

var waves_count = 0
var current_wave = 0
var waves_finished = false
var enemies_spawned = 0
var enemies_died = 0

var map_node
var map_towers_node
var map_tower_exclusion_node
var map_path_nodes
var map_base_node

var map_towers_set = {}

var build_mode = false
var build_valid = false
var build_tile
var build_location
var build_type

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


func is_build_valid():
	var mouse_position = get_global_mouse_position()
	var tower_exclusion_build_tile = map_tower_exclusion_node.local_to_map(mouse_position)
	var towers_build_tile = map_towers_node.local_to_map(mouse_position)
	return (
		map_tower_exclusion_node.get_cell_tile_data(0, tower_exclusion_build_tile) == null and
		not map_towers_set.has(str(towers_build_tile))
	)


func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	build_tile = map_towers_node.local_to_map(mouse_position)
	build_location = map_towers_node.map_to_local(build_tile)
	build_valid = is_build_valid()
	ui.update_tower_preview(build_location, build_valid)


func verify_and_build():
	if build_valid:
		var tower_data = GameData.towers[build_type]
		var tower = load(tower_data["path"]).instantiate()
		tower.position = build_location
		tower.built = true
		tower.data = tower_data
		map_towers_node.add_child(tower, true)
		map_towers_set[str(build_tile)] = true


func cancel_build():
	build_mode = false
	build_valid = false
	build_location = null
	build_type = null
	ui.clear_tower_preview()


func restart_game():
	get_parent().restart_game()


func restart_map():
	get_parent().restart_map()


func go_next_map():
	get_parent().go_next_map()


func sleep(time):
	return get_tree().create_timer(time).timeout


func make_enemy(enemy_type):
	var enemy_data = GameData.enemies[enemy_type]
	var enemy = load("res://Scenes/Enemies/" + enemy_type + ".tscn").instantiate()
	enemy.hp = enemy_data["hp"]
	enemy.speed = enemy_data["speed"]
	return enemy


func spawn_enemy(enemy):
	var path_node = map_path_nodes[randi() % map_path_nodes.size()]
	path_node.add_child(enemy, true)
	enemies_spawned += 1


func _on_enemy_dies():
	enemies_died += 1

	await sleep(5.0)
	if enemies_spawned == enemies_died and waves_finished:
		on_won()


func start_waves():
	var random = RandomNumberGenerator.new()
	random.randomize()

	waves_count = map_data.waves.size()

	current_wave = 0
	enemies_spawned = 0
	enemies_died = 0

	for wave in map_data.waves:
		await sleep(map_data.waves_delay)

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


func set_pause(value):
	ui.set_pause(value)


func on_won():
	set_pause(false)
	get_tree().paused = true
	play_pause_button.button_pressed = false
	win_screen.visible = true
	win_screen.get_node("HBoxContainer/VBoxContainer/Next").visible = map_i < GameData.maps.size() - 1


func on_loose():
	set_pause(false)
	get_tree().paused = true
	play_pause_button.button_pressed = false
	loose_screen.visible = true


func replace_node(new_node, old_node):
	remove_child(old_node)
	add_child(new_node)
	new_node.name = old_node.name
	new_node.position = old_node.position
	print(str(old_node.position))
	old_node.queue_free()


func _ready():
	map_data = GameData.maps[map_i]
	map_node = load(map_data["path"]).instantiate()
	replace_node(map_node, get_node("Map"))

	map_towers_node = map_node.get_node("Towers")
	map_tower_exclusion_node = map_node.get_node("TowerExclusion")
	map_path_nodes = map_node.get_tree().get_nodes_in_group("paths")

	map_base_node = map_node.get_node("Base")
	map_base_node.body_entered.connect(_on_Base_body_entered)

	for build_btn in get_tree().get_nodes_in_group("build_buttons"):
		var build_btn_name = build_btn.get_name()
		build_btn.connect("pressed", Callable(self,"init_build_mode").bind(build_btn_name))

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


func _on_try_again_pressed():
	restart_map()


func _on_next_pressed():
	go_next_map()


func _on_restart_pressed():
	restart_map()
