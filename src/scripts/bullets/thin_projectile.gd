class_name ThinProjectile
extends Projectile

const PREDICTION_ITERATIONS := 3

@export var _minimum_forward_coverage: float = 0.25
@export var _scale_x_multiplier_min: float = 0.5
@export var _scale_x_multiplier_max: float = 1.0
@export var _scale_z_multiplier_min: float = 0.5
@export var _scale_z_multiplier_max: float = 1.0

@export_range(0.0, 0.99, 0.01) var _speed_jitter_ratio: float = 0.0

var _direction: Vector3 = Vector3.ZERO
var _traveled_distance: float = 0.0
var _origin_position: Vector3 = Vector3.ZERO
var _speed_multiplier: float = 1.0

@onready var _raycast: RayCast3D = $RayCast3D
@onready var _pooled_module: PooledNodeModule = $PooledNodeModule
@onready var _mesh_pivot: Node3D = $MeshPivot


static func resolve_aim_direction(from: Node3D, to: Node3D, bullet_config: BulletConfig) -> Vector3:
	var player := to as Player
	# Only resolve player as target for now, priority
	if player == null:
		return Bullet.resolve_aim_direction(from, to, bullet_config)

	var config := bullet_config as ProjectileBulletConfig
	Assert.not_null(config, "Thin projectile aim should receive a ProjectileBulletConfig")

	var gravity := Vector3.ZERO
	if not player.is_on_floor():
		gravity = player.get_gravity()

	var predicted_pos := player.global_position
	var travel_time := (from.global_position.distance_to(predicted_pos) / config.projectile_speed)

	# Uses fixed-point iteration
	for i in PREDICTION_ITERATIONS:
		predicted_pos = (
			player.global_position + player.linear_velocity * travel_time
			+ 0.5 * gravity * travel_time * travel_time
		)
		travel_time = (from.global_position.distance_to(predicted_pos) / config.projectile_speed)

	return from.global_position.direction_to(predicted_pos)


func _physics_process(delta: float) -> void:
	var config := _get_typed_bullet_config()
	if _traveled_distance >= config.max_distance:
		_pooled_module.return_to_pool()
		return

	var distance_delta := _speed_multiplier * config.projectile_speed * delta
	distance_delta = minf(distance_delta, config.max_distance - _traveled_distance)

	# Sweep through this tick's movement before updating the visual transform.
	_raycast.target_position = Vector3(distance_delta, 0, 0)

	if _check_and_collide():
		_pooled_module.return_to_pool()
		return

	global_position += _direction * distance_delta
	_traveled_distance += distance_delta


func launch(from_position: Vector3, direction: Vector3, collision_mask: int) -> void:
	Assert.check(
		_minimum_forward_coverage >= 0.0,
		"Minimum forward coverage should not be negative",
	)
	Assert.check(
		_speed_jitter_ratio >= 0.0 && _speed_jitter_ratio < 1.0,
		"Speed jitter ratio should be at least 0 and less than 1",
	)

	global_position = from_position
	_direction = direction

	_traveled_distance = 0.0
	_origin_position = from_position

	# Set up for raycast
	_raycast.position = Vector3.ZERO
	_raycast.collision_mask = collision_mask

	Orientation.lookat_direction(self, _direction, Vector3.RIGHT)

	# Randomize visual
	_mesh_pivot.scale.x = randf_range(_scale_x_multiplier_min, _scale_x_multiplier_max)
	_mesh_pivot.scale.z = randf_range(_scale_z_multiplier_min, _scale_z_multiplier_max)

	# Randomize speed
	_speed_multiplier = randf_range(1.0 - _speed_jitter_ratio, 1.0 + _speed_jitter_ratio)

	# Check the projectile's initial forward coverage before its first movement.
	if _minimum_forward_coverage > 0.0:
		_raycast.target_position = Vector3(_minimum_forward_coverage, 0, 0)
		if _check_and_collide():
			_pooled_module.return_to_pool()


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
