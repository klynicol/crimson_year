class_name Enemies extends CharacterBody2D

enum MobState {
	WALKING,
	ATTACKING,
	HURT,
	DYING,
	IDLE,
}

# Allows for a slight buffer when chasing a car so that we don't get stuck chasing the car and jitter around
const ATTACK_RANGE_BUFFER: float = 80

@export var stats: MobStats
@export var sprite: AnimatedSprite2D
@export var hit_box: Area2D

# please use the lifebar scene for this one, it includes a script and a timer to fade back out after a couple of seconds.
@export var lifebar: ProgressBar

var mob_state: MobState = MobState.IDLE
var player: CharacterBody2D
# One hit per attack animation; cleared when we leave the attack frame
var _attack_hit_this_cycle: bool = false
var damage_knockback_direction: Vector2 = Vector2.ZERO
var damage_knockback_cooldown: float = 0.0
var dying_cooldown: float = 0.0
var attack_cooldown_time: float = 0.0

var on_conveyor: bool = false
var enemy_uses_conveyor: bool = true
var finished_attack_animation: bool = false

# temp for debugging
var physics_id: String
var last_animation: String = ""
var action_cooldown: float = 0.0
const ACTION_COOLDOWN: float = 0.7
var last_state: MobState = MobState.IDLE

func _ready():
	# Each mob needs its own stats copy; the scene's SubResource is shared by all instances
	stats = stats.duplicate()
	call_deferred("_set_player")
	hit_box.area_shape_entered.connect(_on_hit_box_entered)
	stats.mob_died.connect(_on_mob_died)
	attack_cooldown_time = 0
	lifebar.max_value = stats.max_health
	lifebar.value = stats.health

func _set_player():
	player = get_tree().get_first_node_in_group("player")

func _decelerate_to_zero_velocity(delta: float) -> void:
	var vector_x: float = Car.CAR_SPEED if on_conveyor else 0.0
	velocity.x = vector_x
	velocity = velocity.move_toward(Vector2(vector_x, 0), stats.decel * delta)

func _physics_process(delta: float) -> void:
	physics_id = str(randi() % 10000)
	if not player:
		return
	if Game.paused:
		sprite.pause()
		return
	sprite.play()
	_check_on_conveyor()
	_check_state(delta)
	last_state = mob_state
	_set_sprite_animation()
	move_and_slide()
	_print_animation_change()
	_print_state_change()


func _set_sprite_animation() -> void:
	match mob_state:
		MobState.WALKING:
			sprite.play("walk")
		MobState.ATTACKING:
			if _should_play_attack_animation():
				sprite.play("attack")
			else:
				sprite.play("idle")
		MobState.HURT:
			sprite.play("hurt")
		MobState.DYING:
			sprite.play("dying")
		MobState.IDLE:
			sprite.play("idle")

func _print_animation_change() -> void:
	if last_animation != sprite.animation:
		print("animation changed from ", last_animation, " to ", sprite.animation, " ", physics_id, " state ", mob_state)
	last_animation = sprite.animation

func _print_state_change() -> void:
	if last_state != mob_state:
		print("state changed from ", last_state, " to ", mob_state, " ", physics_id)
	last_state = mob_state

# If we're attacking, we should wait for the animation to finish before doing anything else
func _should_play_attack_animation() -> bool:
	if attack_cooldown_time <= 0:
		finished_attack_animation = true
		return true
	if not finished_attack_animation:
		return false
	var frame_count: int = sprite.sprite_frames.get_frame_count("attack")
	var last_frame: int = frame_count - 1
	if sprite.frame == last_frame and sprite.frame_progress > 0.5:
		finished_attack_animation = false
	return true

# Check things in order of priority
func _check_state(delta: float) -> void:
	pass

func _handle_mob_hurt(delta: float) -> void:
	damage_knockback_cooldown -= delta
	if damage_knockback_cooldown <= 0.0:
		mob_state = MobState.IDLE
		return
	velocity = damage_knockback_direction * stats.knockback_speed
	sprite.flip_h = velocity.x > 0

func _handle_mob_dying(delta: float) -> void:
	_apply_standard_conveyor_movement()
	if dying_cooldown > 0.0:
		dying_cooldown -= delta
		return
	queue_free()

func _handle_walking(delta: float) -> void:
	mob_state = MobState.WALKING
	action_cooldown = ACTION_COOLDOWN
	var closest_car: CharacterBody2D = get_closest_car()
	if closest_car:
		"""
		add a slight buffer to the displacement vector so that we don't get stuck chasing the car and jitter around
		the buffer distance is the RANGED_BUFFER_DISTANCE but we need to modify it in a Vector2 direction
		to match the direction of the vector to the car
		"""
		var chase_target: Vector2 = closest_car.global_position
		# if stats.attack_range > 0:
		# 	var vector_to_car: Vector2 = closest_car.global_position - global_position
		# 	var direction: Vector2 = vector_to_car.normalized()
		# 	var buffer_vector: Vector2 = direction * RANGED_BUFFER_DISTANCE
		# 	print("buffer_vector: ", buffer_vector)
		# 	chase_target = closest_car.global_position + buffer_vector
		# Leave it up to chase to handle the conveyor movement if they need
		chase(chase_target, delta)
		return
	_apply_standard_conveyor_movement()
	mob_state = MobState.IDLE

func _on_mob_died() -> void:
	mob_state = MobState.DYING

func _on_hit_box_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name != "WaterDamage":
		return
	mob_state = MobState.HURT
	damage_knockback_direction = (global_position - player.global_position).normalized()
	damage_knockback_cooldown = 0.5
	# need to get the parent of the area and then get the stats from the parent
	var water_spray_projectile = area.get_parent()
	var damage: float = water_spray_projectile.get_damage_and_increment_reflect()
	if damage > 0:
		stats.take_water_damage(damage)
		_flash_lifebar()

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


func _check_on_conveyor() -> void:
	if global_position.y < World.conveyor_y_max and global_position.y > World.conveyor_y_min:
		on_conveyor = true

func _apply_standard_conveyor_movement() -> void:
	if on_conveyor and enemy_uses_conveyor:
		velocity.x = Car.CAR_SPEED
		velocity.y = 0

# Standard chase function for all enemies
func chase(target_pos: Vector2, delta: float) -> void:
	var displacement: Vector2 = target_pos - global_position
	var move_vector: Vector2 = displacement.normalized() * stats.speed
	var vector_x: float = Car.CAR_SPEED if on_conveyor else 0.0
	move_vector.x += vector_x
	velocity = velocity.move_toward(move_vector, stats.accel * delta)
	sprite.flip_h = velocity.x - vector_x >= 0

	
func _flash_lifebar() -> void:
	lifebar.set_health_value(stats.health)
