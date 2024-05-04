extends Node

@onready var scene_node_container = $SceneNodeContainer as Node

var player_nodes = {}
var chunks_elegidos = []
#var thread_pcg : Thread
#var thread_normal: Thread
#var mutex_pcg : Mutex
const PLAYER_CHARACTER = preload("res://Characters/PlayerCharacter/PlayerCharacter.tscn")


func _ready():
	
	PlayerManager.player_joined.connect(handle_player_join)
	PlayerManager.player_left.connect(delete_player)
	
	MultiplayerInput.reset()
	PlayerManager.join(-1)
	#mutex_pcg = Mutex.new()
	#thread_pcg = Thread.new()
	##thread_normal = Thread.new()
	##thread_normal.start(_thread_normal_ready)
	#thread_pcg.start(_thread_pcg_function)

#func _thread_pcg_function():
	#chunks_elegidos = PCGcurrent.PCG_General()
	#
#func _thread_normal_ready():
	#PlayerManager.player_joined.connect(handle_player_join)
	#PlayerManager.player_left.connect(delete_player)
	#
	#MultiplayerInput.reset()
	#PlayerManager.join(-1) #Esto es para añadir altiro al teclado

#func _exit_tree():
	#thread_normal.wait_to_finish()

func _process(_delta):
	PlayerManager.handle_join_input()
	PlayerManager.handle_leave_input()
	print(PlayerManager.player_data)
	
func handle_player_join(player: int):
	var current_scene = scene_node_container.get_child(0)
	
	var player_scene = PLAYER_CHARACTER
	player_scene.set_script("res://Player.gd")
	var player_node = player_scene.instantiate()
	player_nodes[player] = player_node
	
	if current_scene.is_in_group("Menus"):
		change_player_menu(current_scene, player,true)
	if current_scene.is_in_group("Levels"):
		spawn_player(player,player_node)

func change_player_menu(scene: Control, player: int , toggle : bool):
	var player_hud = scene.find_child("PlayerContainer") 
	if toggle:
		player_hud.toggle_player_icon(player)
	else:
		player_hud.untoggle_player_icon(player)
	
func spawn_player(player: int, player_node):
	# create the player node
	#var player_scene = load("res://player.tscn")
	#
	#player_scene.set_script("res://Player.gd")
	#var player_node = player_scene.instantiate()
	var player_class_name = PlayerManager.get_player_data(player, "class")
	var player_class = PlayerVariables.get_player_classes(player_class_name).instantiate()
	var default_mesh = player_node.get_child(0)
	player_node.remove_child(default_mesh)
	default_mesh.queue_free()
	player_class.rotation.y = 70
	player_node.add_child(player_class)
	player_node.leave.connect(on_player_leave)
	
	# let the player know which device controls it
	var device = PlayerManager.get_player_device(player)
	player_node.init(player)
	
	# add the player to the tree
	add_child(player_node)
	
	# random spawn position
	player_node.position = Vector3(randf_range(4, 6), randf_range(4, 6),7)
	
func delete_player(player: int):
	var current_scene = scene_node_container.get_child(0)
	if current_scene.is_in_group("Menus"):
		change_player_menu(current_scene, player,false)
	player_nodes[player].queue_free()
	player_nodes.erase(player)

func on_player_leave(player: int):
	# just let the player manager know this player is leaving
	# this will, through the player manager's "player_left" signal,
	# indirectly call delete_player because it's connected in this file's _ready()
	PlayerManager.leave(player)
	
	
func switch_scene(scene_path: String,level=-1):
	var current_scenes = scene_node_container.get_children()
	var scene_count: int = current_scenes.size()
	
	if (scene_count > 0):
		#loading_panel.visible = true
		
		
		await get_tree().create_timer(0.5).timeout
		
		for child in current_scenes:
			scene_node_container.remove_child(child)
			child.queue_free()
		
		var new_scene = load(scene_path).instantiate()
		scene_node_container.add_child(new_scene)

		await get_tree().create_timer(0.4).timeout
		
	for player in range(PlayerManager.get_player_count()):
		handle_player_join(player)
	
		#loading_panel.visible = false
