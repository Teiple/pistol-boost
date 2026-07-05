@abstract
class_name Projectile
extends Bullet


@abstract func launch(from_position: Vector3, direction: Vector3, collision_mask: int) -> void


func _get_typed_bullet_config() -> ProjectileBulletConfig:
	var t_config = _bullet_config as ProjectileBulletConfig
	Assert.not_null(t_config, "Projectile config should be of type ProjectileBulletConfig")
	return t_config
