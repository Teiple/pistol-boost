class_name FlashHitModule
extends Module

@export var _hitbox_module: HitBoxModule
@export var _meshes: Array[MeshInstance3D]
@export var _flash_material: ShaderMaterial
@export var _flash_duration: float = 1.0
@export var _flash_curve: Curve


static func find_on(node: Node) -> FlashHitModule:
	return _find_on(node, _name())


static func _name() -> String:
	return "FlashHitModule"


func _ready() -> void:
	Assert.not_null(_hitbox_module)
	Assert.non_empty_array(_meshes)

	for mesh in _meshes:
		mesh.material_overlay = _flash_material
	_interpolate_flash_amount(0)
	_hitbox_module.hit_taken.connect(_on_hit_taken)


func _on_hit_taken(_atk_hit: Attack.Hit):
	var tween := create_tween()
	tween.tween_method(_interpolate_flash_amount, 0.0, 1.0, _flash_duration).set_trans(Tween.TRANS_LINEAR)


func _interpolate_flash_amount(t: float):
	for mesh in _meshes:
		mesh.set_instance_shader_parameter("flash_amount", _flash_curve.sample(t))
