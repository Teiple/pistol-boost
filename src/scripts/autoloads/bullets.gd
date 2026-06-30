class_name BulletsAutoload
extends Node

@export var _bullet_configs: Array[BulletConfig] = []

var _projectile_spawner := ProjectileBulletSpawner.new()


func _ready():
	for bullet_config in _bullet_configs:
		var registries := _create_bullet_pools(bullet_config)
		for registry in registries:
			Pools.register_pool(registry)


func spawn_bullet(bullet_config: BulletConfig, spawn_context: BulletSpawnContext) -> void:
	Assert.not_null(bullet_config, "Bullet config")
	Assert.not_null(spawn_context, "Bullet spawn context")

	if bullet_config is ProjectileBulletConfig:
		_projectile_spawner.spawn_bullet(spawn_context)

	Assert.unreachable("Bullet spawner was not implemented")


func _create_bullet_pools(bullet_config: BulletConfig) -> Array[PoolRegistry]:
	if bullet_config is ProjectileBulletConfig:
		return _create_projectile_bullet_pools(
			bullet_config as ProjectileBulletConfig,
		)

	Assert.unreachable("Bullet config pool creator was not implemented")
	return []


func _create_projectile_bullet_pools(
		bullet_config: ProjectileBulletConfig,
) -> Array[PoolRegistry]:
	var bullet_pool := ProjectilePool.create(
		10,
		bullet_config,
	)

	var impact_pool := SpatialPool.new(
		10,
		bullet_config.impact_fx.scene,
	)

	return [
		PoolRegistry.new(
			PoolGroup.Type.PROJECTILE,
			bullet_config.bullet.id,
			bullet_pool,
		),
		PoolRegistry.new(
			PoolGroup.Type.IMPACT_EFFECT,
			bullet_config.impact_fx.id,
			impact_pool,
		),
	]
