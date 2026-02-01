extends CharacterBody2D
class_name Mob

@export var stats: MobStats
@export var sprite: AnimatedSprite2D
@export var ray_cast: RayCast2D
@export var hit_box: CollisionShape2D

func _ready():
	print("mob ready")

func _physics_process(delta: float) -> void:
	look_for_player()

## Override in subclasses for mob-specific AI
func look_for_player() -> void:
	pass
