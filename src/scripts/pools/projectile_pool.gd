class_name ProjectilePool
extends SpatialPool

var _bullet_config: ProjectileBulletConfig


func set_bullet_config(config: ProjectileBulletConfig) -> void:
	_bullet_config = config


func _ensure_instance_type(instance: Node) -> Projectile:
	var t_instance := instance as Projectile
	Assert.not_null(t_instance, "Instance should be of type Projectile")
	return t_instance


func _on_create(instance: Node) -> void:
	super._on_create(instance)
	var projectile = _ensure_instance_type(instance)

	Assert.not_null(_bullet_config, "Bullet config was not set")
	projectile.init(_bullet_config)
