extends Node2D

export (int) var bullet_bounces = 1
export (int) var bullet_speed = 800
export (float) var cooldown_amount = 0.5
export (float) var cooldown = 0

func shoot(position, direction):
	return null

func can_shoot():
	return false

func update(delta):
	pass

func get_collision_path(position, direction):
	var points = [position]
	var next = next_collision_point(position, direction)
	var i = 0
	while (next and i <= bullet_bounces):
		i += 1
		points.append(next.position)
		next = next_collision_point(next.position, next.direction, next)
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