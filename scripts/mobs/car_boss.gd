class_name CarBoss extends CharacterBody2D

const BOSS_SPEED: float = 50.0
const BOSS_ACCELERATION: float = 1000.0
const BOSS_DECELERATION: float = 1200.0
const BOSS_KNOCKBACK_SPEED: float = 50.0
const BOSS_ATTACK_COOLDOWN: float = 2
const BOSS_MAX_HEALTH: int = 1000

const SPAWN_COOLDOWN: float = 2
var spawn_cooldown: float = 0.0
var _spawn_completed: bool = false

signal spawn_completed

func _ready() -> void:
	spawn_cooldown = SPAWN_COOLDOWN

func _physics_process(delta: float) -> void:
	spawn_cooldown -= delta
	if spawn_cooldown > 0.0:
		return
	if not _spawn_completed:
		_spawn_completed = true
		spawn_completed.emit()
