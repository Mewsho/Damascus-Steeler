class_name PlayerHud
extends MarginContainer

@onready var mana_bar = $HBoxContainer/InfoContainer/MarginContainer/ManaBar
@onready var mana_delay_bar = $HBoxContainer/InfoContainer/MarginContainer/ManaBar/ManaDelayBar
@onready var timer = $HBoxContainer/InfoContainer/MarginContainer/ManaBar/Timer
@onready var player_label = $HBoxContainer/InfoContainer/PlayerLabel
@onready var mage_icon = $HBoxContainer/IconContainer/MageIcon
@onready var barbarian_icon = $HBoxContainer/IconContainer/BarbarianIcon
@onready var knight_icon = $HBoxContainer/IconContainer/KnightIcon
@onready var ranger_icon = $HBoxContainer/IconContainer/RangerIcon
@onready var icon_container = $HBoxContainer/IconContainer



var mana = 100 : set = set_mana
var player = -1
var player_class

func _ready():
	init_mana(100)

func _process(delta):
	#if player != -1:
		#print("MANA BARRA:", mana)
		#print("value normal:", mana_bar.value)
		#print("Value delay:", mana_delay_bar.value)
	pass

func change_mana(n_player,_mana):
	if n_player == player:
		mana = _mana

func set_player_class(p_class : String):
	player_class = p_class
	for icon in icon_container.get_children(): #Pasa por cada icono y lo  oculta
		icon.hide()
	match player_class:
		"Mage":
			mage_icon.show()
		"Barbarian":
			barbarian_icon.show()
		"Knight":
			knight_icon.show()
		"Ranger":
			ranger_icon.show()

func init_mana(_mana):
	mana = _mana
	mana_bar.max_value = mana
	mana_bar.value = mana
	mana_delay_bar.max_value = mana
	mana_delay_bar.value = mana
		
func set_player_label(n_player: int):
	player_label.text = str("Jugador ",n_player+1)

func set_mana(new_mana):
	var prev_mana = mana
	mana = min(mana_bar.max_value,new_mana)
	mana_bar.value = mana

	if mana <= prev_mana: #Usando mana
		if timer.is_stopped():
			mana_delay_bar.value = prev_mana
		timer.start()
	#else:
		#mana_delay_bar.value = mana
	
func _on_timer_timeout():
	var tween = create_tween()
	tween.tween_property(mana_delay_bar,"value", mana, 0.3).set_trans(Tween.TRANS_CUBIC)
	#mana_delay_bar.value = mana
