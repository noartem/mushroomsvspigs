extends Node


# begin props
var duration: float = 0.0
var subject: Node2D
# end props

var active = false
var timer: SceneTreeTimer


func start():
	active = true
	begin()
	
	timer = get_tree().create_timer(duration)
	await timer.timeout

	if active:
		end()
		active = false
		queue_free()


func stop():
	end()
	active = false
	queue_free()


func begin():
	pass


func end():
	pass
