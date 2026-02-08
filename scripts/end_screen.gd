extends Control


func tween_in() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:x", 0.0, 1.5)
	tween.finished.connect(func() -> void:
		visible = true
	)

func tween_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:x", 3000.0, 1.5)
	tween.finished.connect(func() -> void:
		visible = false
	)
