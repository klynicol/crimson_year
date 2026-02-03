extends RichTextLabel

@onready var option_button: OptionButton = %OptionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_x_button_options_pressed() -> void:
	queue_free()


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			print("Mouse mode selected!")
		1:
			print("Gamepad mode selected!")
