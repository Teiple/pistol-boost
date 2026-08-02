@tool
class_name BonePositionOffset
extends SkeletonModifier3D

@export var enabled: bool = true
@export var position_offset := Vector3.ZERO
@export var _target_bone: String = "":
	set = set_target_bone


func _validate_property(property: Dictionary) -> void:
	if enabled:
		if property.name == "_target_bone":
			var skeleton := get_parent() as Skeleton3D
			if !skeleton:
				return
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = skeleton.get_concatenated_bone_names()


func set_target_bone(target_bone: String) -> void:
	if target_bone != _target_bone:
		_target_bone = target_bone

		var skeleton := get_skeleton()
		if skeleton == null:
			return

		var bone_idx := skeleton.find_bone(_target_bone)
		if bone_idx < 0:
			return

		transform = skeleton.get_bone_global_pose(bone_idx)


func _process_modification_with_delta(_delta: float) -> void:
	var skeleton := get_skeleton()
	if skeleton == null:
		return

	var bone_idx := skeleton.find_bone(_target_bone)
	if bone_idx < 0:
		return

	if !enabled:
		transform = skeleton.get_bone_global_pose(bone_idx)
		return

	var prev_pos := skeleton.get_bone_pose_position(bone_idx)
	var override_pos := prev_pos + position_offset

	skeleton.set_bone_pose_position(bone_idx, override_pos)
	transform = skeleton.get_bone_global_pose(bone_idx)
