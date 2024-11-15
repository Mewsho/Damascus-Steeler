extends CharacterBody3D

const SPEED = 6.1
# Altura de Salto del PJ
const JUMP_VELOCITY = 12.6
# Gravedad del socio
var gravity = 26.2
var y_velo = 0

# Instanciacion de la bala
var instance 
# Instanciar el ataque especial al pj
var instancesp
#Cargar el ataque especial al pj
const SPECIAL = preload("res://Characters/Guns/special.tscn")
const BULLET = preload("res://Characters/Guns/bullet.tscn")
const PET = preload("res://Characters/PlayerCharacter/Pet.tscn")
const SPECIAL_MAGE = preload("res://Characters/Guns/Specials/special_mage.tscn")
const MAGE_BULLET = preload("res://Characters/Guns/Bullets/mage_bullet.tscn")
const SPECIAL_KNIGHT = preload("res://Characters/Guns/Specials/special_knight.tscn")
const KNIGHT_BULLET = preload("res://Characters/Guns/Bullets/knight_bullet.tscn")
const SPECIAL_BARBARIAN = preload("res://Characters/Guns/Specials/special_barbarian.tscn")
const BARBARIAN_BULLET = preload("res://Characters/Guns/Bullets/barbarian_bullet.tscn")
const RANGER_BULLET = preload("res://Characters/Guns/Bullets/ranger_bullet.tscn")

# Regeneracion de mana por dificultad de juego
var mana_regen_rate = 1
# variable por mientras de dificultad ( 0 extremo , 10 dificil, 25 normal, 50 facil,
var difficulty_level = 50
const DeviceInput = preload("res://addons/multiplayer_input/device_input.gd")
var is_in_left_border : bool = false
var is_in_right_border : bool = false
var is_dead : bool = false


@onready var pet_follow_point = $PetFollowPoint as Marker3D
@onready var gun = $Gun
@onready var gun_ray_cast_3d = $Gun/RayCast3D as RayCast3D
@onready var gun_animation_player = $Gun/Pistola/AnimationPlayer as AnimationPlayer
@onready var player_node_container = get_parent()
@onready var area_caida = $AreaCaida
@onready var player_area_3d = $PlayerArea3D
@onready var collision_shape_3d = $CollisionShape3D

## Timer invul
@onready var invul_timer = $InvulTimer



var player: int
var input : DeviceInput
var device 
var player_class : String = "Mage"
var pet_number = 0
# PJs Variables
var mana = 100 : set = _set_mana
var lifes = 3 : set = _set_lifes
var animation_player : AnimationPlayer
var is_landing : bool
var is_facing_front: bool = true
var is_moving_forward : bool = false
var rig
var tween_scale : Tween

signal leave
signal mana_change(n_player, amount)
signal lifes_change(n_player, amount)
signal character_lost_life(n_player)
signal character_game_over(n_player)

# call this function when yspawning this player to set up the input object based on the device
func init(player_num: int):
	player = player_num
	pet_number = 0
	device = PlayerManager.get_player_device(player)
	input = DeviceInput.new(device)
	animation_player = get_node(player_class).get_node("AnimationPlayer") as AnimationPlayer
	animation_player.animation_finished.connect(on_animation_finished)
	rig = get_node(player_class)

func _ready():
	area_caida.monitoring = true

	
func set_player_class(name : String):
	self.player_class = name
	
func get_player_class()-> String:
	return self.player_class
	
func _physics_process(delta):
	

	# Get the input direction and handle the movement/deceleration.
	var move_dir = 0
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if !is_dead:
		handle_movement(move_dir)
	
	camera_checks()
	
	if is_dead:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()
	if !is_dead:
		handle_gun_actions()

	# Test
	if input.is_action_just_pressed("test_action"):
		self.lifes -= 1

	if mana < 60:
		mana += 0.1 * mana_regen_rate
	
