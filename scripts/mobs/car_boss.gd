class_name CarBoss extends Boss

const PROJECTILE_SCENE: PackedScene = preload("uid://ddqeip5vg2qsl")

const SPAWN_COOLDOWN: float = 3
const TIME_TRIGGER_SCREECH_SOUND: float = 2.2
var screech_sound_played: bool = false
var engine_loop_sound_played: bool = false

const WOBBLE_ANGLE_DEG: float = 10
const WOBBLE_SPEED: float = 0.4
const MIN_DISTANCE_FROM_CAR: float = 350.0
const DIRECTION_CHANGE_COOLDOWN: float = 1.8
var spawn_cooldown: float = 0.0
var _spawn_completed: bool = false
var _wobble_time: float = 0.0
var _direction_change_cooldown: float = 0.0
var death_bomb_sound_played: bool = false

@onready var boss_markers: Node2D = $/root/Game/World/BossMarkers
@onready var emitters := {
	"smoke": $SmokeEmitter,
	"gunk": $GunkEmitter,
	"comb":$CombEmitter,
}

const projectiles := {
	"smoke": preload("uid://ddqeip5vg2qsl"),
	"gunk": preload("uid://55b0h1hqgo2b"),
	"comb": preload("uid://bh4i723at2vbs"),
}

# [sound, played]
var spawn_sound = preload("res://audio/sfx/boss_engine/Car-screech-02.wav")
var battle_sounds = [
	preload("res://audio/sfx/boss_engine/Car_rev-01.wav"),
	# preload("res://audio/sfx/actual effect/lelolelo/highpitch.wav"),
	# preload("res://audio/sfx/actual effect/lelolelo/lowlelo.wav"),
]
var death_bomb_sound = preload("uid://vw8kctqbrbi7")

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var engine_audio_player: AudioStreamPlayer2D = $CarEngineLoop

## grab all these boss markers
# Collect all lane markers and their submarkers from $BossMarkers group for quick access
var max_positions: Dictionary = {
	"max_x":0.0,
	"max_y":0.0,
	"min_x":0.0,
	"min_y":0.0,
}

func _play_death_bomb_sound() -> void:
	if death_bomb_sound_played:
		return
	death_bomb_sound_played = true
	audio_player.stream = death_bomb_sound
	audio_player.play()

func _handle_mob_dying(delta: float) -> void:
	_play_death_bomb_sound()
	super._handle_mob_dying(delta)

signal spawn_completed

func _ready() -> void:
	engine_audio_player.stop()
	_collect_lane_markers()
	boss_type = BossType.CAR
	spawn_cooldown = SPAWN_COOLDOWN
	enemy_uses_conveyor = false # This boss does not use the conveyor movement
	super._ready()

func _handle_mob_hurt(delta: float) -> void:
	pass

func _shoot_projectile(target_pos: Vector2) -> void:
	# target_pos += Vector2(150, 0) #account for car movement
	_shoot_projectile_smoke(target_pos)
	_shoot_projectile_gunk(target_pos)
	_shoot_projectile_comb(target_pos)
	# audio_stream_player_2d.stream = attack_sfx
	# audio_stream_player_2d.play()

func _shoot_projectile_smoke(target_pos: Vector2) -> void:
	var emitter_pos: Vector2 = emitters["smoke"].global_position
	var projectile = projectiles["smoke"].instantiate()
	projectile.global_position = emitter_pos
	projectile.dir = emitter_pos.angle_to_point(target_pos)
	projectile.damage = stats.damage
	World.ySort.add_child(projectile)

func _shoot_projectile_gunk(target_pos: Vector2) -> void:
	var emitter_pos: Vector2 = emitters["gunk"].global_position
	var projectile = projectiles["gunk"].instantiate()
	projectile.scale_decay_rate = 1.5
	projectile.global_position = emitter_pos
	projectile.dir = emitter_pos.angle_to_point(target_pos)
	projectile.damage = stats.damage
	World.ySort.add_child(projectile)

