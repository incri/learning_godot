extends CharacterBody3D

@export var turn_speed: float = 4.0
@export var run_speed: float = 4.0
@export var jump_height: float = 6.0
@export var sprint_speed: float = 8.0
@export var gravity: float = 9.8

@export var animationTree: AnimationTree
@export var locomotionBlendPath: String = "parameters/locomotion/blend_position"
@export var locojumpBlendPath: String
@export var fallingBlendPath: String
@export var locolandBlendPath: String

var astrael: Node3D
var camera: Camera3D
var orientation = Transform3D()
var can_double_jump: bool = false
var movement_speed: float

var target_blend: float = 0.0
var movement_blend_speed: float = 2.0
var current_blend: float = 0.0


signal input_dir_updated(new_dir: Vector2)
signal jump_phase_changed(phase: int)

func _ready():
	astrael = $Astrael
	camera = $CameraPivot/SpringArm3D/Camera3D
	animationTree.active = true

func _physics_process(delta):
	# 1. Get input direction (left/right + forward/backward)
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	input_dir_updated.emit(input_dir)

	# 2. Get camera rotation for camera-relative movement
	var cam_rot = camera.global_transform.basis.get_euler()
	var cam_basis = Basis(Vector3.UP, cam_rot.y)

	# 3. Set movement speed and animation target blend value
	if Input.is_action_pressed("sprint") and input_dir.length_squared() > 0:
		movement_speed = sprint_speed
		target_blend = 1.0  # Sprint animation
	elif input_dir.length_squared() > 0:
		movement_speed = run_speed
		target_blend = 0.5  # Walk or run animation
	else:
		movement_speed = 0
		target_blend = 0.0  # Idle animation

	# 4. Move and rotate player
	if input_dir.length_squared() > 0:
		var move_dir = (cam_basis.z * input_dir.y + cam_basis.x * input_dir.x).normalized()
		astrael.look_at(astrael.global_transform.origin - move_dir, Vector3.UP)
		
		velocity.x = move_dir.x * movement_speed
		velocity.z = move_dir.z * movement_speed
	else:
		# Smooth deceleration when no input
		velocity.x = move_toward(velocity.x, 0, run_speed * delta)
		velocity.z = move_toward(velocity.z, 0, run_speed * delta)

	# 5. Smooth animation blend transition
	print("current_blend:", current_blend)
	print("AnimationTree active:", animationTree.active)
	print("Blend path:", locomotionBlendPath)

	current_blend = lerp(current_blend, target_blend, movement_blend_speed * delta)
	animationTree.set(locomotionBlendPath, current_blend)




	# Jumping logic
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_height
			jump_phase_changed.emit(0)
			can_double_jump = true
		elif can_double_jump:
			velocity.y = jump_height
			jump_phase_changed.emit(0)
			can_double_jump = false

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	jump_phase_changed.emit(1)

	# Move the character
	move_and_slide()
