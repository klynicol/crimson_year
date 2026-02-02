class_name Mob extends CharacterBody2D

@export var stats: MobStats
@export var sprite: AnimatedSprite2D
@export var ray_cast: RayCast2D
@export var hit_box: Area2D

var is_chasing: bool = false

var mob_type: World.MobType

var player: CharacterBody2D

func _ready():
	# Each mob needs its own stats copy; the scene's SubResource is shared by all instances
	stats = stats.duplicate()
	call_deferred("_set_player")
	# hook up the hitbox _on_body_entered signal
	hit_box.area_shape_entered.connect(_on_hit_box_entered)
	stats.mob_died.connect(_on_mob_died)
	# super._ready()

func _set_player():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not player:
		return
	# spin_raycast(delta)
	chase(player.global_position, delta) # just chase the player for now

func _on_mob_died() -> void:
	queue_free()

func _on_hit_box_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name != "WaterDamage":
		return
	# need to get the parent of the area and then get the stats from the parent
	var water_spray_projectile = area.get_parent()
	var damage: float = water_spray_projectile.get_damage_and_increment_reflect()
	if damage > 0:
		stats.take_water_damage(damage)

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
