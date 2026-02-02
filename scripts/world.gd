class_name World extends Node2D

enum MobType {
	LIZARD,
	TOAD
}

@onready var debug_label: Label = get_tree().current_scene.get_node("Gui/Control/Label")

static var player_instance: CharacterBody2D
static var ground: TileMapLayer
static var walls: TileMapLayer

# this is probably jank and bad, but this conditional stops the game from running until the menu node toggles it
var playing: bool = false

func _ready():
	ground = get_node("Ground")
	walls = get_node("Walls")
	call_deferred("_set_instances")

func _set_instances():
	greaser_spawns = get_tree().get_nodes_in_group("greaser_spawn")
	player_instance = get_tree().get_first_node_in_group("player")

# Find all the "GreaserSpawn" nodes and get their global position
var greaser_spawns: Array[Node] = []
var max_greasers: int = 50
var cooldown: float = 1.0
var time_since_last_spawn: float = 0.0

func _process(delta: float):
	if playing == true:
		print_debug_info()
		var greasers := get_tree().get_nodes_in_group("greaser")
		if greasers.size() < max_greasers and time_since_last_spawn > cooldown:
			_spawn_greaser()
			time_since_last_spawn = 0.0
		time_since_last_spawn += delta
	
# Spawn a greaser at a random greaser spawn
func _spawn_greaser():
	var random_spawn := greaser_spawns[randi() % greaser_spawns.size()]
	random_spawn.spawn_greaser()

func print_debug_info():
	var greasers := get_tree().get_nodes_in_group("greaser")
	debug_label.text = "Current Greasers: " + str(greasers.size()) + \
		"\nFrags: 0"

func unleash_player() ->void:
	get_node("Character").max_speed = 400.0
	
func _on_play_btn_button_up() -> void:
	unleash_player()
	playing = true
