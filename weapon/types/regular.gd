extends "../weapon.gd"

func _ready():
	pass

func update(delta):
	if cooldown > 0:
		cooldown -= delta

func shoot(position, direction):
	cooldown = cooldown_amount
	var bullet = preload("res://weapon/Bullet.tscn").instance()
	bullet.init(position, direction, self)
	return bullet

func can_shoot():
	return cooldown <= 0