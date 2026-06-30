class_name RapidFiringHandler
extends FiringHandler

var _last_shot_count := 0


func on_fire_held(firing_config: FiringConfig, held_time: float) -> void:
	var rapid_config := _ensure_config_type(firing_config)
	var cur_shot_count := int(held_time / rapid_config.default_firerate)
	if held_time > rapid_config.slow_fire_threshold:
		if cur_shot_count > _last_shot_count:
			fire(firing_config)
		_last_shot_count = cur_shot_count


func on_fire_released(firing_config: FiringConfig, held_time: float) -> void:
	var rapid_config := _ensure_config_type(firing_config)
	if held_time <= rapid_config.slow_fire_threshold:
		fire(firing_config)


func on_weapon_interrupted() -> void:
	_last_shot_count = 0


func _ensure_config_type(firing_config: FiringConfig) -> RapidFiringConfig:
	var t_config := firing_config as RapidFiringConfig
	Assert.not_null(t_config, "Firing config should be of type RapidFiringConfig")
	return t_config
