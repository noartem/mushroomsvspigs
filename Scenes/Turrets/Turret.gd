extends Node2D


var data
var enemies = []
var enemy = null
var type
var built = false
var fire_ready = true


func select_enemy():
	if not enemy or not enemies.has(enemy):
		enemy = enemies[0]


func fire():
	fire_ready = false
	enemy.on_hit(data["damage"])
	yield(get_tree().create_timer(data["rof"]), "timeout")
	fire_ready = true


func turn():
	get_node("Turret").look_at(enemy.position)


func _ready():
	if built:
		data = GameData.towers[type]
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * data["range"]


func _physics_process(delta):
	if enemies.empty() or not built:
		enemy = null
	else:
		select_enemy()
		turn()

		if fire_ready:
			fire()


func _on_Range_body_entered(body):
	enemies.append(body.get_parent())


func _on_Range_body_exited(body):
	enemies.erase(body.get_parent())
