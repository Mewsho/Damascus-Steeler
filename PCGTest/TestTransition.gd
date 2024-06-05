extends Node
@onready var color_rect = $ColorRect
@onready var timer = $Timer

var time = 2


# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = time


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	print("Test")
	
	var tween = create_tween()
	tween.tween_method(set_shader_value,0.0,1.0,time)
	timer.start()


func set_shader_value(value : float):
	var shader = color_rect.material as ShaderMaterial
	shader.set_shader_parameter("progress",value)



func _on_timer_timeout():
	var child = get_child(0)
	remove_child(child)
	child.queue_free()
	
	var new_scene = load("res://PCGTest/testpcg.tscn").instantiate()
	add_child(new_scene)
	
	var tween = create_tween()
	tween.tween_method(set_shader_value,1.0,0.0,time)
