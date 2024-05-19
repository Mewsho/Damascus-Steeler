extends Node

## Script del nodo core, el cual es el nodo mas importante siendo la raiz en la que se ponen el resto de nodos
## Este nodo maneja cuando se unen y salen jugadores, el cambio de escenas y probablemente mas cosas
## en el futuro

## Carga el contenedor de escenas
#@onready var scene_node_container = $SceneNodeContainer as Node
@onready var scene_node_container = $SceneNodeContainer
@onready var player_node_container = $PlayerNodeContainer as Node
@onready var hud = $HUD
@onready var gameplay_hud = $HUD/GameplayHUD

## Nodos de cada jugador
var player_nodes = {}

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
	#PLAYER_CHARACTER.set_script("res://Characters/PlayerCharacter/PlayerCharacter.gd")
	var player_node = PLAYER_CHARACTER.instantiate()
	player_nodes[player] = player_node
	var is_preselected = PlayerManager.get_player_data(player, "is_preselected") #booleano
	player_node.character_lost_life.connect(on_character_lost_life)
	player_node.character_game_over.connect(on_character_game_over)
	#Si esta en un menu, se cambia el hud correspondiente
	if current_scene.is_in_group("Menus"):
		change_player_menu(current_scene, player,true)
	#Si esta en un nivel, genera al jugador
	if current_scene.is_in_group("Levels"):
		if is_preselected: ## Revisa si selecciono o no la clase en character sellection
			spawn_player(player,player_node)
			handle_gameplay_hud(player, true)
		else:
			player_character_selection(player,player_node)
	
	
func on_character_lost_life(player):
	var player_node = player_nodes[player] 
	player_node_container.remove_child(player_node)
	handle_gameplay_hud(player, false)
	player_character_selection(player,player_node)
	## Cuando muera, llama a set player position para mantener cte la posicion, lo mismo abajo
	var camera_node = scene_node_container.get_child(0).get_node("CameraController")
	camera_node.set_player_position(player, true)

func on_character_game_over(player):
	var camera_node = scene_node_container.get_child(0).get_node("CameraController")
	#camera_node.set_player_position(player, true)
	var player_node = player_nodes[player];
	player_node.hide()
	camera_node.set_player_position(player,true)
	camera_node.handle_game_over(player)
	
## Cambia el hud cuando se une o sale un jugador, eliminando o agregando el icono
func change_player_menu(scene: Control, player: int , toggle : bool):
	var player_hud = scene.find_child("PlayerContainer") 
	if toggle:
		player_hud.toggle_player_icon(player)
	else:
		player_hud.untoggle_player_icon(player)

## Funcion llamada cuando el jugador va a elegir personaje dentro del juego
## Busca al hud correspondiente, lo inicializa, muestra y conecta la señal con la funcion de seleccion
func player_character_selection(player, player_node):
	var character_selection_hud = gameplay_hud.find_child(str("CharacterSelectionContainer",player))
	character_selection_hud.init(player)
	character_selection_hud.set_process(true)
	character_selection_hud.show()
	character_selection_hud.character_selected.connect(on_character_selected)

## Cuando se selecciona personaje, oculta y para el _process del container
## Asigna la clase elegida, spawnea al jugador y muestra el hud
func on_character_selected(player,p_class, character_container):
	character_container.hide()
	character_container.set_process(false)
	PlayerManager.set_player_data(player, "class", p_class)
	var player_node = player_nodes[player]
	spawn_player(player, player_node)
	handle_gameplay_hud(player,true)
	

