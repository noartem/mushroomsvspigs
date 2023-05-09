extends Node2D


var map_i = 0
var map_status = "in_process"
var map_data

var wallet = 0 : set = _set_wallet
var base_hp = 0 : set = _set_base_hp
var waves_progress = 0 : set = _set_waves_progress

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

var drag_tower
var drag_tower_range_texture
var drag_control
var drag_valid
var drag_tile
var drag_exclusion_tile
var drag_location
var drag_data
var drag_tower_level = -1

var build_mode = false

var replace_mode = false
var replace_tower_level = -1

var random
var TWEEN_DURATION = 0.25

var color_default = Color(1, 1, 1, 1)
var color_disabled = Color("aaaaaaaa")
var color_valid = Color("00753daa")
var color_invalid = Color("a63430aa")

var base_hp_bar_set_tween
var wallet_label_set_tween
var waves_bar_set_tween

@onready var ui = $UI
@onready var play_pause_button = $UI/MarginContainer/PlayPause
@onready var build_bar = $UI/MarginContainer/BottomBar/BuildBar
@onready var trash_button = $UI/MarginContainer/BottomBar/Trash
@onready var waves_bar = $UI/MarginContainer/BottomBar/VBoxContainer/Waves/ProgressBar
@onready var base_hp_bar = $UI/MarginContainer/BottomBar/VBoxContainer/HP/ProgressBar
@onready var wallet_label = $UI/MarginContainer/BottomBar/VBoxContainer/Wallet/Label2
@onready var pause_screen = $PauseScreen
@onready var loose_screen = $LooseScreen
@onready var win_screen = $WinScreen


func sleep(time):
	return get_tree().create_timer(time).timeout


func replace_node(new_node, old_node):
	remove_child(old_node)
	add_child(new_node)
	new_node.name = old_node.name
	new_node.position = old_node.position
	old_node.queue_free()


func make_tower(tower_data):
	var tower = load(tower_data.path).instantiate()
	tower.data = tower_data
	return tower


func quit_map():
	get_parent().back_to_main_menu()


func restart_game():
	get_parent().restart_game()


func restart_map():
	get_parent().restart_map()


func go_next_map():
	get_parent().go_next_map()


func set_pause(value):
	cancel()

	get_tree().paused = value
	play_pause_button.button_pressed = value
	pause_screen.visible = value


func toggle_pause():
	set_pause(not get_tree().is_paused())


func get_hovering_tower_tile():
	return map_towers_node.local_to_map(get_global_mouse_position())


func get_hovering_tower_exclusion_tile():
	return map_tower_exclusion_node.local_to_map(get_global_mouse_position() - Vector2(16, 16))


func _set_wallet_label(value: int):
	wallet_label.text = str(value).lpad(3, "0")


func _set_wallet(value):
	wallet = value

	if wallet_label_set_tween:
		wallet_label_set_tween.kill()

	wallet_label_set_tween = get_tree().create_tween() 
	wallet_label_set_tween.tween_method(_set_wallet_label, int(wallet_label.text), value, TWEEN_DURATION)

	update_available_towers()


func _set_base_hp(value):
	base_hp = value

	if base_hp_bar_set_tween:
		base_hp_bar_set_tween.kill()

	base_hp_bar_set_tween = get_tree().create_tween()
	base_hp_bar_set_tween.tween_property(base_hp_bar, "value", value, TWEEN_DURATION)	


func _set_waves_progress(value):
	waves_progress = value

	if waves_bar_set_tween:
		waves_bar_set_tween.kill()

	waves_bar_set_tween = get_tree().create_tween()
	waves_bar_set_tween.tween_property(waves_bar, "value", value, TWEEN_DURATION)


func add_tower(tower_data, tower_tile, tower_position):
	var tower = make_tower(tower_data)
	tower.position = tower_position
	tower.built = true

	map_towers_node.add_child(tower, true)
	map_towers_set[str(tower_tile)] = tower
	
	return tower


