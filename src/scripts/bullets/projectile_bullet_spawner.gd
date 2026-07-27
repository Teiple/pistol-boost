class_name ProjectileBulletSpawner
extends BulletSpawner


func ensure_bullet_config_type(bullet_config: BulletConfig) -> ProjectileBulletConfig:
	var t_config := bullet_config as ProjectileBulletConfig
	Assert.not_null("Expecting bullet config of type ProjectileBulletConfig")
	return t_config


func create_bullet_pools(bullet_config: BulletConfig) -> Array[PoolRegistry]:
	var config := ensure_bullet_config_type(bullet_config)
	var bullet_pool := BulletPool.create(10, bullet_config)

	var impact_pool := SpatialPool.new(10, bullet_config.impact_fx.scene)

	return [
		PoolRegistry.new(PoolGroup.Type.PROJECTILE, config.bullet.id, bullet_pool),
		PoolRegistry.new(PoolGroup.Type.IMPACT_EFFECT, config.impact_fx.id, impact_pool),
	]


func spawn_bullet(spawn_context: BulletSpawnContext) -> Projectile:
	Assert.not_null(spawn_context, "Bullet spawn context should not be null")

	var config := ensure_bullet_config_type(spawn_context.bullet_config)

	var projectile := Pools.get_instance(PoolGroup.Type.PROJECTILE, config.bullet.id) as Projectile

	_validate_spawn_bullet(projectile, spawn_context)

	Assert.not_null(projectile, "Projectile instance should not be null")

	var direction := spawn_context.base_direction
	if spawn_context.spread_angle_degrees > 0.0:
		var spread_angle := deg_to_rad(
			randf_range(-spawn_context.spread_angle_degrees, spawn_context.spread_angle_degrees),
		)
		direction = direction.rotated(Vector3.FORWARD, spread_angle)

	projectile.launch(spawn_context.fired_from, direction, spawn_context.collision_mask)

	return projectile
