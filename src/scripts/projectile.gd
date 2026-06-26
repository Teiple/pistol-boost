@abstract
class_name Projectile
extends Node3D

var _speed := 5.0
var _max_distance := 5.0
var _impact_id: String = ""


func init(config: ProjectileBulletConfig) -> void:
	Assert.not_null(config.impact_fx, "Projectile impact data")
	_speed = config.projectile_speed
	_max_distance = config.max_distance
	_impact_id = config.impact_fx.id
	Assert.non_empty_string(_impact_id, "Projectile impact id")


@abstract func launch(atk_origin: Attack.Origin) -> void
