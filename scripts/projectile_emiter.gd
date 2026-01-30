extends Node2D

@onready var projectile = load("res://scenes/projectile.tscn")
@export var projectile_speed = 1500

var cooldown = 0.0
@export var cooldown_time = 0.02

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed('fire') and cooldown <= 0.0:
		shoot()
		cooldown = cooldown_time
	cooldown -= delta

func shoot() -> void:
	# Capture values once so projectile gets a true copy, not affected by character movement
	var pos := global_position
	var rot := global_rotation

	var instance = projectile.instantiate()
	instance.direction_angle = rot
	instance.spawnPosition = Vector2(pos.x, pos.y)
	instance.spawnRotation = rot
	instance.speed = projectile_speed

	# Add to scene root so projectile is NOT a child of the character (won't move with mouse/character)
	get_tree().current_scene.add_child(instance)
	
