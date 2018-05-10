extends Node2D

var type = 0
var grid_position = Vector2()
var offset = Vector2()
var parent = null

func _ready():
	pass

func set_tetromino(tetromino):
	parent = tetromino

func init(grid_x, grid_y, type, parent = null):
	grid_position = Vector2(grid_x, grid_y)
	self.type = type
	self.parent = parent
	$Sprite.frame = type
	update_position()

func set_tint(color):
	$Sprite.modulate = color

func move_down(speed):
	move_to(Vector2(0, 1), speed)

func move_to (direction, speed):
	grid_position += direction
	offset += direction * -1
	interpolate(speed)

func interpolate(speed):
	$Tween.interpolate_property(self, "offset",
				offset, Vector2(0, 0),
				speed,
				Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _process(delta):
	update_position()

func update_position():
	position = (grid_position + offset) * 32
