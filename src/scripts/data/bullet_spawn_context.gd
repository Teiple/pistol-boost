class_name BulletSpawnContext

var fired_from: Vector3 = Vector3.ZERO
var base_direction: Vector3 = Vector3.ZERO
var spread_angle_degrees: float = 0.0
var collision_mask: int = 0
var bullet_config: BulletConfig = null
var muzzle_point: Node3D = null


func _init(
        _bullet_config: BulletConfig,
        _fired_from: Vector3,
        _base_direction: Vector3,
        _spread_angle: float,
        _collision_mask: int,
        _muzzle_point: Node3D,
) -> void:
    bullet_config = _bullet_config
    fired_from = _fired_from
    base_direction = _base_direction
    spread_angle_degrees = _spread_angle
    collision_mask = _collision_mask
    muzzle_point = _muzzle_point
