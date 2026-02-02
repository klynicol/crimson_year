class_name Checkpoint extends Area2D

var id: int
@onready var sprite: Sprite2D = $Sprite2D

signal checkpoint_reached

func _ready() -> void:
	# Get the number at the end of the checkpoint name
	id = int(name.split("_")[-1])
	body_entered.connect(_on_body_entered)
	# hide the sprite
	sprite.visible = false

func _on_body_entered(body: Node2D) -> void:
	print("Checkpoint reached")
	body.set_new_target_position(global_position)
