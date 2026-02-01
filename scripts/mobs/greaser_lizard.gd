extends Mob

## Greaser Lizard: uses raycast to detect player, then chases
func look_for_player() -> void:
	if not ray_cast:
		return
	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		var target = ray_cast.get_collider()
		if target is CharacterBody2D:  # or check for your player group
			chase(target.global_position)
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func chase(target_pos: Vector2) -> void:
	if not stats:
		return
	var direction = (target_pos - global_position).normalized()
	velocity = direction * stats.speed
	if sprite:
		sprite.flip_h = direction.x < 0
