extends CharacterBody3D

const SPEED = 6.2
# Altura de Salto del PJ
const JUMP_VELOCITY = 12.5
# Gravedad del socio
var gravity = 26.2
var y_velo = 0
# Variable con la bala
const BULLET = preload("res://Guns/bullet.tscn")
# Instanciacion de la bala
var instance 
# Instanciar el ataque especial al pj
var instancesp
#Cargar el ataque especial al pj
const SPECIAL = preload("res://Guns/special.tscn")
# Cantidad de mana 
var mana = 100
# Regeneracion de mana por dificultad de juego
var mana_regen_rate = 1 
# variable por mientras de dificultad ( 0 extremo , 10 dificil, 25 normal, 50 facil,
var difficulty_level = 50
const DeviceInput = preload("res://addons/multiplayer_input/device_input.gd")
signal leave

@onready var gun = $Gun
@onready var gun_ray_cast_3d = $Gun/RayCast3D
@onready var gun_animation_player = $Gun/Pistola/AnimationPlayer
@onready var camera_controller = $Camera_controller


var player: int
var input : DeviceInput
var device 

# call this function when yspawning this player to set up the input object based on the device
func init(player_num: int):
	player = player_num
	device = PlayerManager.get_player_device(player)
	input = DeviceInput.new(device)
	

func _ready():
	pass
	
func _physics_process(delta):
	# Make Cam follow this mf | La funcion lerp sirve para darle un poco de smoothing para que no se vea tan choppi |
	camera_controller.position.x = lerp(camera_controller.position.x ,position.x ,0.1)	
	# Get the input direction and handle the movement/deceleration.
	var move_dir = 0
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var input_dir = input.get_vector("move_left", "move_right", "move_down","move_up")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if input.is_action_pressed("move_left"):
		move_dir -=1
	if input.is_action_pressed("move_right"):
		move_dir +=1
	if move_dir > 0:
		scale.x = 1
	if move_dir < 0:
		scale.x = -1
		
	if input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY - gravity*0.05
	# Disminuir la velocidad del PJ si se encuentra en el aire
	if direction:
		if not is_on_floor():
			velocity.x = direction.x * SPEED * 0.9
		else:
			velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	#animation_tree.set("parameters/conditions/idle", input_dir == Vector2.ZERO && is_on_floor())
	#animation_tree.set("parameters/conditions/walk", input_dir != Vector2.ZERO && is_on_floor())
	#animation_tree.set("parameters/conditions/jump", !is_on_floor())
	#animation_tree.set("parameters/conditions/landing", is_on_floor())

# No quitar no se que mierda hace pero sin esto no se mueve 
	move_and_slide()	
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
	# Solucion al problema del spam continuo de disparos
		if !gun_animation_player.is_playing():
			gun_animation_player.play("Shoot")
			instancesp = SPECIAL.instantiate()
			instancesp.position = gun_ray_cast_3d.global_position
			instancesp.transform.basis = gun_ray_cast_3d.global_transform.basis
			get_parent().add_child(instancesp)
	# Amalgamacion para disparar en direcciones del Metal Slug
	if input.is_action_pressed("move_down") && !is_on_floor():
		gun.rotation.z = -1.5
	if input.is_action_just_released("move_down"):
		gun.rotation.z = 0
	if input.is_action_pressed("move_up"):
		gun.rotation.z = 1.5
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
	# Existen formas mas eficintes lo se
	
	if input.is_action_just_pressed("special") && mana > 20:
		mana -= 20
		print(mana)

	if mana <40:
		mana += mana_regen_rate * difficulty_level
		
