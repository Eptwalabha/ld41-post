extends "res://world/game_modes/GameMode.gd"

var tick
var wait_end_of_shooting = false
var down_on_end_bullet = false

func init(world, player):
	self.world = world
	self.player = player
	tick = world.get_node("Tick")
	tick.connect("timeout", self, "_on_tick_timeout")
	tick.start()

func player_shoot():
	player.shoot(world)

func player_start_shooting():
	player_paused = true
	wait_end_of_shooting = true

func player_end_shooting():
	player_paused = false
	wait_end_of_shooting = false
	if down_on_end_bullet:
		_move_blocks_down(0.1)
		down_on_end_bullet = false
		tick.start()

func grid_end_moving_blocks_down():
	down_on_end_bullet = false
	if not wait_end_of_shooting:
		tick.start()

func _on_tick_timeout():
	if not wait_end_of_shooting:
		_move_blocks_down(0.1)
	else:
		down_on_end_bullet = true