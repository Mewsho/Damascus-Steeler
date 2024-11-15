extends Node
#Los autoloads nos permiten comunicar y guardar cosas, en este caso las opciones

## Autoload encargado de contener toda la informacion que se modifica en el menu de opciones
## Ademas se conecta con las multiples señales del Settings SignalBus para conectarse con el resto del codigo
##
## TASK Si se agregan mas opciones es necesario modificar esto
## WARNING Las opciones relacionadas a las keybind es posible que no funcione del todo bien por el uso de multiplayer
## TASK Ademas, no se han agregado nuevas keybinds desde hace rato

## DEFAULTS
@onready var DEFAULT_SETTINGS : DefaultSettingsResource = preload("res://resources/settings/DefaultSettings.tres")
@onready var keybind_resource : PlayerKeybindResource = preload("res://resources/settings/PlayerKeybindDefault.tres")

## Variables conectadas a las opciones
var window_mode_index : int = 0
var resolution_index : int = 0
var master_volume :float = 0.0
var music_volume : float = 0.0
var sfx_volume : float = 0.0
var ui_volume : float = 0.0
var subtitles_set : bool = false

var loaded_data : Dictionary = {}

# Llama a manejarSeñales
func _ready():
	manejarSeñales()

## Funcion que crea el diccionario de la informacion de opciones para guardarla, usa lo valores del script de cada
## atributo del menu de opciones, al final retorna ese diccionario
func create_storage_dictionary() -> Dictionary:
	var graphics_settings_dict : Dictionary = {
		"window_mode_index" : window_mode_index,
		"resolution_index" : resolution_index
	}
	var volume_settings_dict : Dictionary = {
		"master_volume" : master_volume,
		"music_volume" : music_volume,
		"sfx_volume" : sfx_volume,
		"ui_volume" : ui_volume
	}
	var accesibility_settings_dict : Dictionary = {
		"subtitles_set" : subtitles_set
	}

	var settings_container_dict : Dictionary = {
		"graphics_settings_dict" : graphics_settings_dict,
		"volume_settings_dict" : volume_settings_dict,
		"accesibility_settings_dict" : accesibility_settings_dict,
		"keybinds" : create_keybind_dictionary()
	}
	
	return settings_container_dict

##Funcion auxiliar de la anterior, crea el diccionario de keybinds para guardar la informacion,
## por ultimo retorna el diccionario. Se comuna con el keybind_resource, donde se guarda la informacion
## de las keybinds
## TASK Agregar keybinds nuevas
func create_keybind_dictionary() -> Dictionary:
	var keybinds_container_dict = {
		keybind_resource.MOVE_LEFT : keybind_resource.move_left_key,
		keybind_resource.MOVE_RIGHT : keybind_resource.move_right_key,
		keybind_resource.MOVE_FORWARD : keybind_resource.move_forward_key,
		keybind_resource.MOVE_BACKWARD : keybind_resource.move_backward_key,
		keybind_resource.JUMP : keybind_resource.jump_key,
		keybind_resource.PAUSE : keybind_resource.pause_key
	}
	
	return keybinds_container_dict

## Funciones "get" de los atributos del script, todas revisan si hay datos que cargar, si no lo hay
## usan los defaults
#region Funciones get
func get_window_mode_index()->int:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_WINDOW_MODE_INDEX
	return window_mode_index
func get_resolution_index()->int:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_RESOLUTION_INDEX
	return resolution_index

func get_master_volume()-> float:
	if loaded_data =={}:
		return DEFAULT_SETTINGS.DEFAULT_MASTER_VOLUME
	return master_volume
func get_music_volume()->float:
	if loaded_data =={}:
		return DEFAULT_SETTINGS.DEFAULT_MUSIC_VOLUME
	return music_volume	
func get_sfx_volume()->float:
	if loaded_data =={}:
		return DEFAULT_SETTINGS.DEFAULT_SFX_VOLUME
	return sfx_volume	
func get_ui_volume()-> float:
	if loaded_data =={}:
		return DEFAULT_SETTINGS.DEFAULT_UI_VOLUME
	return ui_volume
	
func get_subtitles_set()-> bool:
	if loaded_data =={}:
		return DEFAULT_SETTINGS.DEFAULT_SUBTITLES_SET
	return subtitles_set
	
func get_keybind(action : String):
	if !loaded_data.has("keybinds"):
		match action:
			keybind_resource.MOVE_LEFT:
				return keybind_resource.DEFAULT_MOVE_LEFT_KEY
			keybind_resource.MOVE_RIGHT:
				return keybind_resource.DEFAULT_MOVE_RIGHT_KEY
			keybind_resource.MOVE_FORWARD:
				return keybind_resource.DEFAULT_MOVE_FORWARD_KEY
			keybind_resource.MOVE_BACKWARD:
				return keybind_resource.DEFAULT_MOVE_BACKWARD_KEY
			keybind_resource.JUMP:
				return keybind_resource.DEFAULT_JUMP_KEY
			keybind_resource.PAUSE:
				return keybind_resource.DEFAULT_PAUSE_KEY
	else:
		match action:
			keybind_resource.MOVE_LEFT:
				return keybind_resource.move_left_key
			keybind_resource.MOVE_RIGHT:
				return keybind_resource.move_right_key
			keybind_resource.MOVE_FORWARD:
				return keybind_resource.move_forward_key
			keybind_resource.MOVE_BACKWARD:
				return keybind_resource.move_backward_key
			keybind_resource.JUMP:
				return keybind_resource.jump_key
			keybind_resource.PAUSE:
				return keybind_resource.pause_key
