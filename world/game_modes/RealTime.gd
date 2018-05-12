extends "res://world/game_modes/GameMode.gd"

var tick

func init(world, player):
	self.world = world
	self.player = player
	tick = world.get_node("Tick")
	tick.connect("timeout", self, "_on_tick_timeout")
	tick.start()

func player_shoot():
	player.shoot(world)

func grid_end_moving_blocks_down():
	tick.start()

func _on_tick_timeout():
	_move_blocks_down(0.1)