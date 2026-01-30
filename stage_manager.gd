extends Node

@onready var checkpoints : Array
@onready var car: CharacterBody2D = %Car
@onready var car_speed := 500.0
var target_checkpoint := 1
@onready var target_destination : Vector2 = get_node("Checkpoint_" + str(target_checkpoint)).position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# this loop gets an array of all of the checkpoints in the stage
	for child in get_children():
		if child.is_in_group("checkpoint"):
			checkpoints.append(child)
	
	# this loop connects every member of the checkpoints array to the checkpoint_reached function in this script
	for target in checkpoints:
		target.body_entered.connect(checkpoint_reached)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var pathfinding_vector := target_destination - car.position
	car.position += pathfinding_vector/700.0

func checkpoint_reached() -> void:
	target_checkpoint += 1
	print("ding!")
