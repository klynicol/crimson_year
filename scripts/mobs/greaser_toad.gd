class_name GreaserToad extends Mob

var animation_speed: float
var hop_time: float
var hop_air_time: float
var hop_ground_time: float

var air_timer: float = 0.0
var ground_timer: float = 0.0

const HOP_START_FRAME: int = 1
const HOP_END_FRAME: int = 5
const HOP_AIR_RATIO: float = 0.5
const HOP_ARC_HEIGHT: float = 32.0  # pixels of vertical travel for the hop
const ANIMATION_NAME: String = "default"

func _ready():
	mob_type = World.MobType.TOAD
	animation_speed = sprite.sprite_frames.get_animation_speed("default")
	# Calculate the hop_timer based on the animation speed and the number of frames in the hop
	hop_time = (HOP_END_FRAME - HOP_START_FRAME) * (animation_speed / 60)
	# set ratio of the hop cycles
	hop_air_time = hop_time * HOP_AIR_RATIO
	hop_ground_time = hop_time * (1.0 - HOP_AIR_RATIO)
	super._ready()

"""
Chase is different for the toad: it "hops" toward the target.
- On the ground: velocity eases to zero; we wait hop_ground_time, then launch.
- In the air: move toward target at constant speed; hop appearance comes from modulating Y (arc).
"""
func chase(target_pos: Vector2, delta: float) -> void:
	var displacement := target_pos - global_position
	var dist := displacement.length()

	if dist < stats.attack_range:
		velocity = Vector2.ZERO
		sprite.set_frame(0)
		sprite.pause()
		air_timer = 0.0
		ground_timer = hop_ground_time
		move_and_slide()
		super.chase(target_pos, delta)
		return

	var direction := displacement.normalized() if dist > 0.01 else Vector2.ZERO

	if air_timer > 0.0:
		# In the air: move toward target at constant speed; Y velocity gives the hop arc
		air_timer -= delta
		var hop_phase := 1.0 - (air_timer / hop_air_time)  # 0 at takeoff -> 1 at landing
		# Vertical velocity for arc: up at start, zero at peak, down at land (derivative of sin(phase*PI))
		var hop_velocity_y := -HOP_ARC_HEIGHT * PI / hop_air_time * cos(hop_phase * PI)
		var move_velocity := direction * stats.speed
		velocity = Vector2(move_velocity.x, move_velocity.y + hop_velocity_y)
		sprite.play(ANIMATION_NAME)
	else:
		# On the ground: ease to zero and wait before next hop; zero Y so we don't drift down
		velocity = velocity.move_toward(Vector2.ZERO, stats.decel * delta)
		velocity.y = 0.0
		ground_timer -= delta
		if ground_timer <= 0.0:
			ground_timer = hop_ground_time
			air_timer = hop_air_time  # launch

	move_and_slide()
	super.chase(target_pos, delta)
	
