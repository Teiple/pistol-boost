@abstract class_name TurretState
extends StateMachineState

enum State {
	IDLE = 0,
	TRACK = 1,
	FIRE = 2,
	DIED = 100,
}

const ROTATE_SPEED := 3

var unit: EnemyTurret
var unit_health: HealthModule


static func get_all_states(enemy_turret: EnemyTurret) -> Array[StateMachineState]:
	var states: Array[StateMachineState] = [
		IdleState.new(enemy_turret),
		TrackState.new(enemy_turret),
		FireState.new(enemy_turret),
		DiedState.new(enemy_turret),
	]

	_validate_states(State, states)

	return states


func _init(_unit: EnemyTurret) -> void:
	unit = _unit
	statemachine = unit.statemachine
	unit_health = HealthModule.find_on(unit)
	Assert.not_null(unit_health, "Turret unit should have HealthModule")
	unit_health.died.connect(goto_die)


func goto_die(_health: HealthModule) -> void:
	if statemachine.get_current_state_id() != State.DIED:
		statemachine.goto(State.DIED)


class IdleState extends TurretState:
	func get_state_id() -> State:
		return State.IDLE


class FireState extends TurretState:
	func get_state_id() -> State:
		return State.FIRE


	func enter() -> void:
		unit.firing_controller.start_firing(unit.firing_config)


	func update(_dt: float) -> void:
		if !unit.firing_controller.is_firing():
			statemachine.goto(State.TRACK)


class TrackState extends TurretState:
	var aim_resolver: AimResolver = null


	func get_state_id() -> State:
		return State.TRACK


	func enter():
		if aim_resolver == null:
			aim_resolver = Bullets.get_bullet_aim_resolver(unit.firing_config.bullet_config)


	func update(dt: float):
		# unit.cannon_yaw_offset.angle_offset += Vector3.UP * 2.0 * dt
		# unit.cannon_pitch_offset.angle_offset += Vector3.RIGHT * 2.0 * dt
		var aim_direction := aim_resolver.resolve_direction(unit.cannon_pivot, Global.get_player())

		var local_aim_direction := unit.global_basis.inverse() * aim_direction
		var horizontal_length := Vector2(local_aim_direction.x, local_aim_direction.z).length()

		# Yaw is undefined while aiming vertically, so preserve the current yaw there.
		var target_yaw := unit.cannon_yaw_offset.angle_offset.y
		if !is_zero_approx(horizontal_length):
			target_yaw = atan2(local_aim_direction.x, local_aim_direction.z)

		var target_pitch := atan2(local_aim_direction.y, horizontal_length)

		var minimum_pitch := deg_to_rad(unit.cannon_pitch_degrees_min)
		var maximum_pitch := deg_to_rad(unit.cannon_pitch_degrees_max)
		var target_pitch_in_limits := (
			target_pitch >= minimum_pitch && target_pitch <= maximum_pitch
		)

		var clamped_pitch := clampf(target_pitch, minimum_pitch, maximum_pitch)

		var pitch_at_limit = (
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
			absf(angle_difference(unit.cannon_yaw_offset.angle_offset.y, target_yaw))
			<= firing_angle_tolerance
		)
		var is_pitch_aligned := (
			absf(unit.cannon_pitch_offset.angle_offset.x - clamped_pitch) <= firing_angle_tolerance
		)

		if (
			target_pitch_in_limits && is_yaw_aligned && is_pitch_aligned
			&& unit.firing_controller.can_start_firing(unit.firing_config)
		):
			statemachine.goto(State.FIRE)
			return


class DiedState extends TurretState:
	func get_state_id() -> int:
		return State.DIED


	func enter() -> void:
		# temp
		unit.hide()
		unit.process_mode = Node.PROCESS_MODE_DISABLED
