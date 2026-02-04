extends RichTextLabel

@onready var option_button: OptionButton = %OptionButton
signal control_method_changed(method)

func _ready() -> void:
	pass 

func _process(_delta: float) -> void:
	pass


func _on_x_button_options_pressed() -> void:
	queue_free()

# this signal hooks up with the corresponding function in game.gd, which changes the property in the player's 
# character_controller.gd
func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			print("Mouse mode selected!")
			control_method_changed.emit(PlayerController.ControlMode.KEYBOARD)
		1:
			print("Gamepad mode selected!")
			control_method_changed.emit(PlayerController.ControlMode.GAMEPAD)
