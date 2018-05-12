extends Node

var Particle = preload("res://particles/Hit.tscn")
var Explosion = preload("res://tetris/Effects/Explosion.tscn")

onready var modes = {
	'turn-based': $GameModes/TurnBased,
	'real-time': $GameModes/RealTime
}
var game_mode = null

func _ready():
	_change_game_mode('real-time')
	$Player.set_grid_position(floor($Grid.grid_width / 2), $Grid.grid_height - 1)
	$Player.connect("start_moving", self, "_on_Player_start_moving")
	$Player.connect("end_moving", self, "_on_Player_end_moving")
	$Player.connect("start_shooting", self, "_on_Player_start_shooting")
	$Player.connect("end_shooting", self, "_on_Player_end_shooting")
	$Player.connect("collide_with", self, "_on_Player_collide_with")
	$Grid.connect("block_destroyed", self, "_on_Grid_block_destroyed")
	$Grid.connect("start_moving_blocks_down", self, "_on_Grid_start_moving_blocks_down")
	$Grid.connect("end_moving_blocks_down", self, "_on_Grid_end_moving_blocks_down")
	$Tick.set_wait_time(0.5)

func _change_game_mode(mode_name):
	if modes[mode_name]:
		game_mode = modes[mode_name]
		game_mode.init(self, $Player)

func _process(delta):
	game_mode.process(delta)

func _physics_process(delta):
	$Player.update_aiming($Grid)

func move_player(x):
	if $Grid.is_grid_position_available($Player.grid_position + Vector2(x, 0)):
		$Player.move_x(x)

func spawn_explosion(grid_position):
	var explosion = Explosion.instance()
	explosion.position = grid_position * 32
	explosion.position += Vector2(16, 16)
	add_child(explosion)
	explosion.play()

func spawn_hit_particle(position, rotation):
	var particle = Particle.instance()
	particle.position = position
	particle.rotation = rotation
	add_child(particle)
	particle.set_emitting(true)
	return particle

func move_down():
	game_mode.move_down(0.05)

func _on_Bullet_hit(ray_result):
	var body = ray_result.collider
	spawn_hit_particle(ray_result.position, ray_result.normal.angle())
	if body.is_in_group("block"):
		$Grid.block_has_been_hit(body, ray_result.normal)

func _on_Tick_timeout():
	$Grid.move_block_down(.1)

# Grid's signals
func _on_Grid_start_moving_blocks_down():
	game_mode.grid_start_moving_blocks_down()

func _on_Grid_end_moving_blocks_down():
	game_mode.grid_end_moving_blocks_down()

func _on_Grid_block_destroyed(position):
	spawn_explosion(position)

# Player's signals
func _on_Player_start_shooting():
	game_mode.player_start_shooting()

func _on_Player_end_shooting():
	game_mode.player_end_shooting()

func _on_Player_collide_with(block):
	if block.is_in_group("block"):
		var positions = block.parent_tetromino.destroy_all_blocks()
		for pos in positions:
			spawn_explosion(pos)

func _on_Player_start_moving(from):
	game_mode.player_start_moving(from)

func _on_Player_end_moving(to):
	game_mode.player_end_moving(to)