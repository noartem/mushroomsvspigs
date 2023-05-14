extends Node2D


@onready var range_shape = get_node("Range/CollisionShape2D").get_shape()
@onready var base = get_node("Base")

var color_default = Color(1, 1, 1, 1)
var silver_color = Color("87c0f0")
var gold_color = Color("c0bb97")
var master_color = Color("dfa0df")
var levels_colors = [color_default, silver_color, gold_color, master_color]

var data

var built = false

var enemies = []
var enemy: Node2D = null

var fire_ready = true

var level = -1 : set = _set_level
var max_level_reached = false

var range = -1 : set = _set_range
var damage = -1.0
var rof = -1.0
var effects = []
var size_scale = -1.0 : set = _set_size_scale

var inital_position


func _set_level(value):
	level = value

	max_level_reached = level == len(data.levels)
	modulate = levels_colors[level - 1]
	size_scale = 1.0 + (level - 1) * 0.1

	for level_data in data.levels.slice(0, level):
		apply_stats(level_data)


func _set_range(value):
	range = value

	if range_shape:
		range_shape.radius = 0.5 * range


func _set_size_scale(value):
	size_scale = value
	
	scale.x = size_scale
	scale.y = size_scale

	position = inital_position - Vector2i(data.size[0] * (size_scale - 1.0), data.size[1] * (size_scale - 1.0)) / 2


func select_enemy():
	if not enemy or not enemies.has(enemy):
		enemy = enemies[0]


func shoot_projectile():
	var projectile: Node2D = load(data.attack.path).instantiate()

	projectile.hit = {"damage": damage, "effects": effects}
	projectile.direction = global_position.direction_to(enemy.global_position)

	add_child(projectile)

	projectile.start()


func attack():
	if data.attack.type == "projectile":
		shoot_projectile()


func fire():
	fire_ready = false

	attack()

	await get_tree().create_timer(rof).timeout
	fire_ready = true


func turn():
	base.set_flip_h(base.global_position.x > enemy.global_position.x)


func apply_stats(stats):
	range = stats.get("range", range)
	damage = stats.get("damage", damage)
	rof = stats.get("rof", rof)
	effects = stats.get("effects", effects)


func level_up():
	SoundPlayer.play("jump_2", -10 + level * 2)
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
		if fire_ready: fire()


func _on_Range_body_entered(body):
	enemies.append(body.get_parent())


func _on_Range_body_exited(body):
	enemies.erase(body.get_parent())
