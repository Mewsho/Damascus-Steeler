extends Node3D

@onready var animated_sprite_3d = $AnimatedSprite3D
@onready var hit_particles_3d = $HitParticles3D
@onready var animated_sprite_3d_2 = $AnimatedSprite3D2
@onready var animated_sprite_3d_3 = $AnimatedSprite3D3
@onready var animated_sprite_3d_4 = $AnimatedSprite3D4
@onready var rigid_body_3d = $CheckFloor/RigidBody3D
@onready var check_1 = $CheckFloor/RigidBody3D/Check1
@onready var rigid_body_3d_2 = $CheckFloor/RigidBody3D2
@onready var check_2 = $CheckFloor/RigidBody3D2/Check2
@onready var rigid_body_3d_3 = $CheckFloor/RigidBody3D3
@onready var check_3 = $CheckFloor/RigidBody3D3/Check3
@onready var rigid_body_3d_4 = $CheckFloor/RigidBody3D4
@onready var check_4 = $CheckFloor/RigidBody3D4/Check4
@onready var delete_timer = $DeleteTimer
@onready var hit_area_3d = $HitArea3D
@onready var sfx = $SFX



var is_forward : bool = true
var list_1 = []
var list_2 = []
var list_3 = []
var list_4 = []
var list_x1 = []
var list_x2 = []
var list_x3 = []
var list_x4 = []
var height_list = [0,0,0,0,0]
var x_pos_list = [0,0,0,0,0]
var counter = 0
var is_first_anim : bool = true


func _ready():
	
	height_list[0] = global_position.y
	x_pos_list[0] = global_position.x
	if !is_forward:
		scale.x = -1
	
func _physics_process(delta):
	print(height_list)

	

	print(counter)

func play_animations():
	sfx.play()
	EventBus.emit_especial_shake()
	animated_sprite_3d.visible = true
	animated_sprite_3d_2.visible = true
	animated_sprite_3d_3.visible = true
	animated_sprite_3d_4.visible = true
	hit_particles_3d.emitting = true
	hit_area_3d.monitoring = true
	animated_sprite_3d.play("default")
	animated_sprite_3d_2.play("default")
	animated_sprite_3d_3.play("default")
	animated_sprite_3d_4.play("default")
	
	

func _on_animated_sprite_3d_animation_finished():
	if counter < 4:
		counter+=1
		position.y = height_list[counter]
		position.x = x_pos_list[counter]
		sfx.play()
		EventBus.emit_especial_shake()
		animated_sprite_3d.play("default")
		animated_sprite_3d_2.play("default")
		animated_sprite_3d_3.play("default")
		animated_sprite_3d_4.play("default")
	else:
		queue_free()

	


func _on_delete_timer_timeout():
	queue_free()

func _on_hit_area_3d_area_entered(area):
	if area.is_in_group("enemy"):
		area.hit(2)

func _on_check_1_area_entered(area):
	rigid_body_3d.freeze
	check_1.monitoring = false
	var check_y = rigid_body_3d.global_position.y 
	var check_x = rigid_body_3d.global_position.x
	list_1.append(int(check_y))
	list_x1.append(check_x)
	height_list[1] = list_1[0] +1
	x_pos_list[1] = list_x1[0]


func _on_check_2_area_entered(area):
	rigid_body_3d_2.freeze
	check_2.monitoring = false
	var check_y = rigid_body_3d_2.global_position.y 
	var check_x = rigid_body_3d_2.global_position.x
	list_2.append(int(check_y))
	list_x2.append(check_x)
	height_list[2] = list_2[0] +1
	x_pos_list[2] = list_x2[0]


func _on_check_3_area_entered(area):
	rigid_body_3d_3.freeze
	check_3.monitoring = false
	var check_y = rigid_body_3d_3.global_position.y 
	var check_x = rigid_body_3d_3.global_position.x
	list_3.append(int(check_y))
	list_x3.append(check_x)
	height_list[3] = list_3[0] +1
	x_pos_list[3] = list_x3[0]


func _on_check_4_area_entered(area):
	rigid_body_3d_4.freeze
	check_4.monitoring = false
	var check_y = rigid_body_3d_4.global_position.y 
	var check_x = rigid_body_3d_4.global_position.x
	list_4.append(int(check_y))
	list_x4.append(check_x)
	height_list[4] = list_4[0] + 1
	x_pos_list[4] = list_x4[0]
	

func _on_hit_timer_timeout():
	play_animations()
