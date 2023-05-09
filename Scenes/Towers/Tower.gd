extends Node2D


@onready var animation_player = get_node("AnimationPlayer")
@onready var range_shape = get_node("Range/CollisionShape2D").get_shape()
@onready var base = get_node("Base")
@onready var rotated = get_node("Rotated")

var color_default = Color(1, 1, 1, 1)
var silver_color = Color("87c0f0")
var gold_color = Color("c0bb97")
var master_color = Color("dfa0df")
var levels_colors = [color_default, silver_color, gold_color, master_color]

var data

var built = false

var enemies = []
var enemy = null

var fire_ready = true

var level = -1 : set = _set_level
var max_level_reached = false

var range = -1 : set = _set_range
var damage = -1.0
var rof = -1.0
var size_scale = -1.0 : set = _set_size_scale

var inital_position


func _set_level(value):
	level = value

	max_level_reached = level == len(data.levels)
	modulate = levels_colors[level - 1]
	size_scale = 1.0 + (level - 1) * 0.1

	apply_stats(data.levels[level - 1])


func _set_range(value):
	range = value

	if range_shape:
		print("range_shape.radius = ", range_shape.radius)
		range_shape.radius = 0.5 * range
		print("range_shape.radius = ", range_shape.radius)


func _set_size_scale(value):
	size_scale = value
	
	scale.x = size_scale
	scale.y = size_scale

	position = inital_position - Vector2i(data.size[0] * (size_scale - 1.0), data.size[1] * (size_scale - 1.0)) / 2


func select_enemy():
	if not enemy or not enemies.has(enemy):
		enemy = enemies[0]


func fire():
	fire_ready = false

	animation_player.play("Fire")

	enemy.on_hit(damage)
	await get_tree().create_timer(rof).timeout
	fire_ready = true


func turn():
	rotated.look_at(enemy.position)
	base.set_flip_h(base.global_position.x > enemy.global_position.x)


func apply_stats(stats):
	range = stats.get("range", range)
	damage = stats.get("damage", damage)
	rof = stats.get("rof", rof)


func level_up():
	level += 1


func _ready():
	inital_position = Vector2i(position[0], position[1])

	if built:
		base.play("default")
		level = 1


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
