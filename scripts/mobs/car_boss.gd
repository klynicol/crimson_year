class_name CarBoss extends Boss

const SPAWN_COOLDOWN: float = 2
var spawn_cooldown: float = 0.0
var _spawn_completed: bool = false

signal spawn_completed

func _ready() -> void:
	boss_type = BossType.CAR
	spawn_cooldown = SPAWN_COOLDOWN
	enemy_uses_conveyor = false # This boss does not use the conveyor movement
	super._ready()

func _physics_process(delta: float) -> void:
	# We're running a special bootup sequence for the boss.
	spawn_cooldown -= delta
	if spawn_cooldown > 0.0:
		return

	if not _spawn_completed:
		_spawn_completed = true
		spawn_completed.emit()
	super._physics_process(delta)
