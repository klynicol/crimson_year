class_name CarScoreContainer extends Control

const SMACK_SOUND = preload("uid://wpjl0y0m0aya")
const SOUND_DIR = "res://assets/menu_gui/grade_sounds/"
const GRADE_TEXTURES_SOUNDS = {
	"F": {"texture": preload("uid://cuowrt4k5q5l7"), "sound": preload(SOUND_DIR + "F.wav")},
	"D": {"texture": preload("uid://cev50g5tqk8oq"), "sound": preload(SOUND_DIR + "d.wav")},
	"C": {"texture": preload("uid://dy84o3jrqt33m"), "sound": preload(SOUND_DIR + "c.wav")},
	"B": {"texture": preload("uid://xl3s5b4q2lvs"), "sound": preload(SOUND_DIR + "b.wav")},
	"A": {"texture": preload("uid://d15b6dhy2dhu6"), "sound": preload(SOUND_DIR + "a.wav")},
	"S": {"texture": preload("uid://mnlc4ii738gy"), "sound": preload(SOUND_DIR + "s.wav")},
}

const RANDOM_SOUNDS = [
	preload(SOUND_DIR + "smokehere.wav"),
	preload(SOUND_DIR + "nice ride.wav"),
	preload(SOUND_DIR + "attack.wav"),
	preload(SOUND_DIR + "didsheputupafight.wav"),
]

# Just hack together 2 positions for now
const POSITIONS = [
	Vector2(-148, -128),
	Vector2(20, -128),
]
const CAR_SCORE_SCENE = preload("uid://d47i32v7i084")

signal placed_car_score

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var run_process: bool = false
var cooldown: float = 0.0
const COOLDOWN: float = 1

func reset_and_show_scores() -> void:
	clear_children()
	for car in get_tree().get_nodes_in_group("cars"):
		car.score_placed = false
	run_process = true

func _process(delta: float) -> void:
	if not run_process:
		return
	if cooldown > 0:
		print("cooldown: ", cooldown)
		cooldown -= delta
		return
	var cars_found: bool = false
	for car in get_tree().get_nodes_in_group("cars"):
		print("car: ", car.name, " score placed: ", car.score_placed)
		if car.score_placed:
			continue
		car.score_placed = true
		var car_score_instance = CAR_SCORE_SCENE.instantiate()
		car_score_instance.grade = car.get_grade()
		car_score_instance.texture = CarElement.SPRITE_OPTIONS[car.car_sprite_index]
		add_child(car_score_instance)
		first_tween_car_score(car_score_instance)
		cars_found = true
		cooldown = COOLDOWN
		break
	if not cars_found:
		run_process = false

#Variant interpolate_value(initial_value: Variant, delta_value: Variant, elapsed_time: float, duration: float, trans_type: TransitionType, ease_type: EaseType) static
func first_tween_car_score(node: CarScore) -> void:
	var child_count = get_children().size()
	var position = POSITIONS[child_count % POSITIONS.size()]
	node.position = Vector2(-1000, -1000)
	node.scale = Vector2(1.4, 1.4)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(node, "position", position, 0.7)
	tween.finished.connect(second_tween_car_score.bind(node))
	
func second_tween_car_score(node: CarScore) -> void:
	var tween = create_tween()
	tween.tween_property(node, "scale", Vector2(1.0, 1.0), 0.4) \
		.set_trans(Tween.TRANS_BOUNCE) \
		.set_ease(Tween.EASE_OUT)
	audio_player.stream = SMACK_SOUND
	audio_player.play()
	node.play_sound()
	placed_car_score.emit()

func clear_children() -> void:
	for child in get_children():
		if child != audio_player:
			child.queue_free()