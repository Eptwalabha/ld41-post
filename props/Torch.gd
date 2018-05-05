extends Node2D

export (bool) var lighten = false

func _ready():
	if lighten:
		$Sprite.frame = 1
	else:
		$Sprite.frame = 0
	$Fire.set_emitting(lighten)

func light():
	lighten = true
	$Sprite.frame = 1
	$Fire.set_emitting(true)

func extinguish():
	lighten = false
	$Fire.set_emitting(false)
