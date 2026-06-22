class_name ProjectilesAutoload
extends Node

@export var _configs: Array[ProjectileBulletConfig] = []


func _ready():
	for config in _configs:
		Pools.projectile_scene_collection[config.bullet_id] = SpatialPool.new(
			10,
			[config.projectile_scene],
		)
		Pools.bullet_impact_scene_collection[config.bullet_id] = SpatialPool.new(
			10,
			[config.impact_effect_scene],
		)
