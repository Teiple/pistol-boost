class_name StateMachine

var _states: Dictionary[int, StateMachineState] = { }
var _current_state_id := -1


func init_states(states: Array[StateMachineState]) -> void:
	for state in states:
		_states[state.get_state_id()] = state


func get_current_state_id() -> int:
	return _current_state_id


func goto(state_id: int) -> void:
	if _current_state_id >= 0:
		_states[_current_state_id].exit()
	if state_id in _states:
		_current_state_id = state_id
		_states[state_id].enter()
	else:
		Assert.unreachable("State id of %s was not registered in the state machine" % state_id)


func update(dt: float):
	if _current_state_id >= 0:
		var cur_state := _states[_current_state_id]
		cur_state.update(dt)
