class_name StageManager extends Node

const CAR_SEPARATOR_DISTANCE: float = 100.0
const CAR_SCENE: PackedScene = preload("uid://duee4wsbvb3xl")

@onready var checkpoints : Dictionary[int, Checkpoint]

func _ready() -> void:
	for checkpoint in get_tree().get_nodes_in_group("checkpoint"):
		# Get the number at the end of the checkpoint name
		checkpoints[checkpoint.id] = checkpoint

	# 
				  
