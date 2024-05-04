class_name HotkeyRebindButton
extends Control

@onready var label = $HBoxContainer/Label as Label
@onready var button = $HBoxContainer/Button as Button
@export var action_name : String = "move_left" #Nombre en los campos de proyecto

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_unhandled_key_input(false) #Si esta en true, todos los inputs seran tomados no tomados por algo seran tomados
	set_action_name()
	set_text_key()
	load_keybinds()

func load_keybinds() -> void:
	rebind_action_key(SettingsDataContainer.get_keybind(action_name))


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

func set_text_key():
	var action_events = InputMap.action_get_events(action_name) #Todos los eventos asociados a la accion action name
	#Esto hay que filtrarlo
	var action_event = action_events[0] #Posicion del keycode
	var action_keycode = OS.get_keycode_string(action_event.physical_keycode) #Esto optiene el boton del teclado en si
	
	button.text = "%s" % action_keycode

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
		set_text_key()
		
func _unhandled_key_input(event):
	rebind_action_key(event)
	button.button_pressed = false
	
func rebind_action_key(event):
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	SettingsDataContainer.set_keybind(action_name, event)
	
	set_process_unhandled_key_input(false)
	set_text_key()
	set_action_name()
