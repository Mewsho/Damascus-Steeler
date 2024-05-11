extends Control

@onready var player_hud_0 = $HudContainer/PlayerHUD0 as PlayerHud
@onready var player_hud_1 = $HudContainer/PlayerHUD1 as PlayerHud
@onready var player_hud_2 = $HudContainer/PlayerHUD2 as PlayerHud
@onready var player_hud_3 = $HudContainer/PlayerHUD3 as PlayerHud
@onready var player_node_container = $"../../PlayerNodeContainer"




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
