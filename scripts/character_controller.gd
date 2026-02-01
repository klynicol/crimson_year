extends CharacterBody2D

@export var max_speed := 400.0
@export var accel := 1400.0
@export var decel := 1600.0

@onready var ground: TileMapLayer = $"../Ground"
@onready var walls: TileMapLayer = $"../Walls"
signal player_died
signal player_respawned
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
	).normalized()
	
	if motion.length() > 0.0:
		velocity = velocity.move_toward(motion * max_speed, accel * _delta)
		update_animation("walk")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, decel * _delta)
		update_animation("idle")

	move_and_slide()
	
	# Update perspective center for tilemap shader and all objects
	_update_perspective()

# Update the perspective center for the tilemap shader and all objects
func _update_perspective() -> void:
	Perspective.set_character_position(global_position.x, global_position.y)
	ground.material.set_shader_parameter("center_x", Perspective.center_x)
	ground.material.set_shader_parameter("horizon_y", Perspective.horizon_y)
	walls.material.set_shader_parameter("center_x", Perspective.center_x)
	walls.material.set_shader_parameter("horizon_y", Perspective.horizon_y)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()

func update_animation(anim_set):
	var angle = Utilities.get_rotation_to_mouse(global_position)
	var slice_dir = Utilities.get_direction_from_rotation(angle)
	$AnimatedSprite2D.play(anim_directions[anim_set][slice_dir][0])
