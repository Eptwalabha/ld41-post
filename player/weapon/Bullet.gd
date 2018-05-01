extends Node2D

signal bullet_end
signal bullet_hit(result)

var bounces
var direction = Vector2()

var weapon
var next

func _ready():
	$Tween.connect("tween_completed", self, "_on_tween_completed")
	pass

func init(position, direction, weapon):
	self.position = position
	self.direction = direction
	self.weapon = weapon

func start():
	bounces = weapon.bullet_bounces
	next_move()

func next_move():
	next = weapon.next_collision_point(position, direction, next)
	if next:
		var duration = position.distance_to(next.position) / weapon.bullet_speed
		$Tween.interpolate_property(
					self, "position",
					position, next.position,
					duration,
					Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
	else:
		destroy_bullet()

func _on_tween_completed(obj, prop):
	emit_signal("bullet_hit", next.result)
	if bounces > 0:
		bounces -= 1
		direction = next.direction
		next_move()
	else:
		destroy_bullet()

func destroy_bullet():
	emit_signal("bullet_end")
	queue_free()