extends Node

export (float) var speed = 1
export (int) var bullet_speed = 1000
var Particle = preload("res://particles/Hit.tscn")
var paused = false

func _ready():
	paused = false
	$Tick.set_wait_time(speed)
	$Tick.start()
	pass

func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and not paused:
		var direction = get_mouse_direction($Player.position)
		$Player.shoot(self, direction)

func _physics_process(delta):
	update_player_aiming()

func update_player_aiming():
	var direction = get_mouse_direction($Player.position)
	var points = $Grid.get_collisions($Player.position, direction, $Player.aiming_size)
	$Player.update_aiming(points)

func get_mouse_direction(position):
	return (get_viewport().get_mouse_position() - position).normalized()

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
		$Grid.move_block_to(body, ray_result.normal * -1)

func _on_Bullet_end():
	resume()

func _on_Tick_timeout():
	$Grid.move_block_down(speed / 3)
	
func _on_Grid_move_down_ended():
	$Tick.start()