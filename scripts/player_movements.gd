extends CharacterBody3D

@export var turn_speed: float = 5.0
@export var run_speed: float = 8.0
@export var gravity: float = 30.0
@export var jump_speed: float = 12.0
@export var sprint_speed: float = 14.0
@export var dash_speed: float = 20.0
@export var dash_duration: float = 0.2
@export var dash_cooldown_time: float = 1.0

var astrael: Node3D
var camera: Camera3D
var orientation = Transform3D()
var can_double_jump: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var is_dashing: bool = false
var has_air_dashed: bool = false
var intro_timer: float = 12.0  

signal input_dir_updated(new_dir: Vector2)

func _ready():
	astrael = $Astrael
	camera = $CameraPivot/SpringArm3D/Camera3D

func _physics_process(delta):
	intro_timer -= delta  
	if intro_timer > 0:
		velocity = Vector3.ZERO 
		return  
	
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_backward"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1

	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
	input_dir_updated.emit(input_dir)
	var cam_rot = camera.global_transform.basis.get_euler()
	
	var move_dir = Vector3.ZERO
	var current_speed = run_speed
	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed

	if input_dir != Vector2.ZERO:
		orientation.basis = Basis(Vector3.UP, cam_rot.y)
		move_dir = orientation.basis.x * input_dir.x + orientation.basis.z * input_dir.y
		move_dir = move_dir.normalized()

		if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0:
			if is_on_floor():
				is_dashing = true
				dash_timer = dash_duration
				dash_cooldown_timer = dash_cooldown_time
				has_air_dashed = false
			elif not is_on_floor() and not has_air_dashed:
				is_dashing = true
				dash_timer = dash_duration
				has_air_dashed = true
				dash_cooldown_timer = dash_cooldown_time

		if is_dashing:
			velocity = move_dir * dash_speed
			velocity.y = 0
			dash_timer -= delta
			if dash_timer <= 0:
				is_dashing = false
		else:
			velocity.x = move_dir.x * current_speed
			velocity.z = move_dir.z * current_speed

		if move_dir.length() > 0.01:
			astrael.transform = astrael.transform.looking_at(astrael.transform.origin + move_dir, Vector3.UP)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	if not is_dashing and not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_speed
			can_double_jump = true
		elif can_double_jump:
			velocity.y = jump_speed
			can_double_jump = false

	move_and_slide()