func handle_movement(move_dir):
	var input_dir = input.get_vector("move_left", "move_right", "move_down","move_up")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if input.is_action_pressed("move_left"):
		is_moving_forward = true
		move_dir -=1
		if is_on_floor():
			is_landing = false
			animation_player.set_default_blend_time(0.2)
			animation_player.play("Running_A")
	
	if input.is_action_pressed("move_right"):
		is_moving_forward = true
		move_dir +=1
		if is_on_floor():
			is_landing = false
			animation_player.set_default_blend_time(0.2)
			animation_player.play("Running_A")
	
	if input.is_action_pressed("move_down"):
		tween_scale = create_tween()
		player_area_3d.scale.y = 0.5
		collision_shape_3d.scale.y = 0.5
		collision_shape_3d.position.y = 0.5
		tween_scale.tween_property(rig,"scale", Vector3(1,0.5,1),0.1)
		#rig.scale.y = 0.5
	else:
		player_area_3d.scale.y = 1
		collision_shape_3d.scale.y = 1
		collision_shape_3d.position.y = 1
		#if tween_scale:
			#tween_scale.kill()
		tween_scale = create_tween()
		tween_scale.tween_property(rig,"scale", Vector3(1,1,1),0.1).set_trans(Tween.TRANS_QUAD)


	if is_dead:
		move_dir = 0;

	if move_dir > 0:
		rotation.y = 0
		is_facing_front = true
	if move_dir < 0:
		rotation.y = -110
		is_facing_front = false
		
	if move_dir == 0 && is_on_floor():
		if is_landing:
			animation_player.animation_set_next("Jump_Land","Idle")
		else:
			animation_player.play("Idle")
		is_moving_forward = false

	if input.is_action_just_pressed("jump") and is_on_floor():
		animation_player.set_default_blend_time(0.2)
		animation_player.play("Jump_Start")
		animation_player.set_speed_scale(1.8)
		velocity.y = JUMP_VELOCITY - gravity*0.05
		
	if velocity.y < 0 && !is_on_floor() && !is_landing:
		animation_player.set_default_blend_time(0.1)
		animation_player.play("Jump_Idle")
		animation_player.set_speed_scale(1.8)

	# Disminuir la velocidad del PJ si se encuentra en el aire
	if direction:
		if not is_on_floor():
			velocity.x = direction.x * SPEED * 0.9
		else:
			velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
func camera_checks():
	if is_in_left_border == true:
		#velocity.clamp(Vector3(0,0,0),Vector3(100,100,100))
		if velocity.x < 0:
			velocity.x = 0
	if is_in_right_border == true:
		if velocity.x > 0:
			velocity.x = 0

func handle_gun_actions():
	# Disparos Insanos
	if input.is_action_just_pressed("attack"):
	# Solucion al problema del spam continuo de disparos
		if !gun_animation_player.is_playing():
			gun_animation_player.play("Shoot")
			instance = BULLET.instantiate()
			match player_class:
				"Mage":
					instance = MAGE_BULLET.instantiate()
				"Knight":
					instance = KNIGHT_BULLET.instantiate()
				"Barbarian":
					instance = BARBARIAN_BULLET.instantiate()
				"Ranger":
					instance = RANGER_BULLET.instantiate()
			instance.position = gun_ray_cast_3d.global_position
			instance.transform.basis = gun_ray_cast_3d.global_transform.basis
			get_parent().add_child(instance)
	
	if input.is_action_just_pressed("special"):
		handle_special(player_class)
		
	# Amalgamacion para disparar en direcciones del Metal Slug
	if input.is_action_pressed("move_down") && !is_on_floor():
		gun.rotation.z = -1.5
	if input.is_action_just_released("move_down"):
		gun.rotation.z = 0
	if input.is_action_pressed("move_up"):
		gun.rotation.z = 1.55
	if input.is_action_just_released("move_up"):
		gun.rotation.z = 0
	if input.is_action_pressed("move_up") && input.is_action_pressed("move_right") :
		gun.rotation.z = 0.5
	if input.is_action_just_released("move_up") && input.is_action_pressed("move_right") :
		gun.rotation.z = 0
	if input.is_action_pressed("move_up") && input.is_action_pressed("move_left") :
		gun.rotation.z = 0.5
	if input.is_action_just_released("move_up") && input.is_action_pressed("move_left") :
		gun.rotation.z = 0


func handle_special(p_class : String):
	if mana < 39:
		return
	var class_special = p_class
	match class_special:
		"Mage":
			mage_special()
		"Knight":
			knight_special()
		"Barbarian":
			barbarian_special()
		"Ranger":
			ranger_special()

		
