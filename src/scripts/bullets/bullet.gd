@abstract
class_name Bullet
extends Node3D

var _bullet_config: BulletConfig


func init(config: BulletConfig) -> void:
	_bullet_config = config


@abstract func _get_typed_bullet_config() -> BulletConfig
