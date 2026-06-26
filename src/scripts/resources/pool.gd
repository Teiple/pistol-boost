@abstract
class_name Pool
extends Resource

@export var _capacity: int = 10
@export var _scene: PackedScene = null
@export var _preinstantiate: bool = false
@export var _force_readable_names: bool = true

var _pool: Array[Node] = []
var _active_instances: Array[Node] = []


func _init(capacity := _capacity, scene := _scene) -> void:
	_capacity = capacity
	_scene = scene

	if _preinstantiate:
		_preinit()


@abstract func _on_create(_instance: Node) -> void


@abstract func _on_destroy(_instance: Node) -> void


@abstract func _on_get(_instance: Node) -> void


@abstract func _on_release(_instance: Node) -> void


func release(instance: Node) -> void:
	Assert.not_null(instance, "Instance to release should not be null")
	Assert.array_not_contains(
		_pool,
		instance,
		"Trying to release an instance that is already in the pool",
	)

	_active_instances.erase(instance)

	if _pool.size() == _capacity:
		_on_destroy(instance)
		if !instance.is_queued_for_deletion():
			instance.queue_free()
		return

	if instance.get_parent() != Global.current_scene():
		instance.reparent(Global.current_scene())
	_on_release(instance)
	_pool.push_back(instance)


func get_instance() -> Node:
	var instance: Node

	if _pool.size() == 0:
		var created: Variant = _create_func.call()

		Assert.not_null(created, "Instance received should not be null")
		Assert.check(created is Node, "Instance received should be of type Node")

		var pooled_node: Node = created
		var pooled_mod := PooledNodeModule.find_on(pooled_node)
		if pooled_mod != null:
			pooled_mod.set_parent_pool(self)

		instance = created
	else:
		instance = _pool.pop_back()
		Assert.not_null(instance, "Instance from pool should not be null")

	if instance.get_parent() != Global.current_scene():
		instance.reparent(Global.current_scene())
	_on_get(instance)

	_active_instances.push_back(instance)
	return instance


func actives_instances() -> Array[Node]:
	return _active_instances


func clear_actives() -> void:
	var active_instances: Array[Node] = _active_instances.duplicate()
	for active in active_instances:
		if is_instance_valid(active):
			release(active)
		else:
			_active_instances.erase(active)


func clear() -> void:
	for active in _active_instances:
		if is_instance_valid(active) && !active.is_queued_for_deletion():
			_on_destroy(active)
			active.queue_free()

	for pooled in _pool:
		if is_instance_valid(pooled) && !pooled.is_queued_for_deletion():
			_on_destroy(pooled)
			pooled.queue_free()

	_active_instances.clear()
	_pool.clear()


func _create_func() -> Node:
	Assert.not_null(_scene, "Pool scene should not be null")
	var created: Node = _scene.instantiate()
	Global.add_node_to_current_scene(created, _force_readable_names)
	_on_create(created)
	return created


func _preinit() -> void:
	Assert.not_null(_scene, "Pool scene should not be null")
	_pool.resize(_capacity)
	for i in _capacity:
		var created: Node = _scene.instantiate()
		Assert.not_null(created, "Instance received should not be null")
		Global.add_node_to_current_scene(created)
		_on_create(created)

		var pooled_mod := PooledNodeModule.find_on(created)
		if pooled_mod != null:
			pooled_mod.set_parent_pool(self)

		var instance: Node = created
		_pool[i] = instance
