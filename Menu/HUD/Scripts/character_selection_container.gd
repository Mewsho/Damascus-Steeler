extends MarginContainer

## Script del contenedor de iconos con los que se selecciona personaje dentro del gameplay

## Variables de la escena
@onready var mage_button = $CharactersButtons/MageRect/MageButton as Button
@onready var knight_button = $CharactersButtons/KnightRect/KnightButton as Button
@onready var barbarian_button = $CharactersButtons/BarbarianRect/BarbarianButton as Button
@onready var ranger_button = $CharactersButtons/RangerRect/RangerButton as Button
@onready var character_selection_container = $"."
@onready var characters_buttons = $CharactersButtons
@onready var mage_rect = $CharactersButtons/MageRect as NinePatchRect
@onready var knight_rect = $CharactersButtons/KnightRect as NinePatchRect
@onready var barbarian_rect = $CharactersButtons/BarbarianRect as NinePatchRect
@onready var ranger_rect = $CharactersButtons/RangerRect as NinePatchRect

var default_region_rect : Rect2
var hovered_region_rect : Rect2 = Rect2(476, 486, 48, 48)
var tween_scale : Vector2 = Vector2(1.3,1.3)
var tween_default : Vector2 = Vector2(1,1)

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
	default_region_rect = mage_rect.get_region_rect()
	
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
	
	mage_rect.set_region_rect(default_region_rect)
	knight_rect.set_region_rect(default_region_rect)
	barbarian_rect.set_region_rect(default_region_rect)
	ranger_rect.set_region_rect(default_region_rect)
	

	## Dependiendo del personaje hovereado, se hace una pequeña animacion donde agranda el icono
	match current_hover:
		0:
			mage_rect.set_region_rect(hovered_region_rect)
			tween.tween_property(mage_rect, "scale", tween_scale, 0.5)
			tween.tween_property(knight_rect, "scale", Vector2(1,1), 0.5)
			tween.tween_property(barbarian_rect, "scale", Vector2(1,1), 0.5)
			tween.tween_property(ranger_rect, "scale", Vector2(1,1), 0.5)
		1:
			knight_rect.set_region_rect(hovered_region_rect)
			tween.tween_property(mage_rect, "scale", Vector2(1,1), 0.5)
			tween.tween_property(knight_rect, "scale", tween_scale, 0.5)
			tween.tween_property(barbarian_rect, "scale", Vector2(1,1), 0.5)
			tween.tween_property(ranger_rect, "scale", Vector2(1,1), 0.5)
		2:
			barbarian_rect.set_region_rect(hovered_region_rect)
			tween.tween_property(mage_rect, "scale", Vector2(1,1), 0.5)
			tween.tween_property(knight_rect, "scale", Vector2(1,1), 0.5)
			tween.tween_property(barbarian_rect, "scale", tween_scale, 0.5)
			tween.tween_property(ranger_rect, "scale", Vector2(1,1), 0.5)
		3:
			ranger_rect.set_region_rect(hovered_region_rect)
			tween.tween_property(mage_rect, "scale", Vector2(1,1), 0.5)
			tween.tween_property(knight_rect, "scale", Vector2(1,1), 0.5)
			tween.tween_property(barbarian_rect, "scale", Vector2(1,1), 0.5)
			tween.tween_property(ranger_rect, "scale", tween_scale, 0.5)

	
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
