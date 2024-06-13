extends CharacterBody3D

var player = null
var enemy_life = 2

var area_3d
var animation_player
var damage
# Velocidad enemigo
const SPEED = 5.0
# Altura de salto del socio ? va a saltar siquiera
const JUMP_VELOCITY = 4.5

# Tipo de enemigo
var tipo_enemigo

# Gravedad
var gravity = 20

# Funcion 
func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity
		
	move_and_slide()
	
func _ready():
	tipo_enemigo = get_child(1)
	
	animation_player = tipo_enemigo.get_node("AnimationPlayer")
	area_3d = get_node("Area3D")
	
	
	
	
	
	area_3d.body_part_hit.connect(_on_area_3d_body_part_hit)
	
	
func _on_area_3d_body_part_hit(dam):
	enemy_life -= dam
	if enemy_life <= 0:
		queue_free()
	
