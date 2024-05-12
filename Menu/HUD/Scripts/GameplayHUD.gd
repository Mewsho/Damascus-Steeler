extends Control

## Script basico del gameplay hud
## Asigna algunos atributos a sus hijos y los oculta o muestra

## Variables de la escena
@onready var player_hud_0 = $HudContainer/PlayerContainer0/VBoxContainer/PlayerHUD0 as PlayerHud
@onready var player_hud_1 = $HudContainer/PlayerContainer1/VBoxContainer/PlayerHUD1 as PlayerHud
@onready var player_hud_2 = $HudContainer/PlayerContainer2/VBoxContainer/PlayerHUD2 as PlayerHud
@onready var player_hud_3 = $HudContainer/PlayerContainer3/VBoxContainer/PlayerHUD3 as PlayerHud
@onready var player_container_0 = $HudContainer/PlayerContainer0
@onready var player_container_1 = $HudContainer/PlayerContainer1
@onready var player_container_2 = $HudContainer/PlayerContainer2
@onready var player_container_3 = $HudContainer/PlayerContainer3
@onready var character_selection_container_0 = $HudContainer/PlayerContainer0/VBoxContainer/CharacterSelectionContainer0
@onready var character_selection_container_1 = $HudContainer/PlayerContainer1/VBoxContainer/CharacterSelectionContainer1
@onready var character_selection_container_2 = $HudContainer/PlayerContainer2/VBoxContainer/CharacterSelectionContainer2
@onready var character_selection_container_3 = $HudContainer/PlayerContainer3/VBoxContainer/CharacterSelectionContainer3

@onready var player_node_container = $"../../PlayerNodeContainer"

## Funcion que le asigna la información al player hud de su numero de player y clase
func set_player_data_hud(player: int):
	var target_hud
	match player:
		0:
			target_hud = player_hud_0
		1:
			target_hud = player_hud_1
		2:
			target_hud = player_hud_2
		3:
			target_hud = player_hud_3
	target_hud.set_player_label(player)
	target_hud.player = player
	var player_class = PlayerManager.get_player_data(player, "class")
	target_hud.set_player_class(player_class)


## Muestra el player hud
func show_player_hud(player : int):
	match player:
		0:
			player_hud_0.show()
		1:
			player_hud_1.show()
		2:
			player_hud_2.show()
		3:
			player_hud_3.show()
## Oculta player hud
func hide_player_hud(player):
	match player:
		0:
			player_hud_0.hide()
		1:
			player_hud_1.hide()
		2:
			player_hud_2.hide()
		3:
			player_hud_3.hide()

## Muestra la seleccion de personaje
func show_player_character_selection(player):
	match player:
		0:
			character_selection_container_0.show()
		1:
			character_selection_container_1.show()
		2:
			character_selection_container_2.show()
		3:
			character_selection_container_3.show()
## Oculta la seleccion de personaje
func hide_player_character_selection(player):
	match player:
		0:
			character_selection_container_0.hide()
		1:
			character_selection_container_1.hide()
		2:
			character_selection_container_2.hide()
		3:
			character_selection_container_3.hide()
