extends Node2D


onready var animation_player = get_node("AnimationPlayer")

var data
var type

var built = false

var enemies = []
var enemy = null

var fire_ready = true


func select_enemy():
	if not enemy or not enemies.has(enemy):
		enemy = enemies[0]


func fire_gun():
	animation_player.play("Fire")


func fire_missile():
	animation_player.play("Fire")


func fire():
	fire_ready = false
	
	if data["category"] == "Projectile":
		fire_gun()
	elif data["category"] == "Missile":
		fire_missile()

	enemy.on_hit(data["damage"])
	yield(get_tree().create_timer(data["rof"]), "timeout")
	fire_ready = true


func turn():
	get_node("Turret").look_at(enemy.position)


func _ready():
	if built:
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * data["range"]


func _physics_process(delta):
	if enemies.empty() or not built:
		enemy = null
	else:
		select_enemy()
		if not animation_player.is_playing(): turn()
		if fire_ready: fire()


func _on_Range_body_entered(body):
	enemies.append(body.get_parent())


func _on_Range_body_exited(body):
	enemies.erase(body.get_parent())
