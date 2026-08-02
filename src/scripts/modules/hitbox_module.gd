@tool
class_name HitBoxModule
extends Module

@export var _damage_multiplier := 1.0


static func find_array_on(node: Node) -> Array[HitBoxModule]:
	var arr: Array[HitBoxModule]
	arr.assign(_find_array_on(node, _name()))
	return arr


static func _name() -> String:
	return "HitBoxModule"


func take_hit(hit: Attack.Hit) -> void:
	var health_mod := HealthModule.find_on(module_owner())
	Assert.not_null(health_mod, "Hitbox can only work with owner with HealthModule")
	hit.damage *= _damage_multiplier
	hit.impact_force *= _damage_multiplier
	health_mod.take_hit(hit)


func _on_child_entered_tree(node: Node) -> void:
	if Engine.is_editor_hint():
		return

	var col_shape := node as CollisionShape3D
	if col_shape != null:
		col_shape.debug_color = Color("c0e500c8")
