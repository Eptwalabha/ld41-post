extends Node

export (float) var speed = 1
export (int) var bullet_speed = 1000

var coolDown = 0

func _ready():
	$Tick.set_wait_time(speed)
	$Tick.start()
	pass

func _process(delta):
	if coolDown > 0:
		coolDown -= delta
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		shoot_bullet()

func _physics_process(delta):
	update_player_aiming()

func update_player_aiming():
	var direction = get_mouse_direction($Player.position)
	var points = $Grid.get_collisions($Player.position, direction, $Player.aiming_size)
	$Player.update_aiming(points)

func get_mouse_direction(position):
	return (get_viewport().get_mouse_position() - position).normalized()

func pause():
	$Tick.set_paused(true)

func resume():
	$Tick.set_paused(false)

func shoot_bullet():
	if can_shoot():
		var position = $Player.position
		var direction = get_mouse_direction(position)
		var bullet = preload("res://player/weapon/Bullet.tscn").instance()
		bullet.position = $Player.position
		add_child(bullet)
		bullet.init(position, direction, $Player.aiming_size, bullet_speed)
		bullet.connect("bullet_end", self, "resume")
		bullet.connect("bullet_hit", self, "bullet_hit")
		coolDown = .2
		pause()

func bullet_hit(ray_result):
	var body = ray_result.collider
	var hit_particle = preload("res://particles/Hit.tscn").instance()
	add_child(hit_particle)
	hit_particle.position = ray_result.position
	hit_particle.rotation = ray_result.normal.angle()
	hit_particle.set_emitting(true)
	if body.is_in_group("block"):
		$Grid.move_block_to(body, ray_result.normal * -1)

func can_shoot():
	return coolDown <= 0

func _on_Tick_timeout():
	$Grid.move_block_down(speed / 3)
	
func _on_Grid_move_down_ended():
	$Tick.start()