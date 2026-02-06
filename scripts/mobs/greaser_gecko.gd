class_name GreaserGecko extends Mob

@onready var projectile_emitter: Marker2D = $ProjectileEmitter
const PROJECTILE_SCENE: PackedScene = preload("uid://ddqeip5vg2qsl")

func _ready():
	mob_type = Mob.MobType.GECKO
	super._ready()

func _shoot_projectile(target_pos: Vector2) -> void:
	target_pos += Vector2(150, 0) #account for car movement
	var projectile = PROJECTILE_SCENE.instantiate()
	var pos_y = projectile_emitter.global_position.y
	var pos_x = projectile_emitter.global_position.x
	if sprite.flip_h:
		pos_x += projectile_emitter.position.x * -2
	projectile.global_position = Vector2(pos_x, pos_y)
	projectile.dir = global_position.angle_to_point(target_pos)
	projectile.damage = stats.damage
	World.ySort.add_child(projectile)

func _handle_attack(bodies_in_range: Array[CharacterBody2D], delta: float) -> void:
	# add on to flip sprite during attack phase
	if bodies_in_range.size() > 0 and bodies_in_range[0].global_position.x > global_position.x:
		sprite.flip_h = true
	super._handle_attack(bodies_in_range, delta)
