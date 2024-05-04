extends Node3D

var current_selected_character_name : String
var selection_area = preload("res://Level/CharacterSelection/selection_area.tscn") as PackedScene

@onready var characters = $Characters as Node
@onready var character_label = $MarginContainer/VBoxContainer/CharacterLabel as Label
@onready var selection = $MarginContainer/HBoxContainer/VBoxContainer/Selection as Button
@onready var core = get_tree().get_root().get_node("Core")
@onready var rogue = $Characters/Rogue
@onready var barbarian = $Characters/Barbarian
@onready var mage = $Characters/Mage
@onready var knight = $Characters/Knight

signal animation_finished


var cant_selection_rings = 1
#var is_first_move = []
var character_hover = []
var ring_pos = []
var animation_players = []

func _ready() -> void:
	PlayerManager.player_joined.connect(update_selection_rings)
	for player in range(PlayerManager.get_player_count()):
		update_selection_rings(player)
	#TASK Arreglar que no se pueda agregar pjs en la seleccion de personajes
	
func character_selected(character_name):
	current_selected_character_name = character_name
	character_label.text = current_selected_character_name

func _process(delta):
	handle_inputs()


func handle_inputs():
	for i in range(PlayerManager.get_player_count()):
		#is_first_move.append(false)
		character_hover.append(0)
		ring_pos.append(0)
	for player in range(PlayerManager.get_player_count()):
		var device = PlayerManager.get_player_device(player)
		if  MultiplayerInput.is_action_just_pressed(device, "move_left"): # MultiplayerInput.is_action_just_pressed(player,"ui_left") or
			#if is_first_move[player] == true:
				#character_hover[player] = 0
				#is_first_move[player]= false
			#else:
			if character_hover[player] == 0:
				character_hover[player] = 3
			else:
				character_hover[player] -=1
			gamepad_character_hover(player,character_hover[player])
		if MultiplayerInput.is_action_just_pressed(device, "move_right"):  #MultiplayerInput.is_action_just_pressed(player,"ui_right") or
			#if is_first_move[player] == true:
				#character_hover[player] = 0
				#is_first_move[player]= false
			#else:
			if character_hover[player] == 3:
				character_hover[player] = 0
			else:
				character_hover[player] +=1
			gamepad_character_hover(player,character_hover[player])
		if MultiplayerInput.is_action_just_pressed(device, "jump"):
			select_character(player,character_hover[player])
		if MultiplayerInput.is_action_just_pressed(device, "start"):
			core.switch_scene("res://world.tscn")

func select_character(player: int, character_hovered):
	var character_name = str(characters.get_child(character_hovered).name)
	character_selected(character_name)
	PlayerManager.set_player_data(player, "class",character_name)
	var selected_character = characters.get_child(character_hovered)
	selected_character.get_node("AnimationPlayer").play("Cheer")
	await selected_character.get_node("AnimationPlayer").animation_finished
	selected_character.get_node("AnimationPlayer").play("Idle")
	#print(character_hovered)
	#selected_character.get_node(str("SelectionArea",player)).play_anim("Cheer")

func move_node(node, new_parent): # node - the node that you want to move, new_parent - where you want to move the node
	var ring = node
	node.get_parent().remove_child(node) # Get node's parent and remove node from it    
	new_parent.add_child(ring) # Add node to new parent as a child   

func update_selection_rings(n_player : int):
	var selection_area_ins = selection_area.instantiate()
	selection_area_ins.name = str("SelectionArea", n_player)
	var selection_ring = selection_area_ins.get_node("SelectionRing")
	match n_player:
		0:
			selection_ring.get_surface_override_material(0).albedo_color = Color(1,0,0)
			selection_ring.scale.x = 1
			selection_ring.scale.z = 1
		1:
			selection_ring.get_surface_override_material(0).albedo_color = Color(0,0,1)
			selection_ring.scale.x = 1.1
			selection_ring.scale.z = 1.1
		2:
			selection_ring.get_surface_override_material(0).albedo_color = Color(255,255,0)
			selection_ring.scale.x = 1.2
			selection_ring.scale.z = 1.2
		3:
			selection_ring.get_surface_override_material(0).albedo_color = Color(0,1,0)
			selection_ring.scale.x = 1.3
			selection_ring.scale.z = 1.3
	characters.get_child(0).add_child(selection_area_ins)
		#n_player += 1
		#cant_selection_rings += 1
	
		
func gamepad_character_hover(player, character_hovered):
	var ring
	ring = characters.get_child(ring_pos[player]).get_node(str("SelectionArea",player))
	move_node(ring, characters.get_child(character_hovered))
	ring_pos[player] = character_hovered
	ring.show_selection()

func _on_selection_pressed():
	if current_selected_character_name:
		PlayerVariables.set_player_character(current_selected_character_name)
	core.switch_scene("res://world.tscn")
	
		
	
