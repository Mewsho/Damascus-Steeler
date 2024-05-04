extends Control


const target_scene_path = "res://world.tscn"

var loading_status : int
var progress : Array[float]

@onready var progress_bar : ProgressBar = $ProgressBar

func _ready():
	# Request to load the target scene:
	ResourceLoader.load_threaded_request(target_scene_path)
	
func _process(_delta: float):#Cada frame
	# Obtiene el status
	loading_status = ResourceLoader.load_threaded_get_status(target_scene_path, progress)
	
	# Revisa el status:
	match loading_status: #Esta wea es un switch encubierto
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress[0] * 100 # Change the ProgressBar value
		ResourceLoader.THREAD_LOAD_LOADED:
			# When done loading, change to the target scene:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(target_scene_path))
		ResourceLoader.THREAD_LOAD_FAILED:
			# Error
			print("Error. Could not load Resource")
