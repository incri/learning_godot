extends Node3D

@export var mouse_sensitivity: float = 0.002
@export var tilt_limit: float = deg_to_rad(75)
@export var invert_y: bool = false

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Yaw (left/right) - rotate the pivot (this node)
		rotation.y -= event.relative.x * mouse_sensitivity
		# Pitch (up/down) - rotate the spring arm
		var pitch_delta = event.relative.y * mouse_sensitivity
		if invert_y:
			spring_arm.rotation.x += pitch_delta
		else:
			spring_arm.rotation.x -= pitch_delta
		# Clamp pitch
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -tilt_limit, tilt_limit)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(_delta):
	pass
