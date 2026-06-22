class_name HitBoxModule
extends Module


static func _name() -> String:
	return "HitBoxModule"


static func find_on(_node: Node) -> HitBoxModule:
	return _find_on(_node, _name())
