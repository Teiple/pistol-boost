class_name ThinProjectile
extends Projectile

const MAX_PREDICTION_TIME := 2.0
const ROOT_SEARCH_STEPS := 24
const BISECTION_ITERATIONS := 8
const ROOT_VALUE_TOLERANCE := 0.0001
const GROUND_VELOCITY_DAMPING := 0.8

@export var _scale_x_multiplier_min: float = 0.5
@export var _scale_x_multiplier_max: float = 1.0
@export var _scale_z_multiplier_min: float = 0.5
@export var _scale_z_multiplier_max: float = 1.0

@export_range(0.0, 0.99, 0.01) var _speed_jitter_ratio: float = 0.0

var _direction: Vector3 = Vector3.ZERO
var _traveled_distance: float = 0.0
var _origin_position: Vector3 = Vector3.ZERO
var _speed_multiplier: float = 1.0

var _collision_length := 0.0

@onready var _raycast: RayCast3D = $RayCast3D
@onready var _pooled_module: PooledNodeModule = $PooledNodeModule
@onready var _mesh_pivot: Marker3D = $MeshPivot
@onready var _end_marker: Marker3D = $EndMarker


static func resolve_aim_direction(from: Node3D, to: Node3D, bullet_config: BulletConfig) -> Vector3:
	var player := to as Player
	# only resolve player as target for now, priority
	if player == null:
		# default to direct aim
		return Bullet.resolve_aim_direction(from, to, bullet_config)

	var config := bullet_config as ProjectileBulletConfig
	Assert.not_null(config, "Thin projectile aim should receive a ProjectileBulletConfig")
	Assert.positivef(config.projectile_speed, "Projectile speed should be positive")

	var is_player_grounded := player.is_on_floor()
	var gravity := Vector3.ZERO
	if !is_player_grounded:
		gravity = player.get_gravity()

	var relative_position := player.global_position - from.global_position
	var target_velocity := player.linear_velocity
	if is_player_grounded:
		target_velocity *= 1.0 - GROUND_VELOCITY_DAMPING

	var interception_time := -1.0
	var max_prediction_time := minf(
		MAX_PREDICTION_TIME,
		config.max_distance / config.projectile_speed,
	)

	if gravity.is_zero_approx():
		# Solve |relative_position + target_velocity * t| = projectile_speed * t.
		var a := (
			target_velocity.length_squared() - config.projectile_speed * config.projectile_speed
		)
		var b := 2.0 * relative_position.dot(target_velocity)
		var c := relative_position.length_squared()

		if is_zero_approx(a):
			if !is_zero_approx(b):
				var linear_root := -c / b
				if linear_root > 0.0:
					interception_time = linear_root
		else:
			var discriminant := b * b - 4.0 * a * c
			if discriminant >= 0.0:
				var root_discriminant := sqrt(discriminant)
				var first_root := (-b - root_discriminant) / (2.0 * a)
				var second_root := (-b + root_discriminant) / (2.0 * a)

				if first_root > 0.0:
					interception_time = first_root
				if (
					second_root > 0.0
					&& (interception_time < 0.0 || second_root < interception_time)
				):
					interception_time = second_root
	else:
		# Find the earliest root of:
		# |relative_position + target_velocity * t + 0.5 * gravity * t²|
		# - projectile_speed * t = 0.
		# A positive value means the projectile has not reached the target yet.
		# A non-positive value means it has reached or passed the target.

		# Coarsely sample the prediction horizon to find two times surrounding a root.
		var search_step := max_prediction_time / ROOT_SEARCH_STEPS
		var previous_time := 0.0
		var previous_value := relative_position.length()

		for step_index in range(1, ROOT_SEARCH_STEPS + 1):
			var current_time := search_step * step_index

			# Evaluate the target's predicted offset at this sample time.
			var current_target_offset := (
				relative_position + target_velocity * current_time
				+ 0.5 * gravity * current_time * current_time
			)

			# Compare the required distance with how far the projectile can travel.
			var current_value := (
				current_target_offset.length() - config.projectile_speed * current_time
			)

			# A positive-to-non-positive change brackets an interception root.
			if current_value <= 0.0 && previous_value >= 0.0:
				var left_time := previous_time
				var right_time := current_time
				var left_value := previous_value

				# Refine the bracket by repeatedly keeping the half containing the root.
				for _iteration in BISECTION_ITERATIONS:
					var middle_time := (left_time + right_time) * 0.5
					var middle_target_offset := (
						relative_position + target_velocity * middle_time
						+ 0.5 * gravity * middle_time * middle_time
					)
					var middle_value := (
						middle_target_offset.length() - config.projectile_speed * middle_time
					)

					# Stop early when the midpoint is already sufficiently close to the root.
					if absf(middle_value) <= ROOT_VALUE_TOLERANCE:
						left_time = middle_time
						right_time = middle_time
						break

					# Replace the boundary with the same sign as the midpoint.
					if (middle_value > 0.0) == (left_value > 0.0):
						left_time = middle_time
						left_value = middle_value
					else:
						right_time = middle_time

				# Either boundary now approximates the root; use their midpoint.
				interception_time = (left_time + right_time) * 0.5
				break

			# Advance the coarse search bracket to the next pair of samples.
			previous_time = current_time
			previous_value = current_value

	if interception_time < 0.0 || interception_time > max_prediction_time:
		return Bullet.resolve_aim_direction(from, to, bullet_config)

	var predicted_position := (
		player.global_position + target_velocity * interception_time
		+ 0.5 * gravity * interception_time * interception_time
	)
	return from.global_position.direction_to(predicted_position)


func _ready() -> void:
	_collision_length = _end_marker.position.x
	Assert.greaterf(_collision_length, 0, "Projectile length should be greater than zero")


func _physics_process(delta: float) -> void:
	var config := _get_typed_bullet_config()
	if _traveled_distance >= config.max_distance:
		_pooled_module.return_to_pool()
		return

	var distance_delta := _speed_multiplier * config.projectile_speed * delta
	distance_delta = minf(distance_delta, config.max_distance - _traveled_distance)

	# Sweep through this tick's movement before updating the visual transform.
	_raycast.target_position = Vector3(distance_delta + _collision_length, 0, 0)

	if _check_and_collide():
		_pooled_module.return_to_pool()
		return

	global_position += _direction * distance_delta
	_traveled_distance += distance_delta


func launch(from_position: Vector3, direction: Vector3, collision_mask: int) -> void:
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
	_raycast.position = Vector3.ZERO
	_raycast.target_position = Vector3(_collision_length, 0, 0)

	if _check_and_collide():
		_pooled_module.return_to_pool()


func _check_and_collide() -> bool:
	var projectile_config := _get_typed_bullet_config()

	_raycast.force_raycast_update()
	if !_raycast.is_colliding():
		return false
	visible = false

	var collider := _raycast.get_collider() as Node3D
	Assert.not_null(collider, "Collider should be of type Node3D")

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

	var hitbox_mod := collider as HitBoxModule
	if hitbox_mod != null:
		hitbox_mod.take_hit(atk_hit)

	return true
