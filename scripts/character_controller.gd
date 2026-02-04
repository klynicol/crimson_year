class_name PlayerController extends CharacterBody2D

@export var max_speed := 400.0
@export var accel := 2000.0
@export var decel := 3000.0
@export var dash_cooldown_time := 0.3
@export var dash_reset_cooldown_time := .3

var previous_anim_direction: String = "idle"
var previous_anim_action: int = 0 # 0 is idle, 1 is action
var previous_anim_frame: int = 0
var previous_anim_frame_progress: float = 0.0

var dash_cooldown := 0.0
var dash_reset_cooldown := 0.0
var input_released_by_code := false

# this will determine whether the Utilities file uses the get_rotation_to_mouse()
# or the get_rotation_to_stick() functions
@export var control_type = PlayerController.ControlMode.KEYBOARD
enum ControlMode{
	KEYBOARD,
	GAMEPAD
}

signal player_died
signal player_respawned

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var anim_directions = {
	"idle": [ # list of [animation name, horizontal flip]
		["left_idle", "left_idle_shooting"],
		["left_idle", "left_idle_shooting"],
		["left_idle", "left_idle_shooting"],
		["left_idle", "left_idle_shooting"],
	],
	"walk": [
		["left_walking", "left_walking_shooting"],
		["left_walking", "left_walking_shooting"],
		["left_walking", "left_walking_shooting"],	
		["left_walking", "left_walking_shooting"],
	],
	'dash': [
		["left_dash", "left_dash"],
		["left_dash", "left_dash"],
		["left_dash", "left_dash"],
		["left_dash", "left_dash"],
	],
}

func _physics_process(_delta: float) -> void:
	var motion := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	if Input.is_action_pressed("dash") and dash_cooldown <= 0.0 and dash_reset_cooldown <= 0.0:
		dash_reset_cooldown = dash_reset_cooldown_time
		dash_cooldown = dash_cooldown_time
		input_released_by_code = false

	var speed = max_speed
	# Give the character a slight "hop" when walking
	if previous_anim_direction == "walk":
		match sprite.frame:
			1, 4:
				speed = speed * .35
			2, 3:
				speed = speed * 1.8

	# update the dash cooldown and reset cooldown
	var is_dashing := false
	if dash_cooldown > 0.0:
		is_dashing = true
		dash_cooldown -= _delta
		speed = speed * 10
	elif dash_reset_cooldown > 0.0:
		dash_reset_cooldown -= _delta
	
	# update animation and velocity based on the current state
	if is_dashing:
		velocity = velocity.move_toward(motion * speed, accel * _delta)
		update_animation("dash")
	elif motion.length() > 0.0:
		velocity = velocity.move_toward(motion * speed, accel * _delta)
		update_animation("walk")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, decel * _delta)
		update_animation("idle")

	move_and_slide()

# Update the perspective center for the tilemap shader and all objects
# func _update_perspective() -> void:
# 	Perspective.set_character_position(global_position.x, global_position.y)
# 	if not World.ground or not World.walls:
# 		return
# 	World.ground.material.set_shader_parameter("center_x", Perspective.center_x)
# 	World.ground.material.set_shader_parameter("horizon_y", Pearspective.horizon_y)
# 	World.walls.material.set_shader_parameter("center_x", Perspective.center_x)
# 	World.walls.material.set_shader_parameter("horizon_y", Perspective.horizon_y)

func update_animation(anim_direction: String):

	var rot_angle = Utilities.get_rotation_of_aim(self, global_position)
	var slice_dir = Utilities.get_direction_from_rotation(rot_angle)

	var anim_action: int = 1 if Input.is_action_pressed("fire") else 0

	$AnimatedSprite2D.play(anim_directions[anim_direction][slice_dir][anim_action])

	if anim_direction == previous_anim_direction and anim_action != previous_anim_action:
		print("Continuing animation")
		# Restore both the frame and frame progress to continue smoothly
		$AnimatedSprite2D.set_frame_and_progress(previous_anim_frame, previous_anim_frame_progress)
	# Handle fllip horizontal for the sprite based on the aim direction
	if rot_angle > PI / 2 or rot_angle < -PI / 2:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true

	previous_anim_direction = anim_direction
	previous_anim_action = anim_action
	previous_anim_frame = $AnimatedSprite2D.frame
	previous_anim_frame_progress = $AnimatedSprite2D.frame_progress

func get_control_type() -> ControlMode:
	return control_type
