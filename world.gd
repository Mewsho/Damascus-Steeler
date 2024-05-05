extends Node3D

## Script del escenario default, llama a otras funciones y tiene el metodo de pausa

## Cargar los elementos a usar
@onready var grid_map = $GridMap as GridMap
@onready var pause_menu = $PauseMenu as PauseMenu
var paused : bool = false
var pj = load("res://Level/CharacterSelection/mage.tscn") as PackedScene
@onready var player_position = $PlayerPosition as Marker3D
@onready var core = get_tree().get_root().get_node("Core") as Node
@onready var pcg_code = $PCGCode as PCGCode

# Called when the node enters the scene tree for the first time.
func _ready():
	pcg_code.PCG_General() ## Invoca a la generacion procedural
	var chunks = pcg_code.get_chunk_elegidos() ## Guarda los chunks elegidos
	pcg_code.chunks_creation(chunks,grid_map) ## Los dibuja en el mundo

func _process(delta):
	## Revisa constantemente si alguien quiere pausar
	for player in range(PlayerManager.get_player_count()):
		var device = PlayerManager.get_player_device(player)
		if MultiplayerInput.is_action_just_pressed(device, "pause"):
			pause_menu_pressed()

## Funcion cuando se apreta pause, se muestra el menu de pausa y se para el juego, para mostrar el menu de pausa
func pause_menu_pressed():
	if paused:
		pause_menu.visible = true
		pause_menu.resume_button.grab_focus()
		get_tree().paused = true
	else:
		get_tree().paused = false
		pause_menu.visible = false
	paused = !paused
