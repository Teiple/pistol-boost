@abstract
class_name BulletSpawner


@abstract func ensure_bullet_config_type(bullet_config: BulletConfig) -> BulletConfig


@abstract func spawn_bullet(spawn_context: BulletSpawnContext) -> Bullet


@abstract func create_bullet_pools(bullet_config: BulletConfig) -> Array[PoolRegistry]


func _validate_spawn_bullet(bullet: Bullet, spawn_context: BulletSpawnContext) -> void:
	Assert.same_instance(
		bullet.get_bullet_config(),
		spawn_context.bullet_config,
		"Mismatch resources. Two bullet configs are claiming the same bullet id of %s"
		% [spawn_context.bullet_config.bullet.id],
	)
