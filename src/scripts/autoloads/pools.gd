class_name PoolsAutoload
extends Node

const DEFAULT_ID := "_"

# Runtime pools
var _runtime_pools: Dictionary[String, Pool] = { }
var _runtime_pool_resource_paths: Dictionary[String, String] = { }


func register_pool(registry: PoolRegistry) -> void:
	Assert.not_null(registry.pool, "Pool to register should not be null")
	var key := pool_key(registry.group, registry.id)
	var resource_path := registry.pool.get_resource_path_to_scene()

	if key in _runtime_pools:
		Assert.check(
			_runtime_pool_resource_paths[key] == resource_path,
			"Pool key %s was already registered with a different resource path: %s != %s" % [
				key,
				_runtime_pool_resource_paths[key],
				resource_path,
			],
		)
		return

	registry.pool.preinit()
	_runtime_pools[key] = registry.pool
	_runtime_pool_resource_paths[key] = resource_path


func get_pool(group: int, id: String) -> Pool:
	var key := pool_key(group, id)

	Assert.dict_contains(
		_runtime_pools,
		key,
		"Trying to get a pool that was not registered",
	)
	return _runtime_pools[key]


func get_instance(group: PoolGroup.Type, id: String) -> Node:
	return get_pool(group, id).get_instance()


func pool_key(group: int, id: String) -> String:
	Assert.dict_contains(
		PoolGroup.NAMES,
		group,
		"Pool group should have a registered group name",
	)
	Assert.non_empty_string(id, "Pool id should not be empty")
	return "%s/%s" % [PoolGroup.NAMES[group], id]


func clear_runtime_pools() -> void:
	for pool: Pool in _runtime_pools.values():
		pool.clear()
	_runtime_pool_resource_paths.clear()
