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
	Assert.not_null("Turret unit should have HealthModule")
	unit_health.died.connect(goto_die)


func goto_die(_health: HealthModule) -> void:
	if statemachine.get_current_state_id() != State.DIED:
		statemachine.goto(State.DIED)


class IdleState extends TurretState:
	func get_state_id() -> State:
		return State.IDLE


	func update(dt: float):
		unit.cannon.rotation.z = move_toward(
			unit.cannon.rotation.z,
			deg_to_rad(unit.cannon_neutral_angle_degrees),
			ROTATE_SPEED * dt,
		)

		if is_zero_approx(
			angle_difference(unit.cannon.rotation.z, deg_to_rad(unit.cannon_neutral_angle_degrees))
		):
			statemachine.goto(State.TRACK)


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
		var aim_direction := aim_resolver.resolve_direction(unit.cannon_muzzle, Global.get_player())

		var local_aim_direction := unit.global_basis.inverse() * aim_direction
		var angle_to_target := atan2(local_aim_direction.y, local_aim_direction.x)

		if angle_to_target < 0 && angle_to_target <= -PI / 2:
			angle_to_target += TAU

		angle_to_target = clampf(
			angle_to_target,
			deg_to_rad(unit.cannon_angle_degrees_min),
			deg_to_rad(unit.cannon_angle_degrees_max),
		)

		unit.cannon.rotation.z = move_toward(
			unit.cannon.rotation.z,
			angle_to_target,
			ROTATE_SPEED * dt,
		)

		if absf(angle_difference(unit.cannon.rotation.z, angle_to_target)) <= deg_to_rad(
			unit.firing_angle_tolerance_degrees
		) && unit.firing_controller.can_start_firing(unit.firing_config):
			statemachine.goto(State.FIRE)
			return


class DiedState extends TurretState:
	func get_state_id() -> int:
		return State.DIED


	func enter() -> void:
		# temp
		unit.hide()
		unit.process_mode = Node.PROCESS_MODE_DISABLED
