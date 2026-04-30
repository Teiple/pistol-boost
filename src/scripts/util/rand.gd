class_name Rand


static func vec3(max_abs_val: float) -> Vector3:
	var rand_x := randf_range(-max_abs_val, max_abs_val)
	var rand_y := randf_range(-max_abs_val, max_abs_val)
	var rand_z := randf_range(-max_abs_val, max_abs_val)
	return Vector3(rand_x, rand_y, rand_z)


static func rotated_vec3(vec: Vector3, max_abs_angle_deg: float) -> Vector3:
	var angle_rad := deg_to_rad(max_abs_angle_deg)
	var z := vec.normalized()

	var u := Vector3.UP
	var v := Vector3.ZERO
	var dot := vec.dot(u)

	if absf(dot) > 0.98:
		u = Vector3.RIGHT
		v = z.cross(u).normalized()
		u = v.cross(z).normalized()
	else:
		v = u.cross(z).normalized()
		u = z.cross(v).normalized()

	var vec_rot := vec.rotated(u, randf_range(-angle_rad, angle_rad))
	vec_rot = vec_rot.rotated(v, randf_range(-angle_rad, angle_rad))
	return vec_rot
