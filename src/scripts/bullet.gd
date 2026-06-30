@abstract
class_name Bullet
extends Node3D


@abstract func init(config: BulletConfig) -> void


func _ensure_config_type(bullet_config: BulletConfig) -> BulletConfig:
	Assert.not_null(bullet_config, "Bullet config should be not be null")
	return bullet_config
