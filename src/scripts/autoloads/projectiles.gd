class_name ProjectilesAutoload
extends Node

@export var _configs: Array[ProjectileBulletConfig] = []


func _ready():
	for config in _configs:
		Assert.not_null(config.impact_fx, "Projectile impact data")
		Assert.not_null(config.impact_fx.scene, "Impact effect scene")
		Assert.non_empty_string(config.impact_fx.id, "Impact id")

		var projectile_pool := ProjectilePool.new(
			10,
			config.projectile_scene,
		)
		projectile_pool.set_bullet_config(config)

		var impact_pool := SpatialPool.new(
			10,
			config.impact_fx.scene,
		)

		Pools.register_pool(
			PoolGroup.Type.PROJECTILE,
			config.bullet_id,
			projectile_pool,
		)
		Pools.register_pool(
			PoolGroup.Type.IMPACT_EFFECT,
			config.impact_fx.id,
			impact_pool,
		)


func get_projectile(bullet_id: String) -> Projectile:
	Assert.non_empty_string(bullet_id, "Projectile id")
	var projectile := Pools.get_instance(PoolGroup.Type.PROJECTILE, bullet_id) as Projectile
	Assert.not_null(projectile, "Projectile pool should return a Projectile")
	return projectile
