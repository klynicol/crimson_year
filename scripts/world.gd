class_name World extends Node2D

const MAX_GREASERS: int = 60
const SPAWN_COOLDOWN: float = 1.0
const PLAYER_START_POSITION: Vector2 = Vector2(-4302, 593)
const CONVEYOR_ANIMATION_SPEED: float = 62.5

static var player_instance: CharacterBody2D
static var ground: TileMapLayer
static var conveyor: TileMapLayer
# static var walls: TileMapLayer
static var ySort: Node2D

# Find all the "GreaserSpawn" nodes and get their global position
var greaser_spawns: Array[Node] = []
var time_since_last_spawn: float = 0.0

var mob_fragments: int = 0
var conveyor_buffer_bool: bool = false

@onready var conveyor_y_max_marker: Node2D = $ConveyorYMax
@onready var conveyor_y_min_marker: Node2D = $ConveyorYMin
static var conveyor_y_max: float = 0.0
static var conveyor_y_min: float = 0.0

func _ready():
	ground = get_node("Ground")
	# walls = get_node("Walls")
	_set_instances()  # Run immediately so player_instance is ready before StageManager._init_wave
	conveyor_y_max = conveyor_y_max_marker.global_position.y
	conveyor_y_min = conveyor_y_min_marker.global_position.y

func _process(delta: float):
	if Game.paused:
		_pause_conveyor()
		conveyor_buffer_bool = true
	if not Game.paused and conveyor_buffer_bool:
		_resume_conveyor()
		conveyor_buffer_bool = false

func _pause_conveyor():
	for cell in conveyor.get_used_cells():
		conveyor.set_cell(cell, 1, Vector2i.ZERO)

func _resume_conveyor():
	for cell in conveyor.get_used_cells():
		conveyor.set_cell(cell, 0, Vector2i.ZERO)

func _set_instances():
	greaser_spawns = get_tree().get_nodes_in_group("greaser_spawn")
	player_instance = get_tree().get_first_node_in_group("player")
	ySort = get_node("/root/Game/World/YSort")
	conveyor = get_node("/root/Game/World/GroundConveyor")

func prepare_for_wave():
	player_instance.global_position = PLAYER_START_POSITION
	# Clear all the greasers
	for greaser in get_tree().get_nodes_in_group("greasers"):
		greaser.queue_free()
	# Clear all the cars
	for car in get_tree().get_nodes_in_group("cars"):
		car.queue_free()
	# Clear any previous boss so the next wave gets a fresh instance
	for boss in get_tree().get_nodes_in_group("boss"):
		boss.queue_free()
 
