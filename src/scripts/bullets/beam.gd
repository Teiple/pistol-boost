class_name Beam
extends Bullet

var _elapsed_time := 0.0


func update(atk_origin: Attack.Origin, delta: float) -> void:
	_elapsed_time += delta
    
    global_position = atk_origin.fired_from
	var direction := atk_origin.direction
	Orientation.lookat_direction(self, direction, Vector3.RIGHT)


func _get_typed_bullet_config() -> BeamBulletConfig:
	var t_config := _bullet_config as BeamBulletConfig
	Assert.not_null(t_config, "Bullet config should be of type BeamBulletConfig")
	return t_config
