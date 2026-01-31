extends CharacterBody2D

var direction_angle: float  ## Angle in radians; projectile faces this direction
var spawnPosition: Vector2
var spawnRotation: float
var speed: float

func _ready() -> void:
	global_position = spawnPosition
	global_rotation = spawnRotation
	
func _physics_process(delta: float) -> void:
	velocity = Vector2(0, -speed).rotated(direction_angle)
	move_and_slide()
