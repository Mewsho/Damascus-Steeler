extends RigidBody3D

# Velocidad de el proyectil

const GRAVITY = -2

@onready var shape_cast_3d = $ShapeCast3D
@onready var animated_sprite_3d = $AnimatedSprite3D
@onready var trail_particles_3d = $TrailParticles3D
@onready var hit_particles_3d = $HitParticles3D
@onready var explosion_area_3d = $ExplosionArea3D
@onready var delete_timer = $DeleteTimer
@onready var init_timer = $InitTimer
const MAGE_EXPLOSION_SPRITE = preload("res://Characters/Guns/Specials/mage_explosion_sprite.tscn")

var is_activated : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#position += transform.basis * Vector3(0, -SPEED ,0) * delta
	#position += (Vector3(0, GRAVITY ,0) * delta**2)/2
	if shape_cast_3d.is_colliding() && is_activated:
		print("test")
		animated_sprite_3d.visible = false
		trail_particles_3d.one_shot = true
		hit_particles_3d.emitting = true
		
		var explosion_ins = MAGE_EXPLOSION_SPRITE.instantiate()
		explosion_ins.position = global_position
		explosion_ins.position.z = 4	
		explosion_ins.position.y += 1
		get_parent().add_child(explosion_ins)
		shape_cast_3d.enabled = false
		if shape_cast_3d.get_collider(0).is_in_group("enemy"):
			shape_cast_3d.get_collider(0).hit(4)
		
		trail_particles_3d.visible = false
		explosion_area_3d.monitoring = true
		delete_timer.start()
		freeze = true




func _on_explosion_area_3d_area_entered(area):
	if area.is_in_group("enemy"):
		print(area)
		area.hit(4)

func _on_delete_timer_timeout():
	queue_free()

func _on_init_timer_timeout():
	is_activated = true
