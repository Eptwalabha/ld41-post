extends Node2D

signal move_down_ended

export (int) var grid_width = 8
export (int) var grid_height = 10

func _ready():
	for i in range(grid_width):
		for j in range(grid_height / 2):
			if randi() % 10 <= 1:
				var block = preload("res://tetris/Block.tscn").instance()
				block.init(i, j, randi() % 4)
				$Blocks.add_child(block)

func _process(delta):
	pass

func move_block_down(speed):
	for block in $Blocks.get_children():
		block.move_down(speed / 3)
	emit_signal("move_down_ended")

func move_block_to(block, direction):
	var next_position = block.grid_position + direction
	if within_bounds(next_position) and grid_position_is_available(next_position):
		block.move_to(direction)

func within_bounds(position):
	return position.x >= 0 and position.y >= 0 and position.x < grid_width and position.y < grid_height

func grid_position_is_available(position):
	for block in $Blocks.get_children():
		if eq(block.grid_position.x, position.x) and eq(block.grid_position.y, position.y):
			return false
	return true

func eq(a, b):
	return abs(a - b) < 0.0001