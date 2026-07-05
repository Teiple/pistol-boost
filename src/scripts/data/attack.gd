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

class Hit:
	var damage: float = 0.0
	var damage_type: DamageType = DamageType.BULLET
	var position: Vector3 = Vector3.ZERO
	var normal: Vector3 = Vector3.ZERO
	var direction: Vector3 = Vector3.ZERO
	var impact_force: float = 0.0


	func _init(
			_damage: float,
			_damage_type: DamageType,
			_position: Vector3,
			_normal: Vector3,
			_direction: Vector3,
			_impact_force: float,
	) -> void:
		damage = _damage
		damage_type = _damage_type
		position = _position
		normal = _normal
		direction = _direction
		impact_force = _impact_force
