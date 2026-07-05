class_name BulletPool
extends SpatialPool

var _bullet_config: BulletConfig


static func create(
		capacity: int,
		config: BulletConfig,
) -> BulletPool:
	var pool = BulletPool.new(
		capacity,
		config.bullet.scene,
	)
	pool.set_bullet_config(config)
	return pool


func set_bullet_config(config: BulletConfig) -> void:
	_bullet_config = config


func _ensure_instance_type(instance: Node) -> Bullet:
	var t_instance := instance as Bullet
	Assert.not_null(t_instance, "Instance should be of type Bullet")
	return t_instance


func _on_create(instance: Node) -> void:
	super._on_create(instance)
	var projectile = _ensure_instance_type(instance)

	Assert.not_null(_bullet_config, "Bullet config was not set")
	projectile.init(_bullet_config)
