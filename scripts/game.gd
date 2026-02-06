class_name Game extends Node

@onready var next_stage_button: BaseButton = $Gui/Control/TextureButton  # Button (renamed from Label for click)
@onready var stage: StageManager = $World/Stage
@onready var character: PlayerController = $World/YSort/Character

#music
const PLAY_MUSIC: bool = false
@onready var rockabily: AudioStreamPlayer = $World/Rockabily
@onready var funk: AudioStreamPlayer = $World/Funk

static var paused: bool = false

var life_time_mob_fragments: int = 0

func _ready() -> void:
	next_stage_button.visible = false
	next_stage_button.pressed.connect(_on_next_stage_pressed)
	# see below comments for explanation of this dumb thing
	get_node("Gui/Menu").connect_control_method.connect(_on_connect_control_method)
	if PLAY_MUSIC:
		funk.play()

func show_next_stage_prompt() -> void:
	next_stage_button.visible = true

func hide_next_stage_prompt() -> void:
	next_stage_button.visible = false

func _on_next_stage_pressed() -> void:
	var stage_manager: StageManager = $World/Stage
	stage_manager.start_next_wave()
	hide_next_stage_prompt()
	# Wave end had set Game.paused = true; unpause so the next wave can spawn cars/enemies
	Game.paused = false

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
