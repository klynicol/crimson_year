class_name Mob extends Enemies

enum MobType {
	LIZARD,
	TOAD,
	GECKO,
}

const mob_scense: Dictionary[MobType, PackedScene] = {
	MobType.LIZARD: preload("uid://xriknrldek0f"),
	MobType.TOAD: preload("uid://dcqdtdvxviuqr"),
	MobType.GECKO: preload("uid://ducr0tccltrqt"),
}

@export var attack_frame: int

var mob_type: MobType

func _check_state(delta: float) -> void:
	if mob_state == MobState.DYING:
		_handle_mob_dying(delta)
		return
	if mob_state == MobState.HURT:
		_handle_mob_hurt(delta)
		return
	# small buffer to prevent jittering between states
	if last_state != mob_state and action_cooldown > 0.0:
		action_cooldown -= delta
		return
	# Check if we should attack
	var bodies_in_range: Array[CharacterBody2D] = _get_bodies_in_attack_range()
	if bodies_in_range.size() > 0:
		_decelerate_to_zero_velocity(delta)
		_handle_attack(bodies_in_range, delta)
		return
	# Last resort, just chase the target
	_handle_walking(delta)

# Checks if the attack aligns with the sprite frame and if bodies are in range, then performs the attack
func _handle_attack(bodies_in_range: Array[CharacterBody2D], delta: float) -> void:
	mob_state = MobState.ATTACKING
	action_cooldown = ACTION_COOLDOWN
	if attack_cooldown_time > 0.0:
		attack_cooldown_time -= delta
		return
	if not _attack_alligns_with_sprite_frame():
		# Wait for the right frame
		attack_cooldown_time = 0
		return
	for body in bodies_in_range:
		if stats.attack_range > 0:
			_shoot_projectile(body.global_position)
		else:
			body.take_damage(stats.damage)
	attack_cooldown_time = stats.attack_cooldown


func _shoot_projectile(target_pos: Vector2) -> void:
	pass

# Helper function to check if the attack aligns with the sprite frame
func _attack_alligns_with_sprite_frame() -> bool:
	if sprite.frame != attack_frame:
		return false
	return true