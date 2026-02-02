extends CharacterBody2D

const CAR_SPEED: float = 70.0
const ACCELERATION: float = 1400.0
var target_position: Vector2
var car: CarType

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# the values of these enums will also translate to the name
# of the animation
enum CarType {
	CHEVY_BEL_AIR,
	CADILLAC_DEVILLE
}

# func _init(car_type: CarType, pos: Vector2, rot: float) -> void:
# 	car = car_type
# 	global_position = pos
# 	global_rotation = rot

func _ready() -> void:
	# set the sprite to the car type
	sprite.play(str(car))
	call_deferred("set_target")
	

func set_target():
#!!!!!! temp set target position to Checkpoint5
	for checkpoint in get_tree().get_nodes_in_group("checkpoint"):
		if checkpoint.id == 0:
			target_position = checkpoint.global_position
			print("target_position: " + str(target_position) + "name: " + checkpoint.name)
			break

func _physics_process(delta: float) -> void:
	# When moving the car we just gonna blast through any collisions
	# Just move the car linearly in the direction of the target position
	var direction = (target_position - global_position).normalized()
	velocity = direction * CAR_SPEED
	move_and_slide()

func set_new_target_position(new_target_position: Vector2) -> void:
	target_position = new_target_position
