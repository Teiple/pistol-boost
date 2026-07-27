class_name EnemyStandardFiringHandler
extends EnemyFiringHandler

const DEFAULT_FIRERATE: float = 2.0

var _last_fired := 0.0


func _start(firing_config: FiringConfig, muzzle_point: Node3D) -> void:
	fire(firing_config, muzzle_point)
	_last_fired = FrameTime.physics_process_time()


func can_start(_firing_config: FiringConfig, _muzzle_point: Node3D) -> bool:
	return !is_firing() && FrameTime.physics_process_time() - _last_fired >= 1.0 / DEFAULT_FIRERATE
