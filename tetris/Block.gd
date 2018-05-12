extends Node2D

var type = 0
var grid_position = Vector2()
var offset = Vector2()
var parent_tetromino = null
var destruct = false

func init(grid_x, grid_y, type, tetromino = null):
	grid_position = Vector2(grid_x, grid_y)
	self.type = type
	parent_tetromino = tetromino
	$Sprite.frame = type
	_update_position()

func set_tint(color):
	$Sprite.modulate = color

func move_down(tween_duration = 0):
	move_to(Vector2(0, 1), tween_duration)

func move_to (direction, tween_duration = 0):
	grid_position += direction
	if tween_duration > 0:
		offset += direction * -1
		_interpolate(tween_duration)

func _interpolate(tween_duration):
	$Tween.interpolate_property(self, "offset",
				offset, Vector2(0, 0),
				tween_duration,
				Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _process(delta):
	_update_position()

func _update_position():
	position = (grid_position + offset) * 32
