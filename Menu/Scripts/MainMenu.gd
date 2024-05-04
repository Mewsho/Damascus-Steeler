class_name MainMenu
extends Control

@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/StartButton as Button
@onready var options_button = $MarginContainer/HBoxContainer/VBoxContainer/OptionsButton as Button
@onready var quit_button = $MarginContainer/HBoxContainer/VBoxContainer/QuitButton as Button
@onready var options_menu = $OptionsMenu as OptionsMenu
@onready var margin_container = $MarginContainer as MarginContainer
@onready var button_press_stream = $ButtonPressStream as AudioStreamPlayer
@onready var core = get_tree().get_root().get_node("Core")



# Called when the node enters the scene tree for the first time.
func _ready():
	manejarSenales()
	start_button.grab_focus()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_start_pressed():
	button_press_stream.play()
	core.switch_scene("res://Level/CharacterSelection/character_selection.tscn")

func on_quit_pressed():
	button_press_stream.play() 
	await button_press_stream.finished
	get_tree().quit()

func on_options_pressed():
	button_press_stream.play()
	margin_container.visible = false
	options_menu.set_process(true)
	options_menu.visible = true
	options_menu.grab_focus()

func on_exit_options_menu():
	margin_container.visible = true
	options_menu.visible = false
	start_button.grab_focus()

func manejarSenales():
	start_button.button_down.connect(on_start_pressed)
	options_button.button_down.connect(on_options_pressed)
	quit_button.button_down.connect(on_quit_pressed)
	options_menu.exit_options_menu.connect(on_exit_options_menu)


#func _on_start_button_pressed():
	#get_tree().change_scene_to_file("res://world.gd")
