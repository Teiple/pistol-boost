@abstract
class_name FiringHandler

var _controller: FiringController


func _init(controller: FiringController) -> void:
	_controller = controller


@abstract func on_fire_held(_firing_config: FiringConfig, _held_time: float) -> void


@abstract func on_fire_released(_firing_config: FiringConfig, _held_time: float) -> void


func fire(firing_config: FiringConfig) -> void:
	Assert.not_null(firing_config, "Firing config should not be null")

	var muzzle_point := _controller.get_muzzle_point()
	var collision_mask := _controller.get_collision_mask()

	var spawn_context := BulletSpawnContext.new()

	spawn_context.fired_from = muzzle_point.global_position
	spawn_context.muzzle_position = muzzle_point.global_position
	spawn_context.base_direction = (
			muzzle_point.global_basis.x * Vector3(1, 1, 0)
	).normalized()
	spawn_context.spread_angle_degrees = firing_config.spread_angle_degrees
	spawn_context.collision_mask = collision_mask
	spawn_context.bullet_config = firing_config.bullet_config

	for i in firing_config.bullets_per_ammo:
		Bullets.spawn_bullet(firing_config.bullet_config, spawn_context)

	_controller.apply_recoil(firing_config.recoil_force)


func on_weapon_interrupted() -> void:
	pass


func _ensure_config_type(firing_config: FiringConfig) -> FiringConfig:
	Assert.not_null(firing_config, "Firing config should be not be null")
	return firing_config
