class_name SmokeProjectile extends CharacterBody2D

var dir: float
var damage: float
var free_countdown: float = 0.2
var time_alive: float
var hit: bool = false

#defaults, override if needed
# These were for the smoke projectile, but we're using a different projectile for the gunk and comb
var speed: float = 500.0
var acceleration: float = 1000.0
var scale_decay_rate: float = 5.0
var max_time_alive: float = 2.0
# var free_cooldown: float = 0.2

func _physics_process(delta: float) -> void:
	if Game.paused:
		return
	velocity = Vector2(speed, 0).rotated(dir)
	_decay(delta)
	_decay_scale(delta)
	_process_free_cooldown(delta)
	move_and_slide()

func _decay(delta: float) -> void:
	time_alive += delta
	if time_alive > max_time_alive:
		queue_free()

# Scale should increase over time
func _decay_scale(delta: float) -> void:
	scale.x += delta * scale_decay_rate
	scale.y += delta * scale_decay_rate

func _process_free_cooldown(delta: float) -> void:
	if not hit:
		return
	free_countdown -= delta
	if free_countdown <= 0.0:
		queue_free()
