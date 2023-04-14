extends PathFollow2D


var speed = 150
var hp = 50
var died = false

signal dies()

@onready var health_bar = $HealthBar


func destroy():
	get_node("CharacterBody2D").queue_free()
	await get_tree().create_timer(0.2).timeout
	self.queue_free()


func on_hit(damage):
	hp -= damage
	health_bar.value = hp
	if hp <= 0 and not died:
		died = true
		dies.emit()
		destroy()


func move(delta):
	set_progress(get_progress() + speed * delta)
	health_bar.set_position(position - Vector2(24, 28))


func _physics_process(delta):
	move(delta)


func _ready():
	$Base.play("default")
	health_bar.max_value = hp
	health_bar.value = hp
	health_bar.set_as_top_level(true)
