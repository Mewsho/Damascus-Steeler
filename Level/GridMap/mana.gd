extends Node3D


var mana = 10




func _on_pick_up_area_3d_area_entered(area):
	if area.is_in_group("player"):
		var player_node = area.get_parent()
		player_node.mana += mana
		queue_free()
