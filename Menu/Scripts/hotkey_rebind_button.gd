class_name HotkeyRebindButton
extends Control

## Script de los botones para cambiar los controles

@onready var label = $HBoxContainer/Label as Label
@onready var button = $HBoxContainer/Button as Button
@export var action_name : String = "move_left" #Nombre en los campos de proyecto

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_unhandled_key_input(false) #Si esta en true, todos los inputs no tomados por algo seran tomados
	set_action_name() # Cambia el nombre al correspondiente
	set_text_key() # Cambia la etiqueta 
	load_keybinds() # Carga datos

## Funcion que carga los keybinds del data container
func load_keybinds() -> void:
	rebind_action_key(SettingsDataContainer.get_keybind(action_name))

## Funcion que cambia el texto de la etiqueta al correspondiente
## TASK Agregar mas con keybinds nuevas
func set_action_name():
	label.text = "NoAsignado"
	
	match action_name: #Switch, para que se vea mas lindo
		"move_left":
			label.text = "Move Left"
		"move_right":
			label.text = "Move Right"
		"jump":
			label.text =  "Jump"
		"move_forward":
			label.text =  "Move Forward"
		"move_backward":
			label.text =  "Move Back"
		"pause":
			label.text = "Pause"

## Funcion que cambia el texto de boton donde se cambia la keybind, por ejemplo en el de moverse a izquierda
## diria "A"
func set_text_key():
	var action_events = InputMap.action_get_events(action_name) #Todos los eventos asociados a la accion action name
	#Esto hay que filtrarlo
	var action_event = action_events[0] #Posicion del keycode
	var action_keycode = OS.get_keycode_string(action_event.physical_keycode) #Esto optiene el boton del teclado en si
	
	button.text = "%s" % action_keycode

## Func asociada a cuando se presiona el boton, cuando se apreta se reemplaza el tesxto y se espera
## a recibir el input de un boton a asignar, luego se devuelve al estado normal
func _on_button_toggled(toggled_on):
	if toggled_on:
		button.text = "Press any key..."
		set_process_unhandled_key_input(toggled_on)
		
		for i in get_tree().get_nodes_in_group("hotkey_button"): #Pasa por todos los botones en el grupo
			if i.action_name != self.action_name: #Esto es para asegurar que el boton vuelva solo a su estado normal
				i.button.toggle_mode = false #Ya no esta toggle
				i.set_process_unhandled_key_input(false)
	else:
		for i in get_tree().get_nodes_in_group("hotkey_button"): #Pasa por todos los botones en el grupo
			if i.action_name != self.action_name: #Esto es para asegurar que el boton vuelva solo a su estado normal
				i.button.toggle_mode = true 
				i.set_process_unhandled_key_input(false)
		set_text_key() #Se configura el texto

## Esta funcion es rara, se llama cuando en la funcion anterior se llama a 
## set_process_unhandled_key_input, toma el evento y lo usa para reemplazar el keybind
func _unhandled_key_input(event):
	rebind_action_key(event)
	button.button_pressed = false
	
## Funcion que cambia el boton asignado y guarda el input en el data container
func rebind_action_key(event):
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	SettingsDataContainer.set_keybind(action_name, event)
	
	set_process_unhandled_key_input(false)
	set_text_key()
	set_action_name()
