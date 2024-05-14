extends Node3D

## Script de la camara principal, se encarga del movimiento de la camara y de limitar a los
## jugadores en la pantalla

## Variables de la escena
@onready var offset_marker_3d = $OffsetMarker3D as Marker3D
@onready var test_visual = $TestVisual
@onready var camera_controller = $"." 
@onready var camera_3d = $Camera3D as Camera3D

## Variables que utliza
var player_nodes = null ## Termina siendo un diccionario de los nodos de los players
var prev_position = global_position ## Posicion previa
## Variables para el calculo de la distancia promedio con el offset
var combined_x_position : float = 0 
var player_pos_x
var pos_with_offset
var combined_x_global_position = 0
## Booleanos para seguir a los jugadores
var is_player_in_left_border : bool = false
var is_player_in_right_border : bool = false


func _physics_process(delta):
	if player_nodes == null:
		return
	
	is_player_in_left_border = false
	is_player_in_right_border = false
	## Revisa si los jugadores estan en el borde de la pantalla, usa de referencia la posicion
	## 2d en la ventana
	for player in player_nodes:
		var player_node = player_nodes[player]
		var player_in_screen = camera_3d.unproject_position(player_node.global_position)
		if player_in_screen.x < 50: ## Si esta a la izquierda
			if player_node.velocity.x <= 0:
				#player_node.velocity.x = -10*player_node.velocity.x
				player_node.is_in_left_border = true
			is_player_in_left_border = true
		elif player_in_screen.x > 1070: ## Si esta en el borde derecho
			if player_node.velocity.x >= 0:
				player_node.is_in_right_border = true
			is_player_in_left_border = true
		else: ## Si no esta en ninguno
			player_node.is_in_left_border = false
			player_node.is_in_right_border = false
		

	combined_x_position = 0.0
	combined_x_global_position = 0
	## Calcula la combinacion de las distancias de cada personaje, para avanzar de acuerdo al movimiento
	## combinado de todos
	for player in player_nodes:
		player_pos_x = player_nodes[player].global_position.x
		if player_pos_x == 0: ## Si no existe o algo raro lo hace igual al offset
			player_pos_x = offset_marker_3d.global_position.x
		pos_with_offset = player_pos_x - offset_marker_3d.global_position.x ## Posicion en relacion al offset
		#print("Separation")
		#print("player ", player ," ", player_pos_x)
		#print("player-offset ", pos_with_offset)
		combined_x_position += pos_with_offset ## Vector combinado de todos los jugadores
		
	#print(player_nodes)
	#print("combined normal x ", combined_x_position)
	## Posicion real de la posicion combinada
	combined_x_global_position = combined_x_position + offset_marker_3d.global_position.x 

	#print("offset x ", offset_marker_3d.global_position.x)
	#print("combined global x ", combined_x_global_position)
	#print("Maximunt mov ", maximum_movement)
	test_visual.global_position.x = combined_x_global_position
	## Si la posicion es mayor al offset, mueve la camara con lerp
	if combined_x_global_position > offset_marker_3d.global_position.x and is_player_in_left_border == false: ## Si el pj esta sobre el offset
		var target_x = combined_x_global_position - offset_marker_3d.position.x
		## Evita que cuando se distancien mucho los jugadores, la camara avance muy rapido
		target_x = clamp(target_x, global_position.x,global_position.x+0.8)
		global_position.x = lerp(global_position.x,target_x, 0.1) ## Movimiento mas suave
		
	if prev_position.x > global_position.x: ## Evita que la camara vaya para atras
		global_position = prev_position
	prev_position = global_position

## Inicializa los nodos de los jugadores
func init(_player_nodes):
	player_nodes = _player_nodes

## Para preconfigurar la posicion, cuando muera el jugador
func set_player_position(player, is_dead):
	if is_dead:
		player_nodes[player].global_position.x = offset_marker_3d.global_position.x
		




