class_name ProjectileBulletSpawner
extends BulletSpawner


func spawn_bullet(spawn_context: BulletSpawnContext) -> Projectile:
	Assert.not_null(spawn_context, "Bullet spawn context should not be null")

	var bullet_config := spawn_context.bullet_config

	var projectile := Pools.get_instance(
		PoolGroup.Type.PROJECTILE,
		bullet_config.bullet.id,
	) as Projectile

	Assert.not_null(projectile, "Projectile instance should not be null")

	var direction := spawn_context.base_direction
	if spawn_context.spread_angle_degrees > 0.0:
		direction = direction.rotated(
			Vector3.FORWARD,
			deg_to_rad(
				randf_range(
					-spawn_context.spread_angle_degrees,
					spawn_context.spread_angle_degrees,
				),
			),
		)

	var atk_origin := Attack.Origin.new()
	atk_origin.fired_from = spawn_context.fired_from
	atk_origin.direction = direction
	atk_origin.collision_mask = spawn_context.collision_mask

	projectile.launch(atk_origin)

	return projectile
