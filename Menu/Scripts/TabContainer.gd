class_name SettingsTabContainer
extends Control

## Script del tabcontainer, el cual es el elemento principal del menu de opciones, contiene
## la mayoria de los elementos personalizados de interfaz
## TASK Hay que implementar una mejor manera de interactuar con el control o teclado
## TASK Hay que adaptarla al uso de MultiplayerInput

## Cargar elementos
@onready var tab_container = $TabContainer as TabContainer
@onready var button_press_stream = $ButtonPressStream as AudioStreamPlayer
@onready var options_menu = $"../../.."
@onready var first_hotkey_rebind_button = $TabContainer/Controls/MarginContainer/ScrollContainer/VBoxContainer/HotkeyRebindButton as HotkeyRebindButton
@onready var controls = $TabContainer/Controls as TabBar
@onready var exit_button = $"../ExitButton" as Button


signal exit_options_menu


## Funcion basica para cambiar la ventana
func change_tab(tab : int) -> void:
	tab_container.set_current_tab(tab)

## Funcion que maneja los input del usuario, moviendose a traves del hud del tab container
## y el boton para salir de las opciones
func options_menu_input() -> void:
	if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("ui_right"):
		if tab_container.current_tab >= tab_container.get_tab_count() -1:
			change_tab(0)
			return
		var next_tab = tab_container.current_tab + 1
		change_tab(next_tab)
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("ui_left"):
		if tab_container.current_tab == 0:
			change_tab(tab_container.get_tab_count()-1)
			return
		var previous_Tab = tab_container.current_tab - 1 
		change_tab(previous_Tab)
	
	if (Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("move_down")) and tab_container.is_visible_in_tree():
		exit_button.grab_focus()
	
	if tab_container.is_visible_in_tree() and Input.is_action_just_pressed("move_up"):
		exit_button.hide()
		exit_button.show()
		tab_container.get_current_tab_control().grab_focus()
	
	if Input.is_action_just_pressed("ui_cancel"): ## Salir del menu de opciones
		exit_options_menu.emit()



func _process(delta):
	options_menu_input()

## Cuando se cambie de tab, se hace un sonido
func _on_tab_container_tab_changed(tab):
	if options_menu.visible:
		button_press_stream.play()

