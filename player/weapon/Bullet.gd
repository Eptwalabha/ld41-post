extends Node2D

signal bullet_end
signal bullet_hit(result)

export (int) var ttl = 3
var speed
var next_position = Vector2()
var bounce_direction = Vector2()
var previous_result
var life = 0
var direction = Vector2()

func _ready():
	$Tween.connect("tween_completed", self, "_on_tween_completed")
	pass

func init(position, direction, ttl = 3, speed = 100):
	self.ttl = ttl
	self.speed = speed
	self.position = position
	self.direction = direction

func start():
	next_direction(position, direction)

func next_direction(position, direction):
	var space_state = get_world_2d().direct_space_state
	var exclude = [self]
	if previous_result:
		exclude = [self, previous_result.rid]
	var result = space_state.intersect_ray(position, position + direction * 1000, exclude, 3)
	if result.empty() or result.normal == Vector2(0, 0):
		destroy_bullet()
	else:
		previous_result = result
		next_position = result.position
		bounce_direction = direction.bounce(result.normal)
		var duration = position.distance_to(next_position) / speed
		$Tween.interpolate_property(
					self, "position",
					position, next_position,
					duration,
					Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()

func _on_tween_completed(obj, property):
	self.ttl -= 1
	if ttl <= 0:
		destroy_bullet()
	else:
		emit_signal("bullet_hit", previous_result)
		next_direction(next_position, bounce_direction)

func destroy_bullet():
	emit_signal("bullet_end")
	queue_free()