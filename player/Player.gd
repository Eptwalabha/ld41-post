extends Node2D

export (int) var aiming_size = 5

var weapon = null

onready var weapon_types = {
	'regular': $Weapon/Regular
}

func _ready():
	weapon = $Weapon/Regular
	for i in range(aiming_size + 1):
		$Aiming.add_point(Vector2())
	pass

func _process(delta):
	weapon.update(delta)
	pass

func update_aiming(points):
	for i in points.size():
		$Aiming.points[i + 1] = points[i] - position

func set_weapon(weapon_name):
	if weapon_types[weapon_name]:
		weapon = weapon_types[weapon_name]

func shoot(parent, direction):
	if weapon.can_shoot():
		var bullet = weapon.shoot(position, direction)
		if bullet:
			bullet.ttl = aiming_size
			parent.add_child(bullet)
			bullet.start()
			bullet.connect("bullet_end", parent, "_on_Bullet_end")
			bullet.connect("bullet_hit", parent, "_on_Bullet_hit")