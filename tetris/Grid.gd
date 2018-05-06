extends Node2D

signal move_down_ended

var grid_width = 10
var grid_height = 22
var spawn = 0

func _ready():
	pass

func _process(delta):
	pass

func move_block_down(speed):
	if spawn <= 0:
		spawn_tetromino_at(randi() % grid_width, -1, null)
		spawn = 3
	spawn -= 1
	clean_old_blocks()
	check_for_full_raw()
	for tetromino in $Tetrominos.get_children():
		tetromino.move_down()
	emit_signal("move_down_ended")

func clean_old_blocks():
	for tetromino in $Tetrominos.get_children():
		for block in tetromino.get_blocks():
			if block.grid_position.y > grid_height + 1:
				block.queue_free()
		tetromino.destroy_if_empty()

func check_for_full_raw():
	# delete line of blocks here
	pass

func spawn_tetromino_at(x, y, tetromino_spec):
	var tetromino = preload("res://tetris/Tetromino.tscn").instance()
	tetromino.init(x, y, tetromino_spec)
	$Tetrominos.add_child(tetromino)

func move_block_to(block, direction):
	if block.parent:
		var tetromino = block.parent
		if can_move_tetromino(tetromino, direction):
			tetromino.move_to(direction)

func can_move_tetromino(tetromino, direction):
	for block in tetromino.get_blocks():
		var next_position = block.grid_position + direction
		if not within_bounds(next_position):
			return false
		var block_at = block_at(next_position)
		if block_at and block_at.parent != tetromino:
			return false
	return true

func block_at(grid_position):
	for tetromino in $Tetrominos.get_children():
		for block in tetromino.get_blocks():
			if block.grid_position.x == grid_position.x and block.grid_position.y == grid_position.y:
				return block
	return null

func is_grid_position_available(grid_position):
	return within_bounds(grid_position) and not block_at(grid_position)

func within_bounds(position):
	return within_bounds_x(position.x) and position.y >= 0 and position.y < grid_height

func within_bounds_x(x):
	return x >= 0 and x < grid_width