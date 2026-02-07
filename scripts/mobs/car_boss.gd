class_name CarBoss extends Boss

const PROJECTILE_SCENE: PackedScene = preload("uid://ddqeip5vg2qsl")

const SPAWN_COOLDOWN: float = 3
var spawn_cooldown: float = 0.0
var _spawn_completed: bool = false

# [sound, played]
var sounds := [
	[preload("uid://go2ejpgvc17o"), false],
	[preload("uid://dr4fluy7y0eic"), false],
	[preload("uid://cflg2ph6g7dw4"), false],
]

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

signal spawn_completed

func _ready() -> void:
	boss_type = BossType.CAR
	spawn_cooldown = SPAWN_COOLDOWN
	enemy_uses_conveyor = false # This boss does not use the conveyor movement
	super._ready()

func _physics_process(delta: float) -> void:
	# We're running a special bootup sequence for the boss.
	spawn_cooldown -= delta

	if spawn_cooldown <= SPAWN_COOLDOWN / 2:
		trigger_sound()

	if spawn_cooldown > 0.0:
		return

	if not _spawn_completed:
		_spawn_completed = true
		spawn_completed.emit()
	super._physics_process(delta)

func trigger_sound() -> void:
	var sound = sounds[randi() % sounds.size()]
	if sound[1]:
		return
	sound[1] = true
	print("triggering sound: ", sound[0])
	audio_player.stream = sound[0]
	audio_player.play()
