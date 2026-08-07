extends Node

signal test_signal

@onready var _result_label: Label = $ResultLabel


func _ready() -> void:
	TestReceiver.call_count = 0

	var receiver: TestReceiver = TestReceiver.new()
	var receiver_reference: Variant = weakref(receiver)
	test_signal.connect(receiver.on_test_signal)

	test_signal.emit()
	var calls_before_release := TestReceiver.call_count
	var defaults_to_ref_counted := receiver is RefCounted

	# Dropping the last strong reference should free the receiver and its connection.
	receiver = null
	var receiver_was_freed := receiver_reference.get_ref() == null
	var connections_after_release := test_signal.get_connections().size()

	test_signal.emit()
	var calls_after_release := TestReceiver.call_count
	var passed := (
		defaults_to_ref_counted && calls_before_release == 1 && receiver_was_freed
		&& connections_after_release == 0 && calls_after_release == 1
	)

	_result_label.text = (
		"GDScript RefCounted signal cleanup: %s\n" % ("PASSED" if passed else "FAILED")
		+ "Implicitly RefCounted: %s\n" % defaults_to_ref_counted
		+ "Receiver freed: %s\n" % receiver_was_freed
		+ "Connections remaining: %d\n" % connections_after_release
		+ "Calls before/after release: %d/%d" % [calls_before_release, calls_after_release]
	)
	print(_result_label.text)


class TestReceiver:
	static var call_count := 0


	func on_test_signal() -> void:
		call_count += 1
		print("TestReceiver received signal. Call count: %d" % call_count)


	func _notification(what: int) -> void:
		if what == NOTIFICATION_PREDELETE:
			print("TestReceiver freed automatically")
