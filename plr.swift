extends CharacterBody3D

enum speed_modifier {
	STANDING = 0,
	SPRINTING = 2,
}

@onready var head = $Head
@onready var cam = $Head/Camera3D

const DEFAULT_SPEED = 5.0
const JUMP_VELOCITY = 4.5

const DEFAULT_SENSITIVITY = 0.003
const ZOOM_SENSITIVITY = 0.0005

var DEFAULT_FOV
var ZOOM_FOV

var sensitivity = DEFAULT_SENSITIVITY
var current_mode = speed_modifier.STANDING # standing, crouching, crawling

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	DEFAULT_FOV = cam.fov # need to assign them here for some reason
	ZOOM_FOV = DEFAULT_FOV - 50

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: # looking around
		head.rotate_y(-event.relative.x * sensitivity)
		cam.rotate_x(-event.relative.y * sensitivity)
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-60), deg_to_rad(60)) # camera limits

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Zoom"): # zooming
		cam.fov = ZOOM_FOV
		sensitivity = ZOOM_SENSITIVITY
	elif event.is_action_released("Zoom"):
		cam.fov = DEFAULT_FOV
		sensitivity = DEFAULT_SENSITIVITY

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		# Handle jump.
		if Input.is_action_just_pressed("Jump") and is_on_floor() and current_mode == speed_modifier.STANDING:
			velocity.y = JUMP_VELOCITY
		
		var speed = DEFAULT_SPEED + current_mode + (speed_modifier.SPRINTING if Input.is_action_pressed("Sprint") else 0)
		
		# Get the input direction and handle the movement/deceleration.
		var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
		var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = 0
			velocity.z = 0
		
		move_and_slide()
