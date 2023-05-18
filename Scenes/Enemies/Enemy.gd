extends PathFollow2D


var speed = -1
var hp = -1 : set = _set_hp
var damage = -1
var died = false

var data

var effects = {}

signal dies()

@onready var health_bar = $HealthBar

func _set_hp(value):
	hp = value
	
	if health_bar:
		health_bar.value = hp

	if hp <= 0 and not died:
		kill()


func destroy():
	remove_effects()
	get_node("CharacterBody2D").queue_free()
	await get_tree().create_timer(0.2).timeout
	self.free()


func kill():
	died = true
	dies.emit(self)
	destroy()
	SoundPlayer.play("death", -20.0, 0.1)


func add_effect(effect_data):	
	if effects.has(effect_data.name):
		var previous_effect = effects[effect_data.name]
		if previous_effect != null:
			previous_effect.stop()

	var effect: Node = load(GameData.effects[effect_data.name]).new()
	effect.subject = self
	for key in effect_data:
		effect[key] = effect_data[key]

	add_child(effect)
	effect.start()
	effects[effect_data.name] = effect


func remove_effect(effect_name):
	if effects.has(effect_name):
		var effect = effects[effect_name]
		if effect != null:
			effect.stop()
			effects[effect_name] = null


func remove_effects():
	for effect in effects:
		remove_effect(effect)


func add_effects(_effects):
	for effect in _effects:
		add_effect(effect)


func on_hit(hit: Dictionary):
	hp -= hit.damage

	SoundPlayer.play("hurt", -20.0)

	if hit.has("effects"):
		add_effects(hit.effects)


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
	
	var size_scale = data.get("size_scale", 1.0)
	scale.x *= size_scale
	scale.y *= size_scale

	add_effects(data.get("effects", []))
