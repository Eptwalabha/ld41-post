extends Sprite

func _ready():
	visible = false
	$Animation.connect("animation_finished", self, "_on_animation_finished")

func play():
	$Animation.play("explode")
	visible = true

func _on_animation_finished(name):
	queue_free()