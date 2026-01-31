extends CharacterBody2D

@export var max_speed := 400.0

@onready var ground: TileMapLayer = $"../Ground"
var last_direction = Vector2(1, 0)

var anim_directions = {
	"idle": [ # list of [animation name, horizontal flip]
		["right_idle", false],
		["front_idle", false],
		["left_idle", false],
		["back_idle", false],
	],
	"walk": [
		["right_walking", false],
		["front_walking", false],
		["left_walking", false],
		["back_walking", false],
	],
}


func _physics_process(_delta: float) -> void:
	var motion := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	if motion.length() > 0.0:
		motion = motion.normalized() * max_speed
		update_animation("walk")
	else:
		update_animation("idle")

	set_velocity(motion)
	move_and_slide()
	
	# Update perspective center for tilemap shader and all objects
	_update_perspective()

# Update the perspective center for the tilemap shader and all objects
func _update_perspective() -> void:
	Perspective.set_character_position(global_position.x, global_position.y)
	ground.material.set_shader_parameter("center_x", Perspective.center_x)
	ground.material.set_shader_parameter("horizon_y", Perspective.horizon_y)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()

func update_animation(anim_set):
	var angle = rad_to_deg(_get_rotation_to_mouse())
	
	# Normalize to 0-360 and add offset for 4-way division
	angle = fmod(angle + 360.0 + 45.0, 360.0)
	
	# Divide into 4 slices (90° each) instead of 8
	var slice_dir = int(angle / 90.0) % 4
	
	$AnimatedSprite2D.play(anim_directions[anim_set][slice_dir][0])
	print("updating animation to: " + anim_set + " " + str(slice_dir) + " (angle: " + str(angle) + ")")

func _get_rotation_to_mouse() -> float:
	var direction_to_mouse := (get_global_mouse_position() - global_position).normalized()
	return atan2(direction_to_mouse.y, direction_to_mouse.x)
