extends Node3D

@onready var pcg_code = $PCGCode
@onready var grid_map = $GridMap

signal chunks_finished_drawing

# Called when the node enters the scene tree for the first time.
func _ready():
	PCGcurrent.PCG_General() ## Invoca a la generacion procedural
	var chunks = PCGcurrent.get_chunk_elegidos() ## Guarda los chunks elegidos
	PCGcurrent.chunks_creation(chunks,grid_map) ## Los dibuja en el mundo
	emit_signal("chunks_finished_drawing")
	

	
