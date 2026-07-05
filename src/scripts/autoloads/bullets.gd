class_name BulletsAutoload
extends Node

@export var _bullet_configs: Array[BulletConfig] = []

var _projectile_spawner := ProjectileBulletSpawner.new()
var _hitscan_spawner := HitscanBulletSpawner.new()
var _beam_spawner := BeamBulletSpawner.new()


func _ready():
	var registered_bullet_config_paths: Dictionary[String, String] = { }
	for bullet_config in _bullet_configs:
		var registries := _create_bullet_pools(bullet_config)
		_validate_unique_bullet_config(
			registered_bullet_config_paths,
			bullet_config,
			registries,
		)

		for registry in registries:
			Pools.register_pool(registry)


func spawn_bullet(spawn_context: BulletSpawnContext) -> Bullet:
	Assert.not_null(spawn_context, "Bullet spawn context should not be null")

	Assert.not_null(
		spawn_context.bullet_config,
		"Bullet config should not be null instead spawn context",
	)

	if spawn_context.bullet_config is ProjectileBulletConfig:
		return _projectile_spawner.spawn_bullet(spawn_context)
	if spawn_context.bullet_config is HitscanBulletConfig:
		return _hitscan_spawner.spawn_bullet(spawn_context)
	if spawn_context.bullet_config is BeamBulletConfig:
		return _beam_spawner.spawn_bullet(spawn_context)

	Assert.unreachable("Bullet spawner was not implemented")
	return null


func _create_bullet_pools(bullet_config: BulletConfig) -> Array[PoolRegistry]:
	Assert.not_null(bullet_config, "Bullet config should not be null")

	if bullet_config is ProjectileBulletConfig:
		return _create_projectile_bullet_pools(
			bullet_config as ProjectileBulletConfig,
		)
	if bullet_config is HitscanBulletConfig:
		return _create_hitscan_bullet_pools(
			bullet_config as HitscanBulletConfig,
		)
	if bullet_config is BeamBulletConfig:
		return _create_laser_bullet_pools(
			bullet_config as BeamBulletConfig,
		)

	Assert.unreachable("Bullet config pool creator was not implemented")
	return []


func _create_projectile_bullet_pools(
		bullet_config: ProjectileBulletConfig,
) -> Array[PoolRegistry]:
	var bullet_pool := BulletPool.create(
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


func _create_laser_bullet_pools(
		bullet_config: BeamBulletConfig,
) -> Array[PoolRegistry]:
	var bullet_pool := BulletPool.create(
		10,
		bullet_config,
	)

	var impact_pool := SpatialPool.new(
		10,
		bullet_config.impact_fx.scene,
	)

	return [
		PoolRegistry.new(
			PoolGroup.Type.BEAM,
			bullet_config.bullet.id,
			bullet_pool,
		),
		PoolRegistry.new(
			PoolGroup.Type.IMPACT_EFFECT,
			bullet_config.impact_fx.id,
			impact_pool,
		),
	]


func _create_hitscan_bullet_pools(
		bullet_config: HitscanBulletConfig,
) -> Array[PoolRegistry]:
	var bullet_pool := BulletPool.create(
		10,
		bullet_config,
	)

	var impact_pool := SpatialPool.new(
		10,
		bullet_config.impact_fx.scene,
	)

	return [
		PoolRegistry.new(
			PoolGroup.Type.HITSCAN,
			bullet_config.bullet.id,
			bullet_pool,
		),
		PoolRegistry.new(
			PoolGroup.Type.IMPACT_EFFECT,
			bullet_config.impact_fx.id,
			impact_pool,
		),
	]


func _validate_unique_bullet_config(
		registered_bullet_config_paths: Dictionary[String, String],
		bullet_config: BulletConfig,
		registries: Array[PoolRegistry],
) -> void:
	Assert.not_null(bullet_config, "Bullet config should not be null")
	Assert.non_empty_array(registries, "Bullet config should create at least one pool registry")

	var bullet_registry := registries[0]
	Assert.not_null(bullet_registry, "Bullet registry should not be null")
	var key := Pools.pool_key(bullet_registry.group, bullet_registry.id)
	var config_path := bullet_config.resource_path

	if key in registered_bullet_config_paths:
		Assert.check(
			registered_bullet_config_paths[key] == config_path,
			"Bullet pool key %s is used by multiple bullet configs: %s != %s" % [
				key,
				registered_bullet_config_paths[key],
				config_path,
			],
		)
		return

	registered_bullet_config_paths[key] = config_path
