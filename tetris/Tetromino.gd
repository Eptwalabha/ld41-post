extends Node

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

func init(x, y, spec):
	x = randi() % 6
	var type = randi() % 4
	var shape = shapes[randi() % shapes.size()]
	for block_spec in shape:
		var block = preload("res://tetris/Block.tscn").instance()
		block.init(block_spec.x + x, block_spec.y - 1, type, self)
		$Blocks.add_child(block)

func move_down():
	for block in $Blocks.get_children():
		block.grid_position.y += 1

func move_to(direction):
	for block in $Blocks.get_children():
		block.move_to(direction)

func get_blocks():
	return $Blocks.get_children()

func destroy_if_empty():
	if $Blocks.get_children().size() == 0:
		queue_free()