func _shoot_projectile_comb(target_pos: Vector2) -> void:
	var emitter_pos: Vector2 = emitters["comb"].global_position
	var projectile = projectiles["comb"].instantiate()
	projectile.scale_decay_rate = 1.5
	projectile.global_position = emitter_pos
	projectile.dir = emitter_pos.angle_to_point(target_pos)
	projectile.damage = stats.damage
	World.ySort.add_child(projectile)

func _physics_process(delta: float) -> void:
	hit_this_cycle = false
	# We're running a special bootup sequence for the boss.
	spawn_cooldown -= delta

	if spawn_cooldown <= TIME_TRIGGER_SCREECH_SOUND:
		trigger_sound()

	if spawn_cooldown > 0.0:
		return

	if not engine_loop_sound_played:
		engine_loop_sound_played = true
		engine_audio_player.play()

	if not _spawn_completed:
		_spawn_completed = true
		spawn_completed.emit()

	_random_play_battle_sound()

	# check_position_in_lanes()
	super._physics_process(delta)

func _random_play_battle_sound() -> void:
	if randf() > 0.002:
		return
	var random_sound = battle_sounds.pick_random()
	audio_player.stream = random_sound
	audio_player.play()

func chase(target_pos: Vector2, delta: float) -> void:
	_wobble_time += delta
	# Wobble: rotate back and forth by 15 degrees
	rotation = sin(_wobble_time * WOBBLE_SPEED) * deg_to_rad(WOBBLE_ANGLE_DEG)

	# Base direction: toward target, but never aim closer than MIN_DISTANCE_FROM_CAR to any car
	var move_direction: Vector2 = Vector2.ZERO

	var cars: Array = get_tree().get_nodes_in_group("cars")
	for car in cars:
		var to_boss: Vector2 = global_position - car.global_position
		var dist: float = to_boss.length()
		if dist < MIN_DISTANCE_FROM_CAR:
			move_direction = to_boss.normalized()

	#40% of the time we should move in a random direction
	_direction_change_cooldown -= delta
	if _direction_change_cooldown <= 0.0:
		_direction_change_cooldown = DIRECTION_CHANGE_COOLDOWN
		if randf() < 0.5:
			move_direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
		else:
			var to_target: Vector2 = target_pos - global_position
			move_direction = to_target.normalized()
	elif move_direction == Vector2.ZERO:
		return

	# Always moving at stats.speed
	var desired_velocity: Vector2 = move_direction * stats.speed
	velocity = velocity.move_toward(desired_velocity, stats.accel * delta)

	# Velocity bounds: stay in lane and never exceed stats.speed.
	# Per axis: max velocity = min(stats.speed, distance_to_boundary / delta) so we can't leave bounds in one frame.
	var min_x: float = max_positions["min_x"]
	var max_x: float = max_positions["max_x"]
	var min_y: float = max_positions["min_y"]
	var max_y: float = max_positions["max_y"]
	var vel_x_upper: float = minf(stats.speed, (max_x - global_position.x) / delta)
	var vel_x_lower: float = maxf(-stats.speed, (min_x - global_position.x) / delta)
	var vel_y_upper: float = minf(stats.speed, (max_y - global_position.y) / delta)
	var vel_y_lower: float = maxf(-stats.speed, (min_y - global_position.y) / delta)
	velocity.x = clampf(velocity.x, vel_x_lower, vel_x_upper)
	velocity.y = clampf(velocity.y, vel_y_lower, vel_y_upper)
	if velocity.length() > stats.speed:
		velocity = velocity.normalized() * stats.speed


func _collect_lane_markers():
	max_positions.clear()
	for sprite in boss_markers.get_children():
		var x_or_y: String = sprite.name.split("_")[1]
		max_positions[sprite.name] = sprite.global_position[x_or_y]

func trigger_sound() -> void:
	if _spawn_completed or screech_sound_played:
		return
	audio_player.stream = spawn_sound
	audio_player.play()
	screech_sound_played = true
