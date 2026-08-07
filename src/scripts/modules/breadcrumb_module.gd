class_name BreadcrumbModule
extends Module

@export var _tracking_point: Node3D
@export var _breadcrumb_drop_interval := 0.5
@export var _max_breadcrumbs := 4
@export var _debug_draw_breadcrumbs := false

var _drop_time_counter := 0.0
var _breadcrumbs: Array[Vector3]


static func find_on(node: Node) -> BreadcrumbModule:
	return _find_on(node, _name())


static func _name() -> String:
	return "BreadcrumbModule"


func _ready() -> void:
	Assert.greaterf(
		_breadcrumb_drop_interval,
		0.0,
		"Breadcrumb drop interval should be greater than zero",
	)
	Assert.positivei(_max_breadcrumbs, "Maximum breadcrumbs should be greater than zero")


func _process(delta: float) -> void:
	_drop_time_counter += delta
	if _drop_time_counter >= _breadcrumb_drop_interval:
		_breadcrumbs.push_front(_tracking_point.global_position)
		_drop_time_counter = 0.0
		if _breadcrumbs.size() > _max_breadcrumbs:
			_breadcrumbs.pop_back()

	if _debug_draw_breadcrumbs:
		for breadcrumb in _breadcrumbs:
			DebugDraw3D.draw_box(breadcrumb, Quaternion.IDENTITY, Vector3.ONE * 0.1, Color.GREEN, true)


func get_breadcrumbs() -> Array[Vector3]:
	return _breadcrumbs
