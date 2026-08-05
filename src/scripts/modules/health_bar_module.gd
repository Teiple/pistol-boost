class_name HealthBarModule
extends Module

@export var _bar: Range
@export var _current_health_label: Label
@export var _pivot_offset := Vector2(.5, .5)


static func find_on(node: Node) -> HealthBarModule:
	return _find_on(node, _name())


static func _name() -> String:
	return "HealthBarModule"


func _ready() -> void:
	super._ready()
	Assert.not_null(_bar)
	var health_module := HealthModule.find_on(owner)
	Assert.not_null(health_module)
	health_module.health_changed.connect(update_health)
	update_health(health_module)


func _process(_delta: float) -> void:
	var cam := Global.get_camera()
	var pos := cam.unproject_position(global_position)
	_bar.position = pos - _bar.size * _pivot_offset


func update_health(health_module: HealthModule) -> void:
	_bar.max_value = health_module.get_max_health()
	_bar.min_value = 0
	_bar.value = health_module.get_current_health()
	_current_health_label.text = str(floori(_bar.value))
