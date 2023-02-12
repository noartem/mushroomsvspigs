extends PathFollow2D


var speed = 150


func move(delta):
	set_offset(get_offset() + speed * delta)


func _physics_process(delta):
	move(delta)
