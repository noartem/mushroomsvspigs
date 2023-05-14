extends "res://Scenes/Effects/Effect.gd"

# begin props
var slow_coef: float = 0.5
# end props


func begin():
	subject.remove_effect("Burning")
	subject.modulate = Color(0, 0, 1, 1)
	subject.speed *= slow_coef


func end():
	subject.modulate = Color(1, 1, 1, 1)
	subject.speed *= 1 / slow_coef

