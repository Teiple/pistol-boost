class_name Player
extends RigidBody3D

@export var _max_speed := 30.0
@export var _max_turn_speed := 25.0
@export_range(0, 1, 0.0001) var _recoil_velocity_damping := 0.4
@export_range(0, 1, 0.0001) var _recoil_turn_speed_damping := 1.0
@export var _recoil_turn_speed_recovery_curve: Curve = Curve.new()
@export var _recoil_turn_speed_recovery_time := 0.3

var _initial_cam_offset: Vector3 = Vector3.ZERO
var _turn_speed_multiplier := 0.3
var _last_recoil_time := 0.0

@onready var _muzzle_point: Marker3D = $MuzzlePoint
@onready var _follow_cam: Camera3D = $FollowCam
@onready var _recoil_impulse_point: Node3D = $RecoilImpulsePoint


func _ready() -> void:
	_initial_cam_offset = _follow_cam.global_position - global_position
	_follow_cam.top_level = true


func _physics_process(_delta: float) -> void:
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
	var target_basis := Basis(x_axis, y_axis, z_axis)

	var current_quat = global_basis.get_rotation_quaternion()
	var target_quat = Quaternion(target_basis)

	var target_angular_veloc = (target_quat * current_quat.inverse()).get_euler()

	_turn_speed_multiplier = _recoil_turn_speed_recovery_curve.sample(
		(FrameTime.physics_process_time() - _last_recoil_time) / _recoil_turn_speed_recovery_time,
	)

	angular_velocity = target_angular_veloc * _max_turn_speed * Vector3(
		1,
		1,
		_turn_speed_multiplier,
	)

	# speed cap
	if linear_velocity.length_squared() > _max_speed * _max_speed:
		linear_velocity = linear_velocity.normalized() * _max_speed


func get_muzzle_point() -> Node3D:
	return _muzzle_point


func apply_recoil(recoil_force: float) -> void:
	var recoil_direction := -global_basis.x
	var recoil_opposite_direction := -recoil_direction
	# killing the velocity in recoil direction
	var recoil_aligned_velocity := linear_velocity.project(recoil_opposite_direction)
	if recoil_aligned_velocity.dot(recoil_opposite_direction) > 0:
		linear_velocity -= recoil_aligned_velocity * _recoil_velocity_damping

	_turn_speed_multiplier *= 1.0 - _recoil_turn_speed_damping

	apply_impulse(
		recoil_direction * recoil_force,
		_recoil_impulse_point.global_position - global_position,
	)

	_last_recoil_time = FrameTime.physics_process_time()
