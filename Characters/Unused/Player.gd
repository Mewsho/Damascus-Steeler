extends CharacterBody3D

# Vel movimiento del PJ
const SPEED = 6.2
# Altura de Salto del PJ
const JUMP_VELOCITY = 12.5
# Gravedad del socio
var gravity = 26.2
# Velocidad Y
var y_velo = 0
# Variable con la bala
#const BULLET = preload("res://Guns/bullet.tscn")
# Instanciacion de la bala
var instance 
# Cargar el ataque especial al pj
#const SPECIAL = preload("res://Guns/special.tscn")
# Cantidad de mana 
var mana = 100
# Regeneracion de mana por dificultad de juego
var mana_regen_rate = 1 
# variable por mientras de dificultad ( 0 extremo , 10 dificil, 25 normal, 50 facil,
var difficulty_level = 50
# Preparar las animaciones de la bala

@onready var gun_anim = $Gun/Pistola/AnimationPlayer
@onready var gun_barrel = $Gun/RayCast3D
@onready var pistolatotal = $Gun
@onready var animation_tree = $Robot/AnimationPlayer/AnimationTree
@onready var camera_controller = $Camera_controller




# Funcion que se ejecuta cada frame 
func _physics_process(delta):
	# Make Cam follow this mf | La funcion lerp sirve para darle un poco de smoothing para que no se vea tan choppi |
	camera_controller.position.x = lerp(camera_controller.position.x ,position.x ,0.1)	
	# Get the input direction and handle the movement/deceleration.
	var move_dir = 0
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "jump", "move_down")
	var direction = (Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# Forma rancia pa reorientar al socio
	if Input.is_action_pressed("move_left"):
		move_dir -=1
	if Input.is_action_pressed("move_right"):
		move_dir +=1
	if move_dir > 0:
		scale.x = 1
	if move_dir < 0:
		scale.x = -1
	# Agregar gravedad mientras no se encuentra en el aire
	if not is_on_floor():
		velocity.y -= gravity * delta

	## Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
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
		
# Animaciones pal desubicao
	animation_tree.set("parameters/conditions/idle", input_dir == Vector2.ZERO && is_on_floor())
	animation_tree.set("parameters/conditions/walk", input_dir != Vector2.ZERO && is_on_floor())
	animation_tree.set("parameters/conditions/jump", !is_on_floor())
	animation_tree.set("parameters/conditions/landing", is_on_floor())

# No quitar no se que mierda hace pero sin esto no se mueve 
	move_and_slide()	
	# Disparos Insanos
	if Input.is_action_just_pressed("attack"):
	# Solucion al problema del spam continuo de disparos
		if !gun_anim.is_playing():
			gun_anim.play("Shoot")
			#instance = BULLET.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(instance)
	
	if Input.is_action_just_pressed("special"):
	# Solucion al problema del spam continuo de disparos
		if !gun_anim.is_playing():
			gun_anim.play("Shoot")
			#instance = SPECIAL.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(instance)
	# Amalgamacion para disparar en direcciones del Metal Slug
	if Input.is_action_pressed("move_down") && !is_on_floor():
		pistolatotal.rotation.z = -1.5
	if Input.is_action_just_released("move_down"):
			pistolatotal.rotation.z = 0
	if Input.is_action_pressed("move_up"):
		pistolatotal.rotation.z = 1.5
	if Input.is_action_just_released("move_up"):
			pistolatotal.rotation.z = 0
	if Input.is_action_pressed("move_up") && Input.is_action_pressed("move_right") :
		pistolatotal.rotation.z = 0.5
	if Input.is_action_just_released("move_up") && Input.is_action_pressed("move_right") :
		pistolatotal.rotation.z = 0
	if Input.is_action_pressed("move_up") && Input.is_action_pressed("move_left") :
		pistolatotal.rotation.z = 0.5
	if Input.is_action_just_released("move_up") && Input.is_action_pressed("move_left") :
		pistolatotal.rotation.z = 0
	# Existen formas mas eficintes lo se
	
	if Input.is_action_just_pressed("special") && mana > 20:
		mana -= 20
		print(mana)

	if mana <40:
		mana += mana_regen_rate * difficulty_level
		

