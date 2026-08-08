class_name HealthBarModule
extends Module

@export var _bar: TextureProgressBar
@export var _current_health_label: Label
@export var _pivot_offset := Vector2(.5, .5)
@export var _flicker_on_low_health := false
@export var _flicker_min_alpha := 0.5
@export var _flicker_frequency := 10.0

var _tracked_health_module: HealthModule


static func find_on(node: Node) -> HealthBarModule:
	return _find_on(node, _name())


static func _name() -> String:
	return "HealthBarModule"


func _ready() -> void:
	super._ready()
	Assert.not_null(_bar)
	_tracked_health_module = HealthModule.find_on(owner)
	Assert.not_null(_tracked_health_module)
	_tracked_health_module.health_changed.connect(update_health)
	update_health(_tracked_health_module)


func _process(_delta: float) -> void:
	var cam := Global.get_camera()
	var pos := cam.unproject_position(get_global_transform_interpolated().origin)
	_bar.position = pos - _bar.size * _pivot_offset

	if _flicker_on_low_health && _tracked_health_module.is_on_low_health():
		_bar.tint_progress.a = lerpf(
			_flicker_min_alpha,
			1.0,
			sin(_flicker_frequency * FrameTime.process_time()) * 0.5 + 0.5,
		)


func update_health(health_module: HealthModule) -> void:
	_bar.max_value = health_module.get_max_health()
	_bar.min_value = 0
	_bar.value = health_module.get_current_health()
	_current_health_label.text = str(floori(_bar.value))

	var is_dead = health_module.is_dead()
	if is_dead:
		_bar.visible = false
	else:
		_bar.visible = true
