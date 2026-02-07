class_name Game extends Node

@onready var next_stage_button: BaseButton = get_tree().get_first_node_in_group("next_stage_button")
@onready var retry_button: BaseButton = get_tree().get_first_node_in_group("retry_button")
@onready var car_score_container: CarScoreContainer = get_tree().get_first_node_in_group("car_score_container")
@onready var stage: StageManager = $World/Stage
@onready var character: PlayerController = $World/YSort/Character
@onready var end_wave_container: Container = $Gui/Control/EndWaveContainer

#music
const PLAY_MUSIC: bool = false
@onready var rockabily: AudioStreamPlayer = $World/Rockabily
@onready var funk: AudioStreamPlayer = $World/Funk

static var paused: bool = false

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
	retry_button.pressed.connect(_on_retry_pressed)
	next_stage_button.pressed.connect(_on_next_stage_pressed)
	stage.wave_ended.connect(_on_wave_ended)
	hide_next_stage_prompt()
	# see below comments for explanation of this dumb thing
	get_node("Gui/Menu").connect_control_method.connect(_on_connect_control_method)
	if PLAY_MUSIC:
		funk.play()

func _on_wave_ended() -> void:
	print("wave ended")
	show_next_stage_prompt()
	car_score_container.reset_and_show_scores()

func show_next_stage_prompt() -> void:
	# next_stage_button.visible = true
	end_wave_container.visible = true

func hide_next_stage_prompt() -> void:
	# next_stage_button.visible = false
	end_wave_container.visible = false

func _on_next_stage_pressed() -> void:
	stage.start_next_wave()
	hide_next_stage_prompt()
	# Wave end had set Game.paused = true; unpause so the next wave can spawn cars/enemies
	Game.paused = false
	get_viewport().gui_release_focus()

func _on_retry_pressed() -> void:
	stage.init_wave(stage.current_wave)
	hide_next_stage_prompt()
	# Wave end had set Game.paused = true; unpause so the next wave can spawn cars/enemies
	Game.paused = false
	get_viewport().gui_release_focus()

func _on_game_start_pressed() -> void:
	funk.stop()
	if PLAY_MUSIC:
		rockabily.play()
	stage.init_wave(1)
	# Release focus from the Play button so Space (dash) doesn't re-trigger this and call prepare_for_wave again
	get_viewport().gui_release_focus()

# this is probably jank and bad, but because the options_popup doesn't always exist, i have to connect its 
# control_method_changed signal programmatically, and i need this extra signal from menu.gd to tell game.gd
# when options_popup exists
func _on_connect_control_method() -> void:
	get_node("Gui/Menu/OptionsPopup").control_method_changed.connect(_on_control_method_changed)

# this function receives the signal from the options_popup.gd
func _on_control_method_changed(control_method) -> void:
	character.control_type = control_method

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		paused = not paused
