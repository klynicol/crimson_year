class_name Boss extends Enemies

enum BossType {
	CAR,
}

var boss_type: BossType
# will help with movement patterns
var hit_this_cycle: bool = false

#override
func _physics_process(delta: float) -> void:
	if Game.paused:
		# sprite.pause()
		return
	sprite.play()
	_check_state(delta)
	_set_sprite_animation()
	move_and_slide()

#override
func _check_state(delta: float) -> void:
	if mob_state == MobState.DYING:
		_handle_mob_dying(delta)
		return
	# if mob_state == MobState.HURT:
	# 	_handle_mob_hurt(delta)
	# 	return
	# small buffer to prevent jittering between states
	# if last_state != mob_state and action_cooldown > 0.0:
	# 	action_cooldown -= delta
	# 	return
	# # Check if we should attack
	# var bodies_in_range: Array[CharacterBody2D] = _get_bodies_in_attack_range()
	# if bodies_in_range.size() > 0:
	# 	_decelerate_to_zero_velocity(delta)
	# 	_handle_attack(bodies_in_range, delta)
	# 	return
	# # Last resort, just chase the target
	_handle_walking(delta)
	var bodies_in_range: Array[CharacterBody2D] = _get_bodies_in_attack_range()
	if bodies_in_range.size() > 0:
		_handle_attack(bodies_in_range, delta)

#override
func _handle_mob_dying(delta: float) -> void:
	super._handle_mob_dying(delta)

#override
func _find_and_chase_target(delta: float) -> void:
	super._handle_walking(delta)
#override
func _handle_attack(bodies_in_range: Array[CharacterBody2D], delta: float) -> void:
	super._handle_attack(bodies_in_range, delta)

#override
func _get_bodies_in_attack_range() -> Array[CharacterBody2D]:
	return super._get_bodies_in_attack_range()

func _on_hit_box_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name != "WaterDamage":
		return
	hit_this_cycle = true
	var water_spray_projectile = area.get_parent()
	var damage: float = water_spray_projectile.get_damage_and_increment_reflect()
	if damage > 0:
		stats.take_water_damage(damage)
		_flash_lifebar()
