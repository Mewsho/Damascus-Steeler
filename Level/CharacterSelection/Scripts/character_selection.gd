extends Node3D

## Script de la escena de seleccion de personaje, se encarga de asignar el personaje elegido,
## mover el indicador de seleccion, ejecutar las animaciones, modificar el hud, ver la interaccion
## de los jugadores, entre otros 



## Precarga el disco de seleccion 
var selection_area = preload("res://Level/CharacterSelection/selection_area.tscn") as PackedScene
## Variables de los elementos de la escena
@onready var characters = $Characters as Node
@onready var player_hud_container = $MarginContainer/VBoxContainer/PlayerHudContainer
@onready var selection = $MarginContainer/HBoxContainer/VBoxContainer/Selection as Button
@onready var core = get_tree().get_root().get_node("Core") # INFO Core es el nodo central donde se ejecuta todo
@onready var ranger = $Characters/Ranger
@onready var barbarian = $Characters/Barbarian
@onready var mage = $Characters/Mage
@onready var knight = $Characters/Knight
@onready var button_press_stream = $ButtonPressStream
@onready var change_button_stream = $ChangeButtonStream




signal animation_finished
## Variables para manejar el movimiento de los anillos de seleccion
var cant_selection_rings = 1
var character_hover = [0,0,0,0] #Estas listas determinan la posicion en que el jugador esta y la posicion del anillo
var ring_pos = [0,0,0,0]
#Todos comienzan en el default, el mago, indice 0

var TEST_ARRAY

func _ready() -> void:
	# Conecta la señal de union de jugodor con la funcion que actualiza los anillos de seleccion
	PlayerManager.player_joined.connect(update_selection_rings) 
	# Actualiza los anillos de seleccion dependiendo de los jugadores cuando carga la escena
	for player in range(PlayerManager.get_player_count()):
		update_selection_rings(player)
	
## Funcion que actualiza los anillos, eso implica generarlos en la escena, darle una nombre asociado
## al jugador respectivo, darle un color y escala distinta, y agregarlos al personaje primer personaje
func update_selection_rings(n_player : int):
	var selection_area_ins = selection_area.instantiate()
	selection_area_ins.name = str("SelectionArea", n_player) #Le agrega el nombre unico
	var selection_ring = selection_area_ins.get_node("SelectionRing") #Obtiene el anillo en si
	var selection_particles = selection_ring.get_node("SelectionParticles3D") as GPUParticles3D
	
	var player_color_array : Array = [Color(1,0,0),Color(0,0,1),Color(255,255,0),Color(0,1,0)]
	match n_player: #Cambia los atributos del anillo dependiendo del jugador
		0:
			#player_color = Color(1,0,0)
			selection_ring.scale.x = 1
			selection_ring.scale.z = 1
			
		1:
			#player_color =  Color(0,0,1)
			selection_ring.scale.x = 1.1
			selection_ring.scale.z = 1.1
		2:
			#player_color =  Color(255,255,0)
			selection_ring.scale.x = 1.2
			selection_ring.scale.z = 1.2
		3:
			#player_color =  Color(0,1,0)
			selection_ring.scale.x = 1.3
			selection_ring.scale.z = 1.3
	
	#selection_particles.process_material.set_color(Color(0,0,0)) # Es necesario resetaer los colores, porque funciona multiplicativamente el color del process material
	var player_color = player_color_array[n_player]
	
	selection_particles.process_material.set_color(player_color) # Color de las particulas
	selection_particles.draw_pass_1.surface_get_material(0).emission = player_color #Color del brillo
	print(player_color)
	
	characters.get_child(0).add_child(selection_area_ins) #Agrega el anillo al modelo
	print("test")

## Cada frame revisa si alguien esta apretando cosas
func _process(delta):
	handle_inputs()

## Funcion que maneja los inputs de los jugadores mientras estan en la escena, respondiendo acorde
func handle_inputs():
	for player in range(PlayerManager.get_player_count()): #Revisa cada jugador
		var device = PlayerManager.get_player_device(player)
		if  MultiplayerInput.is_action_just_pressed(device, "move_left"): # Si apreta izquierda
			change_button_stream.play()
			if character_hover[player] == 0: #Revisa si es el primero
				character_hover[player] = 3 # Si lo es lleva al ultimo
			else:
				character_hover[player] -=1 #Si no retrocede normalmente
			gamepad_character_hover(player,character_hover[player])
		if MultiplayerInput.is_action_just_pressed(device, "move_right"): #Si apreta derecha
			change_button_stream.play()
			if character_hover[player] == 3: # Revisa si es el ultimo
				character_hover[player] = 0 # Si lo es lleva al primero
			else:
				character_hover[player] +=1 # Si no avanza normalmente
			gamepad_character_hover(player,character_hover[player])
		if MultiplayerInput.is_action_just_pressed(device, "jump"): #Si apreta salto
			select_character(player,character_hover[player])
		if MultiplayerInput.is_action_just_pressed(device, "start"): #Si apreta start
			core.switch_scene("res://world.tscn") # Cambia escena
		if MultiplayerInput.is_action_just_pressed(device, "move_down"): #Si apreta abajo
			selection.grab_click_focus() #Visualmente parece que el boton esta marcado
			selection.grab_focus()
		if MultiplayerInput.is_action_just_pressed(device, "move_up"): #Si apreta arriba
			selection.hide() #Saca la seleccion del boton
			selection.show()


##Funcion que recibe un jugador y el personaje que tiene seleccionado, para obtener el anillo 
## del personaje en que estaba antes y moverlo al que tiene actualmente
func gamepad_character_hover(player, character_hovered):
	var ring
	ring = characters.get_child(ring_pos[player]).get_node(str("SelectionArea",player)) #Obtiene el anillo del pj anterior
	move_node(ring, characters.get_child(character_hovered)) #Mueve el anillo
	ring_pos[player] = character_hovered #Actualiza la posicion
	ring.show_selection() #Muestra el anillo

## Funcion auxiliar, muevel nodo que recibe al nuevo pariente
func move_node(node, new_parent): # node - the node that you want to move, new_parent - where you want to move the node
	var ring = node
	node.get_parent().remove_child(node) # Get node's parent and remove node from it    
	new_parent.add_child(ring) # Add node to new parent as a child   

## Funcion que se llama cuando se selecciona personaje, se obtiene el nombre, se guarda la informacion
## del jugador y se hace una animacion
func select_character(player: int, character_hovered):
	var character_name = str(characters.get_child(character_hovered).name)
	character_selected(player, character_name)
	PlayerManager.set_player_data(player, "class",character_name) # Guarda la informacion
	var verdadero = true
	PlayerManager.set_player_data(player, "is_preselected", verdadero) # Define que fue preelegido en esta escena
	
	var selected_character = characters.get_child(character_hovered) #Obtiene al pj para animarlo
	selected_character.get_node("AnimationPlayer").play("Cheer")
	await selected_character.get_node("AnimationPlayer").animation_finished # Espera a que termine para hacer lo siguiente
	selected_character.get_node("AnimationPlayer").play("Idle")

## Funcion que cambia el texto de la parte superior
func character_selected(player, character_name):
	var current_selected_character_name = character_name
	var current_player = player
	var target_container = player_hud_container.get_child(player).get_child(0) as VBoxContainer
	target_container.show()
	var player_label = target_container.get_child(0) as Label
	var class_label = target_container.get_child(2) as Label
	player_label.text = str("Jugador ", current_player+1)
	class_label.text = current_selected_character_name
	

## DEPRECATED ? Funcion que usabamos antes cuando se seleccionaba con el mouse y clickeando start,
## Sirve cuando se clickea el boton
func _on_selection_pressed():
	#if current_selected_character_name:
		#PlayerVariables.set_player_character(current_selected_character_name)
	button_press_stream.play()
	await button_press_stream.finished
	core.switch_scene("res://world.tscn")
	
	

		
	


func _on_selection_focus_entered():
	change_button_stream.play()


func _on_selection_focus_exited():
	change_button_stream.play()
