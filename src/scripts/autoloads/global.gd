class_name GlobalAutoload
extends Node

var _loading_scene: String = ""
var _current_scene: Node = null


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

	# Let this node run even when the tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	var last_idx := get_tree().root.get_child_count() - 1
	_current_scene = get_tree().root.get_child(last_idx)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CONFINED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED


func current_scene() -> Node:
	return _current_scene


func add_node_to_current_scene(node: Node, force_readable_name: bool = false) -> void:
	Assert.not_null(_current_scene, "Current scene was not initialized yet")
	return _current_scene.add_child(node, force_readable_name)


func get_player() -> Player:
	Assert.not_null(_current_scene, "Current scene was not initialized yet")
	var player := _current_scene.get_node_or_null("Player") as Player
	Assert.not_null(player, "Player could not be found on the current scene")
	return _current_scene.get_node_or_null("Player") as Player


func load_scene(path: String) -> void:
	var packed_scene := ResourceLoader.load(path)
	call_deferred("_load_scene", packed_scene)


func load_scene_async(scene_path: String) -> void:
	if !_loading_scene.is_empty():
		return
	_loading_scene = scene_path
	ResourceLoader.load_threaded_request(_loading_scene)


func get_scene_load_status() -> float:
	var progress := 0.0
	ResourceLoader.load_threaded_get_status(_loading_scene, [progress])
	return progress


func quit(exit_code: int = 0) -> void:
	get_tree().quit(exit_code)


func set_tree_pause(paused: bool) -> void:
	get_tree().paused = paused


func is_tree_paused() -> bool:
	return get_tree().paused


func _load_scene(packed_scene: PackedScene) -> void:
	Assert.not_null(packed_scene, "Scene to load should not be null")
	# Unload current scene
	if _current_scene != null:
		Pools.clear_runtime_pools()
		_current_scene.queue_free()

	var scene := packed_scene.instantiate()
	Assert.not_null(scene, "Scene instantiated should not be null")

	_current_scene = scene

	# Add this last since some _ready() methods may reference _current_scene
	get_tree().root.add_child(scene)
