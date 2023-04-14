extends Node


var main_menu
var game_scene


func go_to_game():
	main_menu.visible = false
	game_scene = load("res://Scenes/MainScenes/GameScene.tscn").instantiate()
	add_child(game_scene)


func back_to_main_menu():
	main_menu.visible = true
	game_scene.queue_free()


func _ready():
	main_menu = $MainMenu
	get_node("MainMenu/Margin/ButtonsBox/NewGame").connect("pressed",Callable(self,"on_new_game_pressed"))
	get_node("MainMenu/Margin/ButtonsBox/Quit").connect("pressed",Callable(self,"on_quit_pressed"))


func on_new_game_pressed():
	go_to_game()


func on_quit_pressed():
	get_tree().quit()
