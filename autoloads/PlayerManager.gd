extends Node

## Este es un autoload que viene de la demo del plugin MultiplayerInput, el cual se integro
## a nuestro proyecto, agregando y modificando ciertas funciones

# player is 0-3
# device is -1 for keyboard/mouse, 0+ for joypads
## Señales del estado de los jugadores
signal player_joined(player)
signal player_left(player)

# map from player integer to dictionary of data
# the existence of a key in this dictionary means this player is joined.
# use get_player_data() and set_player_data() to use this dictionary.
## Este diccionario conecta al player con un diccionario con su informacion, en nuestro caso el
## dispositivo y la clase
var player_data: Dictionary = {}

const MAX_PLAYERS = 4 ## Cantidad maxima de jugadores


## Funcion del plugin original, le asigna un numero al jugador, y agrega la informacion del
## dispositivo y clase default, luego emite la señal de que se unio un jugador
func join(device: int):
	var player = next_player()
	if player >= 0:
		# initialize default player data here
		# "team" and "car" are remnants from my game just to provide an example
		player_data[player] = {
			"device": device,
			"class" : "Mage",
			"is_preselected" : false
		}
		player_joined.emit(player)

## Funcion del plugin original, revisa si el jugador que se va a ir tiene informacion, si la tiene
## la elimina y emite la señal
func leave(player: int):
	if player_data.has(player):
		player_data.erase(player)
		player_left.emit(player)

## Funcion original del plugin, obtiene numero de jugadores
func get_player_count():
	return player_data.size()
## Funcion original del plugin, obtiene los indices de los jugadores
func get_player_indexes():
	return player_data.keys()
## Funcion original del plugin, obtiene el device del player que recibe
func get_player_device(player: int):
	return get_player_data(player, "device")

## Funcion nueva, obtiene el jugador en base al device que recibe
func get_device_player(device: int):
	print(get_player_data(0,"device"))
	for player in range(get_player_count()):
		if get_player_data(player,"device") == device:
			return player

## Funcion original del plugin, sirve universalmente para obtener la informacion de un jugador en
## base a la clave que se le de
func get_player_data(player: int, key: StringName):
	if player_data.has(player) and player_data[player].has(key):
		return player_data[player][key]
	return null


## Funcion original del plugin, sirve para cambiar la informacion del jugador en base a una clave
func set_player_data(player: int, key: StringName, value: Variant):
	# if this player is not joined, don't do anything:
	if !player_data.has(player):
		return
	
	player_data[player][key] = value

# call this from a loop in the main menu or anywhere they can join
# this is an example of how to look for an action on all devices

## Funcion original del plugin, revisa si algun dispositivo quiere unirse y lo une llamando a join
func handle_join_input():
	for device in get_unjoined_devices():
		if MultiplayerInput.is_action_just_pressed(device, "join"):
			join(device)
## Funcion creada, similar a la anterior pero revisa si un dispositvo se quiere salir, y hace que
## el jugador conectado al dispositivo salga
func handle_leave_input():
	for device in get_joined_devices():
		if MultiplayerInput.is_action_just_pressed(device, "leave"):
			var player = get_device_player(device)
			leave(player)
			
# to see if anybody is pressing the "start" action
# this is an example of how to look for an action on all players
# note the difference between this and handle_join_input(). players vs devices.
## Funcion original del plugin, revisa si alguien esta apretando "start"
func someone_wants_to_start() -> bool:
	for player in player_data:
		var device = get_player_device(player)
		if MultiplayerInput.is_action_just_pressed(device, "start"):
			return true
	return false

## Funcion original del plugin, revisa si el device esta unido
func is_device_joined(device: int) -> bool:
	for player_id in player_data:
		var d = get_player_device(player_id)
		if device == d: return true
	return false

# returns a valid player integer for a new player.
# returns -1 if there is no room for a new player.
## Funcion auxiliar original del plugin, da un nuevo int para el player
func next_player() -> int:
	for i in MAX_PLAYERS:
		if !player_data.has(i): return i
	return -1

# returns an array of all valid devices that are *not* associated with a joined player
## Funcion original del plugin, obtiene los joypads conectados pero que no unidos al juego
func get_unjoined_devices():
	var devices = Input.get_connected_joypads()
	# also consider keyboard player
	devices.append(-1)
	
	# filter out devices that are joined:
	return devices.filter(func(device): return !is_device_joined(device))
	
## Funcion creada, muy similar a la anterior, pero obtiene los joypads unidos
func get_joined_devices():
	var devices = Input.get_connected_joypads()
	# also consider keyboard player
	devices.append(-1)
	
	# filter out devices that are unjoined:
	return devices.filter(func(device): return is_device_joined(device))

