extends CharacterBody2D

@export var max_speed := 400.0

@onready var ground: TileMapLayer = $"../Ground"


func _physics_process(_delta: float) -> void:
	var motion := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	if motion.length() > 0.0:
		motion = motion.normalized() * max_speed
	velocity = motion

	# Rotate to face the mouse
	var direction_to_mouse := (get_global_mouse_position() - global_position).normalized()
	rotation = atan2(direction_to_mouse.y, direction_to_mouse.x) - deg_to_rad(90)

	move_and_slide()
	
	# Update tilemap perspective to center on character
	if ground and ground.material:
		ground.material.set_shader_parameter("center_x", global_position.x)
		ground.material.set_shader_parameter("horizon_y", global_position.y)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
