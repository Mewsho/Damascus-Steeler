extends Node3D

## Script del escenario default, llama a otras funciones y tiene el metodo de pausa

## Cargar los elementos a usar
@onready var grid_map = $GridMap as GridMap
@onready var grid_map_aux = $GridMapAux
@onready var grid_map_scenery = $GridMapScenery
@onready var pause_menu = $PauseMenu as PauseMenu
@onready var player_position = $PlayerPosition as Marker3D
@onready var core = get_tree().get_root().get_node("Core") as Node
@onready var camera_controller = $CameraController
@onready var pillars = $Pillars
@onready var background_church = $BackgroundChurch

var t:float = 0.0
var prev_camera_pos = 0
var paused : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	var ini = Time.get_ticks_msec()
	#PCGcurrent.PCG_General() ## Invoca a la generacion procedural
	#var chunks = PCGcurrent.get_chunk_eleg(idos() ## Guarda los chunks elegidos
	var chunks = core._get_chunks_elegidos()
	PCGcurrent.chunks_creation(chunks,grid_map, grid_map_aux, grid_map_scenery) ## Los dibuja en el mundo
	var fin = Time.get_ticks_msec()
	print("Tiempo ejecucion pst pcg chunk creation:", fin-ini)
	pillars.global_position.x = -camera_controller.global_position.x
	prev_camera_pos = camera_controller.global_position
	
func _process(delta):
	## Revisa constantemente si alguien quiere pausar
	for player in range(PlayerManager.get_player_count()):
		var device = PlayerManager.get_player_device(player)
		if device != null:
			if MultiplayerInput.is_action_just_pressed(device, "pause"):
				core.get_node("HUD").visible = false
				pause_menu_pressed()

	
	if camera_controller.global_position.is_equal_approx(prev_camera_pos):
		return
	pillars.global_transform.origin.x = lerp(pillars.global_transform.origin.x, -camera_controller.global_position.x, delta*0.05)
	background_church.global_transform.origin.x = lerp(background_church.global_transform.origin.x, -camera_controller.global_position.x, delta*0.015)
	
	prev_camera_pos = camera_controller.global_position

## Funcion cuando se apreta pause, se muestra el menu de pausa y se para el juego, para mostrar el menu de pausa
func pause_menu_pressed():
	print("test")
	if !paused:
		get_tree().paused = true
		pause_menu.visible = true
		pause_menu.set_hud()
		pause_menu.resume_button.grab_focus()
	else:
		get_tree().paused = false
		pause_menu.visible = false
	paused = !paused
