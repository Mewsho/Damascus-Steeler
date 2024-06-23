extends CharacterBody3D

## Settings del enemigo
var player = null
var enemy_life = 2 : set = _set_enemy_life
const SPEED = 1.0
const JUMP_VELOCITY = 4.5
var is_dead : bool = false
var tipo_enemigo
var gravity = 20

##  Areas De Enemigos
var area_3d : Area3D
var enemy_detect_area : Area3D 
var collision_shape : CollisionShape3D

## Otras variables que se explican solas
var animation_player
var damage

## Archivos necesarios para las balas 
@onready var ray_cast_3d = $Gun/RayCast3D
const ENEMY_BULLET = preload("res://Enemies/NormalEnemies/Enemy_Gun/enemy_bullet.tscn")
var instance
##  Target para seguir al jugador
var player_target = Vector3(0, 0, 0)

## Estado enemigo donde hay un player en el Area = enemy_detect_area
var is_freaky : bool = false
## Variable para hacer que el enemigo ataque
var attack = 0



## Funcion physics process se ejecuta cada frame
func _physics_process(delta):
	## Gravedad
	if not is_on_floor():
		velocity.y -= gravity
	## Para evitar accidentes un check antes de cualquier cosa
	if is_dead:
		velocity = Vector3(0, 0, 0)
		return
		## Estado donde Hay un pj dentro del area
	if is_freaky:
		var target = player_target.global_position
		var direction = position.direction_to(target)
		var distance = position.distance_to(target)
		## Modificadores de velocidad
		if direction:
			if not is_on_floor():
				velocity.x = direction.x * SPEED * 0.9 * 0.5
			else:
				velocity.x = direction.x * SPEED * 0.5 
		
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		if direction > Vector3(0, 0, 0):
			rotation.y = 190
		if direction < Vector3(0, 0, 0):
			rotation.y = -190
			
		
		## Detener al enemigo al llegar a cierta distancia || Suma 1 a ataque y si tiene mas de 2 resta  (No me funciono hacindolo con BOOL)
		if distance < 10:
			if attack == 0:
				attack =+ 1
			if attack > 2:
				attack == 0
			
			velocity = Vector3(0, 0, 0)
			
		## Animaciones de movimiento
		if velocity.x > 0:
			animation_player.set_default_blend_time(0.3)
			animation_player.play("Walking_D_Skeletons")
			rotation.y = 45
		
		if velocity.x < 0:
			animation_player.set_default_blend_time(0.3)
			animation_player.play("Walking_D_Skeletons")
			rotation.y = -190

# Coconut.png from tf2 can you believe it	
	move_and_slide()
	

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
	
func _on_area_3d_body_part_hit(dam):
	enemy_life -= dam
	print(enemy_life)
	
		


func _on_enemy_detect_area_body_entered(body):
	if body.is_in_group("player"):
		if !is_freaky:
			animation_player.play("Taunt")
		player_target = body
		is_freaky = true	


		

func _on_enemy_detect_area_body_exited(body):
	for cuerpo in enemy_detect_area.get_overlapping_bodies():
		if cuerpo.is_in_group("player"):
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
	if attack == 1 && velocity.x == 0:
		animation_player.set_default_blend_time(0.3)
		animation_player.play("2H_Ranged_Shooting")
		instance = ENEMY_BULLET.instantiate()
		instance.position = ray_cast_3d.global_position - Vector3(0, 1, 0)
		instance.transform.basis = ray_cast_3d.global_transform.basis
		get_parent().add_child(instance)
