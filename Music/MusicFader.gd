extends AudioStreamPlayer


"""
Description:
	An AudioStreamPlayer with the ability of fading between two 
	AudioStreams
	https://pigdev.itch.io/audio-kit
"""

@export var fade_time: float = 1.0
@export var fade_floor = 0.1 # (float, 0.0, 1.0)

var tween : Tween


func fade_to(audio_stream):
	tween = create_tween()
	if tween.is_running():
		return
	var current_volume = volume_db
	tween.interpolate_property(self, "volume_db", current_volume,
			linear_to_db(fade_floor), fade_time, tween.TRANS_LINEAR,
			tween.EASE_IN)
	tween.start()
	
	await tween.tween_completed
	stream = audio_stream
	play()
	tween.interpolate_property(self, "volume_db", linear_to_db(fade_floor),
			current_volume, fade_time, tween.TRANS_LINEAR,
			tween.EASE_IN)
	tween.start()
