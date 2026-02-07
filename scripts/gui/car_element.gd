class_name CarElement extends TextureRect

@onready var car_healthbar: ProgressBar = $CarHealthbar
@onready var x_texture: TextureRect = $XTexture
var car: Car

const SPRITE_OPTIONS = [
	preload("uid://cbpembt161ahg"), #black
	preload("uid://cxkj6pgclhfk"), #pink
	preload("uid://dpj03pqktmuod"), #green
	preload("uid://diy6mc76svhwp"), #blue
]

func _ready() -> void:
	car.car_took_damage.connect(on_car_took_damage)
	car.reached_end_checkpoint_signal.connect(_on_reached_end_checkpoint)
	x_texture.visible = false

func set_sprite(sprite_index: int) -> void:
	print("setting sprite: ", sprite_index)
	texture = SPRITE_OPTIONS[sprite_index]

func on_car_took_damage(damage) -> void:
	car_healthbar.value -= damage
	if car_healthbar.value <= 0:
		car_healthbar.visible = false
		x_texture.visible = true

func get_car_progress() -> float:
	if car == null:
		return 0.0
	return car.get_progress()

func _on_reached_end_checkpoint() -> void:
	queue_free()
