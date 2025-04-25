extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_jumping := false
var is_moving := false
var is_running := false

func _process(_delta: float) -> void:
	var parent_body = get_parent() as CharacterBody3D  # Assuming parent is the CharacterBody3D
	if parent_body && not parent_body.is_on_floor():
		is_jumping = true
	else:
		is_jumping = false
	
	# Get input direction
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# Determine movement state
	is_moving = input_dir.length() > 0.1
	
	# Handle animation transitions
	if is_jumping:
		animation_player.play("Player/jump")
	elif is_moving:
		if Input.is_action_pressed("sprint"):
			animation_player.play("Player/run")
		else:
			animation_player.play("Player/walk")
	else:
		animation_player.play("Player/ideal")

# func _input(event: InputEvent) -> void:
# 	if event.is_action_pressed("jump"):
# 		is_jumping = true
# 	elif event.is_action_released("jump"):
# 		is_jumping = false 
