extends Control
@onready var play_btn: Button = %PlayBtn
@onready var instructions_btn: Button = %InstructionsBtn
@onready var options_btn: Button = %OptionsBtn
@onready var instructions_popup: RichTextLabel = %InstructionsPopup


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instructions_btn.button_down.connect(show_instructions)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_instructions() -> void:
	var tween := create_tween()
	tween.tween_property(instructions_popup, "modulate", Color.hex(0xffffffff), 0.5)
	
	
