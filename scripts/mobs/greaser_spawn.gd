extends Node2D

@export var greaser: PackedScene = preload("res://scenes/mobs/greaser_lizard.tscn")

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	# Hide the sprite 
	sprite.visible = false

func spawn_greaser():
	var greaser_instance = greaser.instantiate()
	greaser_instance.global_position = global_position
	greaser_instance.add_to_group("greaser")
	get_parent().call_deferred("add_child", greaser_instance)
