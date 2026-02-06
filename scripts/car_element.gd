extends TextureRect

@onready var car_healthbar: ProgressBar = $CarHealthbar

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func on_car_took_damage(damage) -> void:
	car_healthbar.value -= damage
	if car_healthbar.value == 0.0:
		queue_free()
