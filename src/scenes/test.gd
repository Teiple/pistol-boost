class_name TestClass
extends Node


func _ready() -> void:
	print_debug(TestClass, ", ", TestReceiver)


class TestReceiver:
	static var call_count := 0


	func on_test_signal() -> void:
		call_count += 1
		print("TestReceiver received signal. Call count: %d" % call_count)


	func _notification(what: int) -> void:
		if what == NOTIFICATION_PREDELETE:
			print("TestReceiver freed automatically")
