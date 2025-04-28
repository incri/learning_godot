extends CharacterBody3D

@export var turn_speed: float = 4.0
@export var run_speed: float = 4.0
@export var jump_height: float = 6.0
@export var sprint_speed: float = 8.0
@export var gravity: float = 9.8

var astrael: Node3D
var camera: Camera3D
var orientation = Transform3D()
var can_double_jump: bool = false



signal input_dir_updated(new_dir: Vector2)
signal jump_phase_changed(phase: int)

func _ready():
	astrael = $Astrael
	camera = $CameraPivot/SpringArm3D/Camera3D

func _physics_process(delta):
	#camera and movement
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	input_dir_updated.emit(input_dir)

	var cam_rot = camera.global_transform.basis.get_euler()
	var cam_basis = Basis(Vector3.UP, cam_rot.y)

	var current_speed = run_speed
	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed

	if input_dir.length_squared() > 0:
		var move_dir = (cam_basis.z * input_dir.y + cam_basis.x * input_dir.x).normalized()
		astrael.look_at(astrael.global_transform.origin - move_dir, Vector3.UP)
		
		velocity.x = move_dir.x * current_speed
		velocity.z = move_dir.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
#jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_height
		jump_phase_changed.emit(0)

		can_double_jump = true
	elif can_double_jump:
		velocity.y = jump_height
		jump_phase_changed.emit(0)
		can_double_jump = false
	velocity.y -= gravity * delta
	jump_phase_changed.emit(1)


	move_and_slide()
