class_name StageManager extends Node

var checkpoints : Dictionary[int, Checkpoint];
var greaser_spawns: Array[Node];
const START_CHECKPOINT_ID: int = 5;
const END_CHECKPOINT_ID: int = 0;

var world: World;
var game: Game;

var should_process_wave: bool = false;
var current_wave: int = 1;
var wave_mob_fragments: int = 0;
var car_spawn_index: int = 0;
var cars: Array[Car] = [];
var wave_cars_destroyed: int = 0;

const CAR_SPAWN_COOLDOWN: float = 11.0;

var enemy_spawn_cooldown: float = 0.0;
var boss_spawn_cooldown: float = 0.0;
var car_spawn_cooldown: float = 0.0;

@onready var label = get_tree().current_scene.get_node("Gui/Control/Label")

const WAVES_CONFIG = {
	1: {
		"cars": [Car.CarType.CHEVY_BEL_AIR, Car.CarType.CADILLAC_DEVILLE],
		# "enemies": [Mob.MobType.LIZARD],
		"enemies": [Mob.MobType.LIZARD, Mob.MobType.TOAD],
		"boss": null,
		"enemy_max_qty" :60,
		"enemy_spawn_cooldown" : 1.0,
		"boss_spawn_cooldown" : 1.0,
	},
	2: {
		"cars": [Car.CarType.CHEVY_BEL_AIR, Car.CarType.CADILLAC_DEVILLE],
		"enemies": [Mob.MobType.LIZARD, Mob.MobType.TOAD],
		"boss": null,
		"enemy_max_qty" : 120,
		"enemy_spawn_cooldown" : 0.5,
		"boss_spawn_cooldown" : 0.5,
	},
	3: {
		"cars": [Car.CarType.CHEVY_BEL_AIR, Car.CarType.CADILLAC_DEVILLE],
		"enemies": [Mob.MobType.LIZARD, Mob.MobType.TOAD],
		"boss": null,
		"enemy_max_qty" : 180,
		"enemy_spawn_cooldown" : 0.1,
		"boss_spawn_cooldown" : 0.1,
	},
}

func _ready() -> void:
	call_deferred("_set_instances")
	#call_deferred("_init_wave", 1) # Will be triggered by the menu

func _process(delta: float):
	if not should_process_wave:
		label.text = "....."
		return
	_process_wave(delta)
	label.text = "wave: " + str(current_wave)

func _set_instances():
	for checkpoint in get_tree().get_nodes_in_group("checkpoint"):
		checkpoints[checkpoint.id] = checkpoint
		checkpoint.checkpoint_reached.connect(_on_checkpoint_reached)
	world = get_tree().current_scene.get_node("/root/Game/World");
	game = get_tree().current_scene.get_node("/root/Game");
	greaser_spawns = get_tree().get_nodes_in_group("greaser_spawn");

# Basically resets the wave variables and prepares the world for the next wave
func init_wave(wave_number: int):
	should_process_wave = true;
	print("init_wave: ", wave_number)
	current_wave = wave_number;
	game.life_time_mob_fragments += wave_mob_fragments;
	wave_mob_fragments = 0;
	cars = [];
	car_spawn_index = 0;
	world.prepare_for_wave();

func _process_wave(delta: float):
	_spawn_cars(delta)
	_spawn_enemies(delta)

func _check_wave_end():
	# Don't count cars that are queued for deletion (queue_free runs at end of frame)
	var cars: Array[Node] = get_tree().get_nodes_in_group("cars")
	cars = cars.filter(func(c): return not c.is_queued_for_deletion())
	if cars.size() == 0:
		_end_current_wave()

func _end_current_wave():
	# Pause wave logic and show "Next Stage" prompt
	game.show_next_stage_prompt()
	should_process_wave = false;

func _spawn_enemies(delta: float):
	_spawn_greasers(delta)
	_spawn_boss(delta)

