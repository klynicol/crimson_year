extends Node2D

# Find all the "GreaserSpawn" nodes and get their global position
var greaser_spawns: Array[Node] = []

func _ready():
	greaser_spawns = get_tree().get_nodes_in_group("GreaserSpawn")
	_spawn_greaser()
	
# Spawn a greaser at a random greaser spawn
func _spawn_greaser():
	var random_spawn = greaser_spawns[randi() % greaser_spawns.size()]
	random_spawn.spawn_greaser()