## Funcion que hace aparecer al jugador en el mundo, toma la clase que eligio o tiene asignada,
## obtiene el mesh correspondiente y lo genera en el mundo
func spawn_player(player: int, player_node):
	## Obtiene su clase
	var player_class_name = PlayerManager.get_player_data(player, "class")
	var player_class = PlayerVariables.get_player_classes(player_class_name).instantiate()
	player_node.set_player_class(player_class_name)
	
	var default_mesh ## Obtiene el mesh default
	if player_node.has_node("Mage"):
		default_mesh = player_node.get_node("Mage")
	if player_node.has_node("Knight"):
		default_mesh = player_node.get_node("Knight")
	if player_node.has_node("Barbarian"):
		default_mesh = player_node.get_node("Barbarian")
	if player_node.has_node("Ranger"):
		default_mesh = player_node.get_node("Ranger")
	
	player_node.remove_child(default_mesh) ## Lo elimina
	default_mesh.queue_free()
	player_class.rotation.y = 70
	player_node.name = str(player_class_name,player)
	player_node.add_child(player_class) ## Le agrega la clase 
	player_node.leave.connect(on_player_leave)
	# let the player know which device controls it
	var device = PlayerManager.get_player_device(player)
	player_node.init(player) #Ejecuta la funcion de inicializacion del jugador
	
	handle_camera(player_nodes)
	
	var camera_node = scene_node_container.get_child(0).get_node("CameraController")
	var spawn_position_x = camera_node.get_node("OffsetMarker3D").global_position.x
	
	player_node_container.add_child(player_node) # Lo agrega a la escena
	# Spawn
	player_node.position = Vector3(spawn_position_x-2, randf_range(10, 14),1)
	player_node.is_dead = false
	player_node.mana = 100
## Funcion para eliminar al jugador cuando salga, si esta en un menu, elimina el icono del hud tambien
func delete_player(player: int):
	var current_scene = scene_node_container.get_child(0)
	if current_scene.is_in_group("Menus"):
		change_player_menu(current_scene, player,false)
	if current_scene.is_in_group("Levels"):
		handle_gameplay_hud(player,false)
	player_nodes[player].queue_free()
	player_nodes.erase(player)


## Maneja la camara, la inicializa con los nodos de los jugadores
func handle_camera(player_nodes):
	var camera_node = scene_node_container.get_child(0).get_node("CameraController")
	camera_node.init(player_nodes)

## Funcion para ocultar o mostrar el hud
func handle_gameplay_hud(player, toggle: bool):
	if toggle:
		gameplay_hud.show_player_hud(player)
		gameplay_hud.set_player_data_hud(player)
		var player_node = player_nodes[player]
		var hud_container = gameplay_hud.get_child(0)
		var player_hud = hud_container.find_child(str("PlayerHUD",player))
		player_node.mana_change.connect(player_hud.change_mana)
		player_node.lifes_change.connect(player_hud.change_lifes)
	else:
		gameplay_hud.hide_player_hud(player)
	
## Le avisa al playermanager que se fue el jugador, provocando que se ejecute la funcion delete player y otras cosas
func on_player_leave(player: int):
	PlayerManager.leave(player)
	
## Funcion de cambio de escena, es la funcion que llaman el resto de escenas para cambiar la escena actual
func switch_scene(scene_path: String,level=-1):
	var ini = Time.get_ticks_msec()
	var current_scenes = scene_node_container.get_children()
	var scene_count: int = current_scenes.size() # Se obtiene la cantidad de hijos del scene container
	
	if (scene_count > 0): # Si hay escenas que eliminar
		await get_tree().create_timer(1).timeout
		
		for child in current_scenes: # Elimina las escenas
			scene_node_container.remove_child(child)
			child.queue_free()
		
		# Agrega la nueva escena
		var new_scene = load(scene_path).instantiate() 
		scene_node_container.add_child(new_scene)
		
		if new_scene.is_in_group("Levels"):
			hud.show()
		else:
			hud.hide()
		
		await get_tree().create_timer(0.4).timeout
	
	#Invoca a handle_player_join si hay que agregar jugadores o algo similar
	for player in range(PlayerManager.get_player_count()):
		handle_player_join(player)
	
	 
	
	var fin = Time.get_ticks_msec()
	print("Tiempo cambio de scena: ", fin-ini, "milisegundos")
