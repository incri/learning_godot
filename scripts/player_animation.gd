extends Node3D

@export var animationTree: AnimationTree

@export var locomotionBlendPath: String
@export var locojumpBlendPath: String
@export var fallingBlendPath: String
@export var locolandBlendPath: String

@export var player_movements: CharacterBody3D  

var input_dir = Vector2.ZERO
var current_blend: float = 0.0
var movement_blend_speed: float = 2.0
var jump_blend_speed: float = 5.0

var locojump_blend: float = 0.0
var falling_blend : float
var locoland_blend: float

var was_on_floor: bool = false  # Track previous floor state

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player_movements:
		player_movements.input_dir_updated.connect(_on_input_dir_updated)
		player_movements.jump_phase_changed.connect(_on_jump_phase_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if animationTree:
		var target_blend: float = 0.0
		if input_dir != Vector2.ZERO:
			if Input.is_action_pressed("sprint"):
				target_blend = 1.0
			else:
				target_blend = -1.0
		current_blend = lerp(current_blend, target_blend, movement_blend_speed * _delta)
		animationTree.set(locomotionBlendPath, current_blend)
		
		if Input.is_action_pressed("jump") && !player_movements.is_on_floor():
			print(current_blend)
			var target_locojump_blend: float = 0.0
			if current_blend > 0.6 or current_blend < -0.6:
				target_locojump_blend = 1.0
			else:
				target_locojump_blend = -1.0
			locojump_blend = lerp(locojump_blend, target_locojump_blend, jump_blend_speed * _delta)
			animationTree.set(locojumpBlendPath, locojump_blend)
		
		# Add landing detection and reset
		if not was_on_floor and player_movements.is_on_floor():
			animationTree.set(locomotionBlendPath, 0.0)
			animationTree.set(locojumpBlendPath, 0.0)
			animationTree.set(fallingBlendPath, 0.0)
			animationTree.set(locolandBlendPath, 0.0)  # Reset all to default
		was_on_floor = player_movements.is_on_floor()  # Update state
		
	else:
		print("AnimationTree is not set") 

func _on_input_dir_updated(new_dir: Vector2) -> void:
	input_dir = new_dir 

func _on_jump_phase_changed(phase: int) -> void:
	if phase == 0:  # Initial jump: locoland(0.0)
		animationTree.set(locomotionBlendPath, 0.0)  # Set to jump animation
	elif phase == 1:  # Mid-air transition: locoland(1.0)
		animationTree.set(locomotionBlendPath, 1.0)  # Set to fall transition
	elif phase == 2:  # Falling phase: Handle falling blends (e.g., falling(0) then falling(1))
		# Assuming fallingBlendPath is a blendspace, set to 0 first, then 1 in sequence
		# You might need to add timing or sub-phases; for now, set sequentially
		animationTree.set(fallingBlendPath, 0.0)  # Play falling(0)
		animationTree.set(fallingBlendPath, 1.0)  # Then falling(1)
