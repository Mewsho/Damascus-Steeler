class_name PlayerKeybindResource
extends Resource

## Recurso donde se almacenan los controles del usuario y sus predeterminados

const MOVE_LEFT : String = "move_left"
const MOVE_RIGHT : String = "move_right"
const MOVE_FORWARD : String = "move_forward"
const MOVE_BACKWARD : String = "move_backward"
const JUMP : String = "jump"
const PAUSE : String = "pause"

@export var DEFAULT_MOVE_LEFT_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_RIGHT_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_FORWARD_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_BACKWARD_KEY = InputEventKey.new()
@export var DEFAULT_JUMP_KEY = InputEventKey.new()
@export var DEFAULT_PAUSE_KEY = InputEventKey.new()

var move_left_key = InputEventKey.new()
var move_right_key = InputEventKey.new()
var move_forward_key = InputEventKey.new()
var move_backward_key = InputEventKey.new()
var jump_key = InputEventKey.new()
var pause_key = InputEventKey.new()
