@abstract class_name TurretState
extends StateMachineState

enum State {
	IDLE = 0,
	TRACK = 1,
	FIRE = 2,
	SCAN = 3,
	DIED = 100,
}

const ROTATE_SPEED := 3

var unit: EnemyTurret
var context: TurretContext


static func create_states(enemy_turret: EnemyTurret) -> Array[StateMachineState]:
	var ctx := TurretContext.new(enemy_turret)
	ctx.state_change_requested.connect(enemy_turret.statemachine.goto)
	var states: Array[StateMachineState] = [
		IdleState.new(enemy_turret, ctx),
		TrackState.new(enemy_turret, ctx),
		FireState.new(enemy_turret, ctx),
		ScanState.new(enemy_turret, ctx),
		DiedState.new(enemy_turret, ctx),
		# new states must be added here
	]

	# forget to add new state? don't worry i'll check it
	_validate_states(State, states)

	return states


func _init(_unit: EnemyTurret, shared_context: TurretContext) -> void:
	unit = _unit
	context = shared_context


func rotate_toward_direction(aim_direction: Vector3, dt: float) -> bool:
	var local_aim_direction := unit.global_basis.inverse() * aim_direction
	var horizontal_length := Vector2(local_aim_direction.x, local_aim_direction.z).length()

	# Yaw is undefined while aiming vertically, so preserve the current yaw there.
	var target_yaw := unit.cannon_yaw_offset.angle_offset.y
	if !is_zero_approx(horizontal_length):
		target_yaw = atan2(local_aim_direction.x, local_aim_direction.z)

	var target_pitch := atan2(local_aim_direction.y, horizontal_length)
	var minimum_pitch := deg_to_rad(unit.cannon_pitch_degrees_min)
	var maximum_pitch := deg_to_rad(unit.cannon_pitch_degrees_max)
	var target_pitch_in_limits := target_pitch >= minimum_pitch && target_pitch <= maximum_pitch
	var clamped_pitch := clampf(target_pitch, minimum_pitch, maximum_pitch)
	var pitch_at_limit := (
		absf(unit.cannon_pitch_offset.angle_offset.x - minimum_pitch) < 0.001
		|| absf(unit.cannon_pitch_offset.angle_offset.x - maximum_pitch) < 0.001
	)

	unit.cannon_yaw_offset.angle_offset.y = rotate_toward(
		unit.cannon_yaw_offset.angle_offset.y,
		target_yaw,
		ROTATE_SPEED * dt,
	)

	if target_pitch_in_limits || !pitch_at_limit:
		unit.cannon_pitch_offset.angle_offset.x = move_toward(
			unit.cannon_pitch_offset.angle_offset.x,
			clamped_pitch,
			ROTATE_SPEED * dt,
		)

	var firing_angle_tolerance := deg_to_rad(unit.firing_angle_tolerance_degrees)
	var is_yaw_aligned := (
		absf(angle_difference(unit.cannon_yaw_offset.angle_offset.y, target_yaw)) <= firing_angle_tolerance
	)
	var is_pitch_aligned := (absf(unit.cannon_pitch_offset.angle_offset.x - clamped_pitch) <= firing_angle_tolerance)

	return target_pitch_in_limits && is_yaw_aligned && is_pitch_aligned


func direction_to_position(target_position: Vector3) -> Vector3:
	return unit.cannon_pivot.global_position.direction_to(target_position)


func check_player_los(save_player_position := true) -> bool:
	var player := Global.get_player() as Player
	var markers := VisibilityMarkerModule.find_array_on(player)
	Assert.non_empty_array(markers)

	unit.detection_raycast.collision_mask = unit.detection_collision_mask

	for marker in markers:
		unit.detection_raycast.global_position = unit.detection_origin.global_position
		unit.detection_raycast.target_position = unit.detection_raycast.to_local(marker.global_position)
		unit.detection_raycast.force_raycast_update()

		if !unit.detection_raycast.is_colliding():
			if save_player_position:
				context.set_last_known_player_position(player.global_position)
			return true

	return false


