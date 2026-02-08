class_name Game extends Node

@onready var menu: Control = $Gui/Menu
@onready var next_stage_button: BaseButton = get_tree().get_first_node_in_group("next_stage_button")
@onready var retry_button: BaseButton = get_tree().get_first_node_in_group("retry_button")
@onready var car_score_container: CarScoreContainer = get_tree().get_first_node_in_group("car_score_container")
@onready var stage: StageManager = $World/Stage
@onready var character: PlayerController = $World/YSort/Character
@onready var end_wave_container: Container = $Gui/Control/EndWaveContainer

#music
const PLAY_MUSIC: bool = true
@onready var rockabily: AudioStreamPlayer = $World/Rockabily
@onready var funk: AudioStreamPlayer = $World/Funk
@onready var boss_funk: AudioStreamPlayer = $World/BossFunk

static var paused: bool = true

var life_time_mob_fragments: int = 0

const CAR_GRADES = [
	"F",
	"D",
	"C",
	"B",
	"A",
	"S",
];

func _ready() -> void:
	menu.connect_control_method.connect(_on_options_opened)
	retry_button.pressed.connect(_on_retry_pressed)
	next_stage_button.pressed.connect(_on_next_stage_pressed)
	stage.wave_ended.connect(_on_wave_ended)
	stage.boss_spawned.connect(_on_boss_spawned)
	hide_next_stage_prompt()
	if PLAY_MUSIC:
		funk.play()

func _on_wave_ended() -> void:
	show_next_stage_prompt()
	car_score_container.reset_and_show_scores()

func show_next_stage_prompt() -> void:
	end_wave_container.visible = true

func hide_next_stage_prompt() -> void:
	end_wave_container.visible = false

func _restore_music() -> void:
	if stage.current_wave == 3 and PLAY_MUSIC:
		boss_funk.stop()
		rockabily.play()

func _on_next_stage_pressed() -> void:
	_restore_music()
	stage.start_next_wave()
	hide_next_stage_prompt()
	# Wave end had set Game.paused = true; unpause so the next wave can spawn cars/enemies
	Game.paused = false
	get_viewport().gui_release_focus()

func _on_retry_pressed() -> void:
	_restore_music()
	stage.init_wave(stage.current_wave)
	hide_next_stage_prompt()
	# Wave end had set Game.paused = true; unpause so the next wave can spawn cars/enemies
	Game.paused = false
	get_viewport().gui_release_focus()

func start_pressed() -> void:
	paused = false
	funk.stop()
	if PLAY_MUSIC:
		rockabily.play()
	stage.init_wave(1)
	# Release focus from the Play button so Space (dash) doesn't re-trigger this and call prepare_for_wave again
	get_viewport().gui_release_focus()

func _on_options_opened(options_popup: Node) -> void:
	if options_popup.has_signal("control_method_changed"):
		options_popup.control_method_changed.connect(_on_control_method_changed)

func _on_control_method_changed(control_method) -> void:
	character.control_type = control_method

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		paused = not paused

func _on_boss_spawned(boss: Node) -> void:
	if not PLAY_MUSIC:
		return
	# We should fade the rockabily music out and fade in the boss funk music
	boss_funk.volume_db = -30.0
	boss_funk.play()
	var tween = create_tween()
	tween.tween_property(rockabily, "volume_db", -30.0, 1)
	tween.tween_property(boss_funk, "volume_db", -16, 0.75)
	tween.finished.connect(func():
		rockabily.stop()
		rockabily.volume_db = -12.0
	)
	
