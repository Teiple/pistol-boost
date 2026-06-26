class_name PoolsAutoload
extends Node

# Runtime pools
var _runtime_pools: Dictionary[String, Pool] = { }


func register_pool(group: int, id: String, pool: Pool) -> void:
	Assert.not_null(pool, "Pool to register should not be null")
	var key := pool_key(group, id)

	Assert.dict_not_contains(
		_runtime_pools,
		key,
		"Trying to register a pool with a key that already exists",
	)
	_runtime_pools[key] = pool


func get_pool(group: int, id: String) -> Pool:
	var key := pool_key(group, id)

	Assert.dict_contains(
		_runtime_pools,
		key,
		"Trying to get a pool that was not registered",
	)
	return _runtime_pools[key]


func get_instance(group: int, id: String) -> Node:
	return get_pool(group, id).get_instance()


func pool_key(group: int, id: String) -> String:
	Assert.dict_contains(
		PoolGroup.NAMES,
		group,
		"Pool group should have a registered group name",
	)
	Assert.non_empty_string("Pool id should not be empty")
	return "%s/%s" % [PoolGroup.NAMES[group], id]


func clear_runtime_pools() -> void:
	for pool: Pool in _runtime_pools.values():
		pool.clear()
