class_name PooledNodeModule
extends Module

var parent_pool: Pool = null


static func _name() -> String:
	return "PooledNodeModule"


static func find_on(node: Node) -> PooledNodeModule:
	return _find_on(node, _name())


func set_parent_pool(pool: Pool) -> void:
	parent_pool = pool


func get_pooled_node() -> Node:
	return module_owner() as Node


func return_to_pool() -> void:
	if parent_pool == null:
		parent_pool = Pools.scene_path_to_pool_lookup[module_owner().scene_file_path]
	if parent_pool != null:
		parent_pool.release.call(module_owner())
	else:
		Assert.unreachable("No pool was setup for \"%s\"" % module_owner().scene_file_path)
