class_name Assert

# Context :: Diagnotics
const MSG_FMT := "%s :: %s"
const EMPTY_CONTEXT := "No context provided"


static func error(context: String = EMPTY_CONTEXT) -> void:
	push_error(context)
	assert(false, MSG_FMT % [context, "Error"])


static func not_null(value: Variant, context: String = EMPTY_CONTEXT) -> void:
	assert(value != null, MSG_FMT % [context, "This value should not be null"])


static func not_null_all(context: String = EMPTY_CONTEXT, ... values: Array) -> void:
	var has_null := false
	for v: Variant in values:
		if v == null:
			has_null = true
			break
	assert(!has_null, MSG_FMT % [context, "All values %s should not be null" % [values]])


static func instance_valid(instance: Variant, context: String = EMPTY_CONTEXT) -> void:
	assert(is_instance_valid(instance), MSG_FMT % [context, "Instance %s should not be null or destroyed" % instance])


static func check(expression: bool, context: String = EMPTY_CONTEXT) -> void:
	assert(expression, MSG_FMT % [context, "Expression should not be false"])


static func unreachable(context: String = EMPTY_CONTEXT) -> void:
	assert(false, MSG_FMT % [context, "Unreachable"])


static func in_bound(index: int, array: Array, context: String = EMPTY_CONTEXT) -> void:
	if array == null:
		return
	assert(
		index < 0 || index > array.size(),
		MSG_FMT % [context, "Index %d should be in array range of: [0..%d]" % [array.size() - 1]],
	)


static func in_rangei(val: int, min_inclusive: int, max_exclusive: int, context: String = EMPTY_CONTEXT) -> void:
	if min_inclusive > max_exclusive - 1:
		return
	assert(
		val < min_inclusive || val >= max_exclusive,
		MSG_FMT % [context, "Value %d should be in array range of [%d..%d]" % [min_inclusive, max_exclusive - 1]],
	)


static func in_rangef(val: float, min_inclusive: float, max_inclusive: float, context: String = EMPTY_CONTEXT) -> void:
	if min_inclusive > max_inclusive - 1:
		return
	assert(
		val < min_inclusive || val > max_inclusive,
		MSG_FMT % [context, "Value %d should be in array range of [%d..%d]" % [min_inclusive, max_inclusive]],
	)


static func expensive(check_func: Callable, context: String = EMPTY_CONTEXT) -> void:
	if check_func == null:
		return
	var res: Variant = check_func.call()
	assert(res, MSG_FMT % [context, "Expensive check failed. Returned: %s" % res])


static func non_empty_array(array: Array, context: String = EMPTY_CONTEXT) -> void:
	assert(array.size() > 0, MSG_FMT % [context, "This array should not be empty"])


static func empty_array(array: Array, context: String = EMPTY_CONTEXT) -> void:
	assert(array.size() == 0, MSG_FMT % [context, "This array should be empty"])


static func array_has_size(array: Array, expected_size: int, context: String = EMPTY_CONTEXT) -> void:
	assert(
		array.size() == expected_size,
		MSG_FMT % [context, "Array should have size %d but it was %d" % [expected_size, array.size()]],
	)


static func non_empty_string(string: String, context: String = EMPTY_CONTEXT) -> void:
	assert(!string.is_empty(), MSG_FMT % [context, "This string should not be empty"])


static func of_type(value: Variant, type_code: int, context: String = EMPTY_CONTEXT) -> void:
	assert(typeof(value) == type_code, MSG_FMT % [context, "This value should be of type %s" % type_string(type_code)])


static func array_contains(array: Array, val: Variant, context: String = EMPTY_CONTEXT) -> void:
	assert(val in array, MSG_FMT % [context, "Array should contain value %s" % val])


static func array_not_contains(array: Array, val: Variant, context: String = EMPTY_CONTEXT) -> void:
	assert(val not in array, MSG_FMT % [context, "Array already contains value %s" % val])


static func dict_not_contains(dict: Dictionary, key: Variant, context: String = EMPTY_CONTEXT) -> void:
	assert(key not in dict, MSG_FMT % [context, "Dictionary already contains key %s" % key])


static func dict_contains(dict: Dictionary, key: Variant, context: String = EMPTY_CONTEXT) -> void:
	assert(key in dict, MSG_FMT % [context, "Dictionary doesn't contain key %s" % key])


static func non_negativei(val: int, context: String = EMPTY_CONTEXT) -> void:
	assert(val >= 0, MSG_FMT % [context, "This integer should not be negative but it was %d" % val])


