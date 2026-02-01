extends Mob
class_name GreaserToad

@export var jump_force: float = 400.0
@export var gravity: float = 1000.0
@export var hop_interval: float = 0.6
@export var air_steer_strength: float = 900.0

var hop_timer: float = 0.0

func _ready():
	mob_type = World.MobType.TOAD

"""
Chase is a bit different for toad. We will not be using the acceleration and deceleration. The
toad will "hop" toward the target. While on the ground, the movement is more or less 0. While in the air,
the toad will move toward the target at a constant speed, with smooth acceleration/deceleration of velocity.
"""
func chase(target_pos: Vector2, delta: float) -> void:
	var displacement := target_pos - global_position
	var dist := displacement.length()
	var direction := displacement.normalized() if dist > 0.01 else Vector2.ZERO

	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, 1200.0 * delta)
		velocity.y = 0.0
		hop_timer -= delta
		if hop_timer <= 0.0 and dist > stats.attack_range and direction != Vector2.ZERO:
			# Hop toward target: initial horizontal nudge + upward impulse
			velocity = Vector2(direction.x * stats.speed * 0.4, -jump_force)
			hop_timer = hop_interval
	else:
		velocity.y += gravity * delta
		# Steer horizontal velocity toward target at constant speed (smooth tween in air)
		var desired_x := direction.x * stats.speed
		velocity.x = move_toward(velocity.x, desired_x, air_steer_strength * delta)

	move_and_slide()
	super.chase(target_pos, delta)
