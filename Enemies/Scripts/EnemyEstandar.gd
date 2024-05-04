extends CharacterBody3D

var player = null
var enemy_life = 3

var damage
# Velocidad enemigo
const SPEED = 5.0
# Altura de salto del socio ? va a saltar siquiera
const JUMP_VELOCITY = 4.5

# Gravedad
var gravity = 20

# Funcion 
func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity
		
	move_and_slide()


func _on_area_3d_body_part_hit(dam):
	enemy_life -= 1
	if enemy_life <= 0:
		queue_free()
	
