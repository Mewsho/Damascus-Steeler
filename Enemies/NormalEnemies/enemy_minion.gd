extends CharacterBody3D


## Archivos necesarios para las balas 
@onready var ray_cast_3d = $Gun/RayCast3D
const ENEMY_BULLET = preload("res://Enemies/NormalEnemies/Enemy_Gun/enemy_bullet.tscn")
@onready var gun = $Gun

## Settings del enemigo
const SPEED = 1.5
const JUMP_VELOCITY = 12.5
var is_dead : bool = false
var tipo_enemigo
var gravity = 20
var player = null
var enemy_life = 2 : set = _set_enemy_life
##  Areas De Enemigos
var area_3d : Area3D
var enemy_detect_area : Area3D 
var collision_shape : CollisionShape3D

## Otras variables que se explican solas
var animation_player
var damage
var instance
##  Target para seguir al jugador
var player_target = Vector3(0, 0, 0)

## Estado enemigo donde hay un player en el Area = enemy_detect_area
var is_freaky : bool = false
## Variable para hacer que el enemigo ataque
var attack = 0
var attacking : bool = false

func _ready():
	
	tipo_enemigo = get_child(1)
	area_3d = get_node("Area3D") 
	collision_shape = get_node("CollisionShape3D")
	enemy_detect_area = get_node("Enemy_Detect_Area") 
	animation_player = tipo_enemigo.get_node("AnimationPlayer")
	area_3d = get_node("Area3D")

	area_3d.body_part_hit.connect(_on_area_3d_body_part_hit)
	animation_player.animation_finished.connect(on_animation_finished)
	enemy_detect_area.body_entered.connect(_on_enemy_detect_area_body_entered)
	enemy_detect_area.body_exited.connect(_on_enemy_detect_area_body_exited)

## Funcion physics process se ejecuta cada frame
func _physics_process(delta):
	## Gravedad
	if not is_on_floor():
		velocity.y -= gravity *delta
	## Para evitar accidentes un check antes de cualquier cosa
	if is_dead:
		velocity.x = 0
		velocity.y -= gravity *delta
		velocity.z = 0
		return
		
	## Estado donde Hay un pj dentro del area
	if is_freaky:
		var target = player_target.global_position
		var direction = position.direction_to(target)
		var distance = position.distance_to(target)
		var y_distance = target.y - self.position.y
		## Modificadores de velocidad
		
		
		if direction:
			if not is_on_floor():
				velocity.x = direction.x * SPEED * 0.9 
			else:
				velocity.x = direction.x * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		

			# Amalgamacion para disparar en direcciones del Metal Slug
		if direction.y < -0.8: #abajo
			gun.rotation.z = -1.5
		elif  direction.y > 0.8: #arriba
			gun.rotation.z = 1.55
		elif  direction.y > 0.5 && direction.x > 0 : #diagonal derecha
			gun.rotation.z = 0.5
		elif  direction.y > 0.5 && direction.x < 0: #diagonal iz
			gun.rotation.z = 0.5
		else :
			gun.rotation.z = 0

		if y_distance > 2 && is_on_floor():
			var rand = randf_range(0,1)
			if rand > 0.98:
				velocity.y = JUMP_VELOCITY - gravity*0.05
		#
		if direction.x > 0:
			rotation.y = 190
		if direction.x < 0:
			rotation.y = -190
			
		
		## Detener al enemigo al llegar a cierta distancia || Suma 1 a ataque y si tiene mas de 2 resta  (No me funciono hacindolo con BOOL)
		#if distance < 20:
			#if attack == 0:
				#attack =+ 1
			#if attack > 2:
				#attack == 0
			#
			#velocity.x = 0
			#velocity.z = 0
			
		if distance < 20:
			attacking = true
		
		if distance < 10:
			velocity.x = 0
			velocity.z = 0
			
		## Animaciones de movimiento
		if velocity.x > 0:
			animation_player.set_default_blend_time(0.3)
			animation_player.play("Walking_D_Skeletons")
			rotation.y = 45
		
		if velocity.x < 0:
			animation_player.set_default_blend_time(0.3)
			animation_player.play("Walking_D_Skeletons")
			rotation.y = -190

	move_and_slide()
	

	
func _on_area_3d_body_part_hit(dam):
	enemy_life -= dam


func _on_enemy_detect_area_body_entered(body):
	if body.is_in_group("player"):
		if !is_freaky:
			animation_player.play("Taunt")
		player_target = body
		is_freaky = true


func _on_enemy_detect_area_body_exited(body):
	for cuerpo in enemy_detect_area.get_overlapping_bodies():
		if cuerpo.is_in_group("player"):
			player_target = cuerpo
			return
	is_freaky = false
	animation_player.set_default_blend_time(0.2)
	animation_player.play("Idle_B")
	velocity.x = 0
	
	

	
func _set_enemy_life(_enemy_life):
	var prev_enemy_life = enemy_life
	enemy_life = max(0 , _enemy_life)
	if enemy_life == 0:
		animation_player.play("Death_A")
		area_3d.process_mode = Node.PROCESS_MODE_DISABLED
		collision_shape.disabled = true
		enemy_detect_area.set_block_signals(true)
		is_dead = true


func on_animation_finished(anim_name):
	if anim_name == "Death_A":
		queue_free()
	if anim_name ==  "Walking_D_Skeletons":
		animation_player.play("Idle_B")

func _on_timer_timeout():
	if is_dead == true:
		return
	if !is_freaky:
		return
	if attacking:
		animation_player.set_default_blend_time(0.3)
		animation_player.play("2H_Ranged_Shooting")
		instance = ENEMY_BULLET.instantiate()
		instance.position = ray_cast_3d.global_position - Vector3(0, 1, 0)
		instance.transform.basis = ray_cast_3d.global_transform.basis
		get_parent().add_child(instance)
