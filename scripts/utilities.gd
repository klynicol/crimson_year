extends Node2D

# Returns the rotation in radians from the global position to the mouse position
# 0° is to the right, 90° is down, 180° is left, 270° is up
func get_rotation_to_mouse(global_pos: Vector2) -> float:
	var direction_to_mouse := (get_global_mouse_position() - global_pos).normalized()
	return atan2(direction_to_mouse.y, direction_to_mouse.x)

# it's the same but uses the directional vector from right stick input to rotate
# instead of mouse position
func get_rotation_to_gamepad(_global_pos: Vector2) -> float:
	var direction_to_stick := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	return atan2(direction_to_stick.y, direction_to_stick.x)


# Returns the rotation in radians from the character to the global position of the mouse or gamepad "aim"
func get_rotation_of_aim(character: PlayerController, global_pos: Vector2) -> float:
	match character.get_control_type():
		PlayerController.ControlMode.KEYBOARD:
			return get_rotation_to_mouse(global_pos)
		PlayerController.ControlMode.GAMEPAD:
			return get_rotation_to_gamepad(global_pos)
		_:
			assert(false, "Invalid control type")
			return 0.0

# Returns the direction from the rotation in degrees
# 0 is right, 1 is down, 2 is left, 3 is up
func get_direction_from_rotation(rot: float) -> int:
	var angle = rad_to_deg(rot)
	# Normalize to 0-360 and add offset for 4-way division
	angle = fmod(angle + 360.0 + 45.0, 360.0)
	# Divide into 4 slices (90° each) instead of 8
	return int(angle / 90.0) % 4

# returns eitehr lef = 0 right = 1
func get_direction_from_rotation_180(rot: float) -> int:
	if rot > PI / 2 or rot < -PI / 2:
		return 1
	return 0
	
