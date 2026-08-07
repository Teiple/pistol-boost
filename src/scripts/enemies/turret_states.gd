@abstract class_name TurretState
extends StateMachineState

enum State {
	IDLE = 0,
	TRACK = 1,
	FIRE = 2,
	SCAN = 3,
	SUPPRESS = 4,
	DIED = 100,
}

const ROTATE_SPEED := 3

var unit: EnemyTurret
var context: TurretContext


static func create_states(enemy_turret: EnemyTurret) -> Array[StateMachineState]:
	var shared_context := TurretContext.new(enemy_turret)
	shared_context.state_change_requested.connect(enemy_turret.statemachine.goto)
	var states: Array[StateMachineState] = [
		IdleState.new(enemy_turret, shared_context),
		TrackState.new(enemy_turret, shared_context),
		FireState.new(enemy_turret, shared_context),
		ScanState.new(enemy_turret, shared_context),
		SuppressState.new(enemy_turret, shared_context),
		DiedState.new(enemy_turret, shared_context),
		# new states must be added here
	]

	# forget to add new state? don't worry i'll check it
	_validate_states(State, states)

	return states


func _init(_unit: EnemyTurret, shared_context: TurretContext) -> void:
	unit = _unit
	context = shared_context


func has_player_los() -> bool:
	var player := Global.get_player() as Player
	var markers := VisibilityMarkerModule.find_array_on(player)
	Assert.non_empty_array(markers)

	unit.detection_raycast.collision_mask = unit.detection_collision_mask

	for marker in markers:
		unit.detection_raycast.global_position = unit.detection_origin.global_position
		unit.detection_raycast.target_position = unit.detection_raycast.to_local(marker.global_position)
		unit.detection_raycast.force_raycast_update()

		if !unit.detection_raycast.is_colliding():
			return true

	return false


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


class TurretContext:
	signal state_change_requested(state_id: int)

	var last_visible_position := Vector3.ZERO
	var has_last_visible_position := false
	var pending_shot_origin := Vector3.ZERO
	var has_pending_shot := false


	func _init(unit: EnemyTurret) -> void:
		var player := Global.get_player()
		var unit_health := HealthModule.find_on(unit)

		player.shot_fired.connect(_on_player_shot_fired)
		unit_health.died.connect(_on_unit_died)


	func request_state(state_id: State) -> void:
		state_change_requested.emit(state_id)


	func _on_player_shot_fired(player: Player) -> void:
		pending_shot_origin = player.global_position
		has_pending_shot = true


	func _on_unit_died(_health: HealthModule) -> void:
		request_state(State.DIED)


class IdleState extends TurretState:
	func get_state_id() -> State:
		return State.IDLE


	func update(_dt: float) -> void:
		if has_player_los():
			context.request_state(State.TRACK)
			return

		if context.has_pending_shot:
			context.request_state(State.SCAN)


class FireState extends TurretState:
	func get_state_id() -> State:
		return State.FIRE


	func enter() -> void:
		unit.firing_controller.start_firing(unit.firing_config)


	func update(_dt: float) -> void:
		if unit.firing_controller.is_firing():
			return

		if has_player_los():
			context.request_state(State.TRACK)
		else:
			context.request_state(State.SUPPRESS)


class TrackState extends TurretState:
	var aim_resolver: AimResolver = null


	func get_state_id() -> State:
		return State.TRACK


	func enter() -> void:
		if aim_resolver == null:
			# each bullet has their own way of prediciting its own trajectory
			aim_resolver = Bullets.get_bullet_aim_resolver(unit.firing_config.bullet_config)


	func update(dt: float) -> void:
		if !has_player_los():
			context.request_state(State.SUPPRESS)
			return

		var player := Global.get_player() as Player
		context.last_visible_position = player.global_position
		context.has_last_visible_position = true
		context.has_pending_shot = false

		var aim_direction := aim_resolver.resolve_direction(unit.cannon_pivot, player)
		var is_aligned := rotate_toward_direction(aim_direction, dt)

		if is_aligned && unit.firing_controller.can_start_firing(unit.firing_config):
			context.request_state(State.FIRE)


class ScanState extends TurretState:
	var _scan_position := Vector3.ZERO
	var _elapsed := 0.0


	func get_state_id() -> State:
		return State.SCAN


	func enter() -> void:
		_elapsed = 0.0
		_consume_pending_shot()


	func update(dt: float) -> void:
		if has_player_los():
			context.request_state(State.TRACK)
			return

		if context.has_pending_shot:
			_consume_pending_shot()

		rotate_toward_direction(direction_to_position(_scan_position), dt)
		_elapsed += dt
		if _elapsed >= unit.scan_duration:
			context.request_state(State.IDLE)


	func _consume_pending_shot() -> void:
		_scan_position = context.pending_shot_origin
		context.has_pending_shot = false
		_elapsed = 0.0


class SuppressState extends TurretState:
	var _bursts_started := 0


	func get_state_id() -> State:
		return State.SUPPRESS


	func enter() -> void:
		_bursts_started = 0


	func update(dt: float) -> void:
		if has_player_los():
			context.request_state(State.TRACK)
			return

		if !context.has_last_visible_position:
			_goto_scan_or_idle()
			return

		var aim_direction := direction_to_position(context.last_visible_position)
		var is_aligned := rotate_toward_direction(aim_direction, dt)

		if unit.firing_controller.is_firing():
			return

		if _bursts_started >= unit.suppress_burst_count:
			_goto_scan_or_idle()
			return

		if is_aligned && unit.firing_controller.can_start_firing(unit.firing_config):
			unit.firing_controller.start_firing(unit.firing_config)
			_bursts_started += 1


	func _goto_scan_or_idle() -> void:
		if context.has_pending_shot:
			context.request_state(State.SCAN)
		else:
			context.request_state(State.IDLE)


class DiedState extends TurretState:
	func get_state_id() -> int:
		return State.DIED


	func enter() -> void:
		# temp, maybe add debris version here
		unit.hide()
		unit.process_mode = Node.PROCESS_MODE_DISABLED
