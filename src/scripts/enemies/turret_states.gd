@abstract class_name TurretState
extends StateMachineState

enum State {
	IDLE = 0,
	TRACK = 1,
	FIRE = 2,
}

const ROTATE_SPEED := 10
const NEUTRAL_ANGLE_RAD := 0

var unit: EnemyTurret


func _init(_unit: EnemyTurret) -> void:
	unit = _unit
	unit.cannon.rotation.z = -PI
	statemachine = unit.statemachine


class IdleState extends TurretState:
	func get_state_id() -> State:
		return State.IDLE


	func update(dt: float):
		unit.cannon.rotation.z = rotate_toward(
			unit.cannon.rotation.z,
			NEUTRAL_ANGLE_RAD,
			ROTATE_SPEED * dt,
		)


class FireState extends TurretState:
	func get_state_id() -> State:
		return State.FIRE


	func update(dt: float):
		# Firing handler here
		pass


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

		unit.cannon.rotation.z = rotate_toward(
			unit.cannon.rotation.z,
			angle_to_target,
			ROTATE_SPEED * dt,
		)

		if absf(angle_difference(unit.cannon.rotation.z, angle_to_target)) <= deg_to_rad(
			unit.firing_angle_tolerance_degrees
		):
			statemachine.goto(State.FIRE)
			return
