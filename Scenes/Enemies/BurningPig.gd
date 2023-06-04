extends "res://Scenes/Enemies/Enemy.gd"


func add_effects(_effects):
	for effect in _effects:
		if effect.name != "Frozen":
			add_effect(effect)


func _ready():
	super._ready()
