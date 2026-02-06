class_name SmokeProjectile extends CharacterBody2D

var speed: float = 500.0
var acceleration: float = 1000.0
var dir: float
var damage: float

const MAX_TIME_ALIVE: float = 2
const SCALE_DECAY_RATE: float = 5.0
var time_alive: float = 0.0

func _physics_process(delta: float) -> void:
	if Game.paused:
		return
	velocity = Vector2(speed, 0).rotated(dir)
	_decay(delta)
	_decay_scale(delta)
	move_and_slide()

func _decay(delta: float) -> void:
	time_alive += delta
	if time_alive > MAX_TIME_ALIVE:
		queue_free()

# Scale should increase over time
func _decay_scale(delta: float) -> void:
	scale.x += delta * SCALE_DECAY_RATE
	scale.y += delta * SCALE_DECAY_RATE
