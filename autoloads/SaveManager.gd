extends Node

## Autoload para administrar el guardado de informacion, actualmente se encarga de guardar
## los datos de las opciones

const SETTINGS_SAVE_PATH : String = "user://SettingsData.save" ## Donde se guarda la info
var settings_data_dict :Dictionary = {} ##Diccionario de la informacion de opciones que se guardara

func _ready():
	## Se conecta con la señal del autoload signalbus para cuando se determine el diccionario de
	## configuraciones, llame a la funcion on_settings_save
	SettingsSignalBus.set_settings_dictionary.connect(on_settings_save) 
	load_settings_data()
	

## Funcion que guarda la informacion del diccionario en un archivo JSON
func on_settings_save(data: Dictionary) -> void:
	#var save_settings_data_file = FileAccess.open_encrypted_with_pass(SETTINGS_SAVE_PATH, FileAccess.WRITE, "Misho") #Abrir con contraseñas
	var save_settings_data_file = FileAccess.open(SETTINGS_SAVE_PATH, FileAccess.WRITE) #Crea el archivo
	var json_data_string = JSON.stringify(data) #Transforma la info en un formato compatible con el json
	
	save_settings_data_file.store_line(json_data_string) #Guarda la info en el json

## Funcion que carga la informacion guardada, la traduce a un diccionario y la emite para que la
## reciba otrap parte del juego
func load_settings_data() -> void:
	if not FileAccess.file_exists(SETTINGS_SAVE_PATH): #Ve si existe
		return
	
	var save_settings_data_file = FileAccess.open(SETTINGS_SAVE_PATH, FileAccess.READ) # Lee el archivo
	var loaded_data : Dictionary = {} # Variable info cargada
	
	while save_settings_data_file.get_position() < save_settings_data_file.get_length(): #Va linea por linea guardando la informacion el loaded_data
		var json_string = save_settings_data_file.get_line()
		var json = JSON.new()
		var _parsed_result = json.parse(json_string)
		
		loaded_data = json.get_data()
	
	SettingsSignalBus.emit_load_settings_data(loaded_data) #Emite la señal del la informacion cargada
	loaded_data = {} #Resetea la informacion cargada
