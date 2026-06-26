class_name ProjectilesAutoload
extends Node

@export var _configs: Array[ProjectileBulletConfig] = []


func _ready():
	for config in _configs:
		Pools.register_pool(
			PoolGroup.Type.PROJECTILE,
			config.bullet_id,
			SpatialPool.new(
				10,
				config.projectile_scene,
			),
		)
		Pools.register_pool(
			PoolGroup.Type.IMPACT,
			config.bullet_id,
			SpatialPool.new(
				10,
				config.impact_effect_scene,
			),
		)
