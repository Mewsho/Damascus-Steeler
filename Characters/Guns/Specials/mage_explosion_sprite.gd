extends AnimatedSprite3D

@onready var sfx = $SFX


func _ready():
	EventBus.emit_especial_shake()
	sfx.play()

func _on_animation_finished():
	queue_free()
