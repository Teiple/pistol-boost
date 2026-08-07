@tool
class_name VisibilityMarkerModule
extends Module


static func find_array_on(node: Node) -> Array[VisibilityMarkerModule]:
	var arr: Array[VisibilityMarkerModule]
	arr.assign(_find_array_on(node, _name()))
	return arr


static func _name() -> String:
	return "VisibilityMarkerModule"


func _ready() -> void:
	super._ready()
	if !Engine.is_editor_hint():
		visible = false
