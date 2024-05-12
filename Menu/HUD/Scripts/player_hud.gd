class_name PlayerHud
extends MarginContainer

## Script del hud del jugador qu muestra el icono de clase, el mana y la cantidad de vidas

## Variabless de la escena
@onready var mana_bar = $HBoxContainer/InfoContainer/MarginContainer/ManaBar
@onready var mana_delay_bar = $HBoxContainer/InfoContainer/MarginContainer/ManaBar/ManaDelayBar
@onready var timer = $HBoxContainer/InfoContainer/MarginContainer/ManaBar/Timer
@onready var player_label = $HBoxContainer/InfoContainer/HBoxContainer/PlayerLabel
@onready var mage_icon = $HBoxContainer/IconContainer/MageIcon
@onready var barbarian_icon = $HBoxContainer/IconContainer/BarbarianIcon
@onready var knight_icon = $HBoxContainer/IconContainer/KnightIcon
@onready var ranger_icon = $HBoxContainer/IconContainer/RangerIcon
@onready var icon_container = $HBoxContainer/IconContainer
@onready var life_icon_container = $HBoxContainer/InfoContainer/HBoxContainer/LifeIconContainer
@onready var life_number_label = $HBoxContainer/InfoContainer/HBoxContainer/LifeNumberLabel



## Variables que maneja el codigo
var mana = 100 : set = set_mana
var player = -1
var player_class
var lifes = 1 : set = _set_lifes

## Inicializamos valores
func _ready():
	init_mana(100)
	lifes = 3

func _process(delta):
	#if player != -1:
		#print("MANA BARRA:", mana)
		#print("value normal:", mana_bar.value)
		#print("Value delay:", mana_delay_bar.value)
	pass

## Estas funciones son las que se conectan a las señales de los jugadores
func change_mana(n_player,_mana):
	if n_player == player:
		mana = _mana
## Es la funcion cuando cambian las vidas de un jugador
func change_lifes(n_player, new_lifes):
	if n_player == player:
		lifes = new_lifes

## Asigna la clase del jugador, y muestra sus componentes del hud dependiendo de la clase
func set_player_class(p_class : String):
	player_class = p_class
	for icon in icon_container.get_children(): #Pasa por cada icono y lo  oculta
		icon.hide()
	for life_icon in life_icon_container.get_children():
		life_icon.hide()
	match player_class:
		"Mage":
			mage_icon.show()
			life_icon_container.get_child(0).show()
		"Barbarian":
			barbarian_icon.show()
			life_icon_container.get_child(1).show()
		"Knight":
			knight_icon.show()
			life_icon_container.get_child(2).show()
		"Ranger":
			ranger_icon.show()
			life_icon_container.get_child(3).show()

## Inicializa el mana junto con los valores de las barras
func init_mana(_mana):
	mana = _mana
	mana_bar.max_value = mana
	mana_bar.value = mana
	mana_delay_bar.max_value = mana
	mana_delay_bar.value = mana

## Cambia el nombre del jugador
func set_player_label(n_player: int):
	player_label.text = str("Jugador ",n_player+1)

## Funcion setter del mana, que se llama cada vez que cambia el mana
## Su objetivo es mantener la barra de delay por un tiempo
func set_mana(new_mana):
	var prev_mana = mana
	mana = min(mana_bar.max_value,new_mana)
	mana_bar.value = mana

	if mana <= prev_mana: #Usando mana
		if timer.is_stopped(): ## Esto hace que se congele el delay mientras se tiren los especiales
			mana_delay_bar.value = prev_mana
		timer.start()

## Cuando se acaba el tiempo, se hace una animacion donde se reduce el valor de la barra de delay
func _on_timer_timeout():
	var tween = create_tween()
	tween.tween_property(mana_delay_bar,"value", mana, 0.3).set_trans(Tween.TRANS_CUBIC)

## Funcion setter de la cantidad de vidas, cambiando el texto del numero
func _set_lifes(new_lifes):
	var prev_lifes = lifes
	lifes = new_lifes
	life_number_label.text = str(lifes)
