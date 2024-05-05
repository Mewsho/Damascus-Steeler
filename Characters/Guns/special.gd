extends Node3D

# Velocidad de el proyectil
const SPEED = 10
# Import External Meshes
@onready var mesh_instance_3d = $MeshInstance3D
@onready var ray_cast_3d = $RayCast3D
@onready var gpu_particles_3d = $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0, -SPEED ,0) * delta
	if ray_cast_3d.is_colliding():
		mesh_instance_3d.visible = false
		gpu_particles_3d.emitting = true
		ray_cast_3d.enabled = false
		if ray_cast_3d.get_collider().is_in_group("enemy"):
			ray_cast_3d.get_collider().hit(4)
			
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_timer_timeout():
	queue_free()
