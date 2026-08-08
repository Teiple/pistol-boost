@tool
class_name HitBoxModule
extends Module

signal hit_taken(hit: Attack.Hit)

@export var _damage_multiplier := 1.0


static func find_array_on(node: Node) -> Array[HitBoxModule]:
	var arr: Array[HitBoxModule]
	arr.assign(_find_array_on(node, _name()))
	return arr


static func _name() -> String:
	return "HitBoxModule"


func take_hit(hit: Attack.Hit) -> void:
	var health_module := HealthModule.find_on(module_owner())
	Assert.not_null(health_module, "Hitbox can only work with owner with HealthModule")
	if health_module.is_dead():
		return

	hit.damage *= _damage_multiplier
	hit.impact_force *= _damage_multiplier

	health_module.take_hit(hit)
	hit_taken.emit(hit)

	DamagePopup.show_popup(
		hit.position,
		(
			DamagePopup.DamagePopupType.PLAYER_DAMAGE
			if module_owner() is Player
			else DamagePopup.DamagePopupType.NON_PLAYER_DAMAGE
		),
		hit.damage,
	)


func _on_child_entered_tree(node: Node) -> void:
	if Engine.is_editor_hint():
		return

	var col_shape := node as CollisionShape3D
	if col_shape != null:
		col_shape.debug_color = Color("c0e500c8")
