extends Node


var map
var map_i = 0

@onready var main_menu = $MainMenu
@onready var new_game_button = main_menu.get_node("Margin/ButtonsBox/NewGame")
@onready var quit_button = main_menu.get_node("Margin/ButtonsBox/Quit")


func start_map():
	map = load("res://Scenes/MainScenes/GameScene.tscn").instantiate()
	map.map_i = map_i
	add_child(map)
	move_child(map, 0)


func remove_map():
	remove_child(map)
	map.call_deferred("free")


func restart_map():
	get_tree().paused = false
	remove_map()
	start_map()


func restart_game():
	map_i = 0
	restart_map()


func go_next_map():
	map_i += 1
	restart_map()


func back_to_main_menu():
	map_i = 0
	remove_map()

	main_menu.show()


func _on_new_game_pressed():
	SoundPlayer.play("click", -15)
	main_menu.hide()
	start_map()


func _on_quit_pressed():
	SoundPlayer.play("click", -15)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


func _ready():
	new_game_button.pressed.connect(_on_new_game_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
