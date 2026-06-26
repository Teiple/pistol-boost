class_name Orientation


static func lookat(
		node: Node3D,
		lookat_position: Vector3,
		local_axis: Vector3 = Vector3(0, 0, -1),
) -> void:
	lookat_direction(node, (lookat_position - node.global_position).normalized(), local_axis)


static func lookat_direction(
		node: Node3D,
		direction: Vector3,
		local_axis: Vector3 = Vector3(0, 0, -1),
) -> void:
	var forward := direction.normalized()
	var axis := local_axis.normalized()

	# We build a rotation that maps `axis` -> `forward`
	var rot := Quaternion(axis, forward)

	var basis := Basis(rot)

	# Handle edge case where vectors are opposite
	if axis.dot(forward) < -0.999:
		var fallback := Vector3.UP
		if abs(axis.dot(fallback)) > 0.9:
			fallback = Vector3.RIGHT
		rot = Quaternion(axis.cross(fallback).normalized(), PI)
		basis = Basis(rot)

	node.global_transform = Transform3D(basis, node.global_position)
