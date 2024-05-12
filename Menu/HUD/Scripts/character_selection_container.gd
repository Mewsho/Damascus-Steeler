extends MarginContainer

## Script del contenedor de iconos con los que se selecciona personaje dentro del gameplay

## Variables de la escena
@onready var mage_button = $CharactersButtons/MageButton as Button
@onready var knight_button = $CharactersButtons/KnightButton as Button
@onready var barbarian_button = $CharactersButtons/BarbarianButton as Button
@onready var ranger_button = $CharactersButtons/RangerButton as Button
@onready var character_selection_container = $"."
@onready var characters_buttons = $CharactersButtons

## Variables que maneja
var player = -1
var device
var current_hover
## Señal emitida cuando se selecciona un personaje
signal character_selected(player,player_class, node)

## Inicializa el player y el device asociado
func init(n_player):
	player = n_player
	device = PlayerManager.get_player_device(player)
	current_hover = 0

## Para evitar que tome inputs cuando no debe
func _ready():
	set_process(false)





func _process(delta):
	
	## Se mueve a traves de los personajes, guiandose con current hover
	if MultiplayerInput.is_action_just_pressed(device,"move_left"):
		if current_hover == 0:
			current_hover = 3
		else:
			current_hover -=1
	if MultiplayerInput.is_action_just_pressed(device, "move_right"):
		if current_hover == 3:
			current_hover = 0
		else:
			current_hover +=1
	
	## Inicia animacion en paralelo
	var tween = create_tween()
	tween.set_parallel(true)
	

	## Dependiendo del personaje hovereado, se hace una pequeña animacion donde agranda el icono
	match current_hover:
		0:
			tween.tween_property(mage_button, "scale", Vector2(1.5,1.5), 0.5)
			tween.tween_property(knight_button, "scale", Vector2(1,1), 0.5)
			tween.tween_property(barbarian_button, "scale", Vector2(1,1), 0.5)
			tween.tween_property(ranger_button, "scale", Vector2(1,1), 0.5)
		1:
			tween.tween_property(mage_button, "scale", Vector2(1,1), 0.5)
			tween.tween_property(knight_button, "scale", Vector2(1.5,1.5), 0.5)
			tween.tween_property(barbarian_button, "scale", Vector2(1,1), 0.5)
			tween.tween_property(ranger_button, "scale", Vector2(1,1), 0.5)
		2:
			tween.tween_property(mage_button, "scale", Vector2(1,1), 0.5)
			tween.tween_property(knight_button, "scale", Vector2(1,1), 0.5)
			tween.tween_property(barbarian_button, "scale", Vector2(1.5,1.5), 0.5)
			tween.tween_property(ranger_button, "scale", Vector2(1,1), 0.5)
		3:
			tween.tween_property(mage_button, "scale", Vector2(1,1), 0.5)
			tween.tween_property(knight_button, "scale", Vector2(1,1), 0.5)
			tween.tween_property(barbarian_button, "scale", Vector2(1,1), 0.5)
			tween.tween_property(ranger_button, "scale", Vector2(1.5,1.5), 0.5)

	
	## Si se apreta el boton, se emite la señal de presionado
	if MultiplayerInput.is_action_just_pressed(device, "jump") or MultiplayerInput.is_action_just_pressed(device, "attack"):
		match current_hover:
			0:
				mage_button.emit_signal("pressed")
			1:
				knight_button.emit_signal("pressed")
			2:
				barbarian_button.emit_signal("pressed")
			3:
				ranger_button.emit_signal("pressed")

## Funciones ejecutadas cuando se aprieta un boton, emiten señales que recibe el core.gd
func _on_mage_button_pressed():
	emit_signal("character_selected",player, "Mage", character_selection_container)
func _on_knight_button_pressed():
	emit_signal("character_selected",player, "Knight", character_selection_container)
func _on_barbarian_button_pressed():
	emit_signal("character_selected",player, "Barbarian", character_selection_container)
func _on_ranger_button_pressed():
	emit_signal("character_selected",player, "Ranger", character_selection_container)
