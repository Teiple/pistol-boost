class_name ControlPool
extends Pool


#override
func get_instance() -> Control:
	return super.get_instance() as Control #abc
	


func _ensure_instance_type(instance: Node) -> Control:
	var t_instance := instance as Control
	Assert.check(instance is Control, "Instance should be of type Control")
	return t_instance


func _on_create(instance: Node) -> void:
	var t_instance := _ensure_instance_type(instance)
	t_instance.visible = false

	t_instance.set_process(false)
	t_instance.set_physics_process(false)
	t_instance.process_mode = Node.PROCESS_MODE_DISABLED


func _on_destroy(_instance: Node) -> void:
	pass


func _on_get(instance: Node) -> void:
	var t_instance := _ensure_instance_type(instance)
	t_instance.visible = true

	t_instance.set_process(true)
	t_instance.set_physics_process(true)
	t_instance.process_mode = Node.PROCESS_MODE_INHERIT


func _on_release(instance: Node) -> void:
	var t_instance := _ensure_instance_type(instance)
	t_instance.visible = false

	t_instance.set_process(false)
	t_instance.set_physics_process(false)
	t_instance.process_mode = Node.PROCESS_MODE_DISABLED