class TurretContext:
	signal state_change_requested(state_id: int)

	const PLAYER_POSITION_MEMORY_DURATION := 5.0

	var _unit: EnemyTurret
	var _last_known_player_position: Variant = null
	var _player_position_saved_at := 0.0


	func _init(unit: EnemyTurret) -> void:
		_unit = unit
		var player := Global.get_player()
		var unit_health := HealthModule.find_on(unit)

		player.shot_fired.connect(_on_player_shot_fired)
		unit_health.died.connect(_on_unit_died)


	func request_state(state_id: State) -> void:
		state_change_requested.emit(state_id)


	func has_last_known_player_position() -> bool:
		_forget_stale_player_position()
		return _last_known_player_position != null


	func get_last_known_player_position() -> Vector3:
		_forget_stale_player_position()
		Assert.not_null(_last_known_player_position, "Last known player position should be available")
		return _last_known_player_position


	func set_last_known_player_position(position: Vector3) -> void:
		_last_known_player_position = position
		_player_position_saved_at = FrameTime.physics_process_time()


	func _forget_stale_player_position() -> void:
		if (
			_last_known_player_position != null
			&& FrameTime.physics_process_time() - _player_position_saved_at >= PLAYER_POSITION_MEMORY_DURATION
		):
			_last_known_player_position = null


	func _on_player_shot_fired(player: Player) -> void:
		set_last_known_player_position(player.global_position)


	func _on_unit_died(_health: HealthModule) -> void:
		request_state(State.DIED)


class IdleState extends TurretState:
	func get_state_id() -> State:
		return State.IDLE


	func update(_dt: float) -> void:
		if check_player_los():
			context.request_state(State.TRACK)
			return

		if context.has_last_known_player_position():
			context.request_state(State.SCAN)


class FireState extends TurretState:
	func get_state_id() -> State:
		return State.FIRE


	func enter() -> void:
		unit.firing_controller.start_firing(unit.firing_config)


	func update(_dt: float) -> void:
		if unit.firing_controller.is_firing():
			return

		if check_player_los(false):
			context.request_state(State.TRACK)
		else:
			context.request_state(State.SCAN)


class TrackState extends TurretState:
	var aim_resolver: AimResolver = null


	func get_state_id() -> State:
		return State.TRACK


	func enter() -> void:
		if aim_resolver == null:
			# each bullet has their own way of prediciting its own trajectory
			aim_resolver = Bullets.get_bullet_aim_resolver(unit.firing_config.bullet_config)


	func update(dt: float) -> void:
		if !check_player_los(false):
			context.request_state(State.SCAN)
			return

		var player := Global.get_player() as Player
		var aim_res := aim_resolver.resolve(unit.cannon_pivot, player)

		# if intercept cannot happen we reserved old predicted position
		if aim_res.resolution == AimResolverResult.Resolution.INTERCEPT:
			# we override known position with predicted position instead
			# since it is abit more acccurate than the last seen position
			# when the player disappear behind cover
			context.set_last_known_player_position(aim_res.predicted_position)
			# DebugDraw3D.draw_box(aim_res.predicted_position, Quaternion.IDENTITY, Vector3.ONE * 0.1, Color.YELLOW)

		var is_aligned := rotate_toward_direction(aim_res.resolved_aim_direction, dt)
		if is_aligned && unit.firing_controller.can_start_firing(unit.firing_config):
			context.request_state(State.FIRE)


class ScanState extends TurretState:
	func get_state_id() -> State:
		return State.SCAN


	func update(dt: float) -> void:
		if check_player_los():
			context.request_state(State.TRACK)
			return

		if !context.has_last_known_player_position():
			context.request_state(State.IDLE)
			return

		var player_position := context.get_last_known_player_position()
		rotate_toward_direction(direction_to_position(player_position), dt)


class DiedState extends TurretState:
	func get_state_id() -> int:
		return State.DIED


	func enter() -> void:
		# temp, maybe add debris version here
		unit.hide()
		unit.process_mode = Node.PROCESS_MODE_DISABLED
