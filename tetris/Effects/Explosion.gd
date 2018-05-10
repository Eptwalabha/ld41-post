extends Sprite

func _ready():
	visible = false
	$Animation.connect("animation_finished", self, "animation_finished")

func animation_finished(name):
	queue_free()

func play():
	$Animation.play("explode")
	visible = true
