class_name Beam
extends Bullet

var _elapsed_time := 0.0
var _attach_point: Node3D = null
var _last_hit_index := 0
var _collision_mask := 0

@onready var _shapecast: ShapeCast3D = $ShapeCast3D
@onready var _pooled_module: PooledNodeModule = $PooledNodeModule


func _physics_process(delta: float) -> void:
	global_transform = _attach_point.global_transform

	var beam_config := _get_typed_bullet_config()

	var cooldown := 1.0 / beam_config.damage_rate
	var hit_index := floori(_elapsed_time / cooldown)
	if hit_index > _last_hit_index:
		_hit()
		_last_hit_index = hit_index

	_elapsed_time += delta


func launch(attach_point: Node3D, collision_mask: int) -> void:
	_attach_point = attach_point
	_collision_mask = collision_mask
	global_transform = _attach_point.global_transform
	_elapsed_time = 0


func stop() -> void:
	_pooled_module.return_to_pool()


func _get_typed_bullet_config() -> BeamBulletConfig:
	var t_config := _bullet_config as BeamBulletConfig
	Assert.not_null(t_config, "Bullet config should be of type BeamBulletConfig")
	return t_config


func _hit():
	_shapecast.force_shapecast_update()
	var beam_config := _get_typed_bullet_config()
	var damage := beam_config.charge_damage_curve.sample(
		clampf(_elapsed_time / beam_config.charge_duration, 0, 1),
	)

	for i in _shapecast.get_collision_count():
		var collider := _shapecast.get_collider(i)

		var collided_position := _shapecast.get_collision_point(i)
		var collided_normal := _shapecast.get_collision_normal(i)
		var hit_direction := -global_basis.x

		if collider is HitBoxModule:
			var hitbox := collider as HitBoxModule

			var attack_hit := Attack.Hit.new(
				damage,
				Attack.DamageType.BULLET,
				collided_position,
				collided_normal,
				hit_direction,
				beam_config.impact_force,
			)

			hitbox.take_hit(attack_hit)

			continue

		if collider is RigidBody3D:
			var rigidbody := collider as RigidBody3D
			rigidbody.apply_impulse(
				hit_direction * beam_config.impact_force,
				collided_position - rigidbody.to_global(rigidbody.center_of_mass),
			)

			continue

		if collider is StaticBody3D:
			continue
