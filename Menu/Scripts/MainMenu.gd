class_name MainMenu
extends Control

## Script del menu principal, donde se maneja que hace cada boton 

## Carga los objetos de la escena
@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/StartButton as Button
@onready var options_button = $MarginContainer/HBoxContainer/VBoxContainer/OptionsButton as Button
@onready var quit_button = $MarginContainer/HBoxContainer/VBoxContainer/QuitButton as Button
@onready var options_menu = $OptionsMenu as OptionsMenu
@onready var margin_container = $MarginContainer as MarginContainer
@onready var button_press_stream = $ButtonPressStream as AudioStreamPlayer
@onready var core = get_tree().get_root().get_node("Core")



# Called when the node enters the scene tree for the first time.
func _ready():
	## Conecta las señales con las funciones
	manejarSenales()
	start_button.grab_focus() ## El foco en el boton de inicio para el uso de control o teclado

## Funcion cuando se presiona start, se carga el metodo de cambio de escena del core y se hace un sonido
func on_start_pressed():
	button_press_stream.play()
	core.switch_scene("res://Level/CharacterSelection/character_selection.tscn")
	
## Funcion cuando se presiona quit, se hace un sonido y se cierra el juego
func on_quit_pressed():
	button_press_stream.play() 
	await button_press_stream.finished
	get_tree().quit()

## Funcion cuando se presiona el menu de opciones, hace un sonido, activa el proceso del menu de opciones
## y lo hace visible
func on_options_pressed():
	button_press_stream.play()
	margin_container.visible = false
	options_menu.set_process(true)
	options_menu.visible = true
	options_menu.grab_focus()

## Funcion cuando se presiona el boton para salir el menu de opciones, se oculta el menu y se centra
## en el menu principal
func on_exit_options_menu():
	margin_container.visible = true
	options_menu.visible = false
	start_button.grab_focus()

## Funcion que conecta las señales de los botones con las funciones correspondientes
func manejarSenales():
	start_button.button_down.connect(on_start_pressed)
	options_button.button_down.connect(on_options_pressed)
	quit_button.button_down.connect(on_quit_pressed)
	## Esto tambien conecta la señal del menu de opciones con la funcion de este script
	options_menu.exit_options_menu.connect(on_exit_options_menu)  


