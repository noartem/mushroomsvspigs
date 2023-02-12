extends PathFollow2D


var speed = 150
var hp = 50

onready var health_bar = get_node("HealthBar")
onready var impact_area = get_node("Impact")
var projectile_impact = preload("res://Scenes/SupportScenes/ProjectileImpact.tscn")


func impact():
	randomize()
	var x = randi() % 31
	randomize()
	var y = randi() % 31
	
	var new_impact = projectile_impact.instance()
	new_impact.position = Vector2(x, y)

	impact_area.add_child(new_impact)


func destroy():
	get_node("KinematicBody2D").queue_free()
	yield(get_tree().create_timer(0.2), "timeout")
	self.queue_free()


func on_hit(damage):
	impact()
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
