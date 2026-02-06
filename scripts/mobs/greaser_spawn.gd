extends Node2D
class_name GreaserSpawn



@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	# Hide the sprite 
	sprite.visible = false

func spawn_greaser(mob_type: Mob.MobType) -> Mob:
	# pick a random greaser type
	var greaser_instance = Mob.mob_scense[mob_type].instantiate()
	greaser_instance.global_position = global_position
	greaser_instance.add_to_group("greasers")
	World.ySort.add_child(greaser_instance)
	return greaser_instance
