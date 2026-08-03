class_name EnemyFiringController

var _default_muzzle_point: Node3D
var _collision_mask: int
var _standard_handler: EnemyStandardFiringHandler
var _burst_handler: EnemyBurstFiringHandler
var _active_handler: EnemyFiringHandler = null
var _firing_sound_player: AudioStreamPlayer3D


func _init(
	collision_mask: int,
	default_muzzle_point: Node3D = null,
	firing_sound_player: AudioStreamPlayer3D = null,
) -> void:
	_default_muzzle_point = default_muzzle_point
	_collision_mask = collision_mask
	_firing_sound_player = firing_sound_player

	_standard_handler = EnemyStandardFiringHandler.new(self)
	_burst_handler = EnemyBurstFiringHandler.new(self)


func update(delta: float) -> void:
	_standard_handler.update(delta)
	_burst_handler.update(delta)


func start_firing(firing_config: FiringConfig, muzzle_point: Node3D = null) -> void:
	Assert.not_null(firing_config, "Enemy firing config should not be null")
	Assert.check(!is_firing(), "Enemy firing controller should not start while already firing")

	var selected_muzzle_point := _select_muzzle_point_or_default(muzzle_point)

	_active_handler = _get_handler(firing_config)
	_active_handler.start(firing_config, selected_muzzle_point)


func can_start_firing(firing_config: FiringConfig, muzzle_point: Node3D = null):
	return _get_handler(firing_config).can_start(
		firing_config,
		_select_muzzle_point_or_default(muzzle_point),
	)


func is_firing() -> bool:
	return _active_handler != null && _active_handler.is_firing()


func get_collision_mask() -> int:
	return _collision_mask


func play_firing_sound(sound: Sound) -> void:
	_firing_sound_player.stream = sound.stream
	_firing_sound_player.volume_linear = sound.base_volume
	_firing_sound_player.play()


func _select_muzzle_point_or_default(muzzle_point: Node3D) -> Node3D:
	var selected_muzzle_point := muzzle_point
	if selected_muzzle_point == null:
		Assert.not_null(
			_default_muzzle_point,
			"Muzzle point was not specified but no default muzzle point was setup",
		)
		selected_muzzle_point = _default_muzzle_point
	return selected_muzzle_point


func _get_handler(firing_config: FiringConfig) -> EnemyFiringHandler:
	if firing_config is BurstFiringConfig:
		return _burst_handler
	if firing_config is StandardFiringConfig:
		return _standard_handler

	Assert.unreachable("Enemy firing handler is not implemented for %s" % firing_config)
	return null
