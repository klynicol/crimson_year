extends TextureRect

@onready var car_healthbar: ProgressBar = $CarHealthbar
var car: Car

const SPRITE_OPTIONS = [
	preload("uid://cxkj6pgclhfk"), #black
	preload("uid://cxkj6pgclhfk"), #pink
	preload("uid://dpj03pqktmuod"), #green
	preload("uid://diy6mc76svhwp"), #blue
]

func _ready() -> void:
	call_deferred("_set_sprite")
	car.car_took_damage.connect(on_car_took_damage)

func set_sprite(sprite_index: int) -> void:
	texture = SPRITE_OPTIONS[sprite_index]

func on_car_took_damage(damage) -> void:
	car_healthbar.value -= damage
	if car_healthbar.value <= 0:
		queue_free()

func get_car_progress() -> float:
	if car == null:
		return 0.0
	return car.get_progress()
