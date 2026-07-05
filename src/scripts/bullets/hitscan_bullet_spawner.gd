class_name HitscanBulletSpawner
extends BulletSpawner


func spawn_bullet(spawn_context: BulletSpawnContext) -> Hitscan:
	Assert.not_null(spawn_context, "Bullet spawn context should not be null")

	var bullet_config := spawn_context.bullet_config

	var hitscan := Pools.get_instance(
		PoolGroup.Type.HITSCAN,
		bullet_config.bullet.id,
	) as Hitscan

	Assert.not_null(hitscan, "Hitscan instance should not be null")

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

	hitscan.launch(
		spawn_context.fired_from,
		direction,
		spawn_context.collision_mask,
	)

	return hitscan
