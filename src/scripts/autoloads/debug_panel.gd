class_name DebugPanelAutoload
extends Control

@export var _fps_aggregate_interval := 1.0

var _current_interval_delta_sum := 0.0
var _current_interval_fps_sum := 0.0
var _current_interval_frame_count := 0

@onready var _debug_panel_tl: RichTextLabel = $DebugPanelTL


func _process(delta: float) -> void:
	_current_interval_delta_sum += delta
	_current_interval_fps_sum += 1.0 / delta
	_current_interval_frame_count += 1
	if _current_interval_delta_sum >= _fps_aggregate_interval:
		var avg_interval_fps := (
			_current_interval_fps_sum / _current_interval_frame_count
			if _current_interval_frame_count > 0
			else 0.0
		)

		var fps_color := ("green"
			if avg_interval_fps > 30
			else ("yellow" if avg_interval_fps > 20 else "red"))

		_debug_panel_tl.text = "Fps: [color=%s]%d[/color]" % [fps_color, floori(avg_interval_fps)]

		_current_interval_delta_sum = 0
		_current_interval_fps_sum = 0
		_current_interval_frame_count = 0
