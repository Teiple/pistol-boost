class_name BeamBulletSpawner
extends BulletSpawner


func ensure_bullet_config_type(bullet_config: BulletConfig) -> BeamBulletConfig:
	var t_config := bullet_config as BeamBulletConfig
	Assert.not_null("Expecting bullet config of type BeamBulletConfig")
	return t_config


func create_bullet_pools(bullet_config: BulletConfig) -> Array[PoolRegistry]:
	var config := ensure_bullet_config_type(bullet_config)
	var bullet_pool := BulletPool.create(10, bullet_config)

	var impact_pool := SpatialPool.new(10, bullet_config.impact_fx.scene)

	return [
		PoolRegistry.new(PoolGroup.Type.PROJECTILE, config.bullet.id, bullet_pool),
		PoolRegistry.new(PoolGroup.Type.IMPACT_EFFECT, config.impact_fx.id, impact_pool),
	]


func spawn_bullet(spawn_context: BulletSpawnContext) -> Beam:
	Assert.not_null(spawn_context, "Bullet spawn context should not be null")
	Assert.not_null(spawn_context.muzzle_point, "Beam bullet required muzzle point to be specified")

	var bullet_config := spawn_context.bullet_config

	var beam := Pools.get_instance(PoolGroup.Type.BEAM, bullet_config.bullet.id) as Beam

	beam.launch(spawn_context.muzzle_point, spawn_context.collision_mask)

	return beam
