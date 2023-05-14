extends "res://Scenes/Projectile/Projectile.gd"


func _process(delta):
	super._process(delta)
	rotation += delta * 1.0
