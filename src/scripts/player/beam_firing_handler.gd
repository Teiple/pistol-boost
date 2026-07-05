class_name BeamFiringHandler
extends FiringHandler

var _active_beam: Beam = null


func on_fire_pressed(_firing_config: FiringConfig) -> void:
	var muzzle_point := _controller.get_muzzle_point()
	var fire_from := muzzle_point.global_position
	var fire_direction := muzzle_point.global_basis.x * Vector3(1, 0, 1)
	var spawn_context := BulletSpawnContext.new(
		_firing_config.bullet_config,
		fire_from,
		fire_direction,
		0,
		_controller.get_collision_mask(),
		muzzle_point,
	)

	var beam := Bullets.spawn_bullet(spawn_context) as Beam
	Assert.not_null(beam, "Bullet spawn should be of type Beam")

	_active_beam = beam


func on_fire_released(_firing_config: FiringConfig, _held_time: float) -> void:
	if _active_beam != null:
		_active_beam.stop()
		_active_beam = null


func on_weapon_interrupted() -> void:
	pass


func _ensure_config_type(firing_config: FiringConfig) -> BeamFiringConfig:
	var t_config := firing_config as BeamFiringConfig
	Assert.not_null(t_config, "Firing config should be of type BeamFiringConfig")
	return t_config
