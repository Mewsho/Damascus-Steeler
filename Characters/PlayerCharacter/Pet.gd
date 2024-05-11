extends CharacterBody3D


#const SPEED = 6.2
const SPEED = 5.0
const JUMP_VELOCITY = 12.5
#var player_character = load("res://Characters/PlayerCharacter/PlayerCharacter.tscn")
#var follow_point = player_character.get_node("PetFollowPoint") as Marker3D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 22.5

var character_parent
var follow_point
var contador_jump = 0
var pet_offset = 0
var player_id : int
@onready var area_3d = $Area3D
@onready var timer = $Timer
@onready var mesh_instance_3d = $Rig/MeshInstance3D
@onready var animation_player = $AnimationPlayer
var attack_mode : bool = false
var enemy_target
var attacking : bool = false
var previous_distance

func _ready():
	character_parent = get_parent().get_node(str("Ranger",player_id))
	follow_point = character_parent.get_node("PetFollowPoint")

func _physics_process(delta):
	
	
	check_proximity()
	
	
	if !attack_mode:
		contador_jump += 1
		if not is_on_floor():
			velocity.y -= gravity * delta
		
		var target = follow_point.global_position
		
		if target.y > global_position.y and is_on_floor() and contador_jump > 10:
			velocity.y = JUMP_VELOCITY - gravity*0.05
			contador_jump = 0
			
		if contador_jump > 40:
			contador_jump = 0
		

		var distance = position.distance_to(target)
		var direction = position.direction_to(target)
		if direction:
			if not is_on_floor():
				velocity.x = direction.x * SPEED * 0.9
			else:
				velocity.x = direction.x * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		
		area_3d.set_block_signals(true)
		if enemy_target == null:
			attacking = false
			if !area_3d.has_overlapping_areas():
				area_3d.set_block_signals(false)
				attack_mode = false
				mesh_instance_3d.get_surface_override_material(0).albedo_color = Color(0,1,0)
				return
			else:
				var areas = area_3d.get_overlapping_areas()
				#var cant_enemigos = len(areas)
				#var r = randi_range(0,cant_enemigos-1)
				enemy_target = areas[0]
			
		if not is_on_floor():
			velocity.y -= gravity * delta
		

		var target = enemy_target.global_position
		target.x -=0.5
		var distance = position.distance_to(target)
		var direction = position.direction_to(target)
		print(distance)
		print(direction)
		if distance > 0.9 and !attacking:
			
			if distance == previous_distance:
				velocity.y = JUMP_VELOCITY - gravity*0.05
			if direction.y > 0.4:
				velocity.y = JUMP_VELOCITY - gravity*0.05	
			if direction:
				if not is_on_floor():
					velocity.x = direction.x * SPEED * 0.9
				else:
					velocity.x = direction.x * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)

		else:
			velocity = Vector3(0,0,0)
			attacking = true
			pet_attack()
		
		previous_distance = distance
		
	move_and_slide()

func pet_attack():
	print("ataco")
	animation_player.play("Attack")
	mesh_instance_3d.get_surface_override_material(0).albedo_color = Color(1,0,0)
	await animation_player.animation_finished
	enemy_target.hit(0.0001)
	await get_tree().create_timer(0.5).timeout


func check_proximity():
	var distance = position.distance_to(follow_point.global_position)
	if distance > 20:
		self.position = follow_point.global_position
		attacking = false
		area_3d.set_block_signals(false)
		attack_mode = false
		mesh_instance_3d.get_surface_override_material(0).albedo_color = Color(0,1,0)


func _on_area_3d_area_entered(area):
	print(area.name)
	if area.is_in_group("enemy"):
		print(area.get_parent().name)
		mesh_instance_3d.get_surface_override_material(0).albedo_color = Color(1,1,0)
		attack_mode = true
		enemy_target = area


