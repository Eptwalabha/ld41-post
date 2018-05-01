extends Node2D

export (int) var aiming_size = 5

func _ready():
	for i in range(aiming_size + 1):
		$Aiming.add_point(Vector2())
	pass

func _process(delta):
	pass

func update_aiming(points):
	for i in points.size():
		$Aiming.points[i + 1] = points[i] - position