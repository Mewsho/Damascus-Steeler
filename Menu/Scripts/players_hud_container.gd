class_name PlayerHudContainer
extends HBoxContainer
@onready var player_0 = $VBoxContainer/MarginContainer/MarginContainer/HBoxContainer/Player0 as TextureRect
@onready var player_1 = $VBoxContainer/MarginContainer/MarginContainer/HBoxContainer/Player1 as TextureRect
@onready var player_2 = $VBoxContainer/MarginContainer/MarginContainer/HBoxContainer/Player2 as TextureRect
@onready var player_3 = $VBoxContainer/MarginContainer/MarginContainer/HBoxContainer/Player3 as TextureRect
@onready var keyboard_separator = $VBoxContainer/MarginContainer/MarginContainer/HBoxContainer/KeyboardSeparator as VSeparator
@onready var player_5 = $VBoxContainer/MarginContainer/MarginContainer/HBoxContainer/Player5 as TextureRect


func toggle_player_icon(player:int):
	match player:
		0:
			player_0.show()
		1:
			player_1.show()
		2:
			player_2.show()
		3:
			player_3.show()
		-1:
			keyboard_separator.show()
			player_5.show()

func untoggle_player_icon(player:int):
	match player:
		0:
			player_0.hide()
		1:
			player_1.hide()
		2:
			player_2.hide()
		3:
			player_3.hide()
		-1:
			keyboard_separator.hide()
			player_5.hide()


