class_name Checkpoint extends Area2D

var id: int
@onready var sprite: Sprite2D = $Sprite2D

signal checkpoint_reached

func _ready() -> void:
	# Get the number at the end of the checkpoint name (e.g. "Checkpoint0" -> 0)
	id = int(name.trim_prefix("Checkpoint"))
	body_entered.connect(_on_body_entered)
	# hide the sprite
	sprite.visible = false

func _on_body_entered(body: Node2D) -> void:
	checkpoint_reached.emit(id, body)

func spawn_car(car_type: Car.CarType, target_position: Vector2) -> Car:
	var car = Car.PACKED_SCENE.instantiate()
	car.init(car_type, global_position, target_position)
	World.ySort.add_child(car)
	return car
