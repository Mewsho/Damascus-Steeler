extends Node3D


# Velocidad de el proyectil
const SPEED = 15
# Import External Meshes

@onready var ray = $RayCast3D
@onready var sfx = $SFX

@onready var arrow_container = $ArrowContainer
@onready var trail_particles_3d = $TrailParticles3D

# Called when the node enters the scene tree for the first time.
func _ready():
	sfx.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0, -SPEED ,0) * delta
	arrow_container.rotate_y(PI/32)
	if ray.is_colliding():
		arrow_container.visible = false
		trail_particles_3d.one_shot = true
		ray.enabled = false
		if ray.get_collider().is_in_group("enemy"):
			ray.get_collider().hit(1)
		
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_timer_timeout():
	queue_free()

