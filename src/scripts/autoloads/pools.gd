class_name PoolsAutoload
extends Node

# Runtime pools
var projectile_scene_collection: Dictionary[String, SpatialPool] = { }
var hitscan_trail_scene_collection: Dictionary[String, SpatialPool] = { }
var bullet_impact_scene_collection: Dictionary[String, SpatialPool] = { }
# Pool lookup, assigned by [Pool]s
var scene_path_to_pool_lookup: Dictionary[String, Pool] = { }
