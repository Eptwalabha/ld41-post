extends "../weapon.gd"

var cooldown = 0
export (float) var cooldown_amount = 0.5
var bullet_ttl = 5
var bullet_speed = 800

func _ready():
	pass

func update(delta):
	if cooldown > 0:
		cooldown -= delta

func shoot(position, direction):
	cooldown = cooldown_amount
	var bullet = preload("res://player/weapon/Bullet.tscn").instance()
	bullet.position = position
	bullet.init(position, direction, bullet_ttl, bullet_speed)
	return bullet

func can_shoot():
	return cooldown <= 0