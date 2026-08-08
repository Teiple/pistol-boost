@abstract
class_name Bullet
extends Node3D

var _bullet_config: BulletConfig


static func resolve_aim(from: Node3D, to: Node3D, _bconfig: BulletConfig) -> AimResolverResult:
	var res := AimResolverResult.new()
	res.resolution = AimResolverResult.Resolution.DIRECT
	res.predicted_position = to.global_position
	res.resolved_aim_direction = from.global_position.direction_to(to.global_position)
	return res


func init(config: BulletConfig) -> void:
	_bullet_config = config


func get_bullet_config() -> BulletConfig:
	return _bullet_config


@abstract func _get_typed_bullet_config() -> BulletConfig
