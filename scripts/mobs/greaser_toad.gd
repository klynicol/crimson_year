class_name GreaserToad extends Mob

@onready var shadow: Sprite2D = $Shadow
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
var starting_shadow_position: Vector2
var spawn_sfx:= [
	preload("uid://is3kjlhxvorg"),
	preload("uid://dl1ub5nea06rv"),
	preload("uid://s7q26sj8udc5"),
]

var animation_speed: float
var hop_time: float

const HOP_START_FRAME: int = 1
const HOP_END_FRAME: int = 5
const HOP_AIR_RATIO: float = 0.5
const HOP_ARC_HEIGHT: float = 32.0  # pixels of vertical travel for the hop

func _ready():
	mob_type = Mob.MobType.TOAD
	animation_speed = sprite.sprite_frames.get_animation_speed("walk")
	# Hop duration = number of hop frames / FPS (e.g. 5 frames at 7 FPS = 5/7 sec)
	var hop_frame_count := HOP_END_FRAME - HOP_START_FRAME + 1
	hop_time = float(hop_frame_count) / animation_speed
	starting_shadow_position = shadow.position
	super._ready()
	if roll_for_oneliner() == true:
		audio_stream_player_2d.stream = spawn_sfx.pick_random()
		audio_stream_player_2d.play()
"""
Chase is different for the toad: it "hops" toward the target.
- On the ground: velocity is zero; we wait a bit, then launch.
- In the air: based on the cycle time, we start the hop cycle while accelerating toward the target.
- When we reach the "apex" of the hop, we decelerate to zero velocity, where velocity = 0 once we land.
"""
func chase(target_pos: Vector2, delta: float) -> void:
	var displacement := target_pos - global_position
	var dist := displacement.length()
	var direction := displacement.normalized() if dist > 0.01 else Vector2.ZERO

	var in_hop_frames := sprite.frame >= HOP_START_FRAME and sprite.frame <= HOP_END_FRAME
	if in_hop_frames:
		# Hop phase 0 = start of frame 1, 1 = end of frame 5 (5 frames total)
		var hop_frame_count := HOP_END_FRAME - HOP_START_FRAME + 1
		var hop_phase := (float(sprite.frame - HOP_START_FRAME) + sprite.frame_progress) / float(hop_frame_count)
		hop_phase = clampf(hop_phase, 0.0, 1.0)  # guard against animation edge cases
		# var hop_velocity_y := -HOP_ARC_HEIGHT * PI / hop_time * cos(hop_phase * PI)
		var vector_x: float = Car.CAR_SPEED if on_conveyor else 0.0
		var vector_y: float = 0.0
		if hop_phase < 0.5:
			# Ascending to apex: accelerate toward the target

			var target := direction * stats.speed + Vector2(vector_x, vector_y)
			velocity = velocity.move_toward(target, stats.accel * delta)
			shadow.position.y = starting_shadow_position.y + HOP_ARC_HEIGHT * sin(hop_phase * PI)
		else:
			# From apex to land: decelerate to zero (plus hop arc so we land with velocity = 0)
			velocity = velocity.move_toward(Vector2(vector_x, vector_y), stats.decel * delta)
			shadow.position.y = starting_shadow_position.y + HOP_ARC_HEIGHT * sin(hop_phase * PI)
		sprite.flip_h = velocity.x - vector_x >= 0
	else:
		# On the ground (frame 0 or outside hop range): velocity is zero; animation will advance to hop
		velocity = Vector2.ZERO	

func roll_for_oneliner() -> bool:
	var roll = [1, 2, 3].pick_random()
	if roll == 3:
		return true
	else:
		return false
