@tool
class_name BoneRotationOffset
extends SkeletonModifier3D

@export var enabled: bool = true
@export var angle_offset := Vector3.ZERO
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


func set_target_bone(target_bone: String):
	if target_bone != _target_bone:
		_target_bone = target_bone
		var skeleton := get_skeleton()
		if skeleton == null:
			return
		var bone_idx := skeleton.find_bone(_target_bone)
		if bone_idx < 0:
			return
		var prev_pose := skeleton.get_bone_global_pose(bone_idx)

		transform = prev_pose


func _process_modification_with_delta(_delta: float) -> void:
	var skeleton := get_skeleton()
	var bone_idx := skeleton.find_bone(_target_bone)
	if bone_idx < 0:
		return
	var prev_rot := skeleton.get_bone_pose_rotation(bone_idx)

	if !enabled:
		transform = skeleton.get_bone_global_pose(bone_idx)
		return

	var apply_rot := Quaternion.from_euler(angle_offset)
	var override_rot := prev_rot * apply_rot

	skeleton.set_bone_pose_rotation(bone_idx, override_rot)
	transform = skeleton.get_bone_global_pose(bone_idx)
