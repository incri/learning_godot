extends CharacterBody3D

@export var turn_speed: float = 5.0
@export var run_speed: float = 8.0
@export var gravity: float = 30.0
@export var jump_speed: float = 12.0
@export var sprint_speed: float = 14.0

var astrael: Node3D
var camera: Camera3D
var orientation = Transform3D()
var can_double_jump: bool = false


func _ready():
	astrael = $Astrael
	camera = $CameraPivot/SpringArm3D/Camera3D

func _physics_process(delta):
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_backward"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1

	var move_dir = Vector3.ZERO
	var current_speed = run_speed
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		# Update orientation to match camera's Y rotation only
		var cam_rot = camera.global_transform.basis.get_euler()
		orientation.basis = Basis(Vector3.UP, cam_rot.y)
		
		# Transform input direction to world space using orientation
		move_dir = orientation.basis.x * input_dir.x + orientation.basis.z * input_dir.y
		move_dir = move_dir.normalized()

		velocity.x = move_dir.x * current_speed
		velocity.z = move_dir.z * current_speed

		if move_dir.length() > 0.01:
			# Use Transform3D.looking_at to orient Astrael
			astrael.transform = astrael.transform.looking_at(astrael.transform.origin + move_dir, Vector3.UP)
	else:
		velocity.x = move_toward(velocity.x, 0, run_speed)
		velocity.z = move_toward(velocity.z, 0, run_speed)

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
		can_double_jump = true # Reset double jump when on floor

	# Handle jumping
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_speed
			can_double_jump = true
		elif can_double_jump:
			velocity.y = jump_speed
			can_double_jump = false

	move_and_slide()
