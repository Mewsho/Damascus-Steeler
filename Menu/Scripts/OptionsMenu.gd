class_name  OptionsMenu
extends Control


@onready var exit_button = $MarginContainer/VBoxContainer/ExitButton as Button
@onready var button_press_stream = $ButtonPressStream as AudioStreamPlayer
@onready var tab_container = $MarginContainer/VBoxContainer/TabContainer 
@onready var controls = $MarginContainer/VBoxContainer/TabContainer/TabContainer/Controls as TabBar

signal exit_options_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	exit_button.button_down.connect(on_exit_pressed) #Conectar la señal con la funcion del argumeto
	tab_container.exit_options_menu.connect(on_exit_pressed)
	set_process(false) #No hara nada hasta que set_process  sea true 




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_exit_pressed():
	button_press_stream.play()
	exit_options_menu.emit()
	SettingsSignalBus.emit_set_settings_dictionary(SettingsDataContainer.create_storage_dictionary()) #Crea el diccionario, y llama al signal bus para que emita la señal
	#Luego el signal bus emite la señal, que detecta el settings manager, ejecutando el guardado
	set_process(false)
