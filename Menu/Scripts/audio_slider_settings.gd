extends Control

## Script universal asociado a los sliders de sonido, modifica la informacion relacionada y manda
## la informacion al settingsdatacontainer

## Variables de la escena
@onready var audio_name_label = $HBoxContainer/AudioNameLabel as Label
@onready var audio_num_label = $HBoxContainer/AudioNumLabel as Label
@onready var h_slider = $HBoxContainer/HSlider as HSlider
# Permite cambiar el nombre en el editor
@export_enum("Master", "Music", "SFX", "UI") var  bus_name : String
#Indice del bus de sonido
var bus_index : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	h_slider.value_changed.connect(on_value_changed) #Conecta al cambio de valor con la funcion on_value_changed
	#Llama al resto de funciones
	get_bus_name_by_index()
	load_data()
	set_name_label_text()
	set_slider_value()

##Funcion que carga los datos guardados en el settings data container
func load_data() -> void:
	# Carga los datos dependiendo del bus correspondiente
	match bus_name:
		"Master":
			on_value_changed(SettingsDataContainer.get_master_volume())
		"Music":
			on_value_changed(SettingsDataContainer.get_music_volume())
		"SFX":
			on_value_changed(SettingsDataContainer.get_sfx_volume())
		"UI":
			on_value_changed(SettingsDataContainer.get_sfx_volume())

## Cambia el nombre de la etiqueta segun el bus de audio
func set_name_label_text() -> void:
	audio_name_label.text = str(bus_name) + " Volume"
## Cambia el numero del valor del volumen dependiendo del movimiento del slider
func set_audio_num_label_text() -> void:
	audio_num_label.text = str(h_slider.value * 100)
## Entre el indice del bus de audio segun el nombre
func get_bus_name_by_index() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
##Cambia el valor del slider visualmente, dependiendo del valor que tenga puesto
func set_slider_value() -> void:
	h_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	set_audio_num_label_text()

##Funcion que cuando se cambia el valor del slider, cambia el volumen del bus correspondiente
func on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	set_audio_num_label_text()
	match bus_index: #Emite una señal cuando se cambia a las opciones
		0:
			SettingsSignalBus.emit_on_master_sound_set(value)
		1:
			SettingsSignalBus.emit_on_music_sound_set(value)
		2: 
			SettingsSignalBus.emit_on_sfx_sound_set(value)
		3:
			SettingsSignalBus.emit_on_ui_sound_set(value)
