extends Node3D

@export var animationTree: AnimationTree

@export var locomotionBlendPath: String

@export var player_movements: Node  

var input_dir = Vector2.ZERO
var current_blend: float = 0.0
var blend_speed: float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player_movements:
		player_movements.input_dir_updated.connect(_on_input_dir_updated)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if animationTree:
		var target_blend: float = 0.0
		if input_dir != Vector2.ZERO:
			if Input.is_action_pressed("sprint"):
				target_blend = 1.0
			else:
				target_blend = -1.0
		current_blend = lerp(current_blend, target_blend, blend_speed * _delta)
		print("Computed blend value: ", current_blend)
		animationTree.set(locomotionBlendPath, current_blend)
	else:
		print("AnimationTree is not set") 

func _on_input_dir_updated(new_dir: Vector2) -> void:
	input_dir = new_dir 
