extends Node2D


var map_i = 0
var map_status = "in_process"
var map_data

var wallet = 0 : set = _set_wallet
var base_hp = 0

var waves_count = 0
var wave_i = 0
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

var random
var TWEEN_DURATION = 0.25

var color_default = Color(1, 1, 1, 1)
var color_disabled = Color("aaaaaaaa")

@onready var ui = $UI
@onready var play_pause_button = $UI/MarginContainer/HUD/VBoxContainer/PlayPause
@onready var waves_bar = $UI/MarginContainer/HUD/VBoxContainer/Waves/ProgressBar
@onready var base_hp_bar = $UI/MarginContainer/HUD/VBoxContainer/HP/ProgressBar
@onready var wallet_label = $UI/MarginContainer/HUD/VBoxContainer/Wallet/Label2
@onready var build_bar = $UI/MarginContainer/HUD/BuildBar
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
	if not build_valid: return

	var tower_data = GameData.towers[build_type]

	var tower = load(tower_data["path"]).instantiate()
	tower.position = build_location
	tower.built = true
	tower.data = tower_data

	map_towers_node.add_child(tower, true)
	map_towers_set[str(build_tile)] = true

	wallet -= tower_data.price


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
	enemy.damage = enemy_data["damage"]
	enemy.data = enemy_data
	return enemy


func spawn_enemy(enemy):
	var path_node = map_path_nodes[randi() % map_path_nodes.size()]
	path_node.add_child(enemy, true)
	enemies_spawned += 1



func wallet_label_set_raw(value: int):
	wallet_label.text = str(value).lpad(3, "0")

var wallet_label_set_tween

func wallet_label_set(value: int):
	if wallet_label_set_tween:
		wallet_label_set_tween.kill()
	wallet_label_set_tween = get_tree().create_tween() 
	wallet_label_set_tween.tween_method(wallet_label_set_raw, int(wallet_label.text), value, TWEEN_DURATION)


func update_available_towers():
	for tower_type in map_data.towers:
		var tower_data = GameData.towers[tower_type]
		var tower_price = tower_data.price

		var button: TextureButton = build_bar.get_node(tower_type)

		if tower_price > wallet:
			button.disabled = true
			button.modulate = color_disabled
		else:
			button.disabled = false
			button.modulate = color_default


func _set_wallet(value):
	wallet = value
	wallet_label_set(wallet)
	update_available_towers()


func _on_enemy_dies(enemy):
	enemies_died += 1
	
	if enemy.hp <= 0:
		var bounty = int(random.randi_range(enemy.data.bounty_min, enemy.data.bounty_max))

		wallet += bounty

	await sleep(5.0)
	if enemies_spawned == enemies_died and waves_finished:
		on_won()


var waves_bar_set_tween

func waves_bar_set(value):
	if waves_bar_set_tween:
		waves_bar_set_tween.kill()
	waves_bar_set_tween = get_tree().create_tween()
	waves_bar_set_tween.tween_property(waves_bar, "value", value, TWEEN_DURATION)


func spawn_waves():
	for wave in map_data.waves:
		await sleep(map_data.waves_delay)
		
		var wave_parts_count = wave.receipe.size()
		var wave_part_i = 0

		for wave_part in wave.receipe:
			for enemy_i in wave_part.count:
				var enemy = make_enemy(wave_part.type)
				spawn_enemy(enemy)
				enemy.dies.connect(_on_enemy_dies)

				waves_bar_set(wave_i + ((enemy_i + 1.0) / wave_part.count)*(wave_parts_count))

				var enemy_delay_min = wave.get("enemy_delay_min", 0.0)
				var enemy_delay_max = wave.get("enemy_delay_max", 1.0)
				var enemy_delay = random.randf_range(enemy_delay_min, enemy_delay_max)
				await sleep(enemy_delay)

			wave_part_i += 1

		wave_i += 1

	waves_finished = true


func set_pause(value):
	ui.set_pause(value)


func on_won():
	if map_status != "in_process":
		return

	map_status = "won"
	set_pause(false)
	get_tree().paused = true
	play_pause_button.button_pressed = false
	win_screen.visible = true
	win_screen.get_node("HBoxContainer/VBoxContainer/Next").visible = map_i < GameData.maps.size() - 1


func on_loose():
	if map_status != "in_process":
		return

	map_status = "loose"
	set_pause(false)
	get_tree().paused = true
	play_pause_button.button_pressed = false
	loose_screen.visible = true


func replace_node(new_node, old_node):
	remove_child(old_node)
	add_child(new_node)
	new_node.name = old_node.name
	new_node.position = old_node.position
	old_node.queue_free()


func make_image_texture(image_path):
	var texture = ImageTexture.new()
	var image = Image.new()
	image.load("res://icon.png")
	texture.create_from_image(image)
	return texture


func init_build_buttons():
	for button in build_bar.get_children():
		button.hide()

	for tower_type in map_data.towers:
		var button = build_bar.get_node(tower_type)
		button.show()
		button.pressed.connect(init_build_mode.bind(tower_type))

	update_available_towers()


func _ready():
	random = RandomNumberGenerator.new()
	random.randomize()

	map_data = GameData.maps[map_i]
	waves_count = map_data.waves.size()
	wave_i = 0
	enemies_spawned = 0
	enemies_died = 0
	base_hp = map_data.base_hp
	wallet = map_data.wallet_start

	map_node = load(map_data["path"]).instantiate()
	replace_node(map_node, get_node("Map"))

	map_towers_node = map_node.get_node("Towers")
	map_tower_exclusion_node = map_node.get_node("TowerExclusion")
	map_path_nodes = map_node.get_tree().get_nodes_in_group("paths")

	map_base_node = map_node.get_node("Base")
	map_base_node.body_entered.connect(_on_Base_body_entered)

	waves_bar.value = 0

	base_hp_bar.max_value = base_hp
	base_hp_bar_set(base_hp)
	
	waves_bar.max_value = waves_count
	waves_bar_set(0)

	init_build_buttons()

	spawn_waves()


func _process(delta):
	if build_mode:
		update_tower_preview()


func _unhandled_input(event):
	if build_mode and event.is_action_released("ui_accept"):
		verify_and_build()
		cancel_build()

	if build_mode and event.is_action_released("ui_cancel"):
		cancel_build()

	if event.is_action_released("key_exit"):
		set_pause(true)


var base_hp_bar_set_tween

func base_hp_bar_set(value):
	if base_hp_bar_set_tween:
		base_hp_bar_set_tween.kill()
	base_hp_bar_set_tween = get_tree().create_tween()
	base_hp_bar_set_tween.tween_property(base_hp_bar, "value", value, TWEEN_DURATION)	


func _on_base_damage(damage):
	base_hp -= damage
	base_hp_bar_set(base_hp)

	if base_hp <= 0:
		await sleep(TWEEN_DURATION)
		on_loose()


func _on_Base_body_entered(enemy_body):
	var enemy = enemy_body.get_parent()
	_on_base_damage(enemy.damage)
	enemy.kill()


func _on_try_again_pressed():
	restart_map()


func _on_next_pressed():
	go_next_map()


func _on_restart_pressed():
	restart_map()
