@abstract
class_name Projectile
extends Bullet

var _speed := 5.0
var _max_distance := 5.0
var _impact_id: String = ""


func init(config: BulletConfig) -> void:
	var t_config := _ensure_config_type(config)

	Assert.not_null(t_config.impact_fx, "Projectile impact data")

	_speed = t_config.projectile_speed
	_max_distance = t_config.max_distance
	_impact_id = t_config.impact_fx.id

	Assert.non_empty_string(_impact_id, "Projectile impact id")


@abstract func launch(atk_origin: Attack.Origin) -> void


func _ensure_config_type(bullet_config: BulletConfig) -> ProjectileBulletConfig:
	Assert.not_null(bullet_config, "Projectile config should be not be null")
	return bullet_config as ProjectileBulletConfig
