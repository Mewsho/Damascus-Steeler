extends CharacterBody3D

const SPEED = 6.2
# Altura de Salto del PJ
const JUMP_VELOCITY = 12.5
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

signal leave
signal mana_change(n_player, amount)
signal lifes_change(n_player, amount)
signal character_lost_life(n_player)
signal character_game_over(n_player)

# call this function when yspawning this player to set up the input object based on the device
func init(player_num: int):
	player = player_num
	device = PlayerManager.get_player_device(player)
	input = DeviceInput.new(device)
	animation_player = get_node(player_class).get_node("AnimationPlayer") as AnimationPlayer
	animation_player.animation_finished.connect(on_animation_finished)

func _ready():
	connect
	
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
		velocity = Vector3(0,0,0)

	move_and_slide()
	handle_gun_actions()

	# Test
	if input.is_action_just_pressed("test_action"):
		self.lifes -= 1

	if mana < 60:
		mana += 0.1
	
func handle_movement(move_dir):
	var input_dir = input.get_vector("move_left", "move_right", "move_down","move_up")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if input.is_action_pressed("move_left"):
		move_dir -=1
		if is_on_floor():
			is_landing = false
			animation_player.set_default_blend_time(0.2)
			animation_player.play("Running_A")
	
	if input.is_action_pressed("move_right"):
		move_dir +=1
		if is_on_floor():
			is_landing = false
			animation_player.set_default_blend_time(0.2)
			animation_player.play("Running_A")
			
		
	if is_dead:
		move_dir = 0;

	if move_dir > 0:
		rotation.y = 0
	if move_dir < 0:
		rotation.y = -110
		
	if move_dir == 0 && is_on_floor():
		if is_landing:
			animation_player.animation_set_next("Jump_Land","Idle")
		else:
			animation_player.play("Idle")

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
	if mana < 20:
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
			instancesp = SPECIAL.instantiate()
			instancesp.position = gun_ray_cast_3d.global_position
			instancesp.transform.basis = gun_ray_cast_3d.global_transform.basis
			get_parent().add_child(instancesp)
			mana = mana - 20

func knight_special():
	if !gun_animation_player.is_playing():
		gun_animation_player.play("Shoot")
		instancesp = SPECIAL.instantiate()
		instancesp.position = gun_ray_cast_3d.global_position
		instancesp.transform.basis = gun_ray_cast_3d.global_transform.basis
		get_parent().add_child(instancesp)
		mana -= 20

func barbarian_special():
	if !gun_animation_player.is_playing():
		gun_animation_player.play("Shoot")
		instancesp = SPECIAL.instantiate()
		instancesp.position = gun_ray_cast_3d.global_position
		instancesp.transform.basis = gun_ray_cast_3d.global_transform.basis
		get_parent().add_child(instancesp)
		mana = mana - 20
		
## Especial del ranger, instancia una mascota y le agrega un nombre unico
func ranger_special():
	var pet_instance = PET.instantiate()
	pet_instance.global_position = pet_follow_point.global_position
	pet_instance.player_id = player
	pet_instance.name = str("Pet",pet_number)
	#pet_instance.pet_offset = pet_number
	get_parent().add_child(pet_instance) 
	pet_number+=1
	mana = mana - 40


## Funciones setter del mana y vidas, ambas emiten señales que son recibidas
## por el core.gd, el que los conecta con elementos del hud
func _set_mana(_mana):
	var previus_mana = mana
	mana = max(0,_mana)
	emit_signal("mana_change", player, mana)

func _set_lifes(n_lifes):
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



func _on_test_caida_area_entered(area):
	if velocity.y < 0:
		print("test")
		is_landing = true
		## TODO Aplicar el blend en vez que solo un play
		animation_player.play("Jump_Land")
		#animation_player.set_speed_scale(0.2)



