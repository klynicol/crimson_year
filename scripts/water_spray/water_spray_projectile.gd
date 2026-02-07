extends CharacterBody2D

var spawnPosition: Vector2
var spawnRotation: float
var speed: float
var time_alive: float = 0.0
var damage: float = 10.0

# The number of times a projectile can deal damage to a mob before it despawns
const MAX_DAMAGE_REFLECTIONS = 2
var damage_reflections: int = 0

const MAX_TIME_ALIVE = 0.55

const MAX_SCALE_X = 9.0
const MAX_SCALE_Y = 18.0
const SCALE_DECAY_RATE = 22
const MIST_STRENGTH_DECAY_RATE = 1.8
const DAMAGE_DECAY_RATE = 9.0
const COLLISION_BOX_SIZE_DECAY_RATE = 15.0

@onready var vfxSprite = $VFX
@onready var pushback_collision_shape = $Pushback
@onready var damage_collision_shape = $WaterDamage/CollisionShape2D

func _ready() -> void:
	global_position = spawnPosition
	global_rotation = spawnRotation
	vfxSprite.material = vfxSprite.material.duplicate()
	pushback_collision_shape.shape = pushback_collision_shape.shape.duplicate()
	damage_collision_shape.shape = damage_collision_shape.shape.duplicate()
	
func _physics_process(delta: float) -> void:
	if Game.paused:
		return
	_decay(delta)
	# atan2(y,x) uses "right" as 0°, so rotate from (speed, 0) not (0, speed)
	velocity = Vector2(speed, 0).rotated(spawnRotation)
	move_and_slide()

func _decay(delta: float) -> void:
	_despawn(delta)
	_decay_scale(delta)
	_decay_mist_strength(delta)
	_decay_damage(delta)
	_decay_collision_box_size(delta)

func get_damage_and_increment_reflect() -> float:
	damage_reflections += 1
	if damage_reflections > MAX_DAMAGE_REFLECTIONS:
		queue_free()
		return 0.0
	return damage

func _despawn(delta: float) -> void:
	time_alive += delta
	if time_alive > MAX_TIME_ALIVE:
		queue_free()

# As the projectiles moves, the scale should increase to simulate the water spreading out
# Scale the vfxsprite
func _decay_scale(delta: float) -> void:
	vfxSprite.scale.x += delta * SCALE_DECAY_RATE
	vfxSprite.scale.y += delta * SCALE_DECAY_RATE

# As the projectiles moves, the mist strength should decrease to simulate the water spreading out
func _decay_mist_strength(delta: float) -> void:
	vfxSprite.set_mist_strength(vfxSprite.get_mist_strength() + delta * MIST_STRENGTH_DECAY_RATE)

func _decay_damage(delta: float) -> void:
	damage -= delta * DAMAGE_DECAY_RATE

func _decay_collision_box_size(delta: float) -> void:
	pushback_collision_shape.shape.radius += delta * COLLISION_BOX_SIZE_DECAY_RATE
	damage_collision_shape.shape.radius += delta * COLLISION_BOX_SIZE_DECAY_RATE
