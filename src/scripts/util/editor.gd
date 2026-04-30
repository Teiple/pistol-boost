class_name EditorUtils
extends Node


static func push_toast(message: String, severity: EditorToaster.Severity) -> void:
	print_debug(message)
	EditorInterface.get_editor_toaster().push_toast(message, severity)
