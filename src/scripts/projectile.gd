@abstract
class_name Projectile
extends Node3D

@export var _speed := 5.0
@export var _max_distance := 5.0


@abstract func init(atk_origin: Attack.Origin) -> void
