extends ProgressBar

var health_value = self.value: set = set_health_value
@onready var cooldown_timer: Timer = $CooldownTimer

func _ready() -> void:
	cooldown_timer.timeout.connect(lifebar_fade)

func _process(delta: float) -> void:
	pass

func set_health_value(new_value) -> void:
	value = new_value
	create_tween().tween_property(self, "modulate", Color.hex(0xffffffff), 0.5)
	cooldown_timer.start(2.0)
	
func lifebar_fade() -> void:
	create_tween().tween_property(self, "modulate", Color.hex(0xffffff00), 0.5)
