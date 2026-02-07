class_name CarScore extends TextureRect

@onready var grade_texture: TextureRect = $GradeTexture
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var grade: String = "F"
var sound: AudioStream = null

func _ready() -> void:
	call_deferred("set_grade", grade)

func set_grade(grade: String) -> void:
	grade_texture.texture = CarScoreContainer.GRADE_TEXTURES_SOUNDS[grade]["texture"]
	sound = CarScoreContainer.GRADE_TEXTURES_SOUNDS[grade]["sound"]

func play_sound() -> void:
	audio_player.stream = sound
	audio_player.play()
	
