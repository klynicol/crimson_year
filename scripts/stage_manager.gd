extends Node

@onready var checkpoints : Array
@onready var car: CharacterBody2D = %Car
@export var car_speed := 50.0
var target_checkpoint := 1: set = set_target_checkpoint
@onready var target_destination : Vector2 = get_node("Checkpoint_" + str(target_checkpoint)).position

func _ready() -> void:
	
	# this loop gets an array of all of the checkpoints in the stage
	
	for child in get_children():
		if child.is_in_group("checkpoint"):
			checkpoints.append(child)
	
	# this loop connects every member of the checkpoints array to the checkpoint_reached function in this script
	
	for target in checkpoints:
		target.body_entered.connect(func(_body): 
			target_checkpoint += 1
			print("ding!")
		)
		print("signal connected")



func _physics_process(delta: float) -> void:

	# this moves the car
	
	car.position = car.position.move_toward(target_destination, delta * car_speed)


func set_target_checkpoint(new_target_checkpoint) -> void:
	
	# this setter checks that the new checkpoint is valid
	# if so, it targets the new checkpoint
	
	if new_target_checkpoint < checkpoints.size() + 1:
		target_destination = get_node("Checkpoint_" + str(new_target_checkpoint)).position
		target_checkpoint = new_target_checkpoint
	
	# if not, it stops the car
	
	else: 
		target_destination = car.position
