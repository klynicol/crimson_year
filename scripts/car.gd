class_name Car extends CharacterBody2D

const PACKED_SCENE: PackedScene = preload("uid://duee4wsbvb3xl")
const CAR_SPEED: float = 70.0
const ACCELERATION: float = 1400.0

const MAX_HEALTH: int = 700

signal car_died

var target_position: Vector2
var car_type: CarType
var health: int = MAX_HEALTH

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# the values of these enums will also translate to the name
# of the animation
enum CarType {
	CHEVY_BEL_AIR,
	CADILLAC_DEVILLE
}

func init(p_car_type: CarType, pos: Vector2, p_target_position: Vector2) -> void:
	car_type = p_car_type
	global_position = pos
	global_rotation = 0 # for now, we don't need to rotate the car
	target_position = p_target_position

func _ready() -> void:
	add_to_group("cars")
	# set the sprite to the car type
	sprite.play(str(car_type))

func _physics_process(delta: float) -> void:
	# When moving the car we just gonna blast through any collisions
	# Just move the car linearly in the direction of the target position
	var direction = (target_position - global_position).normalized()
	velocity = direction * CAR_SPEED
	move_and_slide()

func set_new_target_position(new_target_position: Vector2) -> void:
	target_position = new_target_position

func take_damage(damage: float) -> void:
	health -= damage
	if health <= 0:
		car_died.emit()
		spawn_car_fragments()
		queue_free()

func spawn_car_fragments() -> void:
	pass  # TODO: implement car fragment spawning
