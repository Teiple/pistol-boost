@abstract
class_name Pool
extends Resource

@export var _capacity: int = 10
@export var _scenes: Array[PackedScene] = []
@export var _preinstantiate: bool = false
@export var _force_readable_names: bool = true

var _pool: Array[Node] = []
var _active_instances: Array[Node] = []


func _init(capacity := _capacity, scenes := _scenes) -> void:
	_capacity = capacity
	_scenes = scenes

	for scene in _scenes:
		Pools.scene_path_to_pool_lookup[scene.resource_path] = self

	if _preinstantiate:
		_preinit()


@abstract func _on_create(_instance: Node) -> void


@abstract func _on_destroy(_instance: Node) -> void


@abstract func _on_get(_instance: Node) -> void


@abstract func _on_release(_instance: Node) -> void


func release(instance: Node) -> void:
	Assert.not_null(instance, "Instance to release should not be null")

	if _pool.size() == _capacity:
		_on_destroy(instance)
		instance.queue_free()
		return

	instance.reparent(Global.current_scene())
	_on_release(instance)

	Assert.array_not_contains(
		_pool,
		instance,
		"Trying to adding an instance that already existed in the pool",
	)
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

	instance.reparent(Global.current_scene())
	_on_get(instance)

	_active_instances.push_back(instance)
	return instance


func actives_instances() -> Array[Node]:
	return _active_instances


func clear_actives() -> void:
	for active in _active_instances:
		release(active)


func _create_func() -> Node:
	var rand_scene: PackedScene = _scenes.pick_random()
	var created: Node = rand_scene.instantiate()
	Global.add_node_to_current_scene(created, _force_readable_names)
	_on_create(created)
	return created


func _preinit() -> void:
	_pool.resize(_capacity)
	for i in _capacity:
		var rand_scene: PackedScene = _scenes.pick_random()
		var created: Node = rand_scene.instantiate()
		Assert.not_null(created, "Instance received should not be null")
		Global.add_node_to_current_scene(created)
		_on_create(created)

		var instance: Node = created
		_pool[i] = instance
