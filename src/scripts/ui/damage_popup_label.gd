class_name DamagePopupLabel
extends Label

@export var _player_hit_color : Color = Color.RED
@export var _enemy_hit_color : Color = Color.WHITE
@export var _label_scene : PackedScene

func _ready() -> void:
	ControlPool.new(50, _label_scene)
