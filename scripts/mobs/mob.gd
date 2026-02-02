class_name Mob extends CharacterBody2D

@export var stats: MobStats
@export var sprite: AnimatedSprite2D
@export var ray_cast: RayCast2D
@export var hit_box: CollisionShape2D

var is_chasing: bool = false

var mob_type: World.MobType

var player: CharacterBody2D

func _ready():
	call_deferred("_set_player")

func _set_player():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not player:
		return
	# spin_raycast(delta)
	chase(player.global_position, delta) # just chase the player for now

# Let's spine the raycast around the mob to detect "things"
func spin_raycast(delta: float) -> void:
	ray_cast.rotation += delta * 10

func find_closest_car() -> CharacterBody2D:
	var cars = get_tree().get_nodes_in_group("cars")
	if cars.size() == 0:
		return
	var closest_car = cars[0]
	for car in cars:
		if car.global_position.distance_to(global_position) < closest_car.global_position.distance_to(global_position):
			closest_car = car
	return closest_car

	# override
func chase(target_pos: Vector2, delta: float) -> void:
	if sprite:
		sprite.flip_h = velocity.x > 0

func look_for_player(delta: float) -> void:
	pass
