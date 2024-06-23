extends Node3D

@onready var light_pillar_sprite = $LightPillarSprite
@onready var ground_splat_sprite = $GroundSplatSprite
@onready var floor_check = $FloorCheck
@onready var floor_check_area_3d = $FloorCheck/FloorCheckArea3D
@onready var mesh_instance_3d = $FloorCheck/MeshInstance3D
@onready var hit_area_3d = $HitArea3d
@onready var hit_particles_3d = $HitParticles3D

var list_height = []

func _on_delete_timer_timeout():
	queue_free()

func _on_area_3d_area_entered(area):
	if area.is_in_group("enemy"):
		print(area)
		area.hit(4)


func _on_floor_check_area_3d_area_entered(area):

	floor_check.freeze
	mesh_instance_3d.visible = false
	floor_check_area_3d.monitoring = false
	
	var check_y = floor_check.global_position.y 
	list_height.append(int(check_y))
	global_position.y = list_height[0] + 1
	
	
	light_pillar_sprite.visible = true
	ground_splat_sprite.visible = true
	light_pillar_sprite.play("default")
	ground_splat_sprite.play("default")
	hit_area_3d.monitoring = true
	hit_particles_3d.emitting = true
	
