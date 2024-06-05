extends Control

## Scrip de la opcion que cambia la resolucion, carga, modifica y guarda la informacion respectiva


@onready var option_button = $HBoxContainer/OptionButton as OptionButton
## Diccionario de resoluciones disponibles
const RESOLUTION_DICTIONARY : Dictionary = {
	"1280 x 720" : Vector2i(1280,720),
	"1600 x 900" : Vector2i(1600,900),
	"1920 x 1080" : Vector2i(1920,1080)
}


func _ready():
	## Conecta la seleccion del objeto en el menu con la funcion on_resolution_selected
	option_button.item_selected.connect(on_resolution_selected)
	add_resolution_items()
	load_data()

## Funcion que carga la informacion del datacontainer
func load_data() -> void:
	on_resolution_selected(SettingsDataContainer.get_resolution_index())
	option_button.select(SettingsDataContainer.get_resolution_index()) ## Deja seleccionado visualmente el que carga

## Agrega las opciones en el menu dropdown segun el diccionario
func add_resolution_items():
	for resolution_size_text in RESOLUTION_DICTIONARY:
		option_button.add_item(resolution_size_text)

## Funcion que recibe el indice de resolucion, emite la señal que se eligio, y cambia el tamaño de 
## la pantalla
## TASK NOTE Esto solo cambia el tamaño de la pantalla, no el escalado de resolucion, hay que ver como hacerlo
func on_resolution_selected(index : int):
	SettingsSignalBus.emit_on_resolution_selected(index) #Llama a emitir la señal
	DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])
	## Estan son modificaciones para que este al medio de la pantalla
	var centre_screen = DisplayServer.screen_get_position() + DisplayServer.screen_get_size()/2
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(centre_screen - window_size/2)
