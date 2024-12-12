extends CharacterBody3D

# Player nodes

@onready var head = $Head
#@onready var standing_collision_shape = $standing_collision_shape
#@onready var crouching_collision_shape = $crouching_collision_shape2
@onready var ray_cast_3d = $RayCast3D

# Speed vars

var current_speed = 5.0

@export var walking_speed = 5.0
@export var sprinting_speed = 8.0
@export var crouching_speed = 3.0
@export var jump_velocity = 4.5
@export var jump_double: bool = true

# Movement vars
var lerp_speed = 10.0
var crouching_depth = -0.5

# Input vars
var direction
const mouse_sens = 0.2



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	
	# Mouse looking logic
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))


func _physics_process(delta):
	update_input(current_speed,0.12,0.27)
	print(velocity.length())
	# Handle movement state
	if %WallSensor.is_colliding() and Input.is_action_pressed("jump"):
		velocity.y = 3
	if is_on_floor() and jump_double == false:
		jump_double = true
		
	#crouching
	if Input.is_action_pressed("crouch"):
		%CollisionShape3D.shape.height = 0.7
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y,1.5 + crouching_depth,delta*lerp_speed)
	if Input.is_action_just_released("crouch"):
		%CollisionShape3D.shape.height = 2
		current_speed = walking_speed
		head.position.y = lerp(head.position.y,1.5,delta*lerp_speed)
	#elif !ray_cast_3d.is_colliding():
		
	# Sprinting
	if Input.is_action_pressed("sprint"):
		current_speed = sprinting_speed
	elif Input.is_action_just_released("sprint"):
		current_speed = walking_speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	elif Input.is_action_just_pressed("jump") and not is_on_floor() and jump_double == true:
		velocity.y = jump_velocity
		jump_double = false
		
		
func update_input(speed: float, acceleration: float, deceleration: float): 
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = lerp(velocity.x,direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z,direction.z * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
		velocity.z = move_toward(velocity.z, 0, deceleration)
	
	move_and_slide()
