extends Node2D

# begin props
var hit
var speed = 1000
var direction = Vector2(1, 0)
var max_distance: float = 1000.0
# end props

var start_position: Vector2
var current_position: Vector2


func start():
	$Base.play()
	$Base.rotate(direction.angle())
	start_position = self.global_position


func stop():
	speed = 0


func stop_and_free():
	stop()
	queue_free()


func check_max_distance():
	if max_distance > 0:
		if start_position.distance_to(current_position) > max_distance:
			stop_and_free()


func _process(delta):
	var move_vector = direction.normalized() * speed * delta
	position += move_vector

	current_position = self.global_position
	check_max_distance()


func _on_range_body_entered(body):
	var enemy = body.get_parent()
	enemy.on_hit(hit)
	stop_and_free()
