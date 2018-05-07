extends "res://weapon/weapon.gd"

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

func get_collision_path(position, direction):
	var points = [position]
	var next = next_collision_point(position, direction)
	if next:
		points.append(next.position)
	return points

func next_collision_point(position, direction, previous = null):
	var exclude = [3]
	if previous:
		exclude = [previous.rid, 3]
	var result = get_world_2d().direct_space_state.intersect_ray(position, position + direction * 1000, exclude, 3)
	if result.empty() or result.normal == Vector2(0, 0):
		return null
	else:
		return process_collision(direction, result)

func process_collision(direction, result):
	return {
		'position': result.position,
		'direction': direction.bounce(result.normal),
		'rid': result.rid,
		'result': result
	}

func can_shoot():
	return cooldown <= 0