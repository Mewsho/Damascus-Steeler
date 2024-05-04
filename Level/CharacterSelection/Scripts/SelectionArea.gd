extends Area3D

@onready var animation_player = $"../AnimationPlayer" as AnimationPlayer
@onready var character = get_parent() as Node3D
@onready var character_selection_scene = get_tree().get_root().get_node("Core/SceneNodeContainer/CharacterSelection")
@onready var selection_ring = $SelectionRing

signal on_character_selected



func _ready() -> void:
	on_character_selected.connect(character_selection_scene.character_selected)
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)


func _on_input_event(camera : Node, event : InputEvent, position, normal, shape_idx):
	if event.is_action_pressed("mouse_left_click"):
		animation_player.play("Cheer")
		emit_signal("on_character_selected", character.name)
		selection_ring.show()

#func play_anim(actionName):
	#character.get_node("AnimationPlayer").play(actionName)

func hide_selection():
	selection_ring.hide()

func show_selection():
	selection_ring.show()

func _on_animation_player_animation_finished(anim_name : StringName):
	if anim_name == "Cheer":
		animation_player.play("Idle")
