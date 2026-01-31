extends Node

# Perspective settings - MUST match tilemap shader (game.tscn ShaderMaterial)
var perspective_strength: float = 0.0005
var horizon_base: float = -300.0  # Offset from character Y; horizon = character.y + horizon_base
var center_x: float = 0.0
var horizon_y: float = -300.0  # Computed: horizon_base + character.y

## Call from character controller each frame - keeps perspective centered on character
func set_character_position(x: float, y: float) -> void:
	center_x = x
	horizon_y = horizon_base + y

## Returns the visual X offset for an object at the given world position
## Add this to your object's visual X to match the floor perspective
func get_x_offset(world_pos: Vector2) -> float:
	var dist_from_horizon: float = world_pos.y - horizon_y
	var scale: float = 1.0 + (dist_from_horizon * perspective_strength)
	var offset_from_center: float = world_pos.x - center_x
	var new_x: float = center_x + (offset_from_center * scale)
	return new_x - world_pos.x

## Returns the full perspective-adjusted position
func get_visual_position(world_pos: Vector2) -> Vector2:
	return Vector2(world_pos.x + get_x_offset(world_pos), world_pos.y)
