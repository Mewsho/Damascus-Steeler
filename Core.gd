extends Node

## Script del nodo core, el cual es el nodo mas importante siendo la raiz en la que se ponen el resto de nodos
## Este nodo maneja cuando se unen y salen jugadores, el cambio de escenas y probablemente mas cosas
## en el futuro

## Carga el contenedor de escenas
@onready var scene_node_container = $SceneNodeContainer as Node

## Nodos de cada jugador
var player_nodes = {}
var chunks_elegidos = [] # Usada antes para el pcg

## Personaje default
const PLAYER_CHARACTER = preload("res://Characters/PlayerCharacter/PlayerCharacter.tscn")


func _ready():
	## Se conectan las señales de unir y salirse a las funciones correspondientes
	PlayerManager.player_joined.connect(handle_player_join)
	PlayerManager.player_left.connect(delete_player)
	
	MultiplayerInput.reset()
	PlayerManager.join(-1) ## INFO Tenemos que se una automaticamente el teclado


func _process(_delta):
	## Constantemente revisa si alguien se quiere unir o salir
	PlayerManager.handle_join_input()
	PlayerManager.handle_leave_input()
	#print(PlayerManager.player_data)
	
## Funcion que ve que hacer cuando se une un jugador, dependiendo si es un menu o un nivel
func handle_player_join(player: int):
	var current_scene = scene_node_container.get_child(0) #Escena principal actual
	# Crea un nodo default para el jugador que se une
	PLAYER_CHARACTER.set_script("res://Characters/PlayerCharacter/PlayerCharacter.gd")
	var player_node = PLAYER_CHARACTER.instantiate()
	player_nodes[player] = player_node
	
	#Si esta en un menu, se cambia el hud correspondiente
	if current_scene.is_in_group("Menus"):
		change_player_menu(current_scene, player,true)
	#Si esta en un nivel, genera al jugador
	if current_scene.is_in_group("Levels"):
		spawn_player(player,player_node)

## Cambia el hud cuando se une o sale un jugador, eliminando o agregando el icono
func change_player_menu(scene: Control, player: int , toggle : bool):
	var player_hud = scene.find_child("PlayerContainer") 
	if toggle:
		player_hud.toggle_player_icon(player)
	else:
		player_hud.untoggle_player_icon(player)
	
## Funcion que hace aparecer al jugador en el mundo, toma la clase que eligio o tiene asignada,
## obtiene el mesh correspondiente y lo genera en el mundo
func spawn_player(player: int, player_node):
	## Obtiene su clase
	var player_class_name = PlayerManager.get_player_data(player, "class")
	var player_class = PlayerVariables.get_player_classes(player_class_name).instantiate()
	var default_mesh = player_node.get_child(0) ## Obtiene el mesh default
	player_node.remove_child(default_mesh) ## Lo elimina
	default_mesh.queue_free()
	player_class.rotation.y = 70
	player_node.add_child(player_class) ## Le agrega la clase 
	player_node.leave.connect(on_player_leave)
	
	# let the player know which device controls it
	var device = PlayerManager.get_player_device(player)
	player_node.init(player) #Ejecuta la funcion de inicializacion del jugador
	
	add_child(player_node) # Lo agrega a la escena
	# Spawn
	player_node.position = Vector3(randf_range(4, 6), randf_range(10, 14),1)
	
## Funcion para eliminar al jugador cuando salga, si esta en un menu, elimina el icono del hud tambien
func delete_player(player: int):
	var current_scene = scene_node_container.get_child(0)
	if current_scene.is_in_group("Menus"):
		change_player_menu(current_scene, player,false)
	player_nodes[player].queue_free()
	player_nodes.erase(player)

## Le avisa al playermanager que se fue el jugador, provocando que se ejecute la funcion de arriba y otras cosas
func on_player_leave(player: int):
	PlayerManager.leave(player)
	
## Funcion de cambio de escena, es la funcion que llaman el resto de escenas para cambiar la escena actual
func switch_scene(scene_path: String,level=-1):
	var ini = Time.get_ticks_msec()
	var current_scenes = scene_node_container.get_children()
	var scene_count: int = current_scenes.size() # Se obtiene la cantidad de hijos del scene container
	
	if (scene_count > 0): # Si hay escenas que eliminar
		await get_tree().create_timer(0.5).timeout
		
		for child in current_scenes: # Elimina las escenas
			scene_node_container.remove_child(child)
			child.queue_free()
		
		# Agrega la nueva escena
		var new_scene = load(scene_path).instantiate() 
		scene_node_container.add_child(new_scene)

		await get_tree().create_timer(0.4).timeout
	
	#Invoca a handle_player_join si hay que agregar jugadores o algo similar
	for player in range(PlayerManager.get_player_count()):
		handle_player_join(player)
	
	var fin = Time.get_ticks_msec()
	print("Tiempo cambio de scena: ", fin-ini, "milisegundos")
