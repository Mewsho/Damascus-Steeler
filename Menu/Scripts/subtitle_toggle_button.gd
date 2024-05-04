extends Control

@onready var state_label = $HBoxContainer/StateLabel as Label
@onready var check_button = $HBoxContainer/CheckButton as CheckButton


# Called when the node enters the scene tree for the first time.
func _ready():

	check_button.toggled.connect(on_subtitles_toggled)
	load_data()

	
func load_data() -> void:
	if SettingsDataContainer.get_subtitles_set() != true:
		check_button.button_pressed = false
	else:
		check_button.button_pressed = true
	on_subtitles_toggled(SettingsDataContainer.get_subtitles_set())

func on_subtitles_toggled(button_pressed : bool):
	set_label_text(button_pressed)
	SettingsSignalBus.emit_on_subtitles_toggled(button_pressed)

func set_label_text(button_pressed : bool):
	if button_pressed != true:
		state_label.text = "Off"
	else: 
		state_label.text = "On"
		


