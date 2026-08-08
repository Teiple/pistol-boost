class_name Crosshair
extends TextureRect

@export var _min_idle_size := 0.95
@export var _idle_frequency := 20.0


func _process(_delta: float) -> void:
	var mouse_pos := get_tree().root.get_mouse_position()
	position = mouse_pos - size * Vector2(0.5, 0.5)
	offset_transform_scale = Vector2.ONE * lerpf(
		_min_idle_size,
		1.0,
		sin(_idle_frequency * FrameTime.process_time() * 0.5 + 0.5),
	)
