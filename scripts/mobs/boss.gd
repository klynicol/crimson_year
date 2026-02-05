class_name Boss extends Enemies

enum BossType {
	CAR,
}

var boss_type: BossType

#override
func _physics_process(delta: float) -> void:
	_check_state(delta)
	_set_sprite_animation()
	move_and_slide()

#override
func _check_state(delta: float) -> void:
	if mob_state == MobState.DYING:
		_handle_mob_dying(delta)
		return
	if mob_state == MobState.HURT:
		_handle_mob_hurt(delta)
		return
	var bodies_in_range: Array[CharacterBody2D] = _get_bodies_in_attack_range()
	if bodies_in_range.size() > 0:
		_handle_attack(bodies_in_range, delta)
		# no need to return here, we want to continue moving the boss
	_find_and_chase_target(delta)

#override
func _handle_mob_hurt(delta: float) -> void:
	pass

#override
func _handle_mob_dying(delta: float) -> void:
	super._handle_mob_dying(delta)

#override
func _handle_attack(bodies_in_range: Array[CharacterBody2D], delta: float) -> void:
	pass
	
func _get_bodies_in_attack_range() -> Array[CharacterBody2D]:
	return []

#override
func _find_and_chase_target(delta: float) -> void:
	super._find_and_chase_target(delta)
