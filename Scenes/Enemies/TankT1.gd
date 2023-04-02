extends PathFollow2D


var speed = 150
var hp = 50

@onready var health_bar = $HealthBar
@onready var impact_area = $Impact
var projectile_impact = preload("res://Scenes/SupportScenes/ProjectileImpact.tscn")


func impact():
	randomize()
	var x = randi() % 31
	randomize()
	var y = randi() % 31
	
	var new_impact = projectile_impact.instantiate()
	new_impact.position = Vector2(x, y)

	impact_area.add_child(new_impact)


func destroy():
	get_node("CharacterBody2D").queue_free()
	await get_tree().create_timer(0.2).timeout
	self.queue_free()


func on_hit(damage):
	impact()
	hp -= damage
	health_bar.value = hp
	if hp <= 0:
		destroy()


func move(delta):
	set_progress(get_progress() + speed * delta)
	health_bar.set_position(position - Vector2(24, 28))


func _physics_process(delta):
	move(delta)


func _ready():
	health_bar.max_value = hp
	health_bar.value = hp
	health_bar.set_as_top_level(true)
