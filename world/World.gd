extends Node

export (float) var speed = 3
export (int) var bullet_speed = 1000
var Particle = preload("res://particles/Hit.tscn")
var paused = false

func _ready():
	paused = false
	$Player.set_grid_position(floor($Grid.grid_width / 2), $Grid.grid_height - 1)
	$Player.connect("player_moved", self, "_on_Player_moved")
	$Tick.set_wait_time(speed)
	$Tick.start()

func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and not paused:
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

func spawn_hit_particle(position, rotation):
	var particle = Particle.instance()
	particle.position = position
	particle.rotation = rotation
	add_child(particle)
	particle.set_emitting(true)
	return particle

func _on_Bullet_hit(ray_result):
	var body = ray_result.collider
	spawn_hit_particle(ray_result.position, ray_result.normal.angle())
	if body.is_in_group("block"):
		if body.type == 1:
			body.queue_free()
		else:
			$Grid.move_block_to(body, ray_result.normal * -1)

func _on_Bullet_end():
	$Grid.move_block_down(speed / 3)
	$Tick.start()
	resume()

func _on_Tick_timeout():
	$Grid.move_block_down(speed / 3)

func _on_Grid_move_down_ended():
	$Tick.start()

func _on_Player_moved():
	$Grid.move_block_down(speed / 3)
	$Tick.start()

func _on_Player_fired():
	pause()
