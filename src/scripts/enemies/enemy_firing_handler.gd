@abstract
class_name EnemyFiringHandler

var _controller: EnemyFiringController


func _init(controller: EnemyFiringController) -> void:
	_controller = controller


func can_start(_firing_config: FiringConfig, _muzzle_point: Node3D) -> bool:
	return !is_firing()


func start(firing_config: FiringConfig, muzzle_point: Node3D) -> void:
	var is_available := can_start(firing_config, muzzle_point)
	Assert.check(
		is_available,
		"Firing cannot be started yet. Call can_start() first before starting.",
	)
	if is_available:
		_start(firing_config, muzzle_point)


func update(_delta: float) -> void:
	pass


func is_firing() -> bool:
	return false


func fire(firing_config: FiringConfig, muzzle_point: Node3D) -> void:
	var standard_config := firing_config as StandardFiringConfig
	Assert.not_null(standard_config, "Enemy firing config should be a StandardFiringConfig")

	for _ammo_index in standard_config.ammo_per_shot:
		for _bullet_index in standard_config.bullets_per_ammo:
			var spawn_context := BulletSpawnContext.new(
				standard_config.bullet_config,
				muzzle_point.global_position,
				(muzzle_point.global_basis.x * Vector3(1, 1, 0)).normalized(),
				standard_config.spread_angle_degrees,
				_controller.get_collision_mask(),
				muzzle_point,
			)

			Bullets.spawn_bullet(spawn_context)

	if firing_config.firing_sound != null:
		_controller.play_firing_sound(firing_config.firing_sound)


@abstract func _start(firing_config: FiringConfig, muzzle_point: Node3D) -> void
