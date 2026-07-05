class_name HitBoxModule
extends Module

@export var _damage_multiplier := 1.0 


static func _name() -> String:
	return "HitBoxModule"


static func find_on(_node: Node) -> HitBoxModule:
	return _find_on(_node, _name())


func take_hit(hit: Attack.Hit) -> void:
	pass