func mage_special():
	if !gun_animation_player.is_playing():
			gun_animation_player.play("Shoot")
			instancesp = SPECIAL_MAGE.instantiate()
			instancesp.position = gun_ray_cast_3d.global_position
			instancesp.transform.basis = gun_ray_cast_3d.global_transform.basis
			if is_facing_front: 
				if gun.rotation.z == -1.5: #Apuntando abajo mirando al frente
					instancesp.linear_velocity.y = -15
				elif is_equal_approx(gun.rotation.z, 1.55): #Apuntando arriba
					instancesp.linear_velocity.y = 15
					instancesp.angular_velocity.z = deg_to_rad(-30)
				elif gun.rotation.z == 0.5: # Diagonal arriba
					print("Diagonal")
					instancesp.linear_velocity.x = sqrt(15**2/2)
					instancesp.linear_velocity.y = sqrt(15**2/2)/2
					instancesp.angular_velocity.z = deg_to_rad(-15)
				else:
					instancesp.linear_velocity.x = 15
					instancesp.angular_velocity.z = deg_to_rad(-10)
			else:
				if gun.rotation.z == -1.5: #Apuntando abajo mirando atras
					instancesp.linear_velocity.y = -15
				elif is_equal_approx(gun.rotation.z, 1.55): #Apuntando arriba
					instancesp.linear_velocity.y = 15
					instancesp.angular_velocity.z = deg_to_rad(30)
				elif gun.rotation.z == 0.5: # Diagonal arriba
					print("Diagonal")
					instancesp.linear_velocity.x = -sqrt(15**2/2)
					instancesp.linear_velocity.y = sqrt(15**2/2)/2
					instancesp.angular_velocity.z = deg_to_rad(15)
				else:
					instancesp.linear_velocity.x = -15
					instancesp.angular_velocity.z = deg_to_rad(10)
			print(gun.rotation.z)
			get_parent().add_child(instancesp)
			mana = mana - 40

func knight_special():
	if !gun_animation_player.is_playing():
		gun_animation_player.play("Shoot")
		instancesp = SPECIAL_KNIGHT.instantiate()
		if is_facing_front:
			instancesp.position = global_position + Vector3(8,0,0)
			if is_moving_forward:
				instancesp.position += Vector3(5,0,0)
		else:
			instancesp.position = global_position - Vector3(8,0,0)
			#if is_moving_forward:
				#instancesp.position -= Vector3(5,0,0)
		get_parent().add_child(instancesp)
		mana -= 40

func barbarian_special():
	if !gun_animation_player.is_playing():
		gun_animation_player.play("Shoot")
		instancesp = SPECIAL_BARBARIAN.instantiate()
		
		instancesp.position = global_position
		
		if !is_facing_front:
			instancesp.is_forward = false
			instancesp.position.x -= 2
		else:
			instancesp.position.x += 2
		#instancesp.transform.basis = gun_ray_cast_3d.global_transform.basis
		get_parent().add_child(instancesp)
		mana = mana - 50
		
## Especial del ranger, instancia una mascota y le agrega un nombre unico
func ranger_special():
	if mana <  59:
		return
	var pet_instance = PET.instantiate()
	pet_instance.global_position = pet_follow_point.global_position
	pet_instance.player_id = player
	pet_instance.name = str("Pet",pet_number)
	#pet_instance.pet_offset = pet_number
	get_parent().add_child(pet_instance) 
	pet_instance.pet_offset = pet_number
	pet_number+=1
	
	mana = mana - 60


## Funciones setter del mana y vidas, ambas emiten señales que son recibidas
## por el core.gd, el que los conecta con elementos del hud
func _set_mana(_mana):
	var previus_mana = mana
	mana = max(0,_mana)
	emit_signal("mana_change", player, mana)

func _set_lifes(n_lifes):
	area_caida.monitoring = false
	var prev_lifes = lifes
	lifes = max(0,n_lifes)
	is_dead = true
	#animation_player.set_speed_scale(5) #Comedia
	animation_player.set_speed_scale(1)
	if prev_lifes == 0:
		
		animation_player.play("Death_B") ##Game over
		
	else:
		animation_player.play("Death_A") ## Muerte normal
	emit_signal("lifes_change",player, lifes)
	#emit_signal("character_game_over",player)
	#emit_signal("character_lost_life", player)

func on_animation_finished(anim_name):
	if anim_name == "Death_A":
		emit_signal("character_lost_life", player)
	if anim_name == "Death_B":
		emit_signal("character_game_over",player)
	if anim_name == "Running_A":
		animation_player.play("Idle")
	if anim_name == "Idle":
		is_landing = false
	if anim_name == "Jump_Land":
		is_landing = false
	if anim_name == "Jump_Start":
		is_landing = false

func hit(dam):
	if is_dead:
		return
	if !invul_timer.is_stopped():
		return
	lifes -= dam
	
	

func iniciartimer():
	invul_timer.start()
	print("Concepcion")

func _on_test_caida_area_entered(area):
	if velocity.y < 0:
		is_landing = true
		## TODO Tal vez aplicar el blend en vez que solo un play
		animation_player.play("Jump_Land")
		#animation_player.set_speed_scale(0.2)



