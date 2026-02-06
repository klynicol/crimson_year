class_name SmokeProjectile extends CharacterBody2D

var speed: float = 100.0
var acceleration: float = 1000.0
var dir: float

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if Game.paused:
		return
	velocity = Vector2(speed, 0).rotated(dir)
	move_and_slide()

func _on_area_entered(area: Area2D) -> void:
	queue_free()
