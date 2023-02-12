extends PathFollow2D


var speed = 150
var hp = 50

onready var health_bar = get_node("HealthBar")


func destroy():
	self.queue_free()


func on_hit(damage):
	hp -= damage
	health_bar.value = hp
	if hp <= 0:
		destroy()


func move(delta):
	set_offset(get_offset() + speed * delta)
	health_bar.set_position(position - Vector2(24, 28))


func _physics_process(delta):
	move(delta)


func _ready():
	health_bar.max_value = hp
	health_bar.value = hp
	health_bar.set_as_toplevel(true)
