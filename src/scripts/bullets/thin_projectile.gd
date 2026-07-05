class_name ThinProjectile
extends Projectile

@export var _length: float = 0.5
@export var _speed_multiplier_min: float = 1.0
@export var _speed_multiplier_max: float = 1.0
@export var _scale_x_multiplier_min: float = 0.5
@export var _scale_x_multiplier_max: float = 1.0
@export var _scale_z_multiplier_min: float = 0.5
@export var _scale_z_multiplier_max: float = 1.0

var _direction: Vector3 = Vector3.ZERO
var _traveled_distance: float = 0.0
var _origin_position: Vector3 = Vector3.ZERO
var _speed_multiplier: float = 1.0

@onready var _raycast: RayCast3D = $RayCast3D
@onready var _pooled_module: PooledNodeModule = $PooledNodeModule
@onready var _mesh_pivot: Node3D = $MeshPivot


func _physics_process(delta: float) -> void:
	var config := _get_typed_bullet_config()
	if _traveled_distance >= config.max_distance || _check_and_collide():
		_pooled_module.return_to_pool()
		return

	var distance_delta = _speed_multiplier * config.projectile_speed * delta
	global_position += _direction * distance_delta
	_traveled_distance += config.projectile_speed * delta


func init(config: BulletConfig) -> void:
	super.init(config)
	_check_cover_length()


func launch(from_position: Vector3, direction: Vector3, collision_mask: int) -> void:
	global_position = from_position
	_direction = direction

	_traveled_distance = 0.0
	_origin_position = from_position

	# Set up for raycast
	_raycast.position = Vector3.ZERO
	_raycast.target_position = Vector3(_length, 0, 0)
	_raycast.collision_mask = collision_mask

	Orientation.lookat_direction(self, _direction, Vector3.RIGHT)

	# Randomize visual
	_mesh_pivot.scale.x = randf_range(_scale_x_multiplier_min, _scale_x_multiplier_max)
	_mesh_pivot.scale.z = randf_range(_scale_z_multiplier_min, _scale_z_multiplier_max)

	# Randomize speed
	_speed_multiplier = randf_range(_speed_multiplier_min, _speed_multiplier_max)

	## Initial check
	if _check_and_collide():
		_pooled_module.return_to_pool()


func _check_cover_length() -> void:
	var config := _get_typed_bullet_config()

	var travel_per_tick := config.projectile_speed / Engine.physics_ticks_per_second
	if travel_per_tick <= _length:
		return

	var max_safe_speed := _length * Engine.physics_ticks_per_second
	var min_safe_length := config.projectile_speed / Engine.physics_ticks_per_second
	Assert.error(
		"%s :: Projectile can clip. " % name +
		"Current speed is %.3f, " % config.projectile_speed +
		"but the max safe speed for cover length %.3f is %.3f. " % [_length, max_safe_speed] +
		"Either lower the speed to %.3f or increase cover length to %.3f" % [
			max_safe_speed,
			min_safe_length,
		],
	)


func _check_and_collide() -> bool:
	var projectile_config := _get_typed_bullet_config()

	_raycast.force_raycast_update()
	if !_raycast.is_colliding():
		return false
	visible = false

	var hit_position := _raycast.get_collision_point()
	var hit_normal := _raycast.get_collision_normal()

	var atk_hit := Attack.Hit.new(
		projectile_config.damage,
		Attack.DamageType.BULLET,
		hit_position,
		hit_normal,
		global_basis.x,
		projectile_config.impact_force,
	)

	var impact_effect := Pools.get_instance(
		PoolGroup.Type.IMPACT_EFFECT,
		projectile_config.impact_fx.id,
	) as ImpactEffect
	Assert.not_null(impact_effect, "Impact pool should return an ImpactEffect")
	impact_effect.play_at(atk_hit.position, atk_hit.normal)
	return true
