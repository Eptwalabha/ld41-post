extends Node

var type

func _ready():
	pass

func init(x, y, spec):
	type = spec.type
	for block_spec in spec.shape:
		var block = preload("res://tetris/Block.tscn").instance()
		block.init(block_spec.x + spec.offset_x, block_spec.y - 1, spec.type, self)
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
