class_name ThinProjectile
extends Projectile

@export var _length: float = 0.5
@export var _scale_x_multiplier_min: float = 0.5
@export var _scale_x_multiplier_max: float = 1.0
@export var _scale_z_multiplier_min: float = 0.5
@export var _scale_z_multiplier_max: float = 1.0

var _direction: Vector3 = Vector3.ZERO
var _traveled_distance: float = 0.0
var _origin_position: Vector3 = Vector3.ZERO
var _impact_force: float = 0.0

@onready var _raycast: RayCast3D = $RayCast3D
@onready var _pooled_module: PooledNodeModule = $PooledNodeModule
@onready var _mesh_pivot: Node3D = $MeshPivot


func _physics_process(delta: float) -> void:
	if _traveled_distance >= _max_distance || _check_and_collide():
		_pooled_module.return_to_pool()
		return
	global_position += _direction * _speed * delta
	_traveled_distance += _speed * delta


func init(atk_origin: Attack.Origin) -> void:
	global_position = atk_origin.fired_from

	_direction = atk_origin.direction
	_traveled_distance = 0.0
	_origin_position = atk_origin.fired_from
	_impact_force = atk_origin.impact_force

	# Set up for raycast
	_raycast.position = Vector3.ZERO
	_raycast.target_position = Vector3(_length, 0, 0)
	_raycast.collision_mask = atk_origin.collision_mask

	Orientation.lookat_direction(self, _direction, Vector3.RIGHT)

	# Randomize visual
	_mesh_pivot.scale.x = randf_range(_scale_x_multiplier_min, _scale_x_multiplier_max)
	_mesh_pivot.scale.z = randf_range(_scale_z_multiplier_min, _scale_z_multiplier_max)

	## Initial check
	#if _check_and_collide():
	#_pooled_module.return_to_pool()


func _check_and_collide() -> bool:
	_raycast.force_raycast_update()
	if !_raycast.is_colliding():
		return false
	visible = false

	var atk_result := Attack.Result.new()
	atk_result.hit_point = _raycast.get_collision_point()
	atk_result.hit_normal = _raycast.get_collision_normal()
	atk_result.collider = _raycast.get_collider()
	atk_result.hit_direction = _direction
	atk_result.impact_force = _impact_force

	var impact_effect := Pools.bullet_impact_scene_collection["plasma_1"].get_instance() as ImpactEffect
	impact_effect.init(atk_result.hit_point, atk_result.hit_normal)
	impact_effect.play()
	print_debug("impac:", impact_effect, atk_result.hit_point, impact_effect.visible, impact_effect.process_mode)
	print_debug("hit", FrameTime.process_time())

	return true
