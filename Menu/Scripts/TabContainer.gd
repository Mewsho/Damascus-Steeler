class_name SettingsTabContainer
extends Control

@onready var tab_container = $TabContainer as TabContainer
@onready var button_press_stream = $ButtonPressStream as AudioStreamPlayer
@onready var options_menu = $"../../.."
@onready var first_hotkey_rebind_button = $TabContainer/Controls/MarginContainer/ScrollContainer/VBoxContainer/HotkeyRebindButton as HotkeyRebindButton
@onready var controls = $TabContainer/Controls as TabBar
@onready var exit_button = $"../ExitButton"


signal exit_options_menu()




func change_tab(tab : int) -> void:
	tab_container.set_current_tab(tab)

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
	
	if Input.is_action_just_pressed("ui_cancel"):
		exit_options_menu.emit()



func _process(delta):
	options_menu_input()

func _on_tab_container_tab_changed(tab):
	if options_menu.visible:
		button_press_stream.play()

