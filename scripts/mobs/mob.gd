class_name Mob extends CharacterBody2D

enum MobType {
	LIZARD,
	TOAD,
	GECKO,
}

enum MobState {
	WALKING, 
	ATTACKING,
	HURT,
	DYING,
	IDLE,
}

@export var stats: MobStats
@export var sprite: AnimatedSprite2D
@export var ray_cast: RayCast2D
@export var hit_box: Area2D
@export var attack_box: Area2D
@export var attack_frame: int

var mob_state: MobState = MobState.IDLE
var last_mob_state: MobState = MobState.IDLE
var mob_type: Mob.MobType
var player: CharacterBody2D
# Once hit, the mob will chase the player for a period of time
var has_been_hit: bool = false
# One hit per attack animation; cleared when we leave the attack frame
var _attack_hit_this_cycle: bool = false
var damage_knockback_direction: Vector2 = Vector2.ZERO
var damage_knockback_cooldown: float = 0.0
var dying_cooldown: float = 0.0

func _ready():
	# Each mob needs its own stats copy; the scene's SubResource is shared by all instances
	stats = stats.duplicate()
	call_deferred("_set_player")
	hit_box.area_shape_entered.connect(_on_hit_box_entered)
	stats.mob_died.connect(_on_mob_died)
	print("state: ", mob_state)

func _set_player():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not player:
		return
	if last_mob_state != mob_state:
		print("mob_state: ", mob_state)
		last_mob_state = mob_state
	_check_state(delta)
	# after state changes, set the sprite animation
	_set_sprite_animation()

func _set_sprite_animation() -> void:
	match mob_state:
		MobState.WALKING:
			sprite.play("walk")
		MobState.ATTACKING:
			sprite.play("attack")
		MobState.HURT:
			sprite.play("hurt")
		MobState.DYING:
			sprite.play("dying")
		MobState.IDLE:
			sprite.play("idle")

# Check things in order of priority
func _check_state(delta: float) -> void:
	if mob_state == MobState.DYING:
		_handle_mob_dying(delta)
		return
	if mob_state == MobState.HURT:
		_handle_mob_hurt(delta)
		return
	var bodies_in_range: Array[CharacterBody2D] = _get_bodies_in_range()
	if bodies_in_range.size() > 0:
		_handle_attack(bodies_in_range)
		return
	_find_and_chase_target(delta)

func _get_bodies_in_range() -> Array[CharacterBody2D]:
	var bodies: Array[CharacterBody2D] = []
	for body in attack_box.get_overlapping_bodies():
		if body is not Car:
			continue
		bodies.append(body)
	return bodies

func _handle_mob_hurt(delta: float) -> void:
	damage_knockback_cooldown -= delta
	if damage_knockback_cooldown <= 0.0:
		mob_state = MobState.IDLE
		return
	velocity = damage_knockback_direction * stats.knockback_speed
	move_and_slide()

func _handle_mob_dying(delta: float) -> void:
	if dying_cooldown > 0.0:
		dying_cooldown -= delta
		return
	queue_free()

# Checks if the attack aligns with the sprite frame and if bodies are in range, then performs the attack
func _handle_attack(bodies_in_range: Array[CharacterBody2D]) -> void:
	mob_state = MobState.ATTACKING
	if not _attack_alligns_with_sprite_frame():
		return
	for body in bodies_in_range:
		body.take_damage(stats.damage)
		_attack_hit_this_cycle = true

func _find_and_chase_target(delta: float) -> void:
	var closest_car: CharacterBody2D = get_closest_car()
	if closest_car:
		mob_state = MobState.WALKING
		chase(closest_car.global_position, delta)
		return
	mob_state = MobState.IDLE

func _on_mob_died() -> void:
	mob_state = MobState.DYING


func _on_hit_box_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name != "WaterDamage":
		return
	mob_state = MobState.HURT
	damage_knockback_direction = (global_position - player.global_position).normalized()
	damage_knockback_cooldown = 0.5
	has_been_hit = true
	# need to get the parent of the area and then get the stats from the parent
	var water_spray_projectile = area.get_parent()
	var damage: float = water_spray_projectile.get_damage_and_increment_reflect()
	if damage > 0:
		stats.take_water_damage(damage)

### !!!! Helper Functions !!!! ###

# Helper function to get the closest car
func get_closest_car() -> CharacterBody2D:
	var cars = get_tree().get_nodes_in_group("cars")
	if cars.size() == 0:
		return
	var closest_car = cars[0]
	for car in cars:
		if car.global_position.distance_to(global_position) < closest_car.global_position.distance_to(global_position):
			closest_car = car
	return closest_car

	# Helper function to check if the attack aligns with the sprite frame
func _attack_alligns_with_sprite_frame() -> bool:
	if sprite.frame != attack_frame:
		_attack_hit_this_cycle = false
		return false
	if _attack_hit_this_cycle:
		return false
	return true	

	# override
func chase(target_pos: Vector2, delta: float) -> void:
	if sprite:
		sprite.flip_h = velocity.x > 0

func look_for_player(delta: float) -> void:
	pass
