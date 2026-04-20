class_name Note
extends Label

@onready var anim: AnimationPlayer = $AnimationPlayer


func  _ready() -> void:
	anim.play("fade")
	await anim.animation_finished
	queue_free()
