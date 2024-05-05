class_name  OptionsMenu
extends Control

## Script del menu de opciones, el cual es un nodo de control que se superpone a los otros menus

## Cargar variables de la escena
@onready var exit_button = $MarginContainer/VBoxContainer/ExitButton as Button
@onready var button_press_stream = $ButtonPressStream as AudioStreamPlayer
@onready var tab_container = $MarginContainer/VBoxContainer/TabContainer 
@onready var controls = $MarginContainer/VBoxContainer/TabContainer/TabContainer/Controls as TabBar
## Señal de salida del menu
signal exit_options_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	## Se conecta el presionar el boton de salida con la funcion de salir
	exit_button.button_down.connect(on_exit_pressed)
	## Se conecta la señal de salir del menu con la funcion
	tab_container.exit_options_menu.connect(on_exit_pressed)
	set_process(false) #No hara nada hasta que set_process  sea true 

## Funcion que al apretar salir, se haga un sonido, se emita la señal que recibe el menu principal
## se emita el diccionario de configuraciones, y para el proceso
func on_exit_pressed():
	button_press_stream.play()
	exit_options_menu.emit()
	SettingsSignalBus.emit_set_settings_dictionary(SettingsDataContainer.create_storage_dictionary()) #Crea el diccionario, y llama al signal bus para que emita la señal
	#Luego el signal bus emite la señal, que detecta el settings manager, ejecutando el guardado
	set_process(false)
