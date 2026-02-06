extends Container

func _process(delta: float) -> void:
	for car_element in get_children():
		_car_position(car_element)

## Inside this container display the car element
# positioned inside this container based on the progress of the car
func _car_position(car_element: Node) -> void:
	var progress = car_element.get_car_progress()
	var size = get_size().x
	var position = progress * get_size().x
	car_element.position = Vector2(size - position, 35)
