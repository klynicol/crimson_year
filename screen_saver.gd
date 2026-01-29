"""
Mini screensaver by Klynicol to test the HTML deployment.

To be deleted on the 29th of January 2026.
"""

extends Node2D

const CHARACTER_SCENE = preload("res://Characters.tscn")
const NUMBER_OF_FRAMES = 15
const SPRITE_SIZE = Vector2(133, 177)
const CHARACTER_SPEED = 123;

var characters: Dictionary
var upper_bounds: Vector2

func _ready() -> void:
	var viewport_size = get_viewport_rect().size	
	upper_bounds = Vector2(
		viewport_size.x / 2 - SPRITE_SIZE.x / 2,
		viewport_size.y / 2 - SPRITE_SIZE.y / 2
	)
	
	for i in range(NUMBER_OF_FRAMES):
		var character_instance = CHARACTER_SCENE.instantiate()

		var animated_sprite = character_instance.get_node("AnimatedSprite2D")
		animated_sprite.frame = i
		animated_sprite.animation = "default"

		character_instance.position = Vector2(
			randf_range(-upper_bounds.x, upper_bounds.x),
			randf_range(-upper_bounds.y, upper_bounds.y)
		)

		# choose between -1 or 1 for the velocity
		var velocity_x = -1 if randf() < 0.5 else 1
		var velocity_y = -1 if randf() < 0.5 else 1

		add_child(character_instance)
		characters[i] = {
			"instance" : character_instance,
			"movement_vector" : Vector2(velocity_x, velocity_y)
		}

func _process(delta: float) -> void:
	
	# Bounce off the edges of the screen
	for i in characters:
		var character = characters[i]

		var curX = character["instance"].position.x
		var curY = character["instance"].position.y

		if curX <= -upper_bounds.x or curX >= upper_bounds.x:
			character["movement_vector"].x = -character["movement_vector"].x
		if curY <= -upper_bounds.y or curY >= upper_bounds.y:
			character["movement_vector"].y = -character["movement_vector"].y

		character["instance"].position = Vector2(
			curX + character["movement_vector"].x * delta * CHARACTER_SPEED, 
			curY + character["movement_vector"].y * delta * CHARACTER_SPEED
		)
