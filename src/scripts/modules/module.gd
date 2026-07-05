@icon("res://editor/icons/puzzle.svg")
class_name Module
extends Node3D

const ARRAY_PREFIX = "arr_"

@export var _custom_owner: Node = null
@export var _is_unique: bool = true


static func _name() -> String:
	Assert.unreachable("Module should have set its own name")
	return "Module"


static func find_on(_node: Node) -> Module:
	Assert.unreachable("Module should define its own find method")
	return null


static func _array_name() -> String:
	return ARRAY_PREFIX + _name()


static func _find_on(node: Node, module_name: String) -> Module:
	Assert.not_null(node, "Node to find module on should not be null")
	Assert.non_empty_string(module_name, "Module name should not be empty")

	if !node.has_meta(module_name):
		return null
	return node.get_meta(module_name)


static func _find_array_on(node: Node, module_name: String) -> Array:
	return type_convert(node.get_meta(ARRAY_PREFIX + module_name), TYPE_ARRAY)


func _ready() -> void:
	if _is_unique:
		if !module_owner().has_meta(_name()):
			module_owner().set_meta(_name(), self)
	else:
		var modules := []
		if !module_owner().has_meta(_array_name()):
			modules.push_back(self)
			module_owner().set_meta(_array_name(), modules)
		else:
			var arr: Array = type_convert(module_owner().get_meta(_array_name()), TYPE_ARRAY)
			arr.push_back(self)
			modules = arr


func module_owner() -> Node:
	return _custom_owner if _custom_owner != null else owner


func set_custom_owner(custom_owner: Node) -> void:
	_custom_owner = custom_owner
