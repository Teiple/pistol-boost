class_name HitscanTrail
extends Node3D

@export var _scale_y_multiplier_min := 0.5
@export var _scale_y_multiplier_max := 1.0
@export var _scale_z_multiplier_min := 0.5
@export var _scale_z_multiplier_max := 1.0
@export var _shrink_duration := 0.1

var _initial_scale: Vector3 = Vector3.ONE
var _cur_tween: Tween = null

@onready var _mesh_pivot: Node3D = $MeshPivot
@onready var _pooled_module: PooledNodeModule = $PooledNodeModule


func _ready():
	_initial_scale = _mesh_pivot.scale


func play_at(start: Vector3, end: Vector3):
	global_position = start
	Orientation.lookat(self, end, Vector3.RIGHT)
	var trail_length := (start - end).length()
	_mesh_pivot.scale.x = trail_length
	_mesh_pivot.scale.y = _initial_scale.y * randf_range(
		_scale_y_multiplier_min,
		_scale_y_multiplier_max,
	)
	_mesh_pivot.scale.z = _initial_scale.z * randf_range(
		_scale_z_multiplier_min,
		_scale_z_multiplier_max,
	)

	if _cur_tween != null:
		_cur_tween.kill()

	_cur_tween = create_tween()
	_cur_tween.tween_property(
		_mesh_pivot,
		"scale",
		Vector3(trail_length, 0, 0),
		_shrink_duration,
	)
	_cur_tween.finished.connect(_on_anim_finish)


func _on_anim_finish() -> void:
	_pooled_module.return_to_pool()
