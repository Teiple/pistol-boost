class_name Hitscan
extends Bullet

@onready var _raycast: RayCast3D = $RayCast3D
@onready var _pooled_module: PooledNodeModule = $PooledNodeModule


func launch(
		from_position: Vector3,
		direction: Vector3,
		collision_mask: int,
):
	var hitscan_config := _get_typed_bullet_config()

	global_position = from_position
	Orientation.lookat_direction(self, direction, Vector3.RIGHT)

	_raycast.target_position = Vector3.RIGHT * hitscan_config.max_distance
	_raycast.collision_mask = collision_mask
	_raycast.force_raycast_update()

	if _raycast.is_colliding():
		var collider := _raycast.get_collider()
		var collided_position := _raycast.get_collision_point()
		var collided_normal := _raycast.get_collision_normal()

		var atk_hit := Attack.Hit.new(
			hitscan_config.damage,
			Attack.DamageType.BULLET,
			collided_position,
			collided_normal,
			direction,
			hitscan_config.impact_force,
		)

		var impact_effect := Pools.get_instance(
			PoolGroup.Type.IMPACT_EFFECT,
			hitscan_config.impact_fx.id,
		) as ImpactEffect
		Assert.not_null(impact_effect, "Impact pool should return an ImpactEffect")
		impact_effect.play_at(atk_hit.position, atk_hit.normal)

		if collider is HitBoxModule:
			var hitbox := collider as HitBoxModule
			hitbox.take_hit(atk_hit)

		if collider is RigidBody3D:
			var rigidbody := collider as RigidBody3D
			rigidbody.apply_impulse(
				atk_hit.direction * atk_hit.impact_force,
				atk_hit.position - rigidbody.to_global(rigidbody.center_of_mass),
			)

		if collider is StaticBody3D:
			pass

	_pooled_module.return_to_pool()


func _get_typed_bullet_config() -> HitscanBulletConfig:
	var t_config = _bullet_config as HitscanBulletConfig
	Assert.not_null(t_config, "Projectile config should be of type HitscanBulletConfig")
	return t_config
