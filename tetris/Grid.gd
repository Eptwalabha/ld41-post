extends Node2D

signal move_down_ended

var grid_width = 10
var grid_height = 22

func _ready():
	for i in range(grid_width):
		for j in range(grid_height / 10 * 9):
			if randi() % 10 <= 6:
				spawn_block_at(i, j, randi() % 4)

func _process(delta):
	pass

func move_block_down(speed):
	spawn_block_at(randi() % grid_width, -1, randi() % 4)
	clean_old_blocks()
	check_for_full_raw()
	for block in $Blocks.get_children():
		block.move_down(speed / 3)
	emit_signal("move_down_ended")

func clean_old_blocks():
	for block in $Blocks.get_children():
		if block.grid_position.y > grid_height + 1:
			block.queue_free()

func check_for_full_raw():
	# delete line of blocks here
	pass

func spawn_block_at(x, y, type):
	var block = preload("res://tetris/Block.tscn").instance()
	block.init(x, y, type)
	$Blocks.add_child(block)

func move_block_to(block, direction):
	var next_position = block.grid_position + direction
	if within_bounds(next_position) and grid_position_is_available(next_position):
		block.move_to(direction)

func block_at(x, y):
	for block in $Blocks.get_children():
		if block.grid_position.x == x and block.grid_position.y == y:
			return block
	return null

func is_grid_position_available(x, y):
	return within_bounds(Vector2(x, y)) and not block_at(x, y)

func within_bounds(position):
	return within_bounds_x(position.x) and position.y >= 0 and position.y < grid_height

func within_bounds_x(x):
	return x >= 0 and x < grid_width

func grid_position_is_available(position):
	for block in $Blocks.get_children():
		if eq(block.grid_position.x, position.x) and eq(block.grid_position.y, position.y):
			return false
	return true

func eq(a, b):
	return abs(a - b) < 0.0001