func remove_tower(tower, tower_tile):
	tower.free()
	map_towers_set.erase(str(tower_tile))


func update_tower_preview():
	drag_tile = get_hovering_tower_tile()
	drag_exclusion_tile = get_hovering_tower_exclusion_tile()
	drag_location = map_towers_node.map_to_local(drag_tile) - Vector2(16, 16)
	drag_control.position = map_towers_node.map_to_local(drag_tile)

	if build_mode:
		drag_valid = (
			map_tower_exclusion_node.get_cell_tile_data(0, drag_exclusion_tile) == null and
			(
				not map_towers_set.has(str(drag_tile)) or
				map_towers_set.get(str(drag_tile)).level == 1
			)
		)

	if replace_mode:
		drag_valid = (
			map_tower_exclusion_node.get_cell_tile_data(0, drag_exclusion_tile) == null and
			(
				not map_towers_set.has(str(drag_tile)) or 
				not map_towers_set.get(str(drag_tile)).max_level_reached and
				map_towers_set.get(str(drag_tile)).level == drag_tower_level
			)
		)

	var new_tower_color = color_valid if drag_valid else color_invalid
	drag_tower.modulate = new_tower_color
	drag_tower_range_texture.modulate = new_tower_color


func set_tower_preview(tower_data, tower_level = 1):
	drag_data = tower_data
	drag_tower_level = tower_level

	drag_tower = make_tower(tower_data)
	drag_tower.set_name("DragTower")
	drag_tower.modulate = color_valid

	drag_tower_range_texture = Sprite2D.new()
	var range_scale = tower_data.levels[drag_tower_level - 1].range / 620.0
	drag_tower_range_texture.scale = Vector2(range_scale, range_scale)
	drag_tower_range_texture.texture = load("res://Assets/UI/range_overlay.png")
	drag_tower_range_texture.modulate = color_valid

	drag_control = Control.new()
	drag_control.add_child(drag_tower, true)
	drag_control.add_child(drag_tower_range_texture, true)
	drag_control.position = get_global_mouse_position()
	drag_control.set_name("TowerPreview")
	drag_control.process_mode = Node.PROCESS_MODE_DISABLED

	ui.add_child(drag_control, true)
	ui.move_child(drag_control, 0)


func cancel_drag():
	drag_control.free()
	drag_tower = null
	drag_control = null
	drag_valid = false
	drag_tile = null
	drag_exclusion_tile = null
	drag_location = null
	drag_data = null
	drag_tower_level = -1


func verify_and_build():
	if not drag_valid: return

	var tile_tower = map_towers_set.get(str(drag_tile))
	if tile_tower:
		tile_tower.level_up()
	else:
		add_tower(drag_data, drag_tile, drag_location)

	wallet -= drag_data.price

	cancel_build()


func cancel_build():
	build_mode = false
	cancel_drag()


func try_init_replace_mode():
	var tower_tile = get_hovering_tower_tile()
	var tower = map_towers_set.get(str(tower_tile))
	if tower:
		init_replace_mode(tower, tower_tile)


func init_replace_mode(tower, tower_tile):
	cancel()
	replace_mode = true
	trash_button.visible = true
	set_tower_preview(tower.data, tower.level)
	drag_tower.level = drag_tower_level
	remove_tower(tower, tower_tile)


func verify_and_replace():
	if not drag_valid:
		return

	var tile_tower = map_towers_set.get(str(drag_tile))
	if tile_tower:
		tile_tower.level_up()
	else:
		var tower = add_tower(drag_data, drag_tile, drag_location)
		tower.level = drag_tower_level

	cancel_replace()


func cancel_replace():
	replace_mode = false
	trash_button.visible = false
	cancel_drag()


func cancel():
	if build_mode:
		cancel_build()

	if replace_mode:
		cancel_replace()


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


func update_available_towers():
	for tower_type in map_data.towers:
		var tower_data = GameData.towers[tower_type]
		var tower_price = tower_data.price

		var button = build_bar.get_node(tower_type)

		if tower_price > wallet:
			button.disabled = true
			button.modulate = color_disabled
		else:
			button.disabled = false
			button.modulate = color_default


func _on_enemy_dies(enemy):
	enemies_died += 1
	
	if enemy.hp <= 0:
		var bounty = int(random.randi_range(enemy.data.bounty_min, enemy.data.bounty_max))

		wallet += bounty

	await sleep(5.0)
	if enemies_spawned == enemies_died and waves_finished:
		on_won()


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

				waves_progress = wave_i + (enemy_i + 1.0) * wave_parts_count / wave_part.count

				var enemy_delay_min = wave.get("enemy_delay_min", 0.0)
				var enemy_delay_max = wave.get("enemy_delay_max", 1.0)
				var enemy_delay = random.randf_range(enemy_delay_min, enemy_delay_max)
				await sleep(enemy_delay)

			wave_part_i += 1

		wave_i += 1

	waves_finished = true


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


func init_build_mode(tower_data):
	cancel()
	build_mode = true
	set_tower_preview(tower_data)


func init_build_buttons():
	for button in build_bar.get_children():
		button.hide()

	for tower_type in map_data.towers:
		var tower_data = GameData.towers[tower_type]
		var button = build_bar.get_node(tower_type)
		button.show()
		button.pressed.connect(init_build_mode.bind(tower_data))

	update_available_towers()


func _on_base_damage(damage):
	base_hp -= damage

	if base_hp <= 0:
		await sleep(TWEEN_DURATION)
		on_loose()


func _on_base_body_entered(enemy_body):
	var enemy = enemy_body.get_parent()
	_on_base_damage(enemy.damage)
	enemy.kill()


func _on_try_again_pressed():
	restart_map()


func _on_next_pressed():
	go_next_map()


func _on_restart_pressed():
	restart_map()


func _on_continue_pressed():
	set_pause(false)


func _on_play_pause_pressed():
	toggle_pause()


func _on_quit_pressed():
	get_tree().paused = false
	quit_map()


func _on_trash_pressed():
	if replace_mode:
		wallet += drag_data.price * 2**(drag_tower_level - 1) * GameData.SELL_COEF
		cancel_replace()


func _process(delta):
	if drag_tower:
		update_tower_preview()


func _unhandled_input(event):
	if event.is_action_released("ui_cancel"):
		cancel()
		return

	if build_mode and event.is_action_released("ui_accept"):
		verify_and_build()
		return

	if not build_mode and not replace_mode and event.is_action_released("ui_accept"):
		try_init_replace_mode()
		return

	if replace_mode and event.is_action_released("ui_accept"):
		verify_and_replace()
		return

	if event.is_action_released("key_exit"):
		set_pause(true)
		return


func _ready():
	random = RandomNumberGenerator.new()
	random.randomize()

	map_data = GameData.maps[map_i]
	waves_count = map_data.waves.size()
	wave_i = 0
	enemies_spawned = 0
	enemies_died = 0
	wallet = map_data.wallet_start

	base_hp_bar.max_value = map_data.base_hp
	base_hp = map_data.base_hp

	map_node = load(map_data["path"]).instantiate()
	replace_node(map_node, get_node("Map"))

	map_towers_node = map_node.get_node("Towers")
	map_tower_exclusion_node = map_node.get_node("TowerExclusion")
	map_path_nodes = map_node.get_tree().get_nodes_in_group("paths")

	map_base_node = map_node.get_node("Base")
	map_base_node.body_entered.connect(_on_base_body_entered)

	waves_bar.value = 0
	
	waves_bar.max_value = waves_count
	waves_progress = 0

	init_build_buttons()

	trash_button.visible = false

	spawn_waves()
