@abstract
class_name PlayerFiringHandler

var _controller: PlayerFiringController


func _init(controller: PlayerFiringController) -> void:
	_controller = controller


func on_fire_pressed(_firing_config: FiringConfig) -> void:
	pass


func on_fire_held(_firing_config: FiringConfig, _held_time: float) -> void:
	pass


func on_fire_released(_firing_config: FiringConfig, _held_time: float) -> void:
	pass


func fire(firing_config: FiringConfig, apply_recoil: bool = true) -> void:
	Assert.not_null(firing_config, "Firing config should not be null")
	var standard_config := firing_config as StandardFiringConfig
	Assert.not_null(standard_config, "Firing config should be of type StandardFiringConfig")

	for i in standard_config.ammo_per_shot:
		for j in standard_config.bullets_per_ammo:
			var muzzle_point := _controller.get_muzzle_point()
			var collision_mask := _controller.get_collision_mask()

			var spawn_context := BulletSpawnContext.new(
				standard_config.bullet_config,
				muzzle_point.global_position,
				(muzzle_point.global_basis.x * Vector3(1, 1, 0)).normalized(),
				standard_config.spread_angle_degrees,
				collision_mask,
				muzzle_point,
			)

			Bullets.spawn_bullet(spawn_context)

	if apply_recoil:
		_controller.apply_recoil(standard_config.recoil_force_per_shot)
	if firing_config.firing_sound != null:
		_controller.play_firing_sound(firing_config.firing_sound)


func on_weapon_interrupted() -> void:
	pass


func _ensure_config_type(firing_config: FiringConfig) -> FiringConfig:
	Assert.not_null(firing_config, "Firing config should be not be null")
	return firing_config
