extends Node2D

@onready var projectile = load("res://scenes/water_spray_projectile.tscn")
@onready var character: CharacterBody2D = get_parent()
# @onready var sprayer: Sprite2D = $"../Sprayer"
@onready var debug_label: Label = get_tree().current_scene.get_node("Gui/Control/Label")
@export var projectile_speed = 400

const MAX_SCALE_X = 9.0
const MIN_SCALE_X = 3.5
const MAX_SCALE_Y = 12.0
const MIN_SCALE_Y = 2.5
const MIN_MIST_STRENGTH = 0.9
const MAX_MIST_STRENGTH = 3.0

# The sprayer will spawn in 4 different spots based on the character's
# direction and sprite.
const SPRAYER_SPAWN_POSITIONS = [
	Vector2(54.5, -36.5), # right
	Vector2(-31, 3), # down
	Vector2(-55.5, -38.5), # left
	Vector2(29, -74), # up
]

var cooldown = 0.0
var cooldown_time: float

var last_shot_rotation: float = 0.0

func _ready() -> void:
	# Each projectile is 20pixels wide
	# based on the projectile speed, we can calculate the cooldown time
	cooldown_time = 46.0 / projectile_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed('fire') and cooldown <= 0.0:
		shoot()
		cooldown = cooldown_time
	cooldown -= delta

func shoot() -> void:
	print("velocity: " + str(character.velocity))
	# Spawn at the tip of the sprayer sprite (end of barrel)
	# var tip_offset := sprayer.global_transform.x * (sprayer.texture.get_width() / 2.0)
	# var spawn_pos := sprayer.global_position + tip_offset
	# var rot := sprayer.global_rotation + PI / 2
	var instance = projectile.instantiate()

	var rot = Utilities.get_rotation_to_mouse(global_position)
	var spawn_pos = SPRAYER_SPAWN_POSITIONS[Utilities.get_direction_from_rotation(rot)]
	instance.spawnPosition = global_position + spawn_pos + (character.velocity * 0.02)
	instance.spawnRotation = rot
	instance.speed = projectile_speed
	
	var rot_since_last_shot = rot - last_shot_rotation

	var vfx: Sprite2D = instance.get_node("VFX")
	# Each instance needs its own material; otherwise shader params (e.g. mist_strength) change all projectiles
	if vfx.material:
		vfx.material = vfx.material.duplicate()

	var rotation_effect = 3.2; # Realistic stream of water sort of follows itself...
	vfx.rotation = - rot_since_last_shot * rotation_effect

	# Larger rotation change = larger scale so projectiles bridge the gap and look connected
	var x_angle_effect = 0.3; # Angle at which the x scale forumula starts to take effect
	var new_scale_x = clamp(
		(MIN_SCALE_X / x_angle_effect) * abs(rot_since_last_shot) + MIN_SCALE_X,
		MIN_SCALE_X,
		MAX_SCALE_X
	)
	var y_angle_effect = 0.3; # Angle at which the y scale forumula starts to take effect
	var new_scale_y = clamp(
		(MIN_SCALE_Y / y_angle_effect) * abs(rot_since_last_shot) + MIN_SCALE_Y,
		MIN_SCALE_Y,
		MAX_SCALE_Y
	)
	vfx.scale.x = new_scale_x
	vfx.scale.y = new_scale_y

	# we also should reduce the mist strength based on the rotation change
	var mist_angle_effect = 0.9; # Angle at which the mist strength forumula starts to take effect
	var new_mist_strength = clamp(mist_angle_effect + abs(rot_since_last_shot), MIN_MIST_STRENGTH, MAX_MIST_STRENGTH)

	# print_text("rot since last shot: " + str(rot_since_last_shot)
	# 	+ " \nscale x: " + str(new_scale_x)
	# 	+ " \nscale y: " + str(new_scale_y)
	# 	+ " \nmist strength: "+ str(new_mist_strength))
	vfx.set_mist_strength(new_mist_strength)

	# Add to scene root so projectile is NOT a child of the character (won't move with mouse/character)
	get_tree().current_scene.add_child(instance)
	
	last_shot_rotation = rot
	
func print_text(text: String) -> void:
	debug_label.text = text
