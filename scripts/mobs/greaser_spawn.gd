extends Node2D
class_name GreaserSpawn

enum GreaserType {
	LIZARD,
	TOAD
}

@onready var greaser_scenes: Dictionary[GreaserType, PackedScene] = {
	GreaserType.LIZARD: preload("uid://xriknrldek0f"),
	GreaserType.TOAD: preload("uid://dcqdtdvxviuqr")
}

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	# Hide the sprite 
	sprite.visible = false

func spawn_greaser(greaser_type: GreaserType) -> Mob:
	# pick a random greaser type
	var greaser_instance = greaser_scenes[greaser_type].instantiate()
	greaser_instance.global_position = global_position
	greaser_instance.add_to_group("greasers")
	World.ySort.add_child(greaser_instance)
	return greaser_instance