func _spawn_greasers(delta: float):
	if enemy_spawn_cooldown > 0.0:
		enemy_spawn_cooldown -= delta
		return
	var gresers := get_tree().get_nodes_in_group("greasers")
	if gresers.size() >= WAVES_CONFIG[current_wave]["enemy_max_qty"]:
		return
	# Spawn a greaser at a random spawn location
	var cars: Array[Node] = get_tree().get_nodes_in_group("cars")
	if cars.size() == 0:
		return;
	var random_spawn := _get_random_mob_spawn(cars);
	var random_enemy_index: int = randi() % WAVES_CONFIG[current_wave]["enemies"].size();
	var greaser_type: GreaserSpawn.GreaserType = WAVES_CONFIG[current_wave]["enemies"][random_enemy_index];
	var greaser: Mob = random_spawn.spawn_greaser(greaser_type);
	greaser.stats.mob_died.connect(_on_mob_died)
	enemy_spawn_cooldown = WAVES_CONFIG[current_wave]["enemy_spawn_cooldown"];

func _spawn_cars(delta: float):
	if car_spawn_cooldown > 0.0:
		car_spawn_cooldown -= delta
		return
	if not WAVES_CONFIG[current_wave]["cars"].has(car_spawn_index):
		# Ran out of cars to spawn
		return
	# var start_checkpoint := checkpoints[1]
	var start_checkpoint := checkpoints[START_CHECKPOINT_ID]

	var car_type: Car.CarType = WAVES_CONFIG[current_wave]["cars"][car_spawn_index];
	var car := start_checkpoint.spawn_car(
		car_type,
		checkpoints[END_CHECKPOINT_ID].global_position
	)
	print("spawned car: ", car.car_type)
	car_spawn_index += 1
	car.car_died.connect(_on_car_died)
	car_spawn_cooldown = CAR_SPAWN_COOLDOWN;

func _spawn_boss(delta: float):
	if boss_spawn_cooldown > 0.0:
		boss_spawn_cooldown -= delta
		return
	if not WAVES_CONFIG[current_wave]["boss"]:
		return
	boss_spawn_cooldown = WAVES_CONFIG[current_wave]["boss_spawn_cooldown"];
	
# !!! -- SIGNAL LISTENERS -- !!!

# If all active cars have reached the end checkpoint, end the wave
func _on_checkpoint_reached(checkpoint_id: int, body: Node2D):
	if checkpoint_id != END_CHECKPOINT_ID:
		return
	if not (body is Car):
		return
	body.queue_free()
	call_deferred("_check_wave_end")

func _on_mob_died():
	wave_mob_fragments += 1

func _on_car_died(car: Car):
	wave_cars_destroyed += 1

# Called when the player clicks "Next Stage" in the GUI
func start_next_wave() -> void:
	var next_wave: int = current_wave + 1
	if not WAVES_CONFIG.has(next_wave):
		# No more waves (e.g. after wave 3) – could show victory or loop
		next_wave = 1
	init_wave(next_wave)

# !!! -- HELPERS -- !!!

func _get_random_mob_spawn(cars: Array[Node]) -> GreaserSpawn:
	# First we need to find the cars and find the avarage position of the cars
	# Then make a radius around the average position nd spawn the greasers randomly within that radius
	var average_car_position: Vector2 = _get_average_car_position(cars);

	var search_radius: float = 1570.0;
	var available_greaser_spawns: Array[GreaserSpawn] = [];
	for greaser_spawn in greaser_spawns:
		if greaser_spawn.global_position.distance_to(average_car_position) < search_radius:
			available_greaser_spawns.append(greaser_spawn);
	return available_greaser_spawns[randi() % available_greaser_spawns.size()];

# Helper function to get the average position of the cars
func _get_average_car_position(cars: Array[Node]) -> Vector2:
	var average_position = Vector2.ZERO
	for car in cars:
		average_position += car.global_position
	average_position /= cars.size()
	return average_position
