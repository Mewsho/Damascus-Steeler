extends Node

## Autoload para mantener variables universales de los jugadores, por ahora guarda el nombre del
## la clase del personaje, y un diccionario con las escenas de cada clase, que se obtienen con una
## funcion get

var player_classes : Dictionary = {
	"Mage" : load("res://Level/CharacterSelection/mage.tscn"),
	"Knight" : load("res://Level/CharacterSelection/knight.tscn"),
	"Barbarian" : load("res://Level/CharacterSelection/barbarian.tscn"),
	"Ranger" : load("res://Level/CharacterSelection/ranger.tscn")
}

var player_character : String

func set_player_character(character_name):
	self.player_character = character_name
	
func get_player_classes(character_name) -> PackedScene:
	return player_classes[character_name]
