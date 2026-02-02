class_name World extends Node2D

const MAX_GREASERS: int = 60
const SPAWN_COOLDOWN: float = 1.0

enum MobType {
	LIZARD,
	TOAD
}

@onready var debug_label: Label = get_tree().current_scene.get_node("Gui/Control/Label")

static var player_instance: CharacterBody2D
static var ground: TileMapLayer
static var walls: TileMapLayer

# Find all the "GreaserSpawn" nodes and get their global position
var greaser_spawns: Array[Node] = []
var time_since_last_spawn: float = 0.0

var mob_fragments: int = 0

func _ready():
	ground = get_node("Ground")
	walls = get_node("Walls")
	call_deferred("_set_instances")

func _set_instances():
	greaser_spawns = get_tree().get_nodes_in_group("greaser_spawn")
	player_instance = get_tree().get_first_node_in_group("player")

func _process(delta: float):
	label_debug_info()
	var greasers := get_tree().get_nodes_in_group("greaser")
	if greasers.size() < MAX_GREASERS and time_since_last_spawn > SPAWN_COOLDOWN:
		_spawn_greaser()
		time_since_last_spawn = 0.0
	for greaser in greasers:
		# if not connected to the mob_died signal, connect it
		if not greaser.stats.mob_died.is_connected(_on_mob_died):
			greaser.stats.mob_died.connect(_on_mob_died)
	time_since_last_spawn += delta
	
# Spawn a greaser at a random greaser spawn
func _spawn_greaser():
	var random_spawn := greaser_spawns[randi() % greaser_spawns.size()]
	random_spawn.spawn_greaser()

func label_debug_info():
	var greasers := get_tree().get_nodes_in_group("greaser")
	debug_label.text = "Current Greasers: " + str(greasers.size()) + \
		"\nFrags: " + str(mob_fragments)

func _on_mob_died():
	mob_fragments += 1
