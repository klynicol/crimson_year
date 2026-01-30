extends CharacterBody2D

@export var max_speed := 400.0
@export var acceleration := 1300.0
@export var deceleration := 1200.0


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	var has_input_direction := direction.length() > 0.0
	if has_input_direction:
		var desired_velocity := direction * max_speed
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	move_and_slide()
	
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
