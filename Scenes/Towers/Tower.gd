extends Node2D


@onready var animation_player = get_node("AnimationPlayer")
@onready var base = get_node("Base")
@onready var rotated = get_node("Rotated")

var data

var built = false

var enemies = []
var enemy = null

var fire_ready = true


func select_enemy():
	if not enemy or not enemies.has(enemy):
		enemy = enemies[0]


func fire():
	fire_ready = false

	animation_player.play("Fire")

	enemy.on_hit(data["damage"])
	await get_tree().create_timer(data["rof"]).timeout
	fire_ready = true


func turn():
	rotated.look_at(enemy.position)
	base.set_flip_h(base.global_position.x > enemy.global_position.x)


func _ready():
	if built:
		base.play("default")
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * data["range"]


func _physics_process(delta):
	if enemies.is_empty() or not built:
		enemy = null
	else:
		select_enemy()
		if not animation_player.is_playing(): turn()
		if fire_ready: fire()


func _on_Range_body_entered(body):
	enemies.append(body.get_parent())


func _on_Range_body_exited(body):
	enemies.erase(body.get_parent())
