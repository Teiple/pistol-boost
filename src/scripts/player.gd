class_name Player
extends RigidBody3D

var _initial_cam_offset: Vector3 = Vector3.ZERO

@onready var _follow_cam: Camera3D = $FollowCam
@onready var _recoil_impulse_point: Node3D = $RecoilImpulsePoint


func _ready() -> void:
	_initial_cam_offset = _follow_cam.global_position - global_position
	_follow_cam.top_level = true


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("primary_fire"):
		apply_impulse(-global_basis.x * 2, _recoil_impulse_point.global_position - global_position)
	elif Input.is_action_just_pressed("secondary_fire"):
		apply_impulse(-global_basis.x * 5, _recoil_impulse_point.global_position - global_position)
	var player_plane_pos := global_position * Vector3(1, 1, 0)

	_follow_cam.global_position = global_position + _initial_cam_offset

	var mouse_pos := get_tree().root.get_mouse_position()
	var project_from := _follow_cam.project_ray_origin(mouse_pos)
	var project_dir := _follow_cam.project_ray_normal(mouse_pos)
	var player_plane := Plane(Vector3.BACK, Vector3.ZERO)
	var look_target := player_plane.intersects_ray(project_from, project_dir) as Vector3
	look_target.z = 0

	var look_vector := look_target - player_plane_pos
	var look_direction := look_vector.normalized()

	var z_axis := Vector3.BACK
	if look_vector.x < 0:
		z_axis = Vector3.FORWARD
	var x_axis: = look_direction
	var y_axis := z_axis.cross(x_axis).normalized()
	var target_basis = Basis(x_axis, y_axis, z_axis)

	var current_quat = global_basis.get_rotation_quaternion()
	var target_quat = Quaternion(target_basis)

	var target_angular_veloc = (target_quat * current_quat.inverse()).get_euler()
	if abs(target_angular_veloc.z) < deg_to_rad(5):
		angular_velocity = target_angular_veloc * 10.0
	else:
		angular_velocity = target_angular_veloc * 30.0
