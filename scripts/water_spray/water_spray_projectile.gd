extends CharacterBody2D

var direction_angle: float  ## Angle in radians; projectile faces this direction
var spawnPosition: Vector2
var spawnRotation: float
var speed: float
var time_alive: float = 0.0
var damage: float = 1.0

const MAX_TIME_ALIVE = 0.9

const MAX_SCALE_X = 9.0
const MAX_SCALE_Y = 18.0
const SCALE_DECAY_RATE = 22
const MIST_STRENGTH_DECAY_RATE = 1.8

@onready var vfxSprite = $VFX

func _ready() -> void:
	global_position = spawnPosition
	global_rotation = spawnRotation
	
func _physics_process(delta: float) -> void:
	velocity = Vector2(0, -speed).rotated(direction_angle)
	move_and_slide()
	_decay(delta)

func _decay(delta: float) -> void:
	_decay_scale(delta)
	_decay_mist_strength(delta)
	_despawn(delta)
	_collision(delta)

func _despawn(delta: float) -> void:
	time_alive += delta
	if time_alive > MAX_TIME_ALIVE:
		queue_free()

#In this function we'll scale the collision shape to simulate the water spreading out
# WE 
func _collision(delta: float) -> void:
	pass

# As the projectiles moves, the scale should increase to simulate the water spreading out
# Scale the vfxsprite
func _decay_scale(delta: float) -> void:
	vfxSprite.scale.x += delta * SCALE_DECAY_RATE
	vfxSprite.scale.y += delta * SCALE_DECAY_RATE

# As the projectiles moves, the mist strength should decrease to simulate the water spreading out
func _decay_mist_strength(delta: float) -> void:
	vfxSprite.set_mist_strength(vfxSprite.get_mist_strength() + delta * MIST_STRENGTH_DECAY_RATE)
