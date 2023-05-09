extends PathFollow2D


var speed = -1
var hp = -1
var damage = -1
var died = false

var data

signal dies()

@onready var health_bar = $HealthBar


func destroy():
	get_node("CharacterBody2D").queue_free()
	await get_tree().create_timer(0.2).timeout
	self.queue_free()


func kill():
	died = true
	dies.emit(self)
	destroy()


func on_hit(hit_damage):
	hp -= hit_damage
	health_bar.value = hp
	if hp <= 0 and not died:
		kill()


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
