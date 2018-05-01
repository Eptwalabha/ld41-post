extends Particles2D

var timeout

func _ready():
	timeout = lifetime

func _process(delta):
	timeout -= delta
	if timeout <= 0:
		queue_free()
	
