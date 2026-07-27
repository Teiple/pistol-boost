class_name HitscanBulletSpawner
extends BulletSpawner


func ensure_bullet_config_type(bullet_config: BulletConfig) -> HitscanBulletConfig:
	var t_config := bullet_config as HitscanBulletConfig
	Assert.not_null("Expecting bullet config of type HitscanBulletConfig")
	return t_config


func create_bullet_pools(bullet_config: BulletConfig) -> Array[PoolRegistry]:
	var config := ensure_bullet_config_type(bullet_config)
	var bullet_pool := BulletPool.create(10, config)

	var impact_pool := SpatialPool.new(10, config.impact_fx.scene)

	var registries: Array[PoolRegistry] = [
		PoolRegistry.new(PoolGroup.Type.HITSCAN, config.bullet.id, bullet_pool),
		PoolRegistry.new(PoolGroup.Type.IMPACT_EFFECT, config.impact_fx.id, impact_pool),
	]

	if config.show_bullet_trail:
		Assert.not_null(
			config.hitscan_trail,
			"Hitscan trail should be set when show_bullet_trail is enabled",
		)
		registries.push_back(
			PoolRegistry.new(
				PoolGroup.Type.HITSCAN_TRAIL,
				config.hitscan_trail.id,
				SpatialPool.new(10, config.hitscan_trail.scene),
			),
		)

	return registries


func spawn_bullet(spawn_context: BulletSpawnContext) -> Hitscan:
	Assert.not_null(spawn_context, "Bullet spawn context should not be null")

	var bullet_config := spawn_context.bullet_config

	var hitscan := Pools.get_instance(PoolGroup.Type.HITSCAN, bullet_config.bullet.id) as Hitscan

	Assert.not_null(hitscan, "Hitscan instance should not be null")

	var direction := spawn_context.base_direction
	if spawn_context.spread_angle_degrees > 0.0:
		var spread_angle := deg_to_rad(
			randf_range(-spawn_context.spread_angle_degrees, spawn_context.spread_angle_degrees),
		)
		direction = direction.rotated(Vector3.FORWARD, spread_angle)

	hitscan.launch(spawn_context.fired_from, direction, spawn_context.collision_mask)

	return hitscan
