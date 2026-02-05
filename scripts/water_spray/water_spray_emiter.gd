extends Node2D

@onready var projectile = load("res://scenes/water_spray_projectile.tscn")
@onready var character: CharacterBody2D = get_parent()
@onready var sprayer: Sprite2D = $"../Sprayer"
@onready var emit_point: Marker2D = $"../Sprayer/EmitPoint"
@onready var debug_label: Label = get_tree().current_scene.get_node_or_null("Gui/Control/Label")
@onready var player_sprite: AnimatedSprite2D = $"../AnimatedSprite2D"
@export var projectile_speed = 400

const MAX_SCALE_X = 9.0
const MIN_SCALE_X = 3.5
const MAX_SCALE_Y = 12.0
const MIN_SCALE_Y = 2.5
const MIN_MIST_STRENGTH = 0.9
const MAX_MIST_STRENGTH = 3.0

const ANIM_SPRAYER_ORIGIN = {
	"left_walking": [Vector2(-30, -40), Vector2(-40, -50)],
	"left_idle_shooting": Vector2(1, -40),
	"left_dash": Vector2(0, -32),
}

var cooldown = 0.0
var cooldown_time: float

var last_shot_rotation: float = 0.0

func _ready() -> void:
	# Each projectile is 20pixels wide
	# based on the projectile speed, we can calculate the cooldown time
	cooldown_time = 46.0 / projectile_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed('fire'):
		sprayer.visible = true
		if cooldown <= 0.0:
			sprayer.visible = true
			shoot()
			cooldown = cooldown_time
	else:
		sprayer.visible = false
	cooldown -= delta

func shoot() -> void:
	# Spawn at the tip of the sprayer sprite (end of barrel)
	# var tip_offset := sprayer.global_transform.x * (sprayer.texture.get_width() / 2.0)
	# var spawn_pos := sprayer.global_position + tip_offset
	# var rot := sprayer.global_rotation + PI / 2
	var instance := projectile.instantiate() as CharacterBody2D

	var rot := Utilities.get_rotation_of_aim(character, global_position)
	#rotate the sprayer sprite to the direction of the shot
	sprayer.rotation = rot + PI

	## Get the position of the sprayer based on sprite and frame
	var origin_definition
	if player_sprite.animation in ANIM_SPRAYER_ORIGIN:
		origin_definition = ANIM_SPRAYER_ORIGIN[player_sprite.animation]
	else:
		origin_definition = Vector2(0, 0)

	var y_offset = 11.2 # because of sprayer flip, we need to offset the position
	if origin_definition is Array:
		# left_walking: interpolate from index 0 (frame 0) to index 1 (frame 3)
		var start_vector = origin_definition[0]
		var end_vector = origin_definition[1]
		if player_sprite.flip_h:
			start_vector.x = -start_vector.x
			end_vector.x = -end_vector.x
			start_vector.y -= y_offset
			end_vector.y -= y_offset
		var frame_count := 3
		var t := clampf(float(player_sprite.frame) / float(frame_count), 0.0, 1.0)
		print("t: ", t)
		sprayer.position = start_vector.lerp(end_vector, t)
	else:
		if player_sprite.flip_h:
			origin_definition.x = -origin_definition.x
			origin_definition.y -= y_offset
		sprayer.position = origin_definition

	# flip the sprite if the player is facing left
	if player_sprite.flip_h:
		sprayer.flip_v = true
	else:
		sprayer.flip_v = false


	instance.spawnPosition = emit_point.global_position + (character.velocity * 0.02)
	instance.spawnRotation = rot
	instance.speed = projectile_speed
	
	var rot_since_last_shot := rot - last_shot_rotation

	var vfx: Sprite2D = instance.get_node("VFX")

	var rotation_effect := 3.2; # Realistic stream of water sort of follows itself...
	vfx.rotation = - rot_since_last_shot * rotation_effect

	# Larger rotation change = larger scale so projectiles bridge the gap and look connected
	var x_angle_effect := 0.3; # Angle at which the x scale forumula starts to take effect
	var new_scale_x = clamp(
		(MIN_SCALE_X / x_angle_effect) * abs(rot_since_last_shot) + MIN_SCALE_X,
		MIN_SCALE_X,
		MAX_SCALE_X
	)
	var y_angle_effect := 0.3; # Angle at which the y scale forumula starts to take effect
	var new_scale_y = clamp(
		(MIN_SCALE_Y / y_angle_effect) * abs(rot_since_last_shot) + MIN_SCALE_Y,
		MIN_SCALE_Y,
		MAX_SCALE_Y
	)
	vfx.scale.x = new_scale_x
	vfx.scale.y = new_scale_y
	# we also should reduce the mist strength based on the rotation change
	var mist_angle_effect := 0.9; # Angle at which the mist strength forumula starts to take effect
	var new_mist_strength: float = clamp(mist_angle_effect + abs(rot_since_last_shot), MIN_MIST_STRENGTH, MAX_MIST_STRENGTH)
	vfx.set_mist_strength(new_mist_strength)
	get_tree().current_scene.add_child(instance)
	
	last_shot_rotation = rot
