class_name Attack

enum DamageType {
	BULLET = 0,
	MELEE = 1,
	EXPLOSION = 2,
}
enum ProjectileModel {
	HITSCAN = 0,
	PROJECTILE = 1,
}

class BulletSpawnContext:
	var attacker: CharacterBody3D = null
	var fired_from: Vector3 = Vector3.ZERO
	var muzzle_position: Vector3 = Vector3.ZERO
	var base_direction: Vector3 = Vector3.ZERO
	var spread_angle_degrees: float = 0.0


class Origin:
	var attacker: CharacterBody3D = null
	var damage: float = 10.0
	var damage_type: DamageType = DamageType.BULLET
	var bullet_id: String = ""
	var direction: Vector3 = Vector3.ZERO
	var fired_from: Vector3 = Vector3.ZERO
	var impact_force: float = 0.0
	var collision_mask: int = 0


class Result:
	var from: Vector3 = Vector3.ZERO
	var hit_point: Vector3 = Vector3.ZERO
	var hit_normal: Vector3 = Vector3.ZERO
	var hit_direction: Vector3 = Vector3.ZERO
	var impact_force: float = 0.0
	var collider: CollisionObject3D = null
