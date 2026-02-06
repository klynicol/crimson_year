class_name StageManager extends Node

var checkpoints : Dictionary[int, Checkpoint];
var greaser_spawns: Array[Node];
const START_CHECKPOINT_ID: int = 5;
const END_CHECKPOINT_ID: int = 0;
const BOSS_CHECKPOINT_ID: int = 3;
const BOSS_SPAWN_LOCATION: Vector2 = Vector2(-255, 303);

var world: World;
var game: Game;

var should_process_wave: bool = false;
var current_wave: int = 1;
var wave_mob_fragments: int = 0;
var car_spawn_index: int = 0;
var cars: Array[Car] = [];
var wave_cars_destroyed: int = 0;
var wave_boss_spawned: bool = false;
var total_spawned_enemies: int = 0;

const CAR_SPAWN_COOLDOWN: float = 11.0;

var enemy_spawn_cooldown: float = 0.0;
var car_spawn_cooldown: float = 0.0;

signal boss_spawned(boss: Node)

@onready var label = get_tree().current_scene.get_node("Gui/Control/Label")
@onready var car_tracker = get_tree().current_scene.get_node("Gui/CarTracker")
@onready var enemy_count_label = get_tree().current_scene.get_node("Gui/EnemyLeftElement/Label")

const CAR_ELEMENT = preload("uid://37hy3p7j2b7y")

const WAVES_CONFIG = {
	1: {
		"cars": [Car.CarType.CHEVY_BEL_AIR, Car.CarType.CADILLAC_DEVILLE],
		"enemies": [Mob.MobType.LIZARD, Mob.MobType.TOAD],
		"boss": null,
		"enemy_max_qty" : 50,
		"enemy_max_alive" : 10,
		"enemy_spawn_cooldown" : 1.6,
	},
	2: {
		"cars": [Car.CarType.CHEVY_BEL_AIR, Car.CarType.CADILLAC_DEVILLE],
		"enemies": [Mob.MobType.LIZARD, Mob.MobType.TOAD, Mob.MobType.GECKO],
		"boss": null,
		"enemy_max_qty" : 100,
		"enemy_max_alive" : 15,
		"enemy_spawn_cooldown" : 1.2,
	},
	3: {
		"cars": [Car.CarType.CHEVY_BEL_AIR, Car.CarType.CADILLAC_DEVILLE],
		"enemies": [Mob.MobType.LIZARD, Mob.MobType.TOAD, Mob.MobType.GECKO],
		"boss": preload("uid://bl7oj4s8kldv8"), # CarBoss
		"enemy_max_qty" : 120,
		"enemy_max_alive" : 20,
		"enemy_spawn_cooldown" : 1,
	},
}

func _ready() -> void:
	call_deferred("_set_instances")
	#call_deferred("_init_wave", 1) # Will be triggered by the menu

func _process(delta: float):
	if Game.paused:
		return
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
	total_spawned_enemies = 0;
	wave_boss_spawned = false;
	current_wave = wave_number;
	game.life_time_mob_fragments += wave_mob_fragments;
	wave_mob_fragments = 0;
	cars = [];
	car_spawn_index = 0;
	for element in car_tracker.get_children():
		element.queue_free()
	world.prepare_for_wave();

func _process_wave(delta: float):
	_spawn_cars(delta)
	_spawn_enemies(delta)
	_update_enemy_count_label()

func _update_enemy_count_label():
	var enemy_count: int = WAVES_CONFIG[current_wave]["enemy_max_qty"] - wave_mob_fragments;
	enemy_count_label.text = str(enemy_count);

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
	Game.paused = true

func _spawn_enemies(delta: float):
	_spawn_greasers(delta)

func _spawn_greasers(delta: float):
	if wave_boss_spawned:
		return
	if total_spawned_enemies >= WAVES_CONFIG[current_wave]["enemy_max_qty"]:
		return
	if enemy_spawn_cooldown > 0.0:
		enemy_spawn_cooldown -= delta
		return
	var gresers := get_tree().get_nodes_in_group("greasers")
	if gresers.size() >= WAVES_CONFIG[current_wave]["enemy_max_alive"]:
		return
	# Spawn a greaser at a random spawn location
	var cars: Array[Node] = get_tree().get_nodes_in_group("cars")
	if cars.size() == 0:
		return;
	var random_spawn := _get_random_mob_spawn(cars);
	var random_enemy_index: int = randi() % WAVES_CONFIG[current_wave]["enemies"].size();
	var greaser_type: Mob.MobType = WAVES_CONFIG[current_wave]["enemies"][random_enemy_index];
	var greaser: Mob = random_spawn.spawn_greaser(greaser_type);
	greaser.stats.mob_died.connect(_on_mob_died)
	enemy_spawn_cooldown = WAVES_CONFIG[current_wave]["enemy_spawn_cooldown"];
	total_spawned_enemies += 1;

func _spawn_cars(delta: float):
	if car_spawn_cooldown > 0.0:
		car_spawn_cooldown -= delta
		return
	if car_spawn_index >= WAVES_CONFIG[current_wave]["cars"].size():
		# Ran out of cars to spawn this wave
		return
	# var start_checkpoint := checkpoints[1]
	var start_checkpoint := checkpoints[START_CHECKPOINT_ID]

	var car_type: Car.CarType = WAVES_CONFIG[current_wave]["cars"][car_spawn_index];
	var car := start_checkpoint.spawn_car(
		car_type,
		checkpoints[END_CHECKPOINT_ID].global_position
	)
	var car_element := CAR_ELEMENT.instantiate()
	car_tracker.add_child(car_element)
	
	print("spawned car: ", car.car_type)
	car_spawn_index += 1
	car.car_died.connect(_on_car_died)
	car.car_took_damage.connect(car_element.on_car_took_damage)
	car_spawn_cooldown = CAR_SPAWN_COOLDOWN;

func _spawn_boss():
	var boss = WAVES_CONFIG[current_wave]["boss"]
	if boss == null:
		return
	var boss_instance = boss.instantiate()
	wave_boss_spawned = true;
	boss_instance.add_to_group("boss")
	World.ySort.add_child(boss_instance)
	boss_instance.global_position = BOSS_SPAWN_LOCATION;
	Game.paused = true;
	boss_spawned.emit(boss_instance);

# !!! -- SIGNAL LISTENERS -- !!!

# If all active cars have reached the end checkpoint, end the wave
func _on_checkpoint_reached(checkpoint_id: int, body: Node2D):
	if not (body is Car):
		return
	if checkpoint_id == BOSS_CHECKPOINT_ID and not wave_boss_spawned:
		_spawn_boss()
	if checkpoint_id == END_CHECKPOINT_ID:
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
