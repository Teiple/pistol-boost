class_name DamagePopupAutoload
extends Node

enum DamagePopupType {
	PLAYER_DAMAGE,
	NON_PLAYER_DAMAGE,
}

@export var _player_hit_color: Color = Color.RED
@export var _non_player_hit_color: Color = Color.WHITE
@export var _label_scene: IdPackedScene


func _ready() -> void:
	var pool := ControlPool.new(50, _label_scene.scene)
	var pool_registry := PoolRegistry.new(PoolGroup.Type.DAMAGE_POPUP, _label_scene.id, pool)
	Pools.register_pool(pool_registry)


func show_popup(at_world_position: Vector3, damage_type: DamagePopupType, damage: float):
	var label := Pools.get_instance(PoolGroup.Type.DAMAGE_POPUP, _label_scene.id) as DamagePopupLabel
	Assert.not_null(label)

	var color := (_non_player_hit_color
		if damage_type == DamagePopupType.NON_PLAYER_DAMAGE
		else _player_hit_color)
	label.show_popup(damage, color, at_world_position)
