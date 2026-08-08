class_name BulletsAutoload
extends Node

@export var _bullet_configs: Array[BulletConfig] = []

var _projectile_spawner := ProjectileBulletSpawner.new()
var _hitscan_spawner := HitscanBulletSpawner.new()
var _beam_spawner := BeamBulletSpawner.new()
var _registered_bullet_configs: Dictionary[String, BulletConfig] = { }


func _ready():
	var registered_bullet_config_paths: Dictionary[String, String] = { }
	for bullet_config in _bullet_configs:
		var registries := _get_bullet_spawner(bullet_config).create_bullet_pools(bullet_config)

		_validate_unique_bullet_config(registered_bullet_config_paths, bullet_config, registries)

		for registry in registries:
			Pools.register_pool(registry)


func spawn_bullet(spawn_context: BulletSpawnContext) -> Bullet:
	Assert.not_null(spawn_context, "Bullet spawn context should not be null")

	Assert.not_null(spawn_context.bullet_config, "Bullet config should not be null instead spawn context")

	_get_bullet_spawner(spawn_context.bullet_config).spawn_bullet(spawn_context)

	return null


func get_bullet_aim_resolver(
	bullet_config: BulletConfig,
	aim_resolve_callable_name: String = Bullet.resolve_aim.get_method(),
) -> AimResolver:
	var script := ResourceUtil.get_scene_script(bullet_config.bullet.scene)
	if script != null && script.has_script_method(aim_resolve_callable_name):
		return AimResolver.new(Callable(script, aim_resolve_callable_name), bullet_config)
	return null


func _get_bullet_spawner(bullet_config: BulletConfig) -> BulletSpawner:
	if bullet_config is ProjectileBulletConfig:
		return _projectile_spawner
	if bullet_config is HitscanBulletConfig:
		return _hitscan_spawner
	if bullet_config is BeamBulletConfig:
		return _beam_spawner

	Assert.unreachable("Bullet spawner was not implemented")
	return null


## Ensure each bullet config has exact 1 presentation
func _validate_unique_bullet_config(
	registered_bullet_config_paths: Dictionary[String, String],
	bullet_config: BulletConfig,
	registries: Array[PoolRegistry],
) -> void:
	Assert.not_null(bullet_config, "Bullet config should not be null")
	Assert.non_empty_array(registries, "Bullet config should create at least one pool registry")

	var bullet_registry := registries[0]
	Assert.not_null(bullet_registry, "Bullet registry should not be null")
	var key := Pools.pool_key(bullet_registry.group, bullet_registry.id) as String
	var config_path := bullet_config.resource_path

	if key in registered_bullet_config_paths:
		Assert.check(
			registered_bullet_config_paths[key] == config_path,
			"Bullet pool key %s is used by multiple bullet configs: %s != %s"
			% [key, registered_bullet_config_paths[key], config_path],
		)
		return

	registered_bullet_config_paths[key] = config_path
	_registered_bullet_configs[key] = bullet_config
