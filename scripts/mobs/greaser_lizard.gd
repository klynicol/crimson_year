class_name GreaserLizard extends Mob

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
var spawn_sfx := [
	preload("uid://dpumfpxwal0h7"),
	preload("uid://umcvgecrr852"),
	preload("uid://e32uhb42ygbp"),
	preload("uid://dhbckqtoxegud"),
]

func _ready():
	mob_type = Mob.MobType.LIZARD
	super._ready()
	audio_stream_player_2d.stream = spawn_sfx.pick_random()
	audio_stream_player_2d.play()
