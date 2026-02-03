class_name Game extends Node

@onready var next_stage_button: BaseButton = $Gui/Control/TextureButton  # Button (renamed from Label for click)
@onready var stage: StageManager = $World/Stage
@onready var character: PlayerController = $World/YSort/Character


var life_time_mob_fragments: int = 0

func _ready() -> void:
	next_stage_button.visible = false
	next_stage_button.pressed.connect(_on_next_stage_pressed)

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

func _on_control_method_changed(control_method) -> void:
	pass
