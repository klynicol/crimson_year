extends Node2D
class_name World

@onready var debug_label: Label = get_tree().current_scene.get_node("Gui/Control/Label")

# Find all the "GreaserSpawn" nodes and get their global position
var greaser_spawns: Array[Node] = []
var max_greasers: int = 50
var cooldown: float = 1.0
var time_since_last_spawn: float = 0.0

func _ready():
	greaser_spawns = get_tree().get_nodes_in_group("greaser_spawn")
	_spawn_greaser()

func _process(delta: float):
	var greasers = get_tree().get_nodes_in_group("greaser")
	if greasers.size() < max_greasers and time_since_last_spawn > cooldown:
		_spawn_greaser()
		time_since_last_spawn = 0.0
	time_since_last_spawn += delta
	
# Spawn a greaser at a random greaser spawn
func _spawn_greaser():
	var random_spawn = greaser_spawns[randi() % greaser_spawns.size()]
	random_spawn.spawn_greaser()
