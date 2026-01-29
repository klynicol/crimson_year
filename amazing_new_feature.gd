extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	extremely_important_vibe_check()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func extremely_important_vibe_check() -> bool:
	var essential_conditional: String = "it's here!"
	if essential_conditional:
		return true
		# yaaaaay it's there! c:
	else:
		return false
		# what, where did it go??? D:
