extends Camera2D

@export var zoom_min: Vector2 = Vector2(0.75, 0.75)
@export var zoom_max: Vector2 = Vector2(2.0, 2.0)
@export var zoom_step: float = 0.15
@export var zoom_toward_cursor: bool = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		var zoom_dir: float = 0.0
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_dir = 1.0
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_dir = -1.0
		if zoom_dir == 0.0:
			return
		if not mb.pressed:
			return

		var viewport := get_viewport()
		var mouse_pos := viewport.get_mouse_position()
		var world_before := _screen_to_world(mouse_pos)

		var new_zoom := zoom + Vector2(zoom_step, zoom_step) * zoom_dir
		new_zoom.x = clampf(new_zoom.x, zoom_min.x, zoom_max.x)
		new_zoom.y = clampf(new_zoom.y, zoom_min.y, zoom_max.y)

		zoom = new_zoom

		if zoom_toward_cursor:
			var world_after := _screen_to_world(mouse_pos)
			position += world_before - world_after


func _screen_to_world(screen_pos: Vector2) -> Vector2:
	var view_size := get_viewport().get_visible_rect().size
	var center := view_size / 2.0
	return position + (screen_pos - center) / zoom
