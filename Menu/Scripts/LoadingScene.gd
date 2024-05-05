extends Control

## DEPRECATED
## Script de la scena de pantalla de carga que se usaba anteriormente, no se a vuelto a implementar

## Escena objetivo
const target_scene_path = "res://world.tscn"

var loading_status : int
var progress : Array[float]
##Carga el objeto de la escena
@onready var progress_bar : ProgressBar = $ProgressBar


func _ready():
	# Cuando carga la escena, empieza a cargar de fondo la escena objetivo
	ResourceLoader.load_threaded_request(target_scene_path)
	
func _process(_delta: float):#Cada frame
	# Obtiene el status de la escena de fondo
	loading_status = ResourceLoader.load_threaded_get_status(target_scene_path, progress)
	
	# Revisa el status:
	match loading_status: # Dependiendo del estado hace distintas cosas
		ResourceLoader.THREAD_LOAD_IN_PROGRESS: # Cambia el valor de la barra
			progress_bar.value = progress[0] * 100 # Change the ProgressBar value
		ResourceLoader.THREAD_LOAD_LOADED: # Si cargo carga la escena
			# When done loading, change to the target scene:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(target_scene_path))
		ResourceLoader.THREAD_LOAD_FAILED: # Error
			print("Error. Could not load Resource")
