class_name BurstFiringHandler
extends PlayerFiringHandler

const LAST_BULLET_RECOIL := true

var _active_config: BurstFiringConfig = null
var _shots_fired := 0
var _shot_timer := 0.0
var _cooldown_timer := 0.0


func update(delta: float) -> void:
	_cooldown_timer = maxf(_cooldown_timer - delta, 0.0)
	if _active_config == null:
		return

	_shot_timer += delta

	var seconds_per_shot := 1.0 / _active_config.burst_firerate
	while _shot_timer >= seconds_per_shot:
		_shot_timer -= seconds_per_shot
		# only due recoil on the last bullet
		var apply_recoil := LAST_BULLET_RECOIL && _shots_fired + 1 == _active_config.burst_size
		fire(_active_config, apply_recoil)
		_shots_fired += 1

		if _shots_fired >= _active_config.burst_size:
			_complete_burst()
			return


func on_fire_pressed(firing_config: FiringConfig) -> void:
	if _active_config != null or _cooldown_timer > 0.0:
		return

	var burst_config := _ensure_config_type(firing_config)

	_active_config = burst_config
	_shots_fired = 1
	_shot_timer = 0.0
	fire(_active_config)

	if _shots_fired >= _active_config.burst_size:
		_complete_burst()


func on_weapon_interrupted() -> void:
	# Once started, a burst cannot be interrupted.
	pass


func _ensure_config_type(firing_config: FiringConfig) -> BurstFiringConfig:
	var burst_config := firing_config as BurstFiringConfig
	Assert.not_null(burst_config, "Firing config should be of type BurstFiringConfig")
	return burst_config


func _complete_burst() -> void:
	_cooldown_timer = _active_config.burst_interval
	_active_config = null
	_shots_fired = 0
	_shot_timer = 0.0
