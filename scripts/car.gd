extends CharacterBody2D

const CAR_SPEED: float = 50.0
const ACCELERATION: float = 1400.0
var target_position: Vector2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# the values of these enums will also translate to the name
# of the animation
enum cars {
	CHEVY_BEL_AIR,
	CADILLAC_DEVILLE
}

func _init(car_type: cars, pos: Vector2, rot: float) -> void:
	car = car_type
	global_position = pos
	global_rotation = rot

func _ready() -> void:
	# set the sprite to the car type
	sprite.play(str(car))

func _physics_process(delta: float) -> void:
	velocity = velocity.move_toward(target_position - global_position * CAR_SPEED, ACCELERATION * delta)
	move_and_slide()

set_new_target_position(new_target_position: Vector2) -> void:
	target_position = new_target_position