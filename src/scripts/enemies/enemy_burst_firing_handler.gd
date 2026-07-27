class_name EnemyBurstFiringHandler
extends EnemyFiringHandler

var _active_config: BurstFiringConfig = null
var _active_muzzle_point: Node3D = null
var _shots_fired := 0
var _shot_timer := 0.0
var _cooldown_timer := 0.0


func _start(firing_config: FiringConfig, muzzle_point: Node3D) -> void:
	if _active_config != null or _cooldown_timer > 0.0:
		return

	var burst_config := firing_config as BurstFiringConfig
	Assert.not_null(burst_config, "Enemy burst handler requires a BurstFiringConfig")
	Assert.positivei(burst_config.burst_size, "Burst size should be positive")
	Assert.positivef(burst_config.burst_firerate, "Burst fire rate should be positive")

	_active_config = burst_config
	_active_muzzle_point = muzzle_point
	_shots_fired = 1
	_shot_timer = 0.0
	fire(_active_config, _active_muzzle_point)

	if _shots_fired >= _active_config.burst_size:
		_complete_burst()


func update(delta: float) -> void:
	_cooldown_timer = maxf(_cooldown_timer - delta, 0.0)
	if _active_config == null:
		return

	_shot_timer += delta
	var seconds_per_shot := 1.0 / _active_config.burst_firerate

	while _shot_timer >= seconds_per_shot:
		_shot_timer -= seconds_per_shot
		fire(_active_config, _active_muzzle_point)
		_shots_fired += 1

		if _shots_fired >= _active_config.burst_size:
			_complete_burst()
			return


func is_firing() -> bool:
	return _active_config != null


func _complete_burst() -> void:
	_cooldown_timer = _active_config.burst_interval
	_active_config = null
	_active_muzzle_point = null
	_shots_fired = 0
	_shot_timer = 0.0
