extends Node2D  # or CharacterBody2D, etc.

@onready var sprite: Sprite2D = $Sprite2D

# func _physics_process(_delta: float) -> void:
	# Keep sprite visually aligned with floor perspective
	# position.x = Perspective.get_x_offset(global_position)
