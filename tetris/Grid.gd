extends Node2D

signal start_moving_blocks_down
signal end_moving_blocks_down
signal block_destroyed(position)

var grid_width = 10
var grid_height = 22
var spawn = 0
var trans_speed = 0.1

var shapes = [
	[Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(3, 0)],	# I
	[Vector2(0, 1), Vector2(1, 1), Vector2(2, 1), Vector2(0, 0)],	# J
	[Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(0, 1)],	# L
	[Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)],	# O
	[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(2, 1)],	# S
	[Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(1, 1)],	# T
	[Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(2, 0)]	# Z
]

var colors = [
	Color("#aa0000"),
	Color("#aa00aa"),
	Color("#aaaa00"),
	Color("#00aaaa"),
	Color("#0000aa"),
	Color("#c0c0c0"),
	Color("#00aa00")
]

func move_block_down(tween_duration):
	emit_signal("start_moving_blocks_down")
	_next_block()
	_clean_old_blocks()
	var nbr_line_deleted = _check_for_full_raw()
	for tetromino in $Tetrominos.get_children():
		tetromino.move_down(tween_duration)
	var duration = tween_duration
	if nbr_line_deleted > 0:
		duration = tween_duration * 2
	$Tween.interpolate_callback(self, duration, "emit_signal", "end_moving_blocks_down")
	$Tween.start()

func block_has_been_hit(block, normal):
	match block.type:
		0:	_move_block_to(block, normal * -1)
		1:	_destroy_block(block)
		2:	_move_tetromino_to(block, normal * -1)
		_:	pass

func is_grid_position_available(grid_position):
	return _within_bounds(grid_position) and not _block_at(grid_position)

func _next_block():
	spawn -= 1
	if spawn <= 0:
		var shape_i = randi() % shapes.size()
		var spec = {
			'type': randi() % 4,
			'tint': colors[shape_i].lightened(0.75),
			'shape': shapes[shape_i],
			'offset_x': randi() % 6
		}
		_spawn_tetromino_at(randi() % grid_width, -1, spec)
		spawn = 2

func _clean_old_blocks():
	for tetromino in $Tetrominos.get_children():
		for block in tetromino.get_blocks():
			if block.grid_position.y >= grid_height:
				block.queue_free()
		tetromino.destroy_if_empty()

func _check_for_full_raw():
	var grid = _get_current_grid()
	var nbr_of_line_deleted = 0
	for i in range(grid_height):
		if _is_line_complete(i, grid):
			nbr_of_line_deleted += 1
			_delete_line(i)
	return nbr_of_line_deleted

func _is_line_complete(line_number, grid):
	for i in range(grid_width):
		if grid[i][line_number] == null:
			return false
	return true

func _delete_line(line_number):
	for tetromino in $Tetrominos.get_children():
		for block in tetromino.get_blocks():
			if block.grid_position.y == line_number:
				_destroy_block(block)

func _get_current_grid():
	var grid = []
	grid.resize(grid_width)
	for x in range(grid_width):
		grid[x] = []
		grid[x].resize(grid_height)
		for y in range(grid_height):
			grid[x][y] = null
	for tetromino in $Tetrominos.get_children():
		for block in tetromino.get_blocks():
			if _within_bounds(block.grid_position):
				grid[block.grid_position.x][block.grid_position.y] = block
	return grid

func _destroy_block(block, delay = 0):
	emit_signal("block_destroyed", block.grid_position)
	block.queue_free()

func _spawn_tetromino_at(x, y, tetromino_spec):
	var tetromino = preload("res://tetris/Tetromino.tscn").instance()
	tetromino.init(x, y, tetromino_spec)
	$Tetrominos.add_child(tetromino)

func _move_block_to(block, direction):
	if _can_move_block(block, direction):
		block.move_to(direction, trans_speed)

func _move_tetromino_to(block, direction):
	var tetromino = block.parent_tetromino
	if tetromino:
		if _can_move_tetromino(tetromino, direction):
			tetromino.move_to(direction, trans_speed)

func _can_move_block(block, direction, true_if_same_parent = false):
	var next_position = block.grid_position + direction
	if not _within_bounds(next_position):
		return false
	var block_at = _block_at(next_position)
	if not block_at:
		return true
	return true_if_same_parent and block_at.parent_tetromino == block.parent_tetromino

func _can_move_tetromino(tetromino, direction):
	for block in tetromino.get_blocks():
		if not _can_move_block(block, direction, true):
			return false
	return true

func _block_at(grid_position):
	for tetromino in $Tetrominos.get_children():
		for block in tetromino.get_blocks():
			if _eq(block.grid_position, grid_position):
				return block
	return null

# see https://github.com/godotengine/godot/issues/17971
func _eq(a, b):
	return abs(a.x - b.x) < 0.00001 and abs(a.y - b.y) < 0.00001

func _within_bounds(position):
	return _within(position.x, 0, grid_width) and _within(position.y, 0, grid_height)

func _within(x, _min, _max):
	return x >= _min and x < _max
