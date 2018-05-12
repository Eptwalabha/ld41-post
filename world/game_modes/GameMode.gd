extends Node

var world
var player
var player_paused = false

func init(world, player):
	print(world, player)
	self.world = world
	self.player = player

func process(delta):
	if not player_paused:
		_player_input()

func _player_input():
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		player_shoot()
	if player.ready_to_move():
		var x = 0
		if Input.is_action_pressed("ui_right"):
			x += 1
		if Input.is_action_pressed("ui_left"):
			x -= 1
		if x != 0:
			world.move_player(x)

func player_shoot():
	player.shoot(world)

func _move_blocks_down(duration):
	var tween = world.get_node("Tween")
	tween.interpolate_callback(self, 0.1, "_do_move_blocks_down", duration)
	tween.start()

func _do_move_blocks_down(duration):
	world.get_node("Grid").move_block_down(duration)

func player_start_shooting():
	player_paused = true

func player_end_shooting():
	player_paused = false

func player_start_moving(from):
	player_paused = true

func player_end_moving(to):
	player_paused = false

func grid_end_moving_blocks_down():
	pass

func grid_start_moving_blocks_down():
	pass