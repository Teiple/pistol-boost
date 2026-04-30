class_name Orientation


static func lookat(node: Node3D, lookat_position: Vector3) -> void:
	lookat_direction(node, (lookat_position - node.global_position).normalized())


static func lookat_direction(node: Node3D, direction: Vector3) -> void:
	# Godot use -Z for forward
	var z := -direction

	var u := Vector3.UP
	var dot := z.dot(Vector3.UP)
	var v := Vector3()

	var basis: Basis
	if absf(dot) > 0.98:
		u = node.global_transform.basis.x
		v = z.cross(u).normalized()
		u = v.cross(z).normalized()
		basis = Basis(u, v, z)
	else:
		v = u.cross(z).normalized()
		u = z.cross(v).normalized()
		basis = Basis(v, u, z)

	node.global_transform = Transform3D(basis, node.global_position)
