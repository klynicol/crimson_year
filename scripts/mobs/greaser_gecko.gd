class_name GreaserGecko extends Mob

@onready var projectile_emitter: Marker2D = $ProjectileEmitter
const PROJECTILE_SCENE: PackedScene = preload("uid://ddqeip5vg2qsl")

func _ready():
	mob_type = Mob.MobType.GECKO
	super._ready()

func _shoot_projectile(target_pos: Vector2) -> void:
	print("shooting projectile: ", physics_id)
	target_pos += Vector2(40, 0) #account for car movement
	var projectile = PROJECTILE_SCENE.instantiate()
	projectile.global_position = projectile_emitter.global_position
	projectile.dir = global_position.angle_to_point(target_pos)
	World.ySort.add_child(projectile)
