extends "res://Scenes/Effects/Effect.gd"

# begin props
var damage: float = 50
var wait_time: float = 1.0
var speed_coef: float = 1.15
# end props

var damage_timer: Timer


func begin():
	subject.remove_effect("Frozen")
	subject.modulate = Color(1, 0, 0, 1)
	subject.speed *= speed_coef

	damage_timer = Timer.new()
	damage_timer.connect("timeout", hit)
	damage_timer.wait_time = wait_time
	subject.add_child(damage_timer)
	damage_timer.start()


func hit():
	subject.hp -= damage


func end():
	subject.modulate = Color(1, 1, 1, 1)
	damage_timer.queue_free()
	subject.speed /= speed_coef

