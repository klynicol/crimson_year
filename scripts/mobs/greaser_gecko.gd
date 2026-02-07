class_name GreaserGecko extends Mob

@onready var projectile_emitter: Marker2D = $ProjectileEmitter
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
const PROJECTILE_SCENE: PackedScene = preload("uid://ddqeip5vg2qsl")


var spawn_sfx:= [
	preload("uid://scsiu7fl126"),
	preload("uid://cjxgxikc0w3ej"),
	preload("uid://clea0p7johlni"),
	preload("uid://cflg2ph6g7dw4"),
]
var attack_sfx:= preload("uid://c45u8hwdfboor")

func _ready():
	mob_type = Mob.MobType.GECKO
	super._ready()
	if roll_for_oneliner() == true:
		audio_stream_player_2d.stream = spawn_sfx.pick_random()
		audio_stream_player_2d.play()

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
	audio_stream_player_2d.stream = attack_sfx
	audio_stream_player_2d.play()

func _handle_attack(bodies_in_range: Array[CharacterBody2D], delta: float) -> void:
	# add on to flip sprite during attack phase
	if bodies_in_range.size() > 0 and bodies_in_range[0].global_position.x > global_position.x:
		sprite.flip_h = true
	super._handle_attack(bodies_in_range, delta)
	
func roll_for_oneliner() -> bool:
	var roll = [1, 2].pick_random()
	if roll == 2:
		return true
	else:
		return false
