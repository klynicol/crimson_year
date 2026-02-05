class_name MobStats extends Resource

# stats system tutorial
#https://www.youtube.com/watch?v=vsBb9921GfA

signal mob_died
signal mob_health_changed

@export var max_health: int
@export var speed: float
@export var damage: int
@export var accel := 1400.0
@export var decel := 1600.0
@export var knockback_speed: float = 200.0
@export var attack_cooldown: float = 2

var _health: int
var health: int:
	get: return _health
	set(value): _on_health_set(value)

func _init() -> void:
	init_stats.call_deferred() # Allow unique values from the inspector to propagate

func init_stats() -> void:
	health = max_health

func _on_health_set(value: int) -> void:
	var actual_value: int
	# change this to clamp??
	if value <= 0:
		actual_value = 0
		mob_died.emit()
	elif value > max_health:
		actual_value = max_health
	else:
		actual_value = value
	_health = actual_value
	mob_health_changed.emit(actual_value)

func take_water_damage(damage: float) -> void:
	health -= damage