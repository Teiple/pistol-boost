@abstract class_name StateMachineState

var statemachine: StateMachine


@abstract func get_state_id() -> int


func enter():
	pass


func update(_dt: float):
	pass


func exit():
	pass
