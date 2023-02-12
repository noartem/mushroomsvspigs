extends Node2D


var enemies = []
var enemy = null
var type
var built = false


func select_enemy():
	if not enemy or not enemies.has(enemy):
		enemy = enemies[0]


func turn():
	get_node("Turret").look_at(enemy.position)


func _ready():
	if built:
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * GameData.towers[type]["range"]


func _physics_process(delta):
	if enemies.empty() or not built:
		enemy = null
	else:
		select_enemy()
		turn()


func _on_Range_body_entered(body):
	enemies.append(body.get_parent())


func _on_Range_body_exited(body):
	enemies.erase(body.get_parent())
