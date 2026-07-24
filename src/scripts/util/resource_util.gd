class_name ResourceUtil


static func get_scene_script(
	scene: PackedScene,
) -> GDScript:
	var gd_script := scene.get_state().get_node_property_value(0, 0) as GDScript
	if gd_script != null:
		return gd_script
	return null