#endregion

## Funciones "set" o "on" como estan planteadas, modifican el valor de los atributos segun lo que reciben
#region Funciones set/on
func on_window_mode_selected(index : int):
	window_mode_index = index
func on_resolution_selected(index : int):
	resolution_index = index
	
func on_master_sound_set(value: float):
	master_volume = value
func on_music_sound_set(value: float):
	music_volume = value
func on_sfx_sound_set(value: float):
	sfx_volume = value
func on_ui_sound_set(value: float):
	ui_volume = value

func on_subtitles_toggled(value: bool):
	subtitles_set = value

## Funcion set/on de los keybinds, es mas grande debido a que son datos mas complejos
## Guarda la informacion en el recurso de keybinds
func on_keybinds_loaded(data : Dictionary) -> void:
	var loaded_move_left = InputEventKey.new()
	var loaded_move_right = InputEventKey.new()
	var loaded_move_forward = InputEventKey.new()
	var loaded_move_backward = InputEventKey.new()
	var loaded_jump = InputEventKey.new()
	var loaded_pause = InputEventKey.new()
	
	loaded_move_left.set_physical_keycode(int(data.move_left))
	loaded_move_right.set_physical_keycode(int(data.move_right))
	loaded_move_forward.set_physical_keycode(int(data.move_forward))
	loaded_move_backward.set_physical_keycode(int(data.move_backward))
	loaded_jump.set_physical_keycode(int(data.jump))
	loaded_pause.set_physical_keycode(int(data.pause))
	
	keybind_resource.move_left_key = loaded_move_left
	keybind_resource.move_right_key = loaded_move_right
	keybind_resource.move_forward_key = loaded_move_forward
	keybind_resource.move_backward_key = loaded_move_backward
	keybind_resource.jump_key = loaded_jump
	keybind_resource.pause_key = loaded_pause

## Funcion usada cuando se carga informacion guardada, llama a todas las funciones anteriores
## usando la informacion cargada
func on_settings_data_loaded(data : Dictionary) -> void:
	loaded_data = data
	on_window_mode_selected(loaded_data.graphics_settings_dict.window_mode_index)
	on_resolution_selected(loaded_data.graphics_settings_dict.resolution_index)
	on_master_sound_set(loaded_data.volume_settings_dict.master_volume)
	on_music_sound_set(loaded_data.volume_settings_dict.music_volume)
	on_sfx_sound_set(loaded_data.volume_settings_dict.sfx_volume)
	on_ui_sound_set(loaded_data.volume_settings_dict.ui_volume)
	on_subtitles_toggled(loaded_data.accesibility_settings_dict.subtitles_set)
	on_keybinds_loaded(loaded_data.keybinds)
	
#endregion

## Esta funcion recibe una accion que modificar y el input que se le asignara
## TASK Agregar las keybinds nuevas
## Es usado principalmente por el menu de opciones, cuando modificas el valor
func set_keybind(action :String, event) -> void:
	match action:
		keybind_resource.MOVE_LEFT:
			keybind_resource.move_left_key = event
		keybind_resource.MOVE_RIGHT:
			keybind_resource.move_right_key = event
		keybind_resource.MOVE_FORWARD:
			keybind_resource.move_forward_key = event
		keybind_resource.MOVE_BACKWARD:
			keybind_resource.move_backward_key = event
		keybind_resource.JUMP:
			keybind_resource.jump_key = event
		keybind_resource.PAUSE:
			keybind_resource.pause_key = event


## Funcion que conecta las señales que emite el SettingsSignalBus con las funciones "on" de este script
## para que se ejecuten cuando se emita la señal
func manejarSeñales() -> void:
	SettingsSignalBus.on_window_mode_selected.connect(on_window_mode_selected)
	SettingsSignalBus.on_resolution_selected.connect(on_resolution_selected)
	SettingsSignalBus.on_master_sound_set.connect(on_master_sound_set)
	SettingsSignalBus.on_music_sound_set.connect(on_music_sound_set)
	SettingsSignalBus.on_sfx_sound_set.connect(on_sfx_sound_set)
	SettingsSignalBus.on_ui_sound_set.connect(on_ui_sound_set)
	SettingsSignalBus.on_subtitles_toggled.connect(on_subtitles_toggled)
	SettingsSignalBus.load_settings_data.connect(on_settings_data_loaded)
