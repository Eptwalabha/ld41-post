extends Node

var type

func _ready():
	pass

func init(x, y, spec):
	type = spec.type
	for block_spec in spec.shape:
		var block = preload("res://tetris/Block.tscn").instance()
		block.init(block_spec.x + spec.offset_x, block_spec.y - 1, spec.type, self)
		block.set_tint(spec.tint)
		$Blocks.add_child(block)

func move_down(tween_duration):
	for block in $Blocks.get_children():
		block.move_down(tween_duration)

func move_to(direction, tween_duration):
	for block in $Blocks.get_children():
		block.move_to(direction, tween_duration)

func get_blocks():
	return $Blocks.get_children()

func destroy_if_empty():
	if $Blocks.get_children().size() == 0:
		queue_free()

func destroy_all_blocks():
	var points = []
	for block in $Blocks.get_children():
		points.append(block.grid_position)
	queue_free()
	return points