extends Node2D

var type = 0
var grid_position = Vector2()

func _ready():
	pass

func init(grid_x, grid_y, type):
	grid_position = Vector2(grid_x, grid_y)
	self.type = type
	$Sprite.frame = type
	update_position()

func move_down(speed):
	grid_position.y += 1

func move_to (direction):
	grid_position += direction

func _process(delta):
	update_position()

func update_position():
	position = grid_position * 32
