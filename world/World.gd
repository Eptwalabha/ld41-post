extends Node

export (float) var speed = 3
export (int) var bullet_speed = 1000
var Particle = preload("res://particles/Hit.tscn")
var Explosion = preload("res://tetris/Effects/Explosion.tscn")
var paused = false

func _ready():
	paused = false
	$Player.set_grid_position(floor($Grid.grid_width / 2), $Grid.grid_height - 1)
	$Player.connect("start_moving", self, "_on_Player_start_moving")
	$Player.connect("end_moving", self, "_on_Player_end_moving")
	$Player.connect("start_shooting", self, "_on_Player_start_shooting")
	$Player.connect("end_shooting", self, "_on_Player_end_shooting")
	$Player.connect("collide_with", self, "_on_Player_collide_with")
	$Grid.connect("block_destroyed", self, "_on_Block_destroyed")
	$Grid.connect("move_down_ended", self, "_on_Grid_move_down_ended")
	$Grid.connect("move_ended", self, "_on_Grid_move_ended")
	$Tick.set_wait_time(speed)
	#$Tick.start()

func _process(delta):
	if paused:
		return
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		if $Player.shoot(self):
			pause()
	if $Player.ready_to_move():
		if Input.is_action_pressed("ui_right"):
			move_player(1)
		if Input.is_action_pressed("ui_left"):
			move_player(-1)

func _physics_process(delta):
	$Player.update_aiming($Grid)

func move_player(x):
	if $Grid.is_grid_position_available($Player.grid_position + Vector2(x, 0)):
		$Player.move_x(x)

func pause():
	paused = true
	$Tick.set_paused(paused)

func resume():
	paused = false
	$Tick.set_paused(paused)

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
	$Grid.move_block_down(.05)
	#$Tick.start()
	resume()

func _on_Bullet_hit(ray_result):
	var body = ray_result.collider
	spawn_hit_particle(ray_result.position, ray_result.normal.angle())
	if body.is_in_group("block"):
		$Grid.block_has_been_hit(body, ray_result.normal)

func _on_Tick_timeout():
	$Grid.move_block_down(.1)

func _on_Grid_move_down_ended():
	#$Tick.start()
	pass

func _on_Grid_move_ended():
	pass

# Player's signals
func _on_Player_start_shooting():
	pause()

func _on_Player_end_shooting():
	$Tween.interpolate_callback(self, 0.1, "move_down")
	$Tween.start()

func _on_Player_collide_with(block):
	if block.is_in_group("block"):
		var positions = block.parent_tetromino.destroy_all_blocks()
		for pos in positions:
			spawn_explosion(pos, 0)

func _on_Player_start_moving(from):
	pause()

func _on_Player_end_moving(to):
	$Tween.interpolate_callback(self, 0.1, "move_down")
	$Tween.start()

func _on_Block_destroyed(position):
	spawn_explosion(position)