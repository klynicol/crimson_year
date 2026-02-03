extends Control
@onready var play_btn: Button = %PlayBtn
@onready var instructions_btn: Button = %InstructionsBtn
@onready var options_btn: Button = %OptionsBtn
const INSTRUCTIONS_POPUP = preload("uid://ctrjieuehfaph")
const OPTIONS_POPUP = preload("uid://b71urgpjn1yg6")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instructions_btn.button_up.connect(show_instructions)
	play_btn.button_up.connect(start_game)
	options_btn.button_up.connect(show_options)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func show_instructions() -> void:
	var tween := create_tween()
	var instructions_popup: PackedScene = INSTRUCTIONS_POPUP
	var instructions_instance:= instructions_popup.instantiate()
	add_child(instructions_instance)
	instructions_instance.z_index = 1
	tween.tween_property(instructions_instance, "modulate", Color.hex(0xffffffff), 0.5)
	get_node("InstructionsPopup/XButtonInstructions").pressed.connect(func() -> void:
		get_node("InstructionsPopup").queue_free()
	)
	
func show_options() -> void:
	var tween := create_tween()
	var options_popup: PackedScene = OPTIONS_POPUP
	var options_instance:= options_popup.instantiate()
	add_child(options_instance)
	options_instance.z_index = 1
	tween.tween_property(options_instance, "modulate", Color.hex(0xffffffff), 0.5)
	#get_node("OptionsPopup/XButtonInstructions").pressed.connect(func() -> void:
	#	get_node("OptionsPopup").queue_free()
	#)
	
func start_game() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:x", 3000.0, 1.5)
	tween.finished.connect(queue_free)

	pass
	
