@abstract class_name StateMachineState

var statemachine: StateMachine


# Check for missing states registration
static func _validate_states(state_enum: Dictionary, states: Array[StateMachineState]) -> void:
	var state_ids: Array[int] = []
	for state in states:
		var state_id := state.get_state_id()
		Assert.array_contains(
			state_enum.values(),
			state_id,
			"Turret state id %s should exist in the State enum" % state_id,
		)
		Assert.array_not_contains(
			state_ids,
			state_id,
			"Turret state id %s should only be registered once" % state_id,
		)
		state_ids.push_back(state_id)

	Assert.array_has_size(
		state_ids,
		state_enum.size(),
		"Turret should create exactly one state for each State enum value",
	)


@abstract func get_state_id() -> int


func enter():
	pass


func update(_dt: float):
	pass


func exit():
	pass
