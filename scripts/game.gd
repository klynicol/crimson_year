class_name Game extends Node

@onready var next_stage_button: BaseButton = $Gui/Control/TextureButton  # Button (renamed from Label for click)
@onready var stage: StageManager = $World/Stage
@onready var character: PlayerController = $World/YSort/Character

static var paused: bool = false

var life_time_mob_fragments: int = 0

func _ready() -> void:
	next_stage_button.visible = false
	next_stage_button.pressed.connect(_on_next_stage_pressed)
	# see below comments for explanation of this dumb thing
	get_node("Gui/Menu").connect_control_method.connect(_on_connect_control_method)

func show_next_stage_prompt() -> void:
	next_stage_button.visible = true

func hide_next_stage_prompt() -> void:
	next_stage_button.visible = false

func _on_next_stage_pressed() -> void:
	var stage_manager: StageManager = $World/Stage
	stage_manager.start_next_wave()
	hide_next_stage_prompt()

func _on_game_start_pressed() -> void:
	stage.init_wave(1)
	
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
