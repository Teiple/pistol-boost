class_name SpatialPool
extends Pool


#override
func get_instance() -> Node3D:
	return super.get_instance() as Node3D


func _on_create(instance: Node) -> void:
	Assert.check(instance is Node3D, "Instance should be of type Node3D")
	var t_instance := instance as Node3D
	t_instance.visible = false

	t_instance.set_process(false)
	t_instance.set_physics_process(false)
	t_instance.process_mode = Node.PROCESS_MODE_DISABLED


func _on_destroy(_instance: Node) -> void:
	pass


func _on_get(instance: Node) -> void:
	Assert.check(instance is Node3D, "Instance should be of type Node3D")
	var t_instance := instance as Node3D
	t_instance.visible = true

	t_instance.set_process(true)
	t_instance.set_physics_process(true)
	t_instance.process_mode = Node.PROCESS_MODE_INHERIT


func _on_release(instance: Node) -> void:
	Assert.check(instance is Node3D, "Instance should be of type Node3D")
	var t_instance := instance as Node3D
	t_instance.visible = false

	t_instance.set_process(false)
	t_instance.set_physics_process(false)
	t_instance.process_mode = Node.PROCESS_MODE_DISABLED
