extends Node2D

signal move_down_ended
signal block_destroyed(position)

var grid_width = 10
var grid_height = 22
var spawn = 0

var shapes = [
	[Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(0, 1)],	# L
	[Vector2(0, 1), Vector2(1, 1), Vector2(2, 1), Vector2(0, 0)],	# J
	[Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(3, 0)],	# I
	[Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(1, 1)],	# T
	[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(2, 1)],	# S
	[Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(2, 0)]	# Z
]

func _ready():
	pass

func _process(delta):
	pass

func move_block_down(speed):
	if spawn <= 0:
		var spec = {
			'type': randi() % 4,
			'shape': shapes[randi() % shapes.size()],
			'offset_x': randi() % (grid_width - 4)
		}
		spawn_tetromino_at(randi() % grid_width, -1, spec)
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

func block_has_been_hit(block, normal):
	match block.type:
		0:	move_block_to(block, normal * -1)
		1:	destroy_block(block)
		2:	move_tetromino_to(block, normal * -1)
		_:	pass

func destroy_block(block):
	emit_signal("block_destroyed", block.grid_position)
	block.queue_free()

func spawn_tetromino_at(x, y, tetromino_spec):
	var tetromino = preload("res://tetris/Tetromino.tscn").instance()
	tetromino.init(x, y, tetromino_spec)
	$Tetrominos.add_child(tetromino)

func move_block_to(block, direction):
	if can_move_block(block, direction):
		block.move_to(direction)

func move_tetromino_to(block, direction):
	var tetromino = block.parent
	if tetromino:
		if can_move_tetromino(tetromino, direction):
			tetromino.move_to(direction)

func can_move_block(block, direction, true_if_same_parent = false):
	var next_position = block.grid_position + direction
	if not within_bounds(next_position):
		return false
	var block_at = block_at(next_position)
	if not block_at:
		return true
	return true_if_same_parent and block_at.parent == block.parent

func can_move_tetromino(tetromino, direction):
	for block in tetromino.get_blocks():
		if not can_move_block(block, direction, true):
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