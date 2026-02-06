class_name Car extends CharacterBody2D

const PACKED_SCENE: PackedScene = preload("uid://duee4wsbvb3xl")
const SPRITE_OPTIONS = 4
const SPRITE_DAMAGE_FRAMES = 3
const CAR_SPEED: float = 70.0
const ACCELERATION: float = 1400.0

const MAX_HEALTH: int = 700

signal car_died
signal car_took_damage(damage_amt)

var target_position: Vector2
var car_type: CarType
var health: int = MAX_HEALTH
var car_sprite_index: int

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_box: Area2D = $HitBox

# the values of these enums will also translate to the name
# of the animation
enum CarType {
	CHEVY_BEL_AIR,
	CADILLAC_DEVILLE
}

func init(p_car_sprite_index: int, pos: Vector2, p_target_position: Vector2) -> void:
	car_sprite_index = p_car_sprite_index
	global_position = pos
	global_rotation = 0 # for now, we don't need to rotate the car
	target_position = p_target_position

func _ready() -> void:
	hit_box.area_entered.connect(_on_hit_box_entered)
	add_to_group("cars")
	# set the sprite to the car type
	sprite.play(str(car_sprite_index))

func _physics_process(delta: float) -> void:
	if Game.paused:
		return
	# When moving the car we just gonna blast through any collisions
	# Just move the car linearly in the direction of the target position
	var direction = (target_position - global_position).normalized()
	velocity = direction * CAR_SPEED
	move_and_slide()

func _on_hit_box_entered(area: Area2D) -> void:
	if area.name != "CarDamageProjectile":
		return
	var projectile = area.get_parent()
	take_damage(projectile.damage)
	projectile.queue_free()

func set_new_target_position(new_target_position: Vector2) -> void:
	target_position = new_target_position

func take_damage(damage: float) -> void:
	health -= damage
	car_took_damage.emit(damage)
	if health <= 0:
		car_died.emit()

#Returns the distance from the end checkpoint
# relative to the total distance of the track
# which is the start checkpoint to the end checkpoint
func get_progress() -> float:
	var start_checkpoint = get_tree().get_first_node_in_group("start_checkpoint")
	var end_checkpoint = get_tree().get_first_node_in_group("end_checkpoint")
	var total_distance = start_checkpoint.global_position.distance_to(end_checkpoint.global_position)
	var current_distance = global_position.distance_to(end_checkpoint.global_position)
	return current_distance / total_distance 
