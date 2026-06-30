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


func init(config: ProjectileBulletConfig) -> void:
	super.init(config)
	_check_cover_length()


func launch(atk_origin: Attack.Origin) -> void:
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
	if _check_and_collide():
		_pooled_module.return_to_pool()


func _check_cover_length() -> void:
	var travel_per_tick := _speed / Engine.physics_ticks_per_second
	if travel_per_tick <= _length:
		return

	var max_safe_speed := _length * Engine.physics_ticks_per_second
	var min_safe_length := _speed / Engine.physics_ticks_per_second
	Assert.error(
		"%s :: Projectile can clip. " % name +
		"Current speed is %.3f, " % _speed +
		"but the max safe speed for cover length %.3f is %.3f. " % [_length, max_safe_speed] +
		"Either lower the speed to %.3f or increase cover length to %.3f" % [
			max_safe_speed,
			min_safe_length,
		],
	)


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

	var impact_effect := Pools.get_instance(
		PoolGroup.Type.IMPACT_EFFECT,
		_impact_id,
	) as ImpactEffect
	Assert.not_null(impact_effect, "Impact pool should return an ImpactEffect")
	impact_effect.play_at(atk_result.hit_point, atk_result.hit_normal)
	return true
