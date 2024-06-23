extends ColorRect

"""
Description:
	A ColorRect that plays an animation adding red colors to underlying
	CanvasItems
"""

@onready var _animator = $AnimationPlayer

@export var playback_speed = 1.0

func blink():
	show()
	_animator.speed_scale = playback_speed
	_animator.play("blink")
	await _animator.animation_finished
	hide()