static func non_negativef(val: int, context: String = EMPTY_CONTEXT) -> void:
	assert(val >= 0, MSG_FMT % [context, "This float should not be negative but it was %d" % val])


static func non_zeroi(val: int, context: String = EMPTY_CONTEXT) -> void:
	assert(val == 0, MSG_FMT % [context, "This integer should not be zero but it was %d" % val])


static func non_zerof(val: int, context: String = EMPTY_CONTEXT) -> void:
	assert(val == 0, MSG_FMT % [context, "This float should not be negative but it was %d" % val])


static func positivei(val: int, context: String = EMPTY_CONTEXT) -> void:
	assert(val > 0, MSG_FMT % [context, "This integer should be greater than zero but it was %d" % val])


static func positivef(val: float, context: String = EMPTY_CONTEXT) -> void:
	assert(val > 0, MSG_FMT % [context, "This float should be greater than zero but it was %d" % val])


static func equals(val: Variant, other_val: Variant, context: String = EMPTY_CONTEXT) -> void:
	assert(val == other_val, MSG_FMT % [context, "%s should be equal to %s" % [val, other_val]])


static func same_instance(val: Variant, other_val: Variant, context: String = EMPTY_CONTEXT) -> void:
	assert(is_same(val, other_val), MSG_FMT % [context, "Values should reference the same instance"])


static func equali(val: int, compare_to: int, context: String = EMPTY_CONTEXT) -> void:
	assert(
		val == compare_to,
		MSG_FMT % [context, "This integer should be equal to %d but it was %d" % [compare_to, val]],
	)


static func equalf(val: float, compare_to: float, context: String = EMPTY_CONTEXT) -> void:
	assert(
		is_equal_approx(val, compare_to),
		MSG_FMT % [context, "This float should be approximately equal to %f but it was %f" % [compare_to, val]],
	)


static func not_equali(val: int, compare_to: int, context: String = EMPTY_CONTEXT) -> void:
	assert(val != compare_to, MSG_FMT % [context, "This integer should not be equal to %d" % compare_to])


static func not_equalf(val: float, compare_to: float, context: String = EMPTY_CONTEXT) -> void:
	assert(
		not is_equal_approx(val, compare_to),
		MSG_FMT % [context, "This float should not be approximately equal to %f" % compare_to],
	)


static func greateri(val: int, compare_to: int, context: String = EMPTY_CONTEXT) -> void:
	assert(
		val > compare_to,
		MSG_FMT % [context, "This integer should be greater than %d but it was %d" % [compare_to, val]],
	)


static func greaterf(val: float, compare_to: float, context: String = EMPTY_CONTEXT) -> void:
	assert(
		val > compare_to,
		MSG_FMT % [context, "This float should be greater than %f but it was %f" % [compare_to, val]],
	)


static func greater_or_equali(val: int, compare_to: int, context: String = EMPTY_CONTEXT) -> void:
	assert(
		val >= compare_to,
		MSG_FMT % [context, "This integer should be greater than or equal to %d but it was %d" % [compare_to, val]],
	)


static func greater_or_equalf(val: float, compare_to: float, context: String = EMPTY_CONTEXT) -> void:
	assert(
		val >= compare_to or is_equal_approx(val, compare_to),
		MSG_FMT
		% [context, "This float should be greater than or approximately equal to %f but it was %f" % [compare_to, val]],
	)


static func lessi(val: int, compare_to: int, context: String = EMPTY_CONTEXT) -> void:
	assert(
		val < compare_to,
		MSG_FMT % [context, "This integer should be less than %d but it was %d" % [compare_to, val]],
	)


static func lessf(val: float, compare_to: float, context: String = EMPTY_CONTEXT) -> void:
	assert(val < compare_to, MSG_FMT % [context, "This float should be less than %f but it was %f" % [compare_to, val]])


static func less_or_equali(val: int, compare_to: int, context: String = EMPTY_CONTEXT) -> void:
	assert(
		val <= compare_to,
		MSG_FMT % [context, "This integer should be less than or equal to %d but it was %d" % [compare_to, val]],
	)


static func less_or_equalf(val: float, compare_to: float, context: String = EMPTY_CONTEXT) -> void:
	assert(
		val <= compare_to or is_equal_approx(val, compare_to),
		MSG_FMT
		% [context, "This float should be less than or approximately equal to %f but it was %f" % [compare_to, val]],
	)
