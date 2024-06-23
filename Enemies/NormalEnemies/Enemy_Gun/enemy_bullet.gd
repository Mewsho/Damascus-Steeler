extends Node3D

# Velocidad de el proyectil
const SPEED = 5
# Import External Meshes
@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D
@onready var trail_particles_3d = $TrailParticles3D
@onready var animated_sprite_3d = $AnimatedSprite3D
@onready var animated_sprite_3d_2 = $AnimatedSprite3D2
@onready var animated_sprite_3d_3 = $AnimatedSprite3D3

## TODO Un event bus para no tener que hacer lo que voy a hacer
@onready var core = get_tree().get_root().get_node("Core") as Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var rand = randi_range(1,3)
	match rand:
		1:
			animated_sprite_3d.visible = true
		2:
			animated_sprite_3d_2.visible = true
		3:
			animated_sprite_3d_3.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0, -SPEED ,0) * delta
	if ray.is_colliding():
		animated_sprite_3d.visible = false
		animated_sprite_3d_2.visible = false
		animated_sprite_3d_3.visible = false
		mesh.visible = false
		particles.emitting = true
		trail_particles_3d.one_shot = true
		ray.enabled = false
		
		if ray.get_collider().is_in_group("player"):
			if is_instance_of(ray.get_collider(),Area3D):
				play_blink()
				EventBus.emit_especial_shake()
				ray.get_collider().get_parent().hit(1)
		
		trail_particles_3d.visible = false
		await get_tree().create_timer(1.0).timeout
		queue_free()


func play_blink():
	core.get_node("DamageOverlay").blink()

func _on_timer_timeout():
	queue_free()
