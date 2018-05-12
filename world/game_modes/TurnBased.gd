extends "res://world/game_modes/GameMode.gd"

func player_end_shooting():
	player_paused = false
	_move_blocks_down(0.1)

func player_end_moving(to):
	player_paused = false
	_move_blocks_down(0.1)