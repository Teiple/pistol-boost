class_name FrameTimeAutoLoad
extends Node

var _process_time := 0.0
var _physics_process_time := 0.0
var _frame_count := 0
var _physics_frame_count := 0


func _process(delta: float) -> void:
	_process_time += delta
	_frame_count += 1


func _physics_process(delta: float) -> void:
	_physics_process_time += delta
	_physics_frame_count += 1


func frame_count() -> float:
	return _frame_count


func physics_frame_count() -> float:
	return _physics_frame_count


func process_time() -> float:
	return _process_time


func physics_process_time() -> float:
	return _physics_process_time
