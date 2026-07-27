@abstract
class_name Bullet
extends Node3D

var _bullet_config: BulletConfig


static func resolve_aim_direction(from: Node3D, to: Node3D, _bconfig: BulletConfig) -> Vector3:
	return from.global_position.direction_to(to.global_position)


func init(config: BulletConfig) -> void:
	_bullet_config = config


func get_bullet_config() -> BulletConfig:
	return _bullet_config


@abstract func _get_typed_bullet_config() -> BulletConfig
