extends Node3D


# Velocidad de el proyectil
const SPEED = 15
# Import External Meshes

@onready var ray = $RayCast3D
@onready var trail_particles_3d = $TrailParticles3D
@onready var sfx = $SFX

@onready var weapon_sprite = $WeaponSprite as Sprite3D

func _ready():
	var column = randi_range(0,9)
	var row = randi_range(0,2)
	var region_x = column * 32
	var region_y = column * 32
	weapon_sprite.region_rect = Rect2(region_x,region_y,32,32)
	if column == 0 or column == 3:
		trail_particles_3d.process_material.color = Color.ORANGE
		trail_particles_3d.draw_pass_1.material.emission = Color.ORANGE
	elif column == 9:
		trail_particles_3d.process_material.color = Color.ROSY_BROWN
		trail_particles_3d.draw_pass_1.material.emission = Color.ROSY_BROWN
	else:
		trail_particles_3d.process_material.color = Color.LIGHT_BLUE
		trail_particles_3d.draw_pass_1.material.emission = Color.LIGHT_BLUE
	
	sfx.play()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0, -SPEED ,0) * delta
	weapon_sprite.rotate_z(PI/32)
	if ray.is_colliding():
		weapon_sprite.visible = false
		trail_particles_3d.one_shot = true
		ray.enabled = false
		if ray.get_collider().is_in_group("enemy"):
			ray.get_collider().hit(1)
		
		trail_particles_3d.visible = false
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_timer_timeout():
	queue_free()
