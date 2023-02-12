extends Node


func _ready():
	get_node("MainMenu/Margin/ButtonsBox/NewGame").connect("pressed", self, "on_new_game_pressed")
	get_node("MainMenu/Margin/ButtonsBox/Quit").connect("pressed", self, "on_quit_pressed")


func on_new_game_pressed():
	get_node("MainMenu").queue_free()
	var game_scene = load("res://Scenes/MainScenes/GameScene.tscn").instance()
	add_child(game_scene)
	pass


func on_quit_pressed():
	get_tree().quit()