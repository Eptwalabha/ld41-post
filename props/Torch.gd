extends Node2D

signal lit

export (bool) var lit = false

func _ready():
	if lit:
		$Sprite.frame = 1
	else:
		$Sprite.frame = 0
	$Fire.set_emitting(lit)

func light():
	emit_signal("lit")
	lit = true
	$Sprite.frame = 1
	$Fire.set_emitting(true)

func extinguish():
	lit = false
	$Fire.set_emitting(false)

func _on_Area2D_area_entered(area):
	light()
