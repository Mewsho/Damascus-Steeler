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
@onready var background_viewport_container = $BackgroundViewportContainer
@onready var back_button_press_stream = $BackButtonPressStream
@onready var change_button_stream = $ChangeButtonStream



# Called when the node enters the scene tree for the first time.
func _ready():
	## Conecta las señales con las funciones
	manejarSenales()
	start_button.grab_focus() ## El foco en el boton de inicio para el uso de control o teclado

	get_viewport().size_changed.connect(on_screen_resized)
	
	on_screen_resized()

func on_screen_resized():
	var window_size := DisplayServer.window_get_size()
	var possible_scale := window_size / Vector2i(background_viewport_container.size)
	var final_scale: Vector2i = max(1, possible_scale.x) * Vector2i.ONE
	background_viewport_container.scale = final_scale
	#background_viewport_container.position = Vector2(window_size) / 2 - background_viewport_container.size * background_viewport_container.scale / 2

## Funcion cuando se presiona start, se carga el metodo de cambio de escena del core y se hace un sonido
func on_start_pressed():
	button_press_stream.play()
	await button_press_stream.finished
	core.switch_scene("res://Level/CharacterSelection/character_selection.tscn")
	
## Funcion cuando se presiona quit, se hace un sonido y se cierra el juego
func on_quit_pressed():
	back_button_press_stream.play() 
	await back_button_press_stream.finished
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
	back_button_press_stream.play()
	margin_container.visible = true
	options_menu.visible = false
	options_button.grab_focus()

## Funcion que conecta las señales de los botones con las funciones correspondientes
func manejarSenales():
	start_button.button_down.connect(on_start_pressed)
	options_button.button_down.connect(on_options_pressed)
	quit_button.button_down.connect(on_quit_pressed)
	## Esto tambien conecta la señal del menu de opciones con la funcion de este script
	options_menu.exit_options_menu.connect(on_exit_options_menu)  







func _on_start_button_focus_exited():
	change_button_stream.play()
func _on_options_button_focus_exited():
	change_button_stream.play()
func _on_quit_button_focus_exited():
	change_button_stream.play()
