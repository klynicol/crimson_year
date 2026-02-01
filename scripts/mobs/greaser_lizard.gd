extends Mob

# override
func chase(target_pos: Vector2, delta: float) -> void:
	if not stats:
		return

	# Get within attack range + buffer
	var displacement = target_pos - global_position
	var decel_distance = stats.attack_range + 200.0
	var rate := stats.accel if displacement.length() > decel_distance else stats.decel
	if displacement.length() <= stats.attack_range:
		velocity = Vector2.ZERO
		return

	velocity = velocity.move_toward(displacement.normalized() * stats.speed, rate * delta)
	move_and_slide()

	if sprite:
		sprite.flip_h = velocity.x > 0
