extends CharacterBody3D

## Script de la mascota invocada por el ranger
## El script se encarga del movimiento y las animaciones que realiza
## El movimiento consiste en seguir al jugador y trackear algun enemigo

const SPEED = 5.0
const JUMP_VELOCITY = 12.5

var gravity = 22.5

@onready var area_3d = $Area3D
@onready var timer = $Timer
@onready var mesh_instance_3d = $Rig/MeshInstance3D
@onready var animation_player = $AnimationPlayer

## Variables que utiliza
var character_parent
var follow_point
var contador_jump = 0 ## Variable auxiliar para evitar que salte constantemente
var pet_offset = 0 ## Variable para separar a los pets WARNING no implementado creo
var player_id : int

var attack_mode : bool = false
var enemy_target
var attacking : bool = false
var previous_distance

func _ready():
	## Al instanciarse determina su pariente y follow point
	character_parent = get_parent().get_node(str("Ranger",player_id))
	follow_point = character_parent.get_node("PetFollowPoint")

func _physics_process(delta):

	check_proximity()
	
	
	## Si no esta en modo ataque es movimiento default siguiendo al jugador
	if !attack_mode:
		contador_jump += 1
		if not is_on_floor():
			velocity.y -= gravity * delta
		
		## Target es el jugador
		var target = follow_point.global_position
		## Salta si esta arriba el jugador
		if target.y > global_position.y and is_on_floor() and contador_jump > 10:
			velocity.y = JUMP_VELOCITY - gravity*0.05
			contador_jump = 0
		## Contador jump es para que no salte constantemente y no usar un timer
		if contador_jump > 40:
			contador_jump = 0
		
		## Distancia y vector normalizado direction
		var distance = position.distance_to(target)
		var direction = position.direction_to(target)
		## Se mueve a la direccion
		if direction:
			if not is_on_floor():
				velocity.x = direction.x * SPEED * 0.9
			else:
				velocity.x = direction.x * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else: ## Si esta en modo ataque
		##Desactiva otras señales del area de detección
		area_3d.set_block_signals(true)
		## Cuando el enemigo pare de existir, para de atacar y revisa si hay mas
		## Si es que no hay desativa el modo ataque
		## Si hay va al siguiente en la lista
		if enemy_target == null:
			attacking = false
			if !area_3d.has_overlapping_areas():
				area_3d.set_block_signals(false)
				attack_mode = false
				mesh_instance_3d.get_surface_override_material(0).albedo_color = Color(0,1,0)
				return
			else:
				var areas = area_3d.get_overlapping_areas()
				enemy_target = areas[0]
			
		if not is_on_floor(): ## Gravedad
			velocity.y -= gravity * delta
			
		## El objetivo enemigo, moviendo el punto un poco mas atras para acomodar la animacion
		var target = enemy_target.global_position
		target.x -=0.5
		var distance = position.distance_to(target)
		var direction = position.direction_to(target)
		print(distance)
		print(direction)
		if distance > 0.9 and !attacking: ## Si esta lejos y no atacando
			## Estos if son intentos de hacer que se mueva al enemigo
			## TODO Mejorar el sistema, sobretodo cuando esta debajo el enemigo
			if distance == previous_distance: ## Si por dos frames esta en el mismo lugar salta
				velocity.y = JUMP_VELOCITY - gravity*0.05
				velocity.x = SPEED * direction.x * 0.9
			## Si se encuentra relativamente arriba
			if direction.y > 0.4: ## Salta
				velocity.y = JUMP_VELOCITY - gravity*0.05
			if direction: ## Movimiento en eje x estandar
				if not is_on_floor():
					velocity.x = direction.x * SPEED * 0.9
				else:
					velocity.x = direction.x * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
		else: ## Si esta cerca, para de moverse y ataca
			velocity = Vector3(0,0,0)
			attacking = true
			pet_attack()
		
		## Variable pa seguir las distancias en frames previos
		previous_distance = distance
		
	move_and_slide()

## Funcion del ataque del jugador, haciendo la animación y el daño
func pet_attack():
	print("ataco")
	print(enemy_target)
	animation_player.play("Attack")
	if enemy_target == null:
		return
	mesh_instance_3d.get_surface_override_material(0).albedo_color = Color(1,0,0)
	await animation_player.animation_finished
	if enemy_target == null or !enemy_target.is_in_group("enemy"):
		return
	enemy_target.hit(0.01)
	await get_tree().create_timer(0.5).timeout

## Funcion que revisa si esta muy lejos del ranger al que esta asignado, si 
## esta muy lejos, desactiva el modo ataque y lo devuelve al lado del ranger
func check_proximity():
	var distance = position.distance_to(follow_point.global_position)
	if distance > 20:
		self.position = follow_point.global_position
		attacking = false
		area_3d.set_block_signals(false)
		attack_mode = false
		mesh_instance_3d.get_surface_override_material(0).albedo_color = Color(0,1,0)

## Funcion cuando un enemigo entra al area de deteccion, cambiando el color,
## activando el modo ataque y asigando el objetivo
func _on_area_3d_area_entered(area):
	if area.is_in_group("enemy"):
		mesh_instance_3d.get_surface_override_material(0).albedo_color = Color(1,1,0)
		attack_mode = true
		enemy_target = area


