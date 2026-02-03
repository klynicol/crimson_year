class_name World extends Node2D

const MAX_GREASERS: int = 60
const SPAWN_COOLDOWN: float = 1.0
const PLAYER_START_POSITION: Vector2 = Vector2(-5797, 593)

static var player_instance: CharacterBody2D
static var ground: TileMapLayer
static var walls: TileMapLayer
static var ySort: Node2D

# Find all the "GreaserSpawn" nodes and get their global position
var greaser_spawns: Array[Node] = []
var time_since_last_spawn: float = 0.0

var mob_fragments: int = 0

func _ready():
	ground = get_node("Ground")
	walls = get_node("Walls")
	_set_instances()  # Run immediately so player_instance is ready before StageManager._init_wave

func _set_instances():
	greaser_spawns = get_tree().get_nodes_in_group("greaser_spawn")
	player_instance = get_tree().get_first_node_in_group("player")
	ySort = get_node("/root/Game/World/YSort")

func prepare_for_wave():
	player_instance.global_position = PLAYER_START_POSITION
	# Clear all the greasers
	for greaser in get_tree().get_nodes_in_group("greasers"):
		greaser.queue_free()
	# Clear all the cars
	for car in get_tree().get_nodes_in_group("cars"):
		car.queue_free()
