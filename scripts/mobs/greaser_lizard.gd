class_name GreaserLizard extends Mob

func _ready():
	mob_type = Mob.MobType.LIZARD
	super._ready()

func chase(target_pos: Vector2, delta: float) -> void:
	# Get within attack range + buffer
	var displacement = target_pos - global_position

	velocity = velocity.move_toward(displacement.normalized() * stats.speed, stats.accel * delta)
	move_and_slide()
	super.chase(target_pos, delta)
