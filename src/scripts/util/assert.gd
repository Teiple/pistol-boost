class_name Assert

# Context :: Diagnotics
const MSG_FMT := "%s :: %s"


static func not_null(value: Variant, context := "") -> void:
	assert(
		value != null,
		MSG_FMT % [context, "This value should not be null"],
	)


static func not_null_all(context: String, ...values: Array) -> void:
	var has_null := false
	for v: Variant in values:
		if v == null:
			has_null = true
			break
	assert(!has_null, MSG_FMT % [context, "All values %s should not be null" % [values]])


static func instance_valid(instance: Variant, context := "") -> void:
	assert(
		is_instance_valid(instance),
		MSG_FMT % [context, "Instance %s should not be null or destroyed" % instance],
	)


static func check(expression: bool, context := "") -> void:
	assert(
		expression,
		MSG_FMT % [context, "Expression should not be false"],
	)


static func unreachable(context := "") -> void:
	assert(
		false,
		MSG_FMT % [context, "Unreachable"],
	)


static func in_bound(index: int, array: Array, context := "") -> void:
	if array == null:
		return
	assert(
		index < 0 || index > array.size(),
		MSG_FMT % [
			context,
			"Index %d should be in array range of: [0..%d]" % [array.size() - 1],
		],
	)


static func in_rangei(val: int, min_inclusive: int, max_exclusive: int, context: String) -> void:
	if min_inclusive > max_exclusive - 1:
		return
	assert(
		val < min_inclusive || val >= max_exclusive,
		MSG_FMT % [
			context,
			"Value %d should be in array range of [%d..%d]" % [min_inclusive, max_exclusive - 1],
		],
	)


static func in_rangef(
		val: float,
		min_inclusive: float,
		max_inclusive: float,
		context: String,
) -> void:
	if min_inclusive > max_inclusive - 1:
		return
	assert(
		val < min_inclusive || val > max_inclusive,
		MSG_FMT % [
			context,
			"Value %d should be in array range of [%d..%d]" % [min_inclusive, max_inclusive],
		],
	)


static func expensive(check_func: Callable, context := "") -> void:
	if check_func == null:
		return
	var res: Variant = check_func.call()
	assert(
		res,
		MSG_FMT % [
			context,
			"Expensive check failed. Returned: %s" % res,
		],
	)


static func non_empty_array(array: Array, context := "") -> void:
	assert(
		array.size() > 0,
		MSG_FMT % [
			context,
			"This array should not be empty",
		],
	)


static func non_empty_string(string: String, context := "") -> void:
	assert(
		!string.is_empty(),
		MSG_FMT % [
			context,
			"This string should not be empty",
		],
	)


static func of_type(value: Variant, type_code: int, context := "") -> void:
	assert(
		typeof(value) == type_code,
		MSG_FMT % [
			context,
			"This value should be of type %s" % type_string(type_code),
		],
	)


static func array_not_contains(array: Array, val: Variant, context := "") -> void:
	assert(
		val not in array,
		MSG_FMT % [
			context,
			"Array alreay contains value %s" % val,
		],
	)


static func dict_not_contains(dict: Dictionary, key: Variant, context := "") -> void:
	assert(
		key not in dict,
		MSG_FMT % [
			context,
			"Dictionary already contains key %s" % key,
		],
	)


static func dict_contains(dict: Dictionary, key: Variant, context := "") -> void:
	assert(
		key in dict,
		MSG_FMT % [
			context,
			"Dictionary doesn't contain key %s" % key,
		],
	)


static func non_negativei(val: int, context: String) -> void:
	assert(
		val >= 0,
		MSG_FMT % [
			context,
			"This integer should not be negative but it was %d" % val,
		],
	)


static func non_negativef(val: int, context: String) -> void:
	assert(
		val >= 0,
		MSG_FMT % [
			context,
			"This float should not be negative but it was %d" % val,
		],
	)


static func non_zeroi(val: int, context: String) -> void:
	assert(
		val == 0,
		MSG_FMT % [
			context,
			"This integer should not be zero but it was %d" % val,
		],
	)


static func non_zerof(val: int, context: String) -> void:
	assert(
		val == 0,
		MSG_FMT % [
			context,
			"This float should not be negative but it was %d" % val,
		],
	)


static func positivei(val: int, context: String) -> void:
	assert(
		val > 0,
		MSG_FMT % [
			context,
			"This integer should be greater than zero but it was %d" % val,
		],
	)


static func positivef(val: float, context: String) -> void:
	assert(
		val > 0,
		MSG_FMT % [
			context,
			"This float should be greater than zero but it was %d" % val,
		],
	)


static func equals(val: Variant, other_val: Variant, context: String) -> void:
	assert(
		val == other_val,
		MSG_FMT % [
			context,
			"%s should be equal to %s" % [val, other_val],
		],
	)


static func greateri(val: int, compare_to: int, context: String) -> void:
	assert(
		val > compare_to,
		MSG_FMT % [
			context,
			"This interger should be greater than %d but it was %d" % [compare_to, val],
		],
	)


static func greaterf(val: float, compare_to: float, context: String) -> void:
	assert(
		val > compare_to,
		MSG_FMT % [
			context,
			"This float should be greater than %d but it was %d" % [compare_to, val],
		],
	)
