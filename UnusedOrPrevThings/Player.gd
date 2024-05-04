extends CharacterBody3D


const SPEED = 10.0
const JUMP_VELOCITY = 9
const DeviceInput = preload("res://addons/multiplayer_input/device_input.gd")
signal leave

var player: int
var input : DeviceInput
var device 
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


@onready var camerabase = $CameraB


# call this function when yspawning this player to set up the input object based on the device
func init(player_num: int):
	player = player_num
	
	# in my project, I got the device integer by accessing the singleton autoload PlayerManager
	# but for simplicity, it's not an autoload in this demo.
	# but I recommend making it a singleton so you can access the player data from anywhere.
	# that would look like the following line, instead of the device function parameter above.
	device = PlayerManager.get_player_device(player)
	input = DeviceInput.new(device)
	
func _input(event):
	if event is InputEventMouseMotion:
		camerabase.rotation.x -= deg_to_rad(event.relative.y * 0.5)
		camerabase.rotation.x = clamp(camerabase.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		rotation.y -= deg_to_rad((event.relative.x*0.5))

func _ready():
	#Input.mouse_mode = 2
	pass
func _physics_process(delta):
	# Add the gravity.
	#print("Core")
	#print(MultiplayerInput.core_actions)
	#print("Device")
	#print(MultiplayerInput.device_actions)
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if input.is_action_just_pressed("jump"): #and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = input.get_vector("move_left", "move_right", "move_forward","move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
