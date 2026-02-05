class_name Mob extends Enemies

enum MobType {
	LIZARD,
	TOAD,
	GECKO,
}

@export var attack_box: Area2D
@export var attack_frame: int

var mob_type: MobType

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
		return
	_find_and_chase_target(delta)

# Checks if the attack aligns with the sprite frame and if bodies are in range, then performs the attack
func _handle_attack(bodies_in_range: Array[CharacterBody2D], delta: float) -> void:
	_apply_standard_conveyor_movement()
	mob_state = MobState.ATTACKING
	attack_cooldown_time -= delta
	if attack_cooldown_time > 0.0:
		mob_state = MobState.IDLE
		return
	if not _attack_alligns_with_sprite_frame():
		attack_cooldown_time = 0
		return
	for body in bodies_in_range:
		body.take_damage(stats.damage)
		_attack_hit_this_cycle = true
	attack_cooldown_time = stats.attack_cooldown

# Helper function to check if the attack aligns with the sprite frame
func _attack_alligns_with_sprite_frame() -> bool:
	if sprite.frame != attack_frame:
		_attack_hit_this_cycle = false
		return false
	if _attack_hit_this_cycle:
		return false
	return true

func _get_bodies_in_attack_range() -> Array[CharacterBody2D]:
	var bodies: Array[CharacterBody2D] = []
	for body in attack_box.get_overlapping_bodies():
		if body is not Car:
			continue
		bodies.append(body)
	return bodies
