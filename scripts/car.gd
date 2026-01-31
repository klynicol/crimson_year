extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var car: cars

# the values of these enums will also translate to the name
# of the animation
enum cars {
	CHEVY_BEL_AIR,
	CADILLAC_DEVILLE
}

func _ready() -> void:
	sprite.play(str(car))
