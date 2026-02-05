class_name GreaserLizard extends Mob

func _ready():
	mob_type = Mob.MobType.LIZARD
	super._ready()

func chase(target_pos: Vector2, delta: float) -> void:
	# Get within attack range + buffer
	var displacement: Vector2 = target_pos - global_position
	var move_vector: Vector2 = displacement.normalized() * stats.speed
	var vector_x: float = Car.CAR_SPEED if on_conveyor else 0.0
	move_vector.x += vector_x
	velocity = velocity.move_toward(move_vector, stats.accel * delta)
	sprite.flip_h = velocity.x - vector_x >= 0
