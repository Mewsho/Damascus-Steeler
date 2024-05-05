extends Area3D

## Script asociado al anillo que se muestra en seleccion de personaje

## WARNING Este era un script cuando se usaba el mouse para seleccionar, actualmente
## la mayoria de las funciones de este codigo las realiza el script de character selection
## por lo cual no se usa mucho


## Cargar elementos de la scene
@onready var animation_player = $"../AnimationPlayer" as AnimationPlayer
@onready var character = get_parent() as Node3D
@onready var character_selection_scene = get_tree().get_root().get_node("Core/SceneNodeContainer/CharacterSelection")
@onready var selection_ring = $SelectionRing

signal on_character_selected


func _ready() -> void:
	# Conecta la seleccion de personaje con la funcion de la escena de character selection
	on_character_selected.connect(character_selection_scene.character_selected)
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)

## Recibe los clicks
func _on_input_event(camera : Node, event : InputEvent, position, normal, shape_idx):
	if event.is_action_pressed("mouse_left_click"):
		animation_player.play("Cheer")
		emit_signal("on_character_selected", character.name)
		selection_ring.show()

##Oculta el anillo
func hide_selection():
	selection_ring.hide()
## Muestra el anillo
func show_selection():
	selection_ring.show()
## Vuelve a la animacion estandar cuando termina la de seleccion
func _on_animation_player_animation_finished(anim_name : StringName):
	if anim_name == "Cheer":
		animation_player.play("Idle")
