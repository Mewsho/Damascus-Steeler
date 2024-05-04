extends Node


var player_classes : Dictionary = {
	"Mage" : load("res://Level/CharacterSelection/mage.tscn"),
	"Knight" : load("res://Level/CharacterSelection/knight.tscn"),
	"Barbarian" : load("res://Level/CharacterSelection/barbarian.tscn"),
	"Rogue" : load("res://Level/CharacterSelection/rogue.tscn")
}

var player_character : String


func set_player_character(character_name):
	self.player_character = character_name
	
func get_player_classes(character_name) -> PackedScene:
	return player_classes[character_name]
