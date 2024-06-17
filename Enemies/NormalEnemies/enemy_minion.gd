extends CharacterBody3D




var player = null
var enemy_life = 2 : set = _set_enemy_life





var area_3d : Area3D
var enemy_detect_area : Area3D 
var collision_shape : CollisionShape3D
var animation_player
var damage

var player_target = Vector3(0, 0, 0)

# Velocidad enemigo
const SPEED = 1.0
# Altura de salto del socio ? va a saltar siquiera
const JUMP_VELOCITY = 4.5

#
var is_dead : bool = false
# Tipo de enemigo
var tipo_enemigo

# Estado enemigo
var is_freaky : bool = false

# Gravedad
var gravity = 20

# Funcion 
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity
	
	
	if is_freaky:
		var target = player_target.global_position
		var direction = position.direction_to(target)
		if direction:
			if not is_on_floor():
				velocity.x = direction.x * SPEED * 0.9 * 0.5
			else:
				velocity.x = direction.x * SPEED * 0.5 
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if velocity.x > 0:
		animation_player.set_default_blend_time(0.3)
		animation_player.play("Walking_D_Skeletons")
		rotation.y = 45
	if velocity.x < 0:
		animation_player.set_default_blend_time(0.3)
		animation_player.play("Walking_D_Skeletons")
		rotation.y = -190


	if is_dead:
		velocity = Vector3(0, 0, 0)
		
	move_and_slide()
	
func handle_attack():
	pass
func _ready():
	
	tipo_enemigo = get_child(1)
	area_3d = get_node("Area3D") 
	collision_shape = get_node("CollisionShape3D")
	enemy_detect_area = get_node("Enemy_Detect_Area") 
	animation_player = tipo_enemigo.get_node("AnimationPlayer")
	
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
