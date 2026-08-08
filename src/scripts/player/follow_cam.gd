class_name FollowCam
extends Camera3D

@export var _camera_smoothing := 20.0

@export var _follow_target: Node3D

var _initial_offset := Vector3.ZERO


func _ready() -> void:
	_initial_offset = global_position - _follow_target.global_position
	top_level = true


func _process(delta: float) -> void:
	global_position = global_position.lerp(
		_follow_target.get_global_transform_interpolated().origin + _initial_offset,
		_camera_smoothing * delta,
	)
