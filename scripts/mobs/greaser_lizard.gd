extends Mob
class_name GreaserLizard

func _ready():
	mob_type = World.MobType.LIZARD
	super._ready()

func chase(target_pos: Vector2, delta: float) -> void:
	# Get within attack range + buffer
	var displacement = target_pos - global_position
	var decel_distance = stats.attack_range + 200.0
	var rate := stats.accel if displacement.length() > decel_distance else stats.decel
	if displacement.length() <= stats.attack_range:
		velocity = Vector2.ZERO
		return

	velocity = velocity.move_toward(displacement.normalized() * stats.speed, rate * delta)
	move_and_slide()
	super.chase(target_pos, delta)
