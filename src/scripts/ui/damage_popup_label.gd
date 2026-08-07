class_name DamagePopupLabel
extends Label

@export var _fade_curve: Curve

var _world_position: Vector3

@onready var _pooled_node_module: PooledNodeModule = $PooledNodeModule


func show_popup(damage: float, text_color: Color, world_position: Vector3):
	text = str(floori(damage))
	modulate = text_color
	_world_position = world_position
	var tween := create_tween()
	tween.tween_method(tween_fade, 0, 1, 2).finished.connect(_pooled_node_module.return_to_pool)


func tween_fade(t: float):
	modulate.a = _fade_curve.sample(t)
	position = Global.get_camera().unproject_position(_world_position) - size * Vector2(0.5, 1)
