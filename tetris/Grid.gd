extends Node2D

signal move_down_ended
signal move_ended
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

func _ready():
	pass

func _process(delta):
	pass

func move_block_down(speed):
	next_block()
	clean_old_blocks()
	check_for_full_raw()
	for tetromino in $Tetrominos.get_children():
		tetromino.move_down(speed)
	$Tween.interpolate_callback(self, speed, "move_down_ended")
	$Tween.start()

func next_block():
	spawn -= 1
	if spawn <= 0:
		var shape_i = randi() % shapes.size()
		var spec = {
			'type': randi() % 4,
			'tint': colors[shape_i].lightened(0.75),
			'shape': shapes[shape_i],
			'offset_x': randi() % 6
		}
		spawn_tetromino_at(randi() % grid_width, -1, spec)
		spawn = 2

func clean_old_blocks():
	for tetromino in $Tetrominos.get_children():
		for block in tetromino.get_blocks():
			if block.grid_position.y > grid_height + 1:
				block.queue_free()
		tetromino.destroy_if_empty()

func check_for_full_raw():
	var grid = get_current_grid()
	for i in range(grid_height):
		if is_line_complete(i, grid):
			delete_line(i)

func is_line_complete(line_number, grid):
	for i in range(grid_width):
		if grid[i][line_number] == null:
			return false
	return true

func delete_line(line_number):
	for tetromino in $Tetrominos.get_children():
		for block in tetromino.get_blocks():
			if block.grid_position.y == line_number:
				block.queue_free()

func get_current_grid():
	var grid = []
	grid.resize(grid_width)
	for x in range(grid_width):
		grid[x] = []
		grid[x].resize(grid_height)
		for y in range(grid_height):
			grid[x][y] = null
	for tetromino in $Tetrominos.get_children():
		for block in tetromino.get_blocks():
			if within_bounds(block.grid_position):
				grid[block.grid_position.x][block.grid_position.y] = block
	return grid

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
		block.move_to(direction, trans_speed)
	$Tween.interpolate_callback(self, trans_speed, "move_ended")
	$Tween.start()

func move_tetromino_to(block, direction):
	var tetromino = block.parent
	if tetromino:
		if can_move_tetromino(tetromino, direction):
			tetromino.move_to(direction, trans_speed)
	$Tween.interpolate_callback(self, trans_speed, "move_ended")
	$Tween.start()

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
			if eq(block.grid_position, grid_position):
				return block
	return null

# see https://github.com/godotengine/godot/issues/17971
func eq(a, b):
	return abs(a.x - b.x) < 0.00001 and abs(a.y - b.y) < 0.00001

func is_grid_position_available(grid_position):
	return within_bounds(grid_position) and not block_at(grid_position)

func within_bounds(position):
	return within_bounds_x(position.x) and position.y >= 0 and position.y < grid_height

func within_bounds_x(x):
	return x >= 0 and x < grid_width

func move_down_ended():
	emit_signal("move_down_ended")

func move_ended():
	emit_signal("move_ended")