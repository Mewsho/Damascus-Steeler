class_name PauseMenu
extends Control

## Script del menu de pausa, esta basado en el menu principal con modificaciones pertinentes

## Cargar objetos de la escena
@onready var resume_button = $MarginContainer/HBoxContainer/VBoxContainer/ResumeButton as Button
@onready var options_button = $MarginContainer/HBoxContainer/VBoxContainer/OptionsButton as Button
@onready var main_menu_button = $MarginContainer/HBoxContainer/VBoxContainer/MainMenuButton as Button
@onready var quit_button = $MarginContainer/HBoxContainer/VBoxContainer/QuitButton as Button
@onready var options_menu = $OptionsMenu as OptionsMenu
@onready var button_press_stream = $ButtonPressStream as AudioStreamPlayer
@onready var margin_container = $MarginContainer as MarginContainer
@onready var world = $".." as Node3D
@onready var core = get_tree().get_root().get_node("Core")
@onready var flow_container = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/MarginContainer/FlowContainer


var hud_list = [0,0,0,0]



func _ready():
	manejarSenales()


func set_hud():
	var gameplay_hud = core.get_node("HUD").get_child(0)
	var player_count = PlayerManager.get_player_count()
	for i in range(0,player_count):
		var node_name = str("PlayerContainer", i)
		hud_list[i] = gameplay_hud.find_child(node_name)
		flow_container.add_child(hud_list[i].duplicate())
		flow_container.get_child(i).visible = true
	

## Llama a la funcion de pausar menu de la escena, despausa el juego
func on_resume_pressed():
	button_press_stream.play()
	await button_press_stream.finished
	world.pause_menu_pressed()
	core.get_node("HUD").visible = true
	hud_list = [0,0,0,0]
	for i in range(0,PlayerManager.get_player_count()):
		var node = flow_container.get_child(i)
		node.queue_free()

## Funcion identica al menu principal, se sale del juego
func on_quit_pressed():
	button_press_stream.play() 
	await button_press_stream.finished
	get_tree().quit()

##Funcion identica a la del menu principal, muestra el menu de opciones
func on_options_pressed():
	button_press_stream.play()
	margin_container.visible = false
	options_menu.set_process(true)
	options_menu.visible = true

## Cuando se presiona el menu principal, se despausa la escena y se cambia al menu
func on_main_menu_pressed():
	button_press_stream.play()
	
	for node in core.get_node("PlayerNodeContainer").get_children():
		node.queue_free()
	core.switch_scene("res://Menu/MainMenu.tscn")
	
	
## Funcion similar al menu principal, hace visible al menu de pausa
func on_exit_options_menu():
	margin_container.visible = true
	options_menu.visible = false
	options_button.grab_focus()

## Funcion que conecta las señales con las funciones
func manejarSenales():
	resume_button.button_down.connect(on_resume_pressed)
	options_button.button_down.connect(on_options_pressed)
	quit_button.button_down.connect(on_quit_pressed)
	options_menu.exit_options_menu.connect(on_exit_options_menu)
	main_menu_button.button_down.connect(on_main_menu_pressed)
