extends Node2D

signal moved
signal fired

var weapon = null
var grid_position = Vector2()
var tween_position = Vector2()
var moving = false

onready var weapon_types = {
	'regular': $Weapon/Regular,
	'laser': $Weapon/Laser
}

func _ready():
	set_weapon('regular')
	$Aiming.add_point(Vector2())
	$Tween.connect("tween_completed", self, "_on_Tween_movement_completed")
	$Sprite.frame = 2
	tween_position = position

func _process(delta):
	weapon.update(delta)
	position = tween_position

func update_aiming(grid):
	var direction = get_mouse_direction()
	if direction.x == 0 and direction.y == 0:
		direction = Vector2(0, -1)
	var points = weapon.get_collision_path(position, direction)
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

func move_x(x):
	moving = true
	grid_position.x += x
	var next_position = grid_position * 32 + Vector2(16, 16)
	$Tween.interpolate_property(
				self, "tween_position",
				position, next_position,
				.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func ready_to_move():
	return not moving

func set_grid_position(x, y):
	grid_position = Vector2(x, y)
	position = grid_position * 32 + Vector2(16, 16)
	tween_position = position

func set_weapon(weapon_name):
	if weapon_types[weapon_name]:
		weapon = weapon_types[weapon_name]
		$Aiming.default_color = weapon.get_aiming_color()

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
			emit_signal("fired")

func _on_Tween_movement_completed(obj, key):
	moving = false
	emit_signal("moved")