extends Node2D

var weapon = null
onready var weapon_types = {
	'regular': $Weapon/Regular
}

func _ready():
	weapon = $Weapon/Regular
	$Aiming.add_point(Vector2())

func _process(delta):
	weapon.update(delta)

func update_aiming(grid):
	var points = weapon.get_collision_path(position, get_mouse_direction())
	var points_count = points.size()
	var sight_points_count = $Aiming.get_point_count()
	var diff = sight_points_count - points_count
	if diff < 0:
		for i in abs(diff):
			$Aiming.add_point(Vector2())
	elif diff > 0:
		for i in abs(diff):
			$Aiming.remove_point(i)
	for i in points.size():
		$Aiming.points[i] = points[i] - position

func set_weapon(weapon_name):
	if weapon_types[weapon_name]:
		weapon = weapon_types[weapon_name]

func get_mouse_direction():
	return (get_viewport().get_mouse_position() - position).normalized()

func shoot(parent):
	if weapon.can_shoot():
		var direction = get_mouse_direction()
		var bullet = weapon.shoot(position, direction)
		if bullet:
			parent.add_child(bullet)
			bullet.start()
			bullet.connect("bullet_end", parent, "_on_Bullet_end")
			bullet.connect("bullet_hit", parent, "_on_Bullet_hit